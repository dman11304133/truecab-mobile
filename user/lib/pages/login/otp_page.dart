import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinput/pinput.dart';
import '../../styles/styles.dart';
import '../../functions/functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math' as math;
import '../../translations/translation.dart';
import '../../widgets/widgets.dart';
import '../noInternet/nointernet.dart';
import '../onTripPage/map_page.dart';
import 'login.dart';
import 'namepage.dart';

class Otp extends StatefulWidget {
  final dynamic from;

  const Otp({super.key, this.from});

  @override
  State<Otp> createState() => _OtpState();
}


class _OtpState extends State<Otp> with TickerProviderStateMixin {
  final _pinPutController2 = TextEditingController();
  dynamic aController;
  bool _resend = false;
  String _error = '';
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  String get timerString {
    Duration duration = aController.duration * aController.value;
    return '${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
  }

  @override
  void initState() {
    debugPrint('OTP initState called');
    aController =
        AnimationController(vsync: this, duration: const Duration(seconds: 60));
    aController.reverse(
        from: aController.value == 0.0 ? 60.0 : aController.value);
    aController.addStatusListener((status) {
      if (status == AnimationStatus.dismissed) {
        if (mounted) {
          setState(() {
            _resend = true;
          });
        }
      }
    });

    // Entry animations
    _fadeController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _fadeAnimation =
        CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
    _slideController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic));

    _fadeController.forward();
    _slideController.forward();

    otpFalse();
    super.initState();
  }

  @override
  void dispose() {
    _error = '';
    aController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

//navigate
  navigate(verify) {
    debugPrint('🚀 [NAV] navigate() called with verify=$verify (type: ${verify.runtimeType})');
    debugPrint('🚀 [NAV] isverifyemail=$isverifyemail, currentPage=$currentPage');
    if (verify == true) {
      debugPrint('🚀 [NAV] ✅ Going to MAPS (home screen)');
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const Maps()),
          (route) => false);
    } else if (verify == false) {
      if (isverifyemail == true) {
        debugPrint('🚀 [NAV] ❌ verify=false, going to currentPage=3 (email profile)');
        currentPage = 3;
        valueNotifierLogin.incrementNotifier();
      } else {
        debugPrint('🚀 [NAV] ❌ verify=false, going to currentPage=2 (COMPLETE PROFILE)');
        setState(() {
          currentPage = 2;
        });
        valueNotifierLogin.incrementNotifier();
      }
    } else {
      debugPrint('🚀 [NAV] ⚠️ verify is neither true nor false: "$verify"');
      _error = verify.toString();
    }
    loginLoading = false;
    valueNotifierLogin.incrementNotifier();
  }

  otpFalse() async {
    debugPrint('📲 [OTP_PAGE] otpFalse() called. phoneAuthCheck=$phoneAuthCheck, isverifyemail=$isverifyemail');
    if (phoneAuthCheck == false) {
      if (isverifyemail == false) {
        // Backend OTP mode: user received a real SMS OTP,
        // wait for them to enter it manually - do NOT auto-submit
        debugPrint('📲 [OTP_PAGE] Backend OTP mode - waiting for user to enter OTP');
      } else {
        debugPrint('📲 [OTP_PAGE] Email verify mode - calling emaillogin()');
        emaillogin();
      }
    } else {
      debugPrint('📲 [OTP_PAGE] Firebase OTP mode - waiting for user to enter code');
    }
  }

  normallogin() async {
    debugPrint('📲 [OTP_PAGE] normallogin() called. phnumber=$phnumber');
    values = 0;

    var verify = await verifyUser(phnumber);
    debugPrint('📲 [OTP_PAGE] normallogin() verifyUser returned: $verify');
    navigate(verify);
  }

  emaillogin() async {
    values = 1;

    var verify = await verifyUser(phnumber);
    // var register = await registerUser();
    if (verify == false) {
      _pinPutController2.text = '123456';
      otpNumber = _pinPutController2.text;
      //referral page
      navigate(verify);
    } else {
      setState(() {
        _pinPutController2.text = '';
        _error = t('text_mobile_already_taken');
      });
    }
  }

