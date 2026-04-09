import 'dart:async';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../styles/styles.dart';
import '../../functions/functions.dart';
import '../../translations/translation.dart';
import '../../widgets/widgets.dart';
import 'dart:math' as math;
import '../loadingPage/loading.dart';
import '../noInternet/nointernet.dart';
import 'agreement.dart';
import 'namepage.dart';
import 'otp_page.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

// String phone = '';
List pages = [1, 2, 3, 4];

ImagePicker picker = ImagePicker();
bool pickImage = false;
String _permission = '';

late StreamController profilepicturecontroller;
StreamSink get profilepicturesink => profilepicturecontroller.sink;
Stream get profilepicturestream => profilepicturecontroller.stream;

class _LoginState extends State<Login> with TickerProviderStateMixin {
  TextEditingController controller = TextEditingController();
  // final _pinPutController2 = TextEditingController();
  dynamic aController;
  String _error = '';
  // bool _resend = false;

  String get timerString {
    Duration duration = aController.duration * aController.value;
    return '${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
  }

  bool terms = true; //terms and conditions true or false

  @override
  void initState() {
    currentPage = 0;
    controller.text = '';
    isfromomobile = true;
    isLoginemail = false;
    phnumber = '';
    email = '';
    values = 0;
    aController =
        AnimationController(vsync: this, duration: const Duration(seconds: 60));
    countryCode();
    super.initState();
  }

  getGalleryPermission() async {
    dynamic status;
    if (platform == TargetPlatform.android) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      if (androidInfo.version.sdkInt <= 32) {
        status = await Permission.storage.status;
        if (status != PermissionStatus.granted) {
          status = await Permission.storage.request();
        }

        /// use [Permissions.storage.status]
      } else {
        status = PermissionStatus.granted;
      }
    } else {
      status = await Permission.photos.status;
      if (status != PermissionStatus.granted) {
        status = await Permission.photos.request();
      }
    }
    return status;
  }

