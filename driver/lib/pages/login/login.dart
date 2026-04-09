import 'dart:async';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../styles/styles.dart';
import '../../functions/functions.dart';
import '../../translation/translation.dart';
import '../../widgets/widgets.dart';
import 'dart:math' as math;
import '../loadingPage/loading.dart';
import '../noInternet/nointernet.dart';
import 'agreement.dart';
import 'namepage.dart';
import 'otp_page.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

//code as int for getting phone dial code of choosen country
// String phone = '';
List pages = [1, 2, 3, 4];


String _permission = '';


class _LoginState extends State<Login> with TickerProviderStateMixin {
  TextEditingController controller = TextEditingController();
  dynamic aController;
  String _error = '';
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  String get timerString {
    Duration duration = aController.duration * aController.value;
    return '${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
  }

  bool terms = true;

  @override
  void initState() {
    debugPrint('Login initState called');
    currentPage = 0;
    controller.text = '';
    aController =
        AnimationController(vsync: this, duration: const Duration(seconds: 60));

    // Entry animations
    _fadeController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000));
    _fadeAnimation =
        CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
    _slideController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic));

    _fadeController.forward();
    _slideController.forward();

    countryCode();
    super.initState();
  }

  countryCode() async {
    isverifyemail = false;
    isLoginemail = false;
    isfromomobile = true;
    var result = await getCountryCode();
    if (mounted) {
      setState(() {
        loginLoading = false;
      });
    }
  }

  //navigate
  navigate() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const Otp()));
  }

  var verifyEmailError = '';

  @override
  void dispose() {
    controller.dispose();
    aController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;

    return Material(
      child: Directionality(
          textDirection: (languageDirection == 'rtl')
              ? TextDirection.rtl
              : TextDirection.ltr,
          child: ValueListenableBuilder(
              valueListenable: valueNotifierLogin.value,
              builder: (context, value, child) {
                return Stack(
                  children: [
                    Container(
                      color: page,
                      width: media.width,
                      height: media.height,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ─── Professional Header ────────────────────────
                          FadeTransition(
                            opacity: _fadeAnimation,
                            child: Container(
                              width: double.infinity,
                              padding: EdgeInsets.only(
                                top: MediaQuery.of(context).padding.top +
                                    media.width * 0.05,
                                bottom: media.width * 0.08,
                                left: media.width * 0.06,
                                right: media.width * 0.06,
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
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  InkWell(
                                    onTap: () {
                                      if (currentPage == 0) {
                                        Navigator.pop(context);
                                      } else if (currentPage == 2) {
                                        setState(() {
                                          controller.text = '';
                                          currentPage = 0;
                                          isverifyemail = false;
                                          isLoginemail = false;
                                          isfromomobile = true;
                                        });
                                      } else if (currentPage == 1) {
                                        if (currentPage == 1 && isverifyemail) {
                                          setState(() {
                                            isfromomobile = false;
                                            currentPage = 2;
                                          });
                                        } else {
                                          setState(() {
                                            currentPage = currentPage - 1;
                                          });
                                        }
                                      } else {
                                        setState(() {
                                          currentPage = currentPage - 1;
                                        });
                                      }
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.15),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.arrow_back_rounded,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: media.width * 0.06),
                                  Text(
                                    languages[choosenLanguage]
                                        ['text_login'],
                                    style: GoogleFonts.poppins(
                                      fontSize: media.width * twentyfour,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  SizedBox(height: media.width * 0.01),
                                  Text(
                                    isLoginemail
                                        ? languages[choosenLanguage]
                                            ['text_what_email']
                                        : languages[choosenLanguage]
                                            ['text_what_mobilenum'],
                                    style: GoogleFonts.poppins(
                                      fontSize: media.width * fourteen,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.white.withOpacity(0.85),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // ─── Main Content ────────────────────────────────
                          Expanded(
                            child: SingleChildScrollView(
                              padding: EdgeInsets.symmetric(
                                  horizontal: media.width * 0.06),
                              child: FadeTransition(
                                opacity: _fadeAnimation,
                                child: SlideTransition(
                                  position: _slideAnimation,
                                  child: (countries.isNotEmpty &&
                                          currentPage == 0)
                                      ? (isLoginemail == false)
                                          ? Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                SizedBox(
                                                    height: media.width * 0.1),

                                                // ─ Phone Input Field ─
                                                Container(
                                                  height: 64,
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            16),
                                                    border: Border.all(
                                                        color: Colors
                                                            .grey.shade200,
                                                        width: 1.5),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.black
                                                            .withOpacity(0.04),
                                                        blurRadius: 12,
                                                        offset: const Offset(
                                                            0, 4),
                                                      )
                                                    ],
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      // Country Picker Trigger
                                                      InkWell(
                                                        onTap: () async {
                                                          if (countries
                                                              .isNotEmpty) {
                                                            await _showCountryDialog(
                                                                context, media);
                                                          } else {
                                                            getCountryCode();
                                                          }
                                                          setState(() {});
                                                        },
                                                        child: Container(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  horizontal:
                                                                      16),
                                                          child: Row(
                                                            children: [
                                                              ClipRRect(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            4),
                                                                child: Image
                                                                    .network(
                                                                  countries[phcode]
                                                                          [
                                                                          'flag']
                                                                      .toString()
                                                                      .replaceAll(
                                                                          'trucabtt.com',
                                                                          url.replaceAll('https://', '').replaceAll('http://', '').replaceAll('/', '')),
                                                                  width: 28,
                                                                  height: 18,
                                                                  fit: BoxFit
                                                                      .cover,
                                                                  errorBuilder: (context,
                                                                          error,
                                                                          stackTrace) =>
                                                                      const Icon(
                                                                          Icons
                                                                              .flag,
                                                                          size:
                                                                              20),
                                                                ),
                                                              ),
                                                              const Icon(
                                                                  Icons
                                                                      .arrow_drop_down_rounded,
                                                                  color: Colors
                                                                      .grey),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                      Container(
                                                        width: 1,
                                                        height: 32,
                                                        color: Colors
                                                            .grey.shade200,
                                                      ),
                                                      const SizedBox(width: 12),
                                                      Expanded(
                                                        child: TextFormField(
                                                          controller:
                                                              controller,
                                                          onChanged: (val) {
                                                            setState(() {
                                                              phnumber =
                                                                  controller
                                                                      .text;
                                                            });
                                                            if (controller
                                                                    .text
                                                                    .length ==
                                                                int.tryParse(countries[phcode]
                                                                    [
                                                                    'dial_max_length'].toString())) {
                                                              FocusManager
                                                                  .instance
                                                                  .primaryFocus
                                                                  ?.unfocus();
                                                            }
                                                          },
                                                           maxLength: int.tryParse(countries[
                                                                   phcode]
                                                               ['dial_max_length'].toString()),
                                                          style: GoogleFonts
                                                              .poppins(
                                                            color: textColor,
                                                            fontSize:
                                                                media.width *
                                                                    eighteen,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                          ),
                                                          keyboardType:
                                                              TextInputType
                                                                  .number,
                                                          decoration:
                                                              InputDecoration(
                                                            counterText: '',
                                                            prefixText:
                                                                '${countries[phcode]['dial_code']} ',
                                                            prefixStyle:
                                                                GoogleFonts
                                                                    .poppins(
                                                              color: textColor,
                                                              fontSize:
                                                                  media.width *
                                                                      eighteen,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                            ),
                                                            hintText: '000 000 0000',
                                                            hintStyle:
                                                                GoogleFonts
                                                                    .poppins(
                                                              color: Colors
                                                                  .grey.shade400,
                                                              fontSize:
                                                                  media.width *
                                                                      eighteen,
                                                            ),
                                                            border:
                                                                InputBorder.none,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),

                                                SizedBox(
                                                    height: media.width * 0.04),
                                                Text(
                                                  languages[choosenLanguage]
                                                      ['text_you_get_otp'],
                                                  style: GoogleFonts.poppins(
                                                    fontSize:
                                                        media.width * twelve,
                                                    color: greyText,
                                                  ),
                                                ),
                                                SizedBox(
                                                    height: media.width * 0.06),

                                                // ─ Error Message ─
                                                if (_error.isNotEmpty)
                                                  _buildErrorContainer(media),

                                                // ─ Continue Button ─
                                                 if (controller.text.length >=
                                                     int.parse(countries[phcode]
                                                         ['dial_min_length'].toString()))
                                                  _buildContinueButton(media,
                                                      onTap: () async {
                                                    _error = '';
                                                    FocusManager
                                                        .instance.primaryFocus
                                                        ?.unfocus();
                                                    setState(() =>
                                                        loginLoading = true);
                                                    debugPrint('🚗 [DRIVER_LOGIN] Continue tapped. phnumber=$phnumber');
                                                    var val = await otpCall();
                                                    debugPrint('🚗 [DRIVER_LOGIN] otpCall() returned: $val (type: ${val.runtimeType})');
                                                    if (val == true) {
                                                      debugPrint('🚗 [DRIVER_LOGIN] Firebase OTP mode - calling phoneAuth()');
                                                      phoneAuthCheck = true;
                                                      await phoneAuth(
                                                          countries[phcode]
                                                                  ['dial_code'] +
                                                              phnumber);
                                                      values = 0;
                                                      currentPage = 1;
                                                    } else if (val == false) {
                                                      debugPrint('🚗 [DRIVER_LOGIN] Backend OTP mode - calling sendOTPtoMobile()');
                                                      phoneAuthCheck = false;
                                                      var result =
                                                          await sendOTPtoMobile(
                                                              phnumber,
                                                              countries[phcode]
                                                                  ['dial_code']);
                                                      debugPrint('🚗 [DRIVER_LOGIN] sendOTPtoMobile result: $result');
                                                      if (result == 'success') {
                                                        currentPage = 1;
                                                      } else {
                                                        _error =
                                                            result.toString();
                                                      }
                                                    }
                                                    setState(() =>
                                                        loginLoading = false);
                                                  }),

                                                SizedBox(
                                                    height: media.width * 0.08),

                                                // ─ Toggle to Email ─
                                                if (isemailmodule == '1')
                                                  _buildEmailPhoneToggle(media),
                                              ],
                                            )
                                          : (isLoginemail == true)
                                              ? Column(
                                                  children: [
                                                    SizedBox(
                                                        height:
                                                            media.width * 0.1),

                                                    // ─ Email Input Field ─
                                                    Container(
                                                      height: 64,
                                                      decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(16),
                                                        border: Border.all(
                                                            color: Colors.grey
                                                                .shade200,
                                                            width: 1.5),
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: Colors.black
                                                                .withOpacity(
                                                                    0.04),
                                                            blurRadius: 12,
                                                            offset:
                                                                const Offset(
                                                                    0, 4),
                                                          )
                                                        ],
                                                      ),
                                                      padding: const EdgeInsets
                                                              .symmetric(
                                                              horizontal: 16),
                                                      child: Row(
                                                        children: [
                                                          Icon(
                                                              Icons
                                                                  .email_rounded,
                                                              color: buttonColor
                                                                  .withOpacity(
                                                                      0.7),
                                                              size: 22),
                                                          const SizedBox(
                                                              width: 16),
                                                          Expanded(
                                                            child: TextFormField(
                                                              controller:
                                                                  controller,
                                                              onChanged: (val) {
                                                                setState(() {
                                                                  email =
                                                                      controller
                                                                          .text;
                                                                });
                                                              },
                                                              style: GoogleFonts
                                                                  .poppins(
                                                                color:
                                                                    textColor,
                                                                fontSize:
                                                                    media.width *
                                                                        eighteen,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                              ),
                                                              decoration:
                                                                  InputDecoration(
                                                                hintText: languages[
                                                                        choosenLanguage]
                                                                    [
                                                                    'text_enter_email'],
                                                                hintStyle:
                                                                    GoogleFonts
                                                                        .poppins(
                                                                  color: Colors
                                                                      .grey
                                                                      .shade400,
                                                                  fontSize:
                                                                      media.width *
                                                                          eighteen,
                                                                ),
                                                                border:
                                                                    InputBorder
                                                                        .none,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),

                                                    SizedBox(
                                                        height:
                                                            media.width * 0.04),
                                                    Text(
                                                      languages[choosenLanguage]
                                                          ['text_you_get_otp'],
                                                      style:
                                                          GoogleFonts.poppins(
                                                        fontSize: media.width *
                                                            twelve,
                                                        color: greyText,
                                                      ),
                                                    ),
                                                    SizedBox(
                                                        height:
                                                            media.width * 0.06),

                                                    // ─ Error Message ─
                                                    if (_error.isNotEmpty)
                                                      _buildErrorContainer(
                                                          media),

                                                    // ─ Continue Button ─
                                                    if (controller
                                                        .text.isNotEmpty)
                                                      _buildContinueButton(
                                                          media,
                                                      onTap: () async {
                                                        setState(() =>
                                                            _error = '');
                                                        var remail = controller
                                                            .text
                                                            .replaceAll(
                                                                ' ', '');
                                                        String pattern =
                                                            r"^[a-zA-Z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[A-Za-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[A-Za-z0-9](?:[A-Za-z0-9-]*[A-Za-z0-9])?\.)+[A-Za-z0-9](?:[A-Za-z0-9-]*[A-Za-z0-9])*$";
                                                        RegExp regex =
                                                            RegExp(pattern);
                                                        if (regex.hasMatch(
                                                            remail)) {
                                                          FocusManager
                                                              .instance
                                                              .primaryFocus
                                                              ?.unfocus();
                                                          setState(() =>
                                                              loginLoading =
                                                                  true);
                                                          email = remail;
                                                          phoneAuthCheck = true;
                                                          await sendOTPtoEmail(
                                                              email);
                                                          values = 1;
                                                          isfromomobile = false;
                                                          currentPage = 1;
                                                          setState(() =>
                                                              loginLoading =
                                                                  false);
                                                        } else {
                                                          setState(() {
                                                            loginLoading =
                                                                false;
                                                            _error = languages[
                                                                    choosenLanguage]
                                                                [
                                                                'text_email_validation'];
                                                          });
                                                        }
                                                      }),

                                                    SizedBox(
                                                        height:
                                                            media.width * 0.08),

                                                    // ─ Toggle to Phone ─
                                                    _buildEmailPhoneToggle(
                                                        media),
                                                  ],
                                                )
                                              : Container()
                                      : (currentPage == 1)
                                          ? const Otp()
                                          : (currentPage == 2)
                                              ? const NamePage()
                                              : (currentPage == 3)
                                                  ? const AggreementPage()
                                                  : Container(),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),



                    //No internet
                    (internet == false)
                        ? Positioned(
                        top: 0,
                        child: NoInternet(onTap: () {
                          setState(() {
                            loginLoading = true;
                            internet = true;
                            countryCode();
                          });
                        }))
                        : Container(),

                    //loader
                    (loginLoading == true)
                        ? const Positioned(top: 0, child: Loading())
                        : Container()
                  ],
                );
              })),
    );
  }

  // ─── Shared UI Helpers ──────────────────────────────────────────────

  Widget _buildContinueButton(Size media, {required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [buttonColor, buttonColor.withBlue(180)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: buttonColor.withOpacity(0.35),
              blurRadius: 16,
              offset: const Offset(0, 6),
            )
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              languages[choosenLanguage]['text_login'],
              style: GoogleFonts.poppins(
                fontSize: media.width * sixteen,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(width: 12),
            const Icon(Icons.arrow_forward_rounded,
                color: Colors.white, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildEmailPhoneToggle(Size media) {
    return InkWell(
      onTap: () {
        controller.clear();
        setState(() {
          _error = '';
          isLoginemail = !isLoginemail;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          color: buttonColor.withOpacity(0.06),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(isLoginemail ? Icons.phone_android_rounded : Icons.email_rounded,
                size: 20, color: buttonColor),
            const SizedBox(width: 8),
            Text(
              isLoginemail
                  ? "${languages[choosenLanguage]['text_continue_with']} ${languages[choosenLanguage]['text_mob_num']}"
                  : "${languages[choosenLanguage]['text_continue_with']} ${languages[choosenLanguage]['text_email']}",
              style: GoogleFonts.poppins(
                color: buttonColor,
                fontSize: media.width * fourteen,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorContainer(Size media) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded,
              color: Colors.red.shade400, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _error,
              style: GoogleFonts.poppins(
                color: Colors.red.shade700,
                fontSize: media.width * twelve,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  _showCountryDialog(BuildContext context, Size media) async {
    await showDialog(
      context: context,
      builder: (context) {
        var searchVal = '';
        return AlertDialog(
          backgroundColor: page,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          contentPadding: EdgeInsets.zero,
          content: StatefulBuilder(
            builder: (context, setState) {
              return Container(
                width: media.width * 0.9,
                height: media.height * 0.7,
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(
                      'Select Country',
                      style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: textColor),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: languages[choosenLanguage]['text_search'],
                          border: InputBorder.none,
                          icon: const Icon(Icons.search_rounded, size: 20),
                        ),
                        onChanged: (val) => setState(() => searchVal = val),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: ListView.separated(
                        itemCount: countries.length,
                        separatorBuilder: (c, i) => Divider(
                            color: Colors.grey.shade200, height: 1),
                        itemBuilder: (context, i) {
                          if (searchVal.isNotEmpty &&
                              !countries[i]['name']
                                  .toLowerCase()
                                  .contains(searchVal.toLowerCase())) {
                            return Container();
                          }
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: Image.network(
                                countries[i]['flag']
                                    .toString()
                                    .replaceAll('trucabtt.com', 'trucabtt.com'),
                                width: 32,
                                height: 20,
                                fit: BoxFit.cover,
                                errorBuilder: (c, e, s) =>
                                    const Icon(Icons.flag_rounded, size: 20),
                              ),
                            ),
                            title: Text(countries[i]['name'],
                                style: GoogleFonts.poppins(fontSize: 14)),
                            trailing: Text(countries[i]['dial_code'],
                                style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600,
                                    color: buttonColor)),
                            onTap: () {
                              this.setState(() => phcode = i);
                              Navigator.pop(context);
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
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
    Paint paint = Paint()
      ..color = backgroundColor
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.butt
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(size.center(Offset.zero), size.width / 2.0, paint);
    paint.color = color;
    double progress = (1.0 - animation.value) * 2 * math.pi;
    canvas.drawArc(Offset.zero & size, math.pi * 1.5, -progress, false, paint);
  }

  @override
  bool shouldRepaint(CustomTimerPainter oldDelegate) {
    return animation.value != oldDelegate.animation.value ||
        color != oldDelegate.color ||
        backgroundColor != oldDelegate.backgroundColor;
  }
}
