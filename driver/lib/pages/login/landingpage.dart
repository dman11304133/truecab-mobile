import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../functions/functions.dart';
import '../../styles/styles.dart';
import '../../translation/translation.dart';
import '../../widgets/widgets.dart';
import 'login.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({Key? key}) : super(key: key);

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> with TickerProviderStateMixin {
  bool colorbutton = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    checkmodule();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.65, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
    ));

    _animationController.forward();
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  checkmodule() {
    if (ownermodule == '0') {
      ischeckownerordriver == 'driver';
      Future.delayed(const Duration(seconds: 2), () {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => const Login()));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;

    return Scaffold(
      body: Directionality(
        textDirection: (languageDirection == 'rtl')
            ? TextDirection.rtl
            : TextDirection.ltr,
        child: Stack(
          children: [
            // Background Layer
            Container(
              height: media.height,
              width: media.width,
              decoration: BoxDecoration(
                color: page,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    page,
                    page.withOpacity(0.8),
                    buttonColor.withOpacity(0.05),
                  ],
                ),
              ),
            ),

            // Content Layer
            SafeArea(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Brand Logo / Placeholder
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Container(
                        width: media.width * 0.25,
                        height: media.width * 0.25,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: buttonColor.withOpacity(0.1),
                          border: Border.all(color: buttonColor, width: 2),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(media.width * 0.12),
                          child: Image.asset(
                            'assets/images/logo.png',
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) => Icon(
                              Icons.local_taxi_rounded,
                              size: media.width * 0.12,
                              color: buttonColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: media.height * 0.05),

                    // Choice Container
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: Container(
                          width: media.width * 0.9,
                          padding: EdgeInsets.all(media.width * 0.08),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(32),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.06),
                                blurRadius: 40,
                                offset: const Offset(0, 20),
                              )
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                languages[choosenLanguage]
                                    ['text_choose_to_explore'],
                                style: GoogleFonts.poppins(
                                  fontSize: media.width * eighteen,
                                  fontWeight: FontWeight.w700,
                                  color: textColor,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              SizedBox(height: media.width * 0.08),

                              // Driver Login Button
                              _buildChoiceButton(
                                media,
                                label: languages[choosenLanguage]
                                    ['text_login_driver'],
                                icon: Icons.person_pin_circle_rounded,
                                isPrimary: true,
                                onTap: () {
                                  ischeckownerordriver = 'driver';
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => const Login()),
                                  );
                                },
                              ),
                              SizedBox(height: media.width * 0.04),

                              // Owner Login Button
                              _buildChoiceButton(
                                media,
                                label: languages[choosenLanguage]
                                    ['text_login_owner'],
                                icon: Icons.business_center_rounded,
                                isPrimary: false,
                                onTap: () {
                                  ischeckownerordriver = 'owner';
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => const Login()),
                                  );
                                },
                              ),
                            ],
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
    );
  }

  Widget _buildChoiceButton(
    Size media, {
    required String label,
    required IconData icon,
    required bool isPrimary,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          color: isPrimary ? buttonColor : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: isPrimary ? null : Border.all(color: buttonColor, width: 1.5),
          boxShadow: isPrimary
              ? [
                  BoxShadow(
                    color: buttonColor.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  )
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: isPrimary ? Colors.white : buttonColor,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: media.width * sixteen,
                fontWeight: FontWeight.w600,
                color: isPrimary ? Colors.white : buttonColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