//get camera permission
  getCameraPermission() async {
    var status = await Permission.camera.status;
    if (status != PermissionStatus.granted) {
      status = await Permission.camera.request();
    }
    return status;
  }

  countryCode() async {
    isverifyemail = false;
    isLoginemail = false;
    isfromomobile = true;
    var result = await getCountryCode();
    if (result == 'success') {
      setState(() {
        loginLoading = false;
      });
    } else {
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: page,
      resizeToAvoidBottomInset: true,
      body: Directionality(
          textDirection: (languageDirection == 'rtl')
              ? TextDirection.rtl
              : TextDirection.ltr,
          child: ValueListenableBuilder(
              valueListenable: valueNotifierLogin.value,
              builder: (context, value, child) {
                return Stack(
                  children: [
                    // Premium Gradient Header
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: media.height * 0.35,
                        width: media.width,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [grad1, grad1.withOpacity(0.8), grad2],
                          ),
                        ),
                        child: Stack(
                          children: [
                            // Subtle background pattern (optional, can add later)
                            Positioned(
                              top: media.height * 0.08,
                              left: media.width * 0.05,
                              child: ShowUp(
                                delay: 100,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (currentPage != 0)
                                      InkWell(
                                        onTap: () {
                                          if (currentPage == 2) {
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
                                            if (currentPage == 3 &&
                                                isverifyemail &&
                                                isLoginemail) {
                                              setState(() {
                                                isfromomobile = false;
                                              });
                                            }
                                            setState(() {
                                              currentPage = currentPage - 1;
                                            });
                                          }
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(0.2),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            Icons.arrow_back_ios_new_rounded,
                                            color: Colors.white,
                                            size: media.height * 0.022,
                                          ),
                                        ),
                                      )
                                    else
                                      const SizedBox(height: 40),
                                    SizedBox(height: media.height * 0.02),
                                    MyText(
                                      text: (currentPage == 0) 
                                          ? "Welcome back!"
                                          : (currentPage == 1) 
                                              ? "Verify Account" 
                                              : "Complete Profile",
                                      size: media.width * 0.08,
                                      color: Colors.white,
                                      fontweight: FontWeight.bold,
                                    ),
                                    MyText(
                                      text: (currentPage == 0)
                                          ? "Join us via phone or email"
                                          : "Enter the code we sent you",
                                      size: media.width * 0.045,
                                      color: Colors.white.withOpacity(0.8),
                                      fontweight: FontWeight.w400,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            // Logo display
                            Positioned(
                              top: media.height * 0.08,
                              right: media.width * 0.05,
                              child: ShowUp(
                                delay: 300,
                                child: Container(
                                  padding: EdgeInsets.all(media.width * 0.015),
                                  width: media.width * 0.18,
                                  height: media.width * 0.18,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 15,
                                        spreadRadius: 2,
                                      )
                                    ],
                                  ),
                                  child: Image.asset(
                                    'assets/images/logo.png',
                                    fit: BoxFit.contain,
                                    errorBuilder: (_, __, ___) => const Icon(Icons.taxi_alert),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Body Content
                    Positioned.fill(
                      top: media.height * 0.32,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: media.width * 0.05),
                        decoration: BoxDecoration(
                          color: page,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(35),
                            topRight: Radius.circular(35),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, -5),
                            )
                          ],
                        ),
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: media.height * 0.04),
                          (countries.isNotEmpty && currentPage == 0)
                              ? (isLoginemail == false)
                              ? Column(
                            children: [
                              ShowUp(
                                delay: 400,
                                child: MyText(
                                  text: t('text_what_mobilenum'),
                                  size: media.width * 0.045,
                                  fontweight: FontWeight.w600,
                                  color: textColor.withOpacity(0.8),
                                ),
                              ),
                              SizedBox(
                                height: media.height * 0.02,
                              ),
                              ShowUp(
                                delay: 500,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  height: media.height * 0.07,
                                  width: media.width * 0.9,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                    border: Border.all(color: textColor.withOpacity(0.1)),
                                    color: Colors.grey.withOpacity(0.05),
                                  ),
                                child: Row(
                                  children: [
                                    InkWell(
                                      onTap: () async {
                                        if (countries.isNotEmpty) {
                                          //dialod box for select country for dial code
                                          await showDialog(
                                              context: context,
                                              builder: (context) {
                                                var searchVal = '';
                                                return AlertDialog(
                                                  backgroundColor:
                                                  page,
                                                  insetPadding:
                                                  const EdgeInsets
                                                      .all(10),
                                                  content: StatefulBuilder(
                                                      builder: (context,
                                                          setState) {
                                                        return Container(
                                                          width: media
                                                              .width *
                                                              0.9,
                                                          color: page,
                                                          child:
                                                          Directionality(
                                                            textDirection: (languageDirection ==
                                                                'rtl')
                                                                ? TextDirection
                                                                .rtl
                                                                : TextDirection
                                                                .ltr,
                                                            child: Column(
                                                              children: [
                                                                Container(
                                                                  padding: const EdgeInsets
                                                                      .only(
                                                                      left:
                                                                      20,
                                                                      right:
                                                                      20),
                                                                  height:
                                                                  40,
                                                                  width: media.width *
                                                                      0.9,
                                                                  decoration: BoxDecoration(
                                                                      borderRadius:
                                                                      BorderRadius.circular(20),
                                                                      border: Border.all(color: Colors.grey, width: 1.5)),
                                                                  child:
                                                                  TextField(
                                                                    decoration: InputDecoration(
                                                                        contentPadding: (languageDirection == 'rtl') ? EdgeInsets.only(bottom: media.width * 0.035) : EdgeInsets.only(bottom: media.width * 0.04),
                                                                        border: InputBorder.none,
                                                                        hintText: t('text_search'),
                                                                        hintStyle: GoogleFonts.poppins(fontSize: media.width * sixteen, color: hintColor)),
                                                                    style: GoogleFonts.poppins(
                                                                        fontSize: media.width * sixteen,
                                                                        color: textColor),
                                                                    onChanged:
                                                                        (val) {
                                                                      setState(() {
                                                                        searchVal = val;
                                                                      });
                                                                    },
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                    height:
                                                                    20),
                                                                Expanded(
                                                                  child:
                                                                  SingleChildScrollView(
                                                                    child:
                                                                    Column(
                                                                      children: countries
                                                                          .asMap()
                                                                          .map((i, value) {
                                                                        return MapEntry(
                                                                            i,
                                                                            SizedBox(
                                                                              width: media.width * 0.9,
                                                                              child: (searchVal == '' && countries[i]['flag'] != null)
                                                                                  ? InkWell(
                                                                                  onTap: () {
                                                                                    setState(() {
                                                                                      phcode = i;
                                                                                    });
                                                                                    Navigator.pop(context);
                                                                                  },
                                                                                  child: Container(
                                                                                    padding: const EdgeInsets.only(top: 10, bottom: 10),
                                                                                    color: page,
                                                                                    child: Row(
                                                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                      children: [
                                                                                        Row(
                                                                                          children: [
                                                                                            Image.network(
                                                                                              countries[i]['flag'].toString().replaceAll('trucabtt.com', 'trucabtt.com'),
                                                                                              width: 30,
                                                                                              height: 20,
                                                                                              fit: BoxFit.cover,
                                                                                              errorBuilder: (context, error, stackTrace) => const Icon(Icons.flag, size: 20),
                                                                                            ),
                                                                                            SizedBox(
                                                                                              width: media.width * 0.02,
                                                                                            ),
                                                                                            SizedBox(
                                                                                              width: media.width * 0.4,
                                                                                              child: MyText(
                                                                                                text: countries[i]['name'],
                                                                                                size: media.width * sixteen,
                                                                                              ),
                                                                                            ),
                                                                                          ],
                                                                                        ),
                                                                                        MyText(text: countries[i]['dial_code'], size: media.width * sixteen)
                                                                                      ],
                                                                                    ),
                                                                                  ))
                                                                                  : (countries[i]['flag'] != null && countries[i]['name'].toLowerCase().contains(searchVal.toLowerCase()))
                                                                                  ? InkWell(
                                                                                  onTap: () {
                                                                                    setState(() {
                                                                                      phcode = i;
                                                                                    });
                                                                                    Navigator.pop(context);
                                                                                  },
                                                                                  child: Container(
                                                                                    padding: const EdgeInsets.only(top: 10, bottom: 10),
                                                                                    color: page,
                                                                                    child: Row(
                                                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                      children: [
                                                                                        Row(
                                                                                          children: [
                                                                                            Image.network(
                                                                                              countries[i]['flag'].toString().replaceAll('trucabtt.com', 'trucabtt.com'),
                                                                                              width: 30,
                                                                                              height: 20,
                                                                                              fit: BoxFit.cover,
                                                                                              errorBuilder: (context, error, stackTrace) => const Icon(Icons.flag, size: 20),
                                                                                            ),
                                                                                            SizedBox(
                                                                                              width: media.width * 0.02,
                                                                                            ),
                                                                                            SizedBox(
                                                                                              width: media.width * 0.4,
                                                                                              child: MyText(text: countries[i]['name'], size: media.width * sixteen),
                                                                                            ),
                                                                                          ],
                                                                                        ),
                                                                                        MyText(text: countries[i]['dial_code'], size: media.width * sixteen)
                                                                                      ],
                                                                                    ),
                                                                                  ))
                                                                                  : Container(),
                                                                            ));
                                                                      })
                                                                          .values
                                                                          .toList(),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        );
                                                      }),
                                                );
                                              });
                                        } else {
                                          getCountryCode();
                                        }
                                        setState(() {});
                                      },
                                      //input field
                                      child: Container(
                                        height: media.height * 0.5,
                                        alignment: Alignment.center,
                                        child: Row(
                                          crossAxisAlignment:
                                          CrossAxisAlignment
                                              .center,
                                          children: [
                                            Image.network(
                                              countries[phcode]['flag'].toString().replaceAll('trucabtt.com', 'trucabtt.com'),
                                              width: 30,
                                              height: 20,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) => const Icon(Icons.flag, size: 20),
                                            ),
                                            SizedBox(
                                              width:
                                              media.width * 0.02,
                                            ),
                                            const SizedBox(
                                              width: 2,
                                            ),
                                            Icon(
                                              Icons.arrow_drop_down,
                                              size: 28,
                                              color: textColor,
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Container(
                                      width: 1,
                                      height: 50,
                                      color: underline,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Container(
                                        alignment:
                                        Alignment.bottomCenter,
                                        height: media.height * 0.5,
                                        child: TextFormField(
                                          textAlign: TextAlign.start,
                                          controller: controller,
                                          onChanged: (val) {
                                            setState(() {
                                              phnumber =
                                                  controller.text;
                                            });
                                             if (controller
                                                 .text.length ==
                                                 int.tryParse(countries[phcode][
                                                 'dial_max_length'].toString())) {
                                              FocusManager.instance
                                                  .primaryFocus
                                                  ?.unfocus();
                                            }
                                          },
                                          maxLength: int.tryParse(countries[phcode]
                                          ['dial_max_length'].toString()),
                                          style: GoogleFonts.poppins(
                                              color: textColor,
                                              fontSize: media.width *
                                                  twentyfour,
                                              letterSpacing: 1),
                                          keyboardType:
                                          TextInputType.number,
                                          decoration: InputDecoration(
                                            counterText: '',
                                            prefixIcon: Padding(
                                              padding:
                                              const EdgeInsets
                                                  .only(top: 6.5),
                                              child: MyText(
                                                text: countries[
                                                phcode]
                                                ['dial_code']
                                                    .toString(),
                                                size: media.width *
                                                    twentyfour,
                                                textAlign:
                                                TextAlign.center,
                                              ),
                                            ),
                                            hintStyle:
                                            GoogleFonts.poppins(
                                              color: textColor
                                                  .withOpacity(0.7),
                                              fontSize: media.width *
                                                  twentyfour,
                                            ),
                                            border: InputBorder.none,
                                            enabledBorder:
                                            InputBorder.none,
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              ),
                              SizedBox(height: media.height * 0.02),
                              MyText(
                                text: t('text_you_get_otp'),
                                size: media.width * fourteen,
                                color: textColor.withOpacity(0.5),
                              ),
                              SizedBox(height: media.height * 0.03),
                              ShowUp(
                                delay: 700,
                                child: (isemailmodule == '1')
                                    ? Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.center,
                                  children: [
                                    InkWell(
                                        onTap: () {
                                          controller.clear();
                                          if (isLoginemail ==
                                              false) {
                                            setState(() {
                                              _error = '';
                                              isLoginemail = true;
                                            });
                                          } else {
                                            setState(() {
                                              _error = '';
                                              isLoginemail =
                                              false;
                                            });
                                          }
                                        },
                                        child: MyText(
                                          text: languages[
                                          choosenLanguage]
                                          [
                                          'text_continue_with'] +
                                              ' ' +
                                              languages[
                                              choosenLanguage]
                                              ['text_email'],
                                          size: media.width *
                                              sixteen,
                                          color: theme,
                                          fontweight:
                                          FontWeight.w600,
                                        )),
                                    SizedBox(
                                        width:
                                        media.width * 0.02),
                                    Icon(Icons.email_outlined,
                                        size: media.width *
                                            eighteen,
                                        color: theme),
                                  ],
                                )
                                    : Container(),
                              ),
                              SizedBox(
                                height: media.height * 0.03,
                              ),
                              if (_error != '')
                                Column(
                                  children: [
                                    SizedBox(
                                        width: media.width * 0.9,
                                        child: MyText(
                                          text: _error,
                                          color: Colors.red,
                                          size:
                                          media.width * fourteen,
                                          textAlign: TextAlign.center,
                                        )),
                                    SizedBox(
                                      height: media.width * 0.025,
                                    )
                                  ],
                                ),
                                   (controller.text.length >=
                                   int.parse(countries[phcode]
                                   ['dial_min_length'].toString()))
                                  ? Container(
                                width: media.width * 1 -
                                    media.width * 0.08,
                                alignment: Alignment.center,
                                child: Button(
                                   onTap: () async {
                                     if (controller
                                         .text.length >=
                                         int.parse(countries[phcode][
                                         'dial_min_length'].toString())) {
                                      _error = '';
                                      FocusManager
                                          .instance.primaryFocus
                                          ?.unfocus();
                                      setState(() {
                                        loginLoading = true;
                                      });
                                      debugPrint('📞 [LOGIN_BTN] Login tapped. phnumber=$phnumber, dialCode=${countries[phcode]['dial_code']}');

                                      // 🍎 [APPLE_BYPASS] Reviewer detected. Skipping SMS for review account.
                                      String fullNumber = countries[phcode]['dial_code'].toString() + phnumber;
                                      if (fullNumber.contains('18681234567')) {
                                        debugPrint('🍎 [APPLE_BYPASS] Reviewer detected ($fullNumber). Forcing phnumber to 1234567.');
                                        phnumber = '1234567'; // Force match the reviewer record in DB
                                        phoneAuthCheck = false;
                                        currentPage = 1;
                                        loginLoading = false;
                                        setState(() {});
                                        return;
                                      }

                                      //check if otp is true or false
                                      var val = await otpCall();
                                      debugPrint('📞 [LOGIN_BTN] otpCall() returned: $val (type: ${val.runtimeType})');
                                      //otp is true
                                      if (val == true) {
                                        debugPrint('📞 [LOGIN_BTN] Firebase OTP path - calling phoneAuth()');
                                        phoneAuthCheck = true;
                                        await phoneAuth(countries[phcode]['dial_code'] + phnumber);
                                        values = 0;
                                        currentPage = 1;
                                        loginLoading = false;
                                        setState(() {});
                                      }
                                      //otp is false
                                      else if (val == false) {
                                        debugPrint('📞 [LOGIN_BTN] Backend OTP path - calling sendOTPtoMobile()');
                                        phoneAuthCheck = false;
                                        var result = await sendOTPtoMobile(phnumber, countries[phcode]['dial_code']);
                                        debugPrint('📞 [LOGIN_BTN] sendOTPtoMobile result: $result');
                                        if (result == 'success') {
                                          debugPrint('📞 [LOGIN_BTN] OTP sent! Setting currentPage=1');
                                          currentPage = 1;
                                        } else {
                                          debugPrint('📞 [LOGIN_BTN] ❌ OTP send failed: $result');
                                          _error = result.toString();
                                        }
                                        loginLoading = false;
                                        setState(() {});
                                      }
                                    }
                                  },
                                  text:
                                  t('text_login'),
                                ),
                              )
                                  : Container(),
                            ],
                          )
                              : Column(
                            children: [
                              ShowUp(
                                delay: 400,
                                child: MyText(
                                  text: t('text_what_email'),
                                  size: media.width * 0.045,
                                  fontweight: FontWeight.w600,
                                  color: textColor.withOpacity(0.8),
                                ),
                              ),
                              SizedBox(
                                height: media.height * 0.02,
                              ),
                              ShowUp(
                                delay: 500,
                                child: Container(
                                    height: media.width * 0.14,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(15),
                                        border: Border.all(color: textColor.withOpacity(0.1)),
                                        color: Colors.grey.withOpacity(0.05)),
                                    padding: const EdgeInsets.symmetric(horizontal: 10),
                                    child: MyTextField(
                                      textController: controller,
                                      hinttext:
                                      t('text_enter_email'),
                                      onTap: (val) {
                                        setState(() {
                                          email = controller.text;
                                        });
                                      },
                                    )),
                              ),
                              SizedBox(height: media.height * 0.02),
                              MyText(
                                text: t('text_you_get_otp'),
                                size: media.width * fourteen,
                                color: textColor.withOpacity(0.5),
                              ),
                              SizedBox(height: media.height * 0.05),
                              ShowUp(
                                delay: 700,
                                child: Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.center,
                                  children: [
                                    InkWell(
                                        onTap: () {
                                          controller.clear();
                                          if (isLoginemail == false) {
                                            setState(() {
                                              _error = '';
                                              isLoginemail = true;
                                            });
                                          } else {
                                            setState(() {
                                              _error = '';
                                              isLoginemail = false;
                                            });
                                          }
                                        },
                                        child: MyText(
                                          text: languages[
                                          choosenLanguage][
                                          'text_continue_with'] +
                                              ' ' +
                                              t('text_mob_num'),
                                          size: media.width * sixteen,
                                          color: theme,
                                          fontweight: FontWeight.w600,
                                        )),
                                    SizedBox(
                                      width: media.width * 0.03,
                                    ),
                                    Icon(Icons.call,
                                        size: media.width * eighteen,
                                        color: theme),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: media.height * 0.05,
                              ),
                              if (_error != '')
                                Column(
                                  children: [
                                    SizedBox(
                                        width: media.width * 0.9,
                                        child: MyText(
                                          text: _error,
                                          color: Colors.red,
                                          size:
                                          media.width * fourteen,
                                          textAlign: TextAlign.center,
                                        )),
                                    SizedBox(
                                      height: media.width * 0.025,
                                    )
                                  ],
                                ),
                              (controller.text.isNotEmpty)
                                  ? Container(
                                  width: media.width * 1,
                                  alignment: Alignment.center,
                                  child: Button(
                                      onTap: () async {
                                        setState(() {
                                          _error = '';
                                        });
                                        var remail = controller
                                            .text
                                            .replaceAll(' ', '');
                                        String pattern =
                                            r"^[a-zA-Z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[A-Za-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[A-Za-z0-9](?:[A-Za-z0-9-]*[A-Za-z0-9])?\.)+[A-Za-z0-9](?:[A-Za-z0-9-]*[A-Za-z0-9])*$";
                                        RegExp regex =
                                        RegExp(pattern);
                                        if (regex
                                            .hasMatch(remail)) {
                                          FocusManager.instance
                                              .primaryFocus
                                              ?.unfocus();

                                          setState(() {
                                            verifyEmailError = '';
                                            loginLoading = true;
                                          });
                                          email = remail;

                                          phoneAuthCheck = true;
                                          await sendOTPtoEmail(
                                              email);
                                          values = 1;
                                          isfromomobile = false;
                                          currentPage = 1;

                                          // navigate();

                                          setState(() {
                                            loginLoading = false;
                                          });
                                        } else {
                                          setState(() {
                                            loginLoading = false;
                                            _error = languages[
                                            choosenLanguage]
                                            [
                                            'text_email_validation'];
                                          });
                                        }
                                      },
                                      text: languages[
                                      choosenLanguage]
                                      ['text_login']))
                                  : Container(),
                            ],
                          )
                              : (currentPage == 1)
                              ? const Otp()
                              : (currentPage == 2)
                              ? const NamePage()
                              : (currentPage == 3)
                              ? const AggreementPage()
                              : Container(),
                        ],
                      ),
                    ),
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
              },
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
