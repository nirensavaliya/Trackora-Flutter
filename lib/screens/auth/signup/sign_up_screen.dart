import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:trackora/app/routes.dart';
import 'package:trackora/core/constants/app_colors.dart';
import 'package:trackora/core/widgets/app_loader.dart';

import '../providers/sign_up_provider.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {

  @override
  Widget build(BuildContext context) {
    final signup = context.watch<SignUpProvider>();
    return Scaffold(
      backgroundColor: const Color(0xFFF0F7F6),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFFF0F7F6),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leadingWidth: 72,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Material(
            color: Colors.white,
            shape: const CircleBorder(),
            elevation: 1,
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(
                Icons.chevron_left,
                color: AppColors.textDark,
                size: 28,
              ),
            ),
          ),
        ),
        centerTitle: true,
        title: Text(
          'Create Account',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Inter_Bold',
            color: AppColors.textDark,
            fontSize: 25,
            height: 1.2,
          ),
        ),
      ),
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
                    child: Form(
                      key: signup.formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 24),
                          _Field(
                            label: 'Company Name',
                            controller: signup.company,
                            icon: Icons.apartment_outlined,
                            validator: (v) => signup.requiredField(v, 'Please enter company name'),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _Field(
                                  label: 'Client Code',
                                  controller: signup.clientCode,
                                  icon: Icons.badge_outlined,
                                  validator: (v) => signup.requiredField(v, 'Please enter client code'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _Field(
                                  label: 'Admin Name',
                                  controller: signup.adminName,
                                  icon: Icons.person_outline_rounded,
                                  validator: (v) => signup.requiredField(v, 'Please enter admin name'),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _Field(
                            label: 'Admin Email',
                            controller: signup.email,
                            icon: Icons.mail_outline_rounded,
                            keyboardType: TextInputType.emailAddress,
                            validator: signup.validateEmail,
                          ),
                          const SizedBox(height: 16),
                          _Field(
                            label: 'Admin Password',
                            controller: signup.password,
                            icon: Icons.lock_outline_rounded,
                            obscure: signup.obscure,
                            suffix: IconButton(
                              onPressed: signup.toggleObscure,
                              icon: Icon(
                                signup.obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                color: AppColors.textGrey,
                                size: 22,
                              ),
                            ),
                            validator: (v) => signup.requiredField(v, 'Please enter password'),
                          ),
                          const SizedBox(height: 18),
                          const Text(
                            'Office Location & Geofence',
                            style: TextStyle(
                              fontFamily: 'Inter_SemiBold',
                              color: AppColors.appColor,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFFE2E6E5)),
                            ),
                            child: Column(
                              children: [
                                SizedBox(
                                  height: 220,
                                  width: double.infinity,
                                  child: _OfficeMap(
                                    office: signup.office,
                                    radiusMeters: signup.geofenceMeters,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 6),
                                  child: Row(
                                    children: const [
                                      Text(
                                        'Lat: ',
                                        style: TextStyle(
                                          fontFamily: 'Inter_Regular',
                                          color: AppColors.textGrey,
                                          fontSize: 12,
                                        ),
                                      ),
                                      Text(
                                        '21.1702',
                                        style: TextStyle(
                                          fontFamily: 'Inter_SemiBold',
                                          color: AppColors.textDark,
                                          fontSize: 12,
                                        ),
                                      ),
                                      SizedBox(width: 18),
                                      Text(
                                        'Lng: ',
                                        style: TextStyle(
                                          fontFamily: 'Inter_Regular',
                                          color: AppColors.textGrey,
                                          fontSize: 12,
                                        ),
                                      ),
                                      Text(
                                        '72.8311',
                                        style: TextStyle(
                                          fontFamily: 'Inter_SemiBold',
                                          color: AppColors.textDark,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
                                  child: Row(
                                    children: [
                                      const Text(
                                        'Geofence',
                                        style: TextStyle(
                                          fontFamily: 'Inter_Medium',
                                          color: AppColors.textDark,
                                          fontSize: 13,
                                        ),
                                      ),
                                      Expanded(
                                        child: SliderTheme(
                                          data: SliderTheme.of(context).copyWith(
                                            activeTrackColor: AppColors.appColor,
                                            inactiveTrackColor:
                                            const Color(0xFFD7DEDC),
                                            thumbColor: AppColors.appColor,
                                            overlayColor: AppColors.appColor
                                                .withValues(alpha: 0.12),
                                            trackHeight: 3,
                                          ),
                                          child: Slider(
                                            min: 50,
                                            max: 1000,
                                            value: signup.geofenceMeters,
                                            onChanged: signup.setGeofence,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        '${signup.geofenceMeters.round()} m',
                                        style: const TextStyle(
                                          fontFamily: 'Inter_SemiBold',
                                          color: AppColors.textDark,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 22),
                          SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: ElevatedButton(
                              onPressed: signup.isLoading ? null : () => signup.onSignUp(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.appColor,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: const Text(
                                'Create Account',
                                style: TextStyle(
                                  fontFamily: 'Inter_SemiBold',
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Center(
                            child: Text.rich(
                              TextSpan(
                                text: 'Already registered? ',
                                style: const TextStyle(
                                  fontFamily: 'Inter_Regular',
                                  color: AppColors.textGrey,
                                  fontSize: 14,
                                ),
                                children: [
                                  WidgetSpan(
                                    alignment: PlaceholderAlignment.baseline,
                                    baseline: TextBaseline.alphabetic,
                                    child: GestureDetector(
                                      onTap: () => Navigator.pop(context),
                                      child: const Text(
                                        'Login',
                                        style: TextStyle(
                                          fontFamily: 'Inter_SemiBold',
                                          color: AppColors.appColor,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (signup.isLoading)
            const Positioned.fill(child: AppLoaderOverlay()),
        ]
      ),
    );
  }
}

class _OfficeMap extends StatefulWidget {
  const _OfficeMap({
    required this.office,
    required this.radiusMeters,
  });

  final LatLng office;
  final double radiusMeters;

  @override
  State<_OfficeMap> createState() => _OfficeMapState();
}

class _OfficeMapState extends State<_OfficeMap> {
  GoogleMapController? _controller;
  bool _ready = false;

  @override
  void dispose() {
    _controller = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
          key: const ValueKey('signup-office-map'),
          mapType: MapType.normal,
          initialCameraPosition: CameraPosition(
            target: widget.office,
            zoom: 15.4,
          ),
          markers: {
            Marker(
              markerId: const MarkerId('office'),
              position: widget.office,
            ),
          },
          circles: {
            Circle(
              circleId: const CircleId('geofence'),
              center: widget.office,
              radius: widget.radiusMeters,
              fillColor: AppColors.appColor.withValues(alpha: 0.15),
              strokeColor: AppColors.appColor,
              strokeWidth: 3,
            ),
          },
          myLocationButtonEnabled: false,
          myLocationEnabled: false,
          zoomControlsEnabled: false,
          zoomGesturesEnabled: true,
          compassEnabled: false,
          mapToolbarEnabled: false,
          indoorViewEnabled: false,
          trafficEnabled: false,
          rotateGesturesEnabled: false,
          tiltGesturesEnabled: false,
          onMapCreated: (controller) async {
            _controller = controller;
            await Future<void>.delayed(const Duration(milliseconds: 250));
            if (!mounted) return;
            await controller.animateCamera(
              CameraUpdate.newLatLngZoom(widget.office, 15.4),
            );
            if (mounted) setState(() => _ready = true);
          },
          gestureRecognizers: {
            Factory<OneSequenceGestureRecognizer>(
              () => EagerGestureRecognizer(),
            ),
          },
        ),
        if (_ready)
          Positioned(
            right: 10,
            bottom: 10,
            child: Column(
              children: [
                _ZoomButton(
                  icon: Icons.add,
                  onTap: () => _controller?.animateCamera(CameraUpdate.zoomIn()),
                ),
                const SizedBox(height: 8),
                _ZoomButton(
                  icon: Icons.remove,
                  onTap: () =>
                      _controller?.animateCamera(CameraUpdate.zoomOut()),
                ),
              ],
            ),
          ),
        if (!_ready)
          const ColoredBox(
            color: Color(0xFFE8EEEE),
            child: Center(
              child: AppLoader(size: 56),
            ),
          ),
      ],
    );
  }
}

class _ZoomButton extends StatelessWidget {
  const _ZoomButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 2,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          width: 36,
          height: 36,
          child: Icon(icon, size: 20, color: AppColors.textDark),
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.label,
    required this.controller,
    required this.icon,
    this.keyboardType,
    this.obscure = false,
    this.suffix,
    required this.validator,
  });

  final String label;
  final TextEditingController controller;
  final IconData icon;
  final TextInputType? keyboardType;
  final bool obscure;
  final Widget? suffix;
  final String? Function(String?) validator;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Inter_SemiBold',
            color: AppColors.appColor,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscure,
          keyboardType: keyboardType,
          validator: validator,
          cursorColor: AppColors.appColor,
          style: const TextStyle(
            fontFamily: 'Inter_Medium',
            color: AppColors.textDark,
            fontSize: 14,
          ),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: AppColors.textGrey, size: 20),
            suffixIcon: suffix,
            filled: true,
            fillColor: Colors.white,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 14,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFDDE4E2)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.appColor, width: 1.6),
            ),
          ),
        ),
      ],
    );
  }
}
