import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trackora/core/constants/app_colors.dart';
import 'package:trackora/core/widgets/app_loader.dart';
import 'package:trackora/core/face/face_circle_progress.dart';
import 'package:trackora/core/face/face_services.dart';
import 'package:trackora/core/utills/camera_image_converter.dart';
import 'package:trackora/core/utills/camera_permission.dart';
import 'package:trackora/screens/attendance/punch_in_success_screen.dart';
import 'package:trackora/screens/face-verify/providers/face_verify_provider.dart';
import 'package:trackora/screens/home/providers/home_provider.dart';

class FaceVerifyScreen extends StatefulWidget {
  const FaceVerifyScreen({super.key});

  @override
  State<FaceVerifyScreen> createState() => _FaceVerifyScreenState();
}

class _FaceVerifyScreenState extends State<FaceVerifyScreen> {
  CameraController? _camera;
  bool _busy = false;
  bool _captureStarted = false;

  FaceVerifyProvider get _verify => context.read<FaceVerifyProvider>();

  @override
  void initState() {
    super.initState();
    _startCamera();
  }

  Future<void> _startCamera() async {
    final permission = await requestCameraPermission();
    if (!mounted) return;
    if (permission != CameraPermissionResult.granted) {
      _verify.setPermissionNeeded();
      return;
    }

    final cameras = await availableCameras();
    if (cameras.isEmpty) {
      _verify.fail('No camera found on this device');
      return;
    }

    final front = cameras.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first,
    );

