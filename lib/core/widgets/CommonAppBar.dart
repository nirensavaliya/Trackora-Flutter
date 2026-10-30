import 'package:flutter/material.dart';
import 'package:trackora/core/constants/App_Font.dart';

class CommonAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final Widget? leading;
  final List<Widget>? actions;
  final bool showBackButton;
  final VoidCallback? onBack;
  final bool showMenuButton;
  final VoidCallback? onMenu;

  const CommonAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.actions,
    this.showBackButton = false,
    this.onBack,
    this.showMenuButton = false,
    this.onMenu,
  });

  @override
  Size get preferredSize => const Size.fromHeight(105);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 105,
      child: Stack(
        children: [
          Container(
            height: 105,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xff287872),
                  Color(0xff246D68),
                  Color(0xff205F5B),
                ],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: SizedBox(
              height: 72,
              child: Row(
                children: [
                  SizedBox(
                    width: 64,
                    child: showBackButton
                        ? IconButton(
                      onPressed: onBack ??
                              () {
                            Navigator.pop(context);
                          },
                      icon: Container(
                        height: 38,
                        width: 38,
                        decoration: BoxDecoration(
                          color:
                          Colors.white.withOpacity(.12),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color:
                            Colors.white.withOpacity(.18),
                            width: 1,
                          ),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons
                                .arrow_back_ios_new_rounded,
                            size: 17,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    )
                        : showMenuButton
                        ? IconButton(
                      onPressed: onMenu,
                      icon: Container(
                        height: 38,
                        width: 38,
                        decoration: BoxDecoration(
                          color: Colors.white
                              .withOpacity(.12),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white
                                .withOpacity(.18),
                            width: 1,
                          ),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.menu_rounded,
                            size: 22,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    )
                        : leading,
                  ),
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment:
                        MainAxisAlignment.center,
                        children: [
                          Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 20,
                              height: 1.1,
                              fontFamily: "Inter_Bold",
                              color: Colors.white,
                              letterSpacing: -.25,
                            ),
                          ),

                          if (subtitle != null) ...[
                            const SizedBox(height: 4),

                            Text(
                              subtitle!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11,
                                height: 1.1,
                                fontFamily:
                                FontFamily.interSemiBold,
                                color: Colors.white
                                    .withOpacity(.72),
                                letterSpacing: .1,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 64,
                    child: actions != null
                        ? Row(
                      mainAxisAlignment:
                      MainAxisAlignment.end,
                      children: actions!,
                    )
                        : null,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}