//auto verify otp

  verifyOtp() async {
    FocusManager.instance.primaryFocus?.unfocus();
    try {
      // Sign the user in (or link) with the credential
      await FirebaseAuth.instance.signInWithCredential(credentials);

      var verify = await verifyUser(phnumber);
      credentials = null;
      navigate(verify);
    } on FirebaseAuthException catch (error) {
      if (error.code == 'invalid-verification-code') {
        setState(() {
          _pinPutController2.clear();
          _error = t('text_otp_error');
        });
      }
    }
  }

  showToast() {
    setState(() {
      showtoast = true;
    });
    Future.delayed(const Duration(seconds: 4), () {
      setState(() {
        showtoast = false;
      });
    });
  }

  bool showtoast = false;

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;

    // PIN theme definitions
    final defaultPinTheme = PinTheme(
      width: media.width * 0.135,
      height: media.width * 0.135,
      textStyle: GoogleFonts.poppins(
        fontSize: media.width * twenty,
        fontWeight: FontWeight.w600,
        color: buttonColor,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade300, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          )
        ],
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(color: buttonColor, width: 2),
      boxShadow: [
        BoxShadow(
          color: buttonColor.withOpacity(0.18),
          blurRadius: 12,
          offset: const Offset(0, 4),
        )
      ],
    );

    final submittedPinTheme = defaultPinTheme.copyDecorationWith(
      color: buttonColor.withOpacity(0.06),
      border: Border.all(color: buttonColor, width: 1.5),
    );

    return Material(
      color: page,
      child: Stack(
        children: [
          Column(
            children: [
              // ─── Hero Header ────────────────────────────────────────
              FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top + media.width * 0.06,
                    bottom: media.width * 0.08,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        buttonColor,
                        buttonColor.withBlue(180),
                      ],
                    ),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(32),
                      bottomRight: Radius.circular(32),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: buttonColor.withOpacity(0.35),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      )
                    ],
                  ),
                  child: Column(
                    children: [
                      // Shield icon with glow
                      Container(
                        width: media.width * 0.18,
                        height: media.width * 0.18,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.15),
                        ),
                        child: Icon(
                          Icons.shield_rounded,
                          color: Colors.white,
                          size: media.width * 0.1,
                        ),
                      ),
                      SizedBox(height: media.width * 0.04),
                      Text(
                        'Verification',
                        style: GoogleFonts.poppins(
                          fontSize: media.width * twentyfour,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 0.3,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.1),
                              offset: const Offset(0, 2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: media.width * 0.02),
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: media.width * 0.1),
                        child: Text(
                          (isfromomobile == true)
                              ? 'A 6-digit code was sent to\n${countries[phcode]['dial_code']} $phnumber'
                              : 'A 6-digit code was sent to\n$email',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: media.width * fourteen,
                            fontWeight: FontWeight.w400,
                            color: Colors.white.withOpacity(0.85),
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ─── Main Content ───────────────────────────────────────
              // Removed Expanded to avoid unbounded height in SingleChildScrollView
              Padding(
                padding: EdgeInsets.symmetric(horizontal: media.width * 0.06),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: media.width * 0.08),

                        // ─ OTP input label ─
                        Text(
                          'Enter OTP Code',
                          style: GoogleFonts.poppins(
                            fontSize: media.width * sixteen,
                            fontWeight: FontWeight.w600,
                            color: textColor,
                          ),
                        ),
                        SizedBox(height: media.width * 0.05),

                        // ─ Pinput ─
                        Pinput(
                          length: 6,
                          onChanged: (val) {
                            otpNumber = _pinPutController2.text;
                          },
                          controller: _pinPutController2,
                          defaultPinTheme: defaultPinTheme,
                          focusedPinTheme: focusedPinTheme,
                          submittedPinTheme: submittedPinTheme,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        ),

                        SizedBox(height: media.width * 0.06),

                        // ─ Error message ─
                        if (_error.isNotEmpty)
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: EdgeInsets.only(bottom: media.width * 0.04),
                            padding: EdgeInsets.symmetric(
                                horizontal: media.width * 0.04,
                                vertical: media.width * 0.03),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: Colors.red.shade200, width: 1),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.error_outline_rounded,
                                    color: Colors.red.shade400,
                                    size: media.width * 0.045),
                                SizedBox(width: media.width * 0.02),
                                Expanded(
                                  child: Text(
                                    _error,
                                    style: GoogleFonts.poppins(
                                      fontSize: media.width * twelve,
                                      color: Colors.red.shade700,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        // ─ Timer + Resend row ─
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Countdown ring
                            AnimatedBuilder(
                              animation: aController,
                              builder: (ctx, _) => SizedBox(
                                width: 42,
                                height: 42,
                                child: CustomPaint(
                                  painter: CustomTimerPainter(
                                    animation: aController,
                                    backgroundColor: buttonColor,
                                    color: Colors.grey.shade200,
                                  ),
                                  child: Center(
                                    child: Text(
                                      timerString,
                                      style: GoogleFonts.poppins(
                                        fontSize: media.width * ten,
                                        fontWeight: FontWeight.w600,
                                        color: buttonColor,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: media.width * 0.03),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Didn't receive the code?",
                                  style: GoogleFonts.poppins(
                                    fontSize: media.width * twelve,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () async {
                                    if (_resend) {
                                      loginLoading = true;
                                      valueNotifierLogin.incrementNotifier();
                                      if (isfromomobile == true) {
                                        phoneAuthCheck = true;
                                        phoneAuth(
                                            countries[phcode]['dial_code'] +
                                                phnumber);
                                      } else {
                                        phoneAuthCheck = true;
                                        await sendOTPtoEmail(email);
                                      }
                                      aController.reverse(
                                          from: aController.value == 0.0
                                              ? 60.0
                                              : aController.value);
                                      setState(() {
                                        _error = '';
                                        _pinPutController2.text = '';
                                        _resend = false;
                                        loginLoading = false;
                                      });
                                      loginLoading = false;
                                      valueNotifierLogin.incrementNotifier();
                                    }
                                  },
                                  child: Text(
                                    t('text_resend_otp'),
                                    style: GoogleFonts.poppins(
                                      fontSize: media.width * fourteen,
                                      fontWeight: FontWeight.w600,
                                      color: _resend
                                          ? buttonColor
                                          : buttonColor.withOpacity(0.35),
                                      decoration: _resend
                                          ? TextDecoration.underline
                                          : TextDecoration.none,
                                    ),
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),

                        SizedBox(height: media.width * 0.08),
                      ],
                    ),
                  ),
                ),
              ),

              // ─── Verify Button ──────────────────────────────────────
              Padding(
                padding: EdgeInsets.fromLTRB(media.width * 0.06, 0,
                    media.width * 0.06, media.width * 0.08),
                child: (isfromomobile == true)
                    ? _buildVerifyButton(media, onTap: () async {
                        if (_pinPutController2.length == 6) {
                          setState(() => _error = '');
                          loginLoading = true;
                          valueNotifierLogin.incrementNotifier();
                          if (phoneAuthCheck == false) {
                            // Backend OTP mode: validate OTP first, then login
                            debugPrint('📲 [OTP_VERIFY] Validating backend OTP: $otpNumber for $phnumber');
                            var otpResult = await validateSmsOtp(phnumber, otpNumber);
                            debugPrint('📲 [OTP_VERIFY] validateSmsOtp result: $otpResult');
                            if (otpResult == 'success') {
                              var verify = await verifyUser(phnumber);
                              values = 0;
                              navigate(verify);
                            } else {
                              setState(() {
                                _pinPutController2.clear();
                                otpNumber = '';
                                _error = otpResult ?? t('text_otp_error');
                              });
                            }
                          } else {
                            try {
                              PhoneAuthCredential credential =
                                  PhoneAuthProvider.credential(
                                      verificationId: verId,
                                      smsCode: otpNumber);
                              await FirebaseAuth.instance
                                  .signInWithCredential(credential);
                              var verify = await verifyUser(phnumber);
                              navigate(verify);
                              values = 0;
                            } on FirebaseAuthException catch (error) {
                              if (error.code == 'invalid-verification-code') {
                                setState(() {
                                  _pinPutController2.clear();
                                  otpNumber = '';
                                  _error = t('text_otp_error');
                                });
                              }
                            }
                          }
                          loginLoading = false;
                          valueNotifierLogin.incrementNotifier();
                        }
                      })
                    : _buildVerifyButton(media, onTap: () async {
                        if (_pinPutController2.length == 6) {
                          setState(() => _error = '');
                          loginLoading = true;
                          valueNotifierLogin.incrementNotifier();
                          var result = await emailVerify(email, otpNumber);
                          if (result == 'success') {
                            isfromomobile = false;
                            _error = '';
                            var verify = await verifyUser(email);
                            values = 1;
                            navigate(verify);
                          } else {
                            setState(() {
                              _pinPutController2.clear();
                              otpNumber = '';
                              _error = t('text_otp_error');
                            });
                          }
                          loginLoading = false;
                          valueNotifierLogin.incrementNotifier();
                        }
                      }),
              ),
            ],
          ),

          // ─── No internet overlay ────────────────────────────────────
          if (internet == false)
            Positioned(
              top: 0,
              child: NoInternet(
                onTap: () {
                  setState(() {
                    internetTrue();
                  });
                },
              ),
            ),

          // ─── Toast ──────────────────────────────────────────────────
          if (showtoast)
            Positioned(
              bottom: media.width * 0.1,
              left: media.width * 0.06,
              right: media.width * 0.06,
              child: Container(
                padding: EdgeInsets.all(media.width * 0.04),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: verifyDeclined,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 12,
                      color: Colors.black.withOpacity(0.2),
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Text(
                  _error,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                      fontSize: media.width * fourteen,
                      fontWeight: FontWeight.w500,
                      color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildVerifyButton(Size media, {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: media.width * 0.14,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [buttonColor, buttonColor.withBlue(180)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: buttonColor.withOpacity(0.4),
              blurRadius: 16,
              offset: const Offset(0, 6),
            )
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              t('text_verify'),
              style: GoogleFonts.poppins(
                fontSize: media.width * sixteen,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
            SizedBox(width: media.width * 0.02),
            const Icon(Icons.arrow_forward_rounded,
                color: Colors.white, size: 20),
          ],
        ),
      ),
    );
  }
}

class CustomTimerPainter extends CustomPainter {
  CustomTimerPainter({
    required this.animation,
    required this.backgroundColor,
    required this.color,
  }) : super(repaint: animation);

  final Animation<double> animation;
  final Color backgroundColor, color;

  @override
  void paint(Canvas canvas, Size size) {
    // Track (background)
    Paint trackPaint = Paint()
      ..color = color
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(size.center(Offset.zero), size.width / 2.0, trackPaint);

    // Progress arc
    Paint progressPaint = Paint()
      ..color = backgroundColor
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    double progress = (1.0 - animation.value) * 2 * math.pi;
    canvas.drawArc(
        Offset.zero & size, math.pi * 1.5, -progress, false, progressPaint);
  }

  @override
  bool shouldRepaint(CustomTimerPainter oldDelegate) {
    return animation.value != oldDelegate.animation.value ||
        color != oldDelegate.color ||
        backgroundColor != oldDelegate.backgroundColor;
  }
}