    final controller = CameraController(
      front,
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: Platform.isAndroid
          ? ImageFormatGroup.yuv420
          : ImageFormatGroup.bgra8888,
    );
    try {
      await controller.initialize();
    } catch (e) {
      if (mounted) _verify.fail('Could not start camera — try again');
      await controller.dispose();
      return;
    }
    if (!mounted) {
      await controller.dispose();
      return;
    }
    setState(() => _camera = controller);
    await controller.startImageStream(_onFrame);
  }

  Future<void> _onFrame(CameraImage image) async {
    if (_busy || _camera == null || !mounted) return;
    final verify = _verify;
    if (verify.phase != FaceVerifyPhase.scanning) return;
    _busy = true;
    try {
      final input = inputImageFromCameraImage(
        image: image,
        controller: _camera!,
        sensorOrientation: _camera!.description.sensorOrientation,
      );
      if (input == null) {
        verify.markCameraNotReady();
        return;
      }

      final faces = await facePipeline.detector.processImage(input);
      if (!mounted) return;

      final shouldCapture = verify.handleFrame(faces: faces);
      if (shouldCapture && !_captureStarted) {
        _captureStarted = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _captureAndVerify();
        });
      }
    } catch (e, stack) {
      debugPrint('FACE SCAN FRAME ERROR: $e\n$stack');
      verify.reportScanIssue('Scan interrupted — hold still and try again');
    } finally {
      _busy = false;
    }
  }

  Future<void> _captureAndVerify() async {
    final camera = _camera;
    if (camera == null) return;

    try {
      await Future<void>.delayed(const Duration(milliseconds: 120));
      if (!mounted) return;
      while (_busy) {
        await Future<void>.delayed(const Duration(milliseconds: 16));
        if (!mounted) return;
      }

      if (camera.value.isStreamingImages) {
        await camera.stopImageStream().timeout(const Duration(seconds: 5));
      }

      final shot = await camera.takePicture().timeout(
        const Duration(seconds: 8),
      );
      final embedding = await facePipeline
          .embeddingFromImageFile(File(shot.path))
          .timeout(const Duration(seconds: 8));
      if (!mounted) return;

      final home = context.read<HomeProvider>();
      if (home.isPunchedOut) {
        _verify.fail('Already punched out today');
        return;
      }
      final forPunchIn = !home.isPunchedIn;
      final ok = await _verify.completeWithEmbeddings(
        embedding == null ? [] : [embedding],
        forPunchIn: forPunchIn,
      );
      if (ok && mounted) {
        await _goToSuccess(forPunchIn: forPunchIn);
      }
    } catch (e) {
      if (mounted) _verify.fail('Could not verify — try again');
    }
  }

  Future<void> _goToSuccess({required bool forPunchIn}) async {
    final home = context.read<HomeProvider>();
    if (forPunchIn) {
      home.punchIn();
    } else {
      home.punchOut();
    }
    home.loadTodayAttendance();
    final now = DateTime.now();
    if (!mounted) return;
    await Navigator.pushReplacement(
      context,
      PageRouteBuilder<bool>(
        opaque: true,
        pageBuilder: (_, __, ___) => PunchInSuccessScreen(
          time: _formatTime(now),
          date: _formatDate(now),
          location: FaceVerifyProvider.punchLocationLabel,
          isPunchOut: !forPunchIn,
        ),
        transitionDuration: const Duration(milliseconds: 350),
        transitionsBuilder: (_, anim, __, child) {
          final curved = CurvedAnimation(parent: anim, curve: Curves.easeOut);
          return ColoredBox(
            color: AppColors.scaffoldBg,
            child: FadeTransition(opacity: curved, child: child),
          );
        },
      ),
    );
  }

  String _formatTime(DateTime now) {
    final hour = now.hour % 12 == 0 ? 12 : now.hour % 12;
    final minute = now.minute.toString().padLeft(2, '0');
    final period = now.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  String _formatDate(DateTime now) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${now.day} ${months[now.month - 1]} ${now.year}';
  }

  Future<void> _retry() async {
    _captureStarted = false;
    _verify.retry();
    final camera = _camera;
    if (camera == null || !camera.value.isInitialized) {
      await _startCamera();
      return;
    }
    if (!camera.value.isStreamingImages) {
      await camera.startImageStream(_onFrame);
    }
  }

  @override
  void dispose() {
    _camera?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final verify = context.watch<FaceVerifyProvider>();
    final ready = _camera != null && _camera!.value.isInitialized;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        backgroundColor: AppColors.scaffoldBg,
        surfaceTintColor: Colors.transparent,
          elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textDark),
          onPressed: () => Navigator.pop(context, false),
        ),
        title: const Column(
          children: [
            Text(
              'Verify Your Identity',
              style: TextStyle(
                fontFamily: 'Inter_Bold',
                color: AppColors.appColor,
                fontSize: 18,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Please position your face inside the circle',
              style: TextStyle(
                fontFamily: 'Inter_Regular',
                color: AppColors.appColor,
                fontSize: 12,
              ),
            ),
          ],
        ),
        toolbarHeight: 72,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16,vertical: 15),
                child: Column(
                  children: [
                    _DirectionChip(
                      label: 'TOP',
                      active: verify.activeDirection == 'TOP',
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 280,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: _DirectionChip(
                              label: 'LEFT',
                              active: verify.activeDirection == 'LEFT',
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: _DirectionChip(
                              label: 'RIGHT',
                              active: verify.activeDirection == 'RIGHT',
                            ),
                          ),
                          SizedBox(
                            width: 248,
                            height: 248,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                CustomPaint(
                                  size: const Size(248, 248),
                                  painter: FaceCircleProgressPainter(
                                    segmentCount:
                                        verify.tracker.segmentCount,
                                    completed: verify.completed,
                                    activeColor: AppColors.appColor,
                                    trackColor: AppColors.progressTrack,
                                  ),
                                ),
                                ClipOval(
                                  child: ColoredBox(
                                    color: const Color(0xFF1A2A28),
                                    child: SizedBox(
                                      width: 214,
                                      height: 214,
                                      child: ready
                                          ? FittedBox(
                                              fit: BoxFit.cover,
                                              child: SizedBox(
                                                width: _camera!
                                                        .value
                                                        .previewSize
                                                        ?.height ??
                                                    214,
                                                height: _camera!
                                                        .value
                                                        .previewSize
                                                        ?.width ??
                                                    214,
                                                child: CameraPreview(_camera!),
                                              ),
                                            )
                                          : const SizedBox.expand(),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    _DirectionChip(
                      label: 'BOTTOM',
                      active: verify.activeDirection == 'BOTTOM',
                    ),
                  ],
                ),
              ),
              Text(
                verify.phase == FaceVerifyPhase.scanning
                    ? (verify.activeDirection == 'CENTER'
                        ? 'Look CENTER'
                        : verify.activeDirection == 'DONE'
                            ? 'Keep moving slowly'
                            : 'Look ${verify.activeDirection}')
                    : verify.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Inter_Bold',
                  color: AppColors.appColor,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Text(
                  verify.subtitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Inter_Regular',
                    color: AppColors.appColor,
                    fontSize: 14,
                  ),
                ),
              ),
              const Spacer(),
              if (verify.phase == FaceVerifyPhase.failed)
                Padding(
                  padding: const EdgeInsets.fromLTRB(40, 0, 40, 12),
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _retry,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.appColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                      child: const Text(
                        'Try again',
                        style: TextStyle(
                          fontFamily: 'Inter_SemiBold',
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(40, 0, 40, 36),
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context, false),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.appColor,
                    side: const BorderSide(color: AppColors.appColor, width: 1.4),
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.cancel_outlined, size: 22),
                      SizedBox(width: 8),
                      Text(
                        'Cancel',
                        style: TextStyle(
                          fontFamily: 'Inter_SemiBold',
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (verify.isBusy)
            const Positioned.fill(
              child: AbsorbPointer(
                child: Material(
                  color: AppColors.scaffoldBg,
                  child: _VerifyingOverlay(),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _VerifyingOverlay extends StatelessWidget {
  const _VerifyingOverlay();

  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: Column(
        children: [
          Spacer(),
          AppLoader(),
          SizedBox(height: 22),
          Text(
            'Verifying your identity',
            style: TextStyle(
              fontFamily: 'Inter_Bold',
              color: AppColors.appColor,
              fontSize: 20,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Please wait a moment',
            style: TextStyle(
              fontFamily: 'Inter_Regular',
              color: AppColors.textGrey,
              fontSize: 14,
            ),
          ),
          Spacer(),
        ],
      ),
    );
  }
}

class _DirectionChip extends StatelessWidget {
  const _DirectionChip({
    required this.label,
    required this.active,
  });

  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: active ? AppColors.appColor : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.appColor, width: 1.4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Inter_SemiBold',
          fontSize: 11,
          color: active ? Colors.white : AppColors.appColor,
        ),
      ),
    );
  }
}
