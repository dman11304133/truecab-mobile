// import 'dart:async';
import 'dart:async';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../functions/functions.dart';
import '../../styles/styles.dart';
import '../../translations/translation.dart';
import '../../widgets/widgets.dart';
import 'login.dart';


class NamePage extends StatefulWidget {
  const NamePage({super.key});

  @override
  State<NamePage> createState() => _NamePageState();
}

String _error = '';
ImagePicker picker = ImagePicker();
bool _pickImage = false;
String _permission = '';

class _NamePageState extends State<NamePage> {
  TextEditingController firstname = TextEditingController();
  TextEditingController lastname = TextEditingController();
  TextEditingController emailtext = TextEditingController();
  TextEditingController controller = TextEditingController();

  @override
  void initState() {
    _error = '';

    if (isLoginemail == true) {
      emailtext.text = email;
    }
    super.initState();
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

  getGalleryPermission() async {
    dynamic status;
    if (platform == TargetPlatform.android) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      if (androidInfo.version.sdkInt <= 32) {
        status = await Permission.storage.status;
        if (status != PermissionStatus.granted) {
          status = await Permission.storage.request();
        }
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

  //pick image from gallery
  pickImageFromGallery() async {
    var permission = await getGalleryPermission();
    if (permission == PermissionStatus.granted) {
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      setState(() {
        proImageFile = pickedFile?.path;
        _pickImage = false;
      });
    } else {
      setState(() {
        _permission = 'noPhotos';
      });
    }
  }

//pick image from camera
  pickImageFromCamera() async {
    var permission = await getCameraPermission();
    if (permission == PermissionStatus.granted) {
      final pickedFile = await picker.pickImage(source: ImageSource.camera);
      setState(() {
        proImageFile = pickedFile?.path;
        _pickImage = false;
      });
    } else {
      setState(() {
        _permission = 'noCamera';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;

    return Material(
      color: page,
      child: Directionality(
        textDirection: (languageDirection == 'rtl')
            ? TextDirection.rtl
            : TextDirection.ltr,
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _pickImage = true;
                      });
                    },
                    child: proImageFile != null
                        ? Container(
                            height: media.width * 0.35,
                            width: media.width * 0.35,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: backgroundColor,
                                image: DecorationImage(
                                    image: FileImage(File(proImageFile)),
                                    fit: BoxFit.cover)),
                          )
                        : Container(
                            alignment: Alignment.center,
                            height: media.width * 0.35,
                            width: media.width * 0.35,
                            decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                    image: AssetImage(
                                        'assets/images/idcard.png'),
                                    fit: BoxFit.contain)),
                          ),
                  ),
                ),
                          const SizedBox(
                            height: 10,
                          ),
                          Center(
                            child: MyText(
                              text: t('text_upload_id'),
                              size: media.width * twelve,
                              fontweight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(
                            height: 18,
                          ),
                          Container(
                              height: media.width * 0.13,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border(
                                    bottom: BorderSide(
                                        width:
                                        1.1,
                                        color: borderLines)),
                              ),
                              padding: const EdgeInsets.only(left: 5, right: 5),
                              child: MyTextField(
                                textController: firstname,
                                readonly:
                                (isfromomobile == false) ? true : false,
                                icon: const Icon(Icons.person, color: Color(0xff000000)),
                                hinttext: t('text_first_name'),
                                onTap: (val) {
                                  setState(() {});
                                },
                              )),
                          SizedBox(
                            height: media.height * 0.02,
                          ),
                          Container(
                              height: media.width * 0.13,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border(
                                    bottom: BorderSide(
                                        width:
                                        1.1,
                                        color: borderLines)),
                              ),
                              padding: const EdgeInsets.only(left: 5, right: 5),
                              child: MyTextField(
                                textController: lastname,
                                readonly:
                                (isfromomobile == false) ? true : false,
                                icon: const Icon(Icons.person, color: Color(0xff000000)),
                                hinttext: t('text_last_name'),
                                onTap: (val) {
                                  setState(() {});
                                },
                              )),
                          SizedBox(
                            height: media.height * 0.02,
                          ),
                          Container(
                              height: media.width * 0.13,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border(
                                    bottom: BorderSide(
                                        width:
                                        1.1,
                                        color: borderLines)),
                              ),
                              padding: const EdgeInsets.only(left: 5, right: 5),
                              child: MyTextField(
                                textController: emailtext,
                                readonly:
                                (isfromomobile == false) ? true : false,
                                hinttext: t('text_enter_email'),
                                icon: const Icon(Icons.email, color: Color(0xff000000)),
                                onTap: (val) {
                                  setState(() {});
                                },
                              )),
                          SizedBox(
                            height: media.width * 0.05,
                          ),
                          (isfromomobile == false)
                              ? Container(
                                  padding:
                                      const EdgeInsets.fromLTRB(10, 0, 10, 0),
                                  height: 55,
                                  width: media.width * 0.9,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: textColor),
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
                                                    backgroundColor: page,
                                                    insetPadding:
                                                        const EdgeInsets.all(
                                                            10),
                                                    content: StatefulBuilder(
                                                        builder: (context,
                                                            setState) {
                                                      return Container(
                                                        width:
                                                            media.width * 0.9,
                                                        color: page,
                                                        child: Directionality(
                                                          textDirection:
                                                              (languageDirection ==
                                                                      'rtl')
                                                                  ? TextDirection
                                                                      .rtl
                                                                  : TextDirection
                                                                      .ltr,
                                                          child: Column(
                                                            children: [
                                                              Container(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .only(
                                                                        left:
                                                                            20,
                                                                        right:
                                                                            20),
                                                                height: 40,
                                                                width: media
                                                                        .width *
                                                                    0.9,
                                                                decoration: BoxDecoration(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            20),
                                                                    border: Border.all(
                                                                        color: Colors
                                                                            .grey,
                                                                        width:
                                                                            1.5)),
                                                                child:
                                                                    TextField(
                                                                  decoration: InputDecoration(
                                                                      contentPadding: (languageDirection ==
                                                                              'rtl')
                                                                          ? EdgeInsets.only(
                                                                              bottom: media.width *
                                                                                  0.035)
                                                                          : EdgeInsets.only(
                                                                              bottom: media.width *
                                                                                  0.04),
                                                                      border: InputBorder
                                                                          .none,
                                                                      hintText:
                                                                          t('text_search'),
                                                                      hintStyle: GoogleFonts.poppins(
                                                                          fontSize: media.width *
                                                                              sixteen,
                                                                          color:
                                                                              hintColor)),
                                                                  style: GoogleFonts.poppins(
                                                                      fontSize:
                                                                          media.width *
                                                                              sixteen,
                                                                      color:
                                                                          textColor),
                                                                  onChanged:
                                                                      (val) {
                                                                    setState(
                                                                        () {
                                                                      searchVal =
                                                                          val;
                                                                    });
                                                                  },
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                  height: 20),
                                                              Expanded(
                                                                child:
                                                                    SingleChildScrollView(
                                                                  child: Column(
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
                                                                                                  Image.network(countries[i]['flag']),
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
                                                                                                      Image.network(countries[i]['flag']),
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
                                          height: 50,
                                          alignment: Alignment.center,
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Image.network(
                                                  countries[phcode]['flag']),
                                              SizedBox(
                                                width: media.width * 0.02,
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
                                        height: 55,
                                        color: underline,
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Container(
                                          alignment: Alignment.bottomCenter,
                                          height: 50,
                                          child: TextFormField(
                                            textAlign: TextAlign.start,
                                            controller: controller,
                                            onChanged: (val) {
                                              setState(() {
                                                phnumber = controller.text;
                                              });
                                              if (controller.text.length ==
                                                  countries[phcode]
                                                      ['dial_max_length']) {
                                                FocusManager
                                                    .instance.primaryFocus
                                                    ?.unfocus();
                                              }
                                            },
                                            maxLength: countries[phcode]
                                                ['dial_max_length'],
                                            style: GoogleFonts.poppins(
                                                color: textColor,
                                                fontSize: media.width * sixteen,
                                                letterSpacing: 1),
                                            keyboardType: TextInputType.number,
                                            decoration: InputDecoration(
                                              counterText: '',
                                              prefixIcon: Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 12),
                                                child: MyText(
                                                  text: countries[phcode]
                                                          ['dial_code']
                                                      .toString(),
                                                  size: media.width * sixteen,
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                              hintStyle: GoogleFonts.poppins(
                                                color:
                                                    textColor.withOpacity(0.7),
                                                fontSize: media.width * sixteen,
                                              ),
                                              border: InputBorder.none,
                                              enabledBorder: InputBorder.none,
                                            ),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                )
                              : Container(),
                const SizedBox(
                  height: 20,
                ),
                if (_error != '')
                  Column(
                    children: [
                      SizedBox(
                          width: media.width * 0.9,
                          child: MyText(
                            text: _error,
                            color: Colors.red,
                            size: media.width * fourteen,
                            textAlign: TextAlign.center,
                          )),
                      SizedBox(
                        height: media.width * 0.025,
                      )
                    ],
                  ),
                (isfromomobile == true)
                    ? Column(
                        children: [
                          Button(
                              onTap: () async {
                                if (firstname.text.isNotEmpty &&
                                    emailtext.text.isNotEmpty && proImageFile != null) {
                                  setState(() {
                                    _error = '';
                                  });
                                  loginLoading = true;
                                  valueNotifierLogin.incrementNotifier();
                                  var remail =
                                      emailtext.text.replaceAll(' ', '');
                                  String pattern =
                                      r"^[A-Za-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[A-Za-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[A-Za-z0-9](?:[A-Za-z0-9-]*[A-Za-z0-9])?\.)+[A-Za-z0-9](?:[A-Za-z0-9-]*[A-Za-z0-9])*$";
                                  RegExp regex = RegExp(pattern);
                                  if (regex.hasMatch(remail)) {
                                    setState(() {
                                      _error = '';
                                    });
                                    FocusScope.of(context).unfocus();
                                    if (lastname.text != '') {
                                      name =
                                          '${firstname.text} ${lastname.text}';
                                    } else {
                                      name = firstname.text;
                                    }
                                    email = remail;
                                    values = 1;
                                    var result = await validateEmail(remail);
                                    if (result == 'success') {
                                      isfromomobile = true;
                                      isverifyemail = true;
                                      currentPage = 3;
                                    } else {
                                      setState(() {
                                        _error = result.toString();
                                      });
                                      // showToast();
                                    }
                                  } else {
                                    // showToast();
                                    setState(() {
                                      _error = t('text_email_validation');
                                    });
                                    // showToast();
                                  }
                                  loginLoading = false;
                                  valueNotifierLogin.incrementNotifier();
                                }
                              },
                              color: (firstname.text.isNotEmpty &&
                                      emailtext.text.isNotEmpty && proImageFile != null)
                                  ? buttonColor
                                  : Colors.grey,
                              text: t('text_next'))
                        ],
                      )
                    : Container(
                        width: media.width * 1 - media.width * 0.08,
                        alignment: Alignment.center,
                        child: Button(
                          onTap: () async {
                            if (firstname.text.isNotEmpty &&
                                controller.text.length >=
                                    countries[phcode]['dial_min_length']) {
                              if (lastname.text != '') {
                                name = '${firstname.text} ${lastname.text}';
                              } else {
                                name = firstname.text;
                              }
                              FocusManager.instance.primaryFocus?.unfocus();
                              loginLoading = true;
                              valueNotifierLogin.incrementNotifier();
                              values = 0;
                              var val = await validateEmail(phnumber);
                              if (val == 'success') {
                                var result = await verifyUser(phnumber);
                                if (result == false) {
                                  var val = await otpCall();
                                  if (val == true) {
                                    phoneAuthCheck = true;
                                    await phoneAuth(countries[phcode]['dial_code'] + phnumber);
                                    currentPage = 1;
                                    isfromomobile = true;
                                    isverifyemail = true;
                                  } else {
                                    phoneAuthCheck = false;
                                    var resultOtp = await sendOTPtoMobile(phnumber, countries[phcode]['dial_code']);
                                    if(resultOtp == 'success') {
                                      isverifyemail = true;
                                      isfromomobile = true;
                                      currentPage = 1;
                                    } else {
                                      setState(() {
                                        _error = resultOtp.toString();
                                      });
                                    }
                                  }
                                } else {
                                  setState(() {
                                    _error = t('text_mobile_already_taken');
                                  });
                                }
                              } else {
                                setState(() {
                                  _error = t('text_mobile_already_taken');
                                });
                              }

                              loginLoading = false;
                              valueNotifierLogin.incrementNotifier();
                            }
                          },
                          color: (firstname.text.isNotEmpty &&
                                  controller.text.length >=
                                      countries[phcode]['dial_min_length'])
                              ? buttonColor
                              : Colors.grey,
                          text: t('text_next'),
                        ),
                      ),
                const SizedBox(
                  height: 25,
                ),
                SizedBox(
                  height: media.height * 0.4,
                )
              ],
            ),
            //display toast
            //display toast
            (_pickImage == true)
                ? Positioned(
                bottom: 0,
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _pickImage = false;
                    });
                  },
                  child: Container(
                    height: media.height * 1,
                    width: media.width * 1,
                    color: Colors.transparent.withOpacity(0.6),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          padding: EdgeInsets.all(media.width * 0.05),
                          width: media.width * 1,
                          decoration: BoxDecoration(
                              borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(25),
                                  topRight: Radius.circular(25)),
                              border: Border.all(
                                color: borderLines,
                                width: 1.2,
                              ),
                              color: page),
                          child: Column(
                            children: [
                              Container(
                                height: media.width * 0.02,
                                width: media.width * 0.15,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                      media.width * 0.01),
                                  color: Colors.grey,
                                ),
                              ),
                              SizedBox(
                                height: media.width * 0.05,
                              ),
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceEvenly,
                                children: [
                                  Column(
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          pickImageFromCamera();
                                        },
                                        child: Container(
                                            height: media.width * 0.171,
                                            width: media.width * 0.171,
                                            decoration: BoxDecoration(
                                                border: Border.all(
                                                    color: borderLines,
                                                    width: 1.2),
                                                borderRadius:
                                                BorderRadius.circular(
                                                    12)),
                                            child: Icon(
                                              Icons.camera_alt_outlined,
                                              size: media.width * 0.064,
                                            )),
                                      ),
                                      SizedBox(
                                        height: media.width * 0.01,
                                      ),
                                      Text(
                                        t('text_camera'),
                                        style: GoogleFonts.roboto(
                                            fontSize: media.width * ten,
                                            color:
                                            const Color(0xff666666)),
                                      )
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          pickImageFromGallery();
                                        },
                                        child: Container(
                                            height: media.width * 0.171,
                                            width: media.width * 0.171,
                                            decoration: BoxDecoration(
                                                border: Border.all(
                                                    color: borderLines,
                                                    width: 1.2),
                                                borderRadius:
                                                BorderRadius.circular(
                                                    12)),
                                            child: Icon(
                                              Icons.image_outlined,
                                              size: media.width * 0.064,
                                            )),
                                      ),
                                      SizedBox(
                                        height: media.width * 0.01,
                                      ),
                                      Text(
                                        t('text_gallery'),
                                        style: GoogleFonts.roboto(
                                            fontSize: media.width * ten,
                                            color:
                                            const Color(0xff666666)),
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ))
                : Container(),

            //permission denied popup
            (_permission != '')
                ? Positioned(
                child: Container(
                  height: media.height * 1,
                  width: media.width * 1,
                  color: Colors.transparent.withOpacity(0.6),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: media.width * 0.9,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            InkWell(
                              onTap: () {
                                setState(() {
                                  _permission = '';
                                  _pickImage = false;
                                });
                              },
                              child: Container(
                                height: media.width * 0.1,
                                width: media.width * 0.1,
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle, color: page),
                                child: const Icon(Icons.cancel_outlined),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: media.width * 0.05,
                      ),
                      Container(
                        padding: EdgeInsets.all(media.width * 0.05),
                        width: media.width * 0.9,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: page,
                            boxShadow: [
                              BoxShadow(
                                  blurRadius: 2.0,
                                  spreadRadius: 2.0,
                                  color: Colors.black.withOpacity(0.2))
                            ]),
                        child: Column(
                          children: [
                            SizedBox(
                                width: media.width * 0.8,
                                child: Text(
                                  (_permission == 'noPhotos')
                                      ? t('text_open_photos_setting')
                                      : t('text_open_camera_setting'),
                                  style: GoogleFonts.roboto(
                                      fontSize: media.width * sixteen,
                                      color: textColor,
                                      fontWeight: FontWeight.w600),
                                )),
                            SizedBox(height: media.width * 0.05),
                            Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: [
                                InkWell(
                                    onTap: () async {
                                      await openAppSettings();
                                    },
                                    child: Text(
                                      t('text_open_settings'),
                                      style: GoogleFonts.roboto(
                                          fontSize: media.width * sixteen,
                                          color: buttonColor,
                                          fontWeight: FontWeight.w600),
                                    )),
                                InkWell(
                                    onTap: () async {
                                      (_permission == 'noCamera')
                                          ? pickImageFromCamera()
                                          : pickImageFromGallery();
                                      setState(() {
                                        _permission = '';
                                      });
                                    },
                                    child: Text(
                                      t('text_done'),
                                      style: GoogleFonts.roboto(
                                          fontSize: media.width * sixteen,
                                          color: buttonColor,
                                          fontWeight: FontWeight.w600),
                                    ))
                              ],
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ))
                : Container(),

            (showtoast == true)
                ? Positioned(
                    bottom: media.width * 0.1,
                    left: media.width * 0.06,
                    right: media.width * 0.06,
                    child: Container(
                        padding: EdgeInsets.all(media.width * 0.04),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                  blurRadius: 2.0,
                                  spreadRadius: 2.0,
                                  color: Colors.black.withOpacity(0.2))
                            ],
                            color: verifyDeclined),
                        child: MyText(
                          text: _error,
                          size: media.width * fourteen,
                          color: textColor,
                          fontweight: FontWeight.w500,
                        )))
                : Container()
          ],
        ),
      ),
    );
  }
}
