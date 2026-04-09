import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:share_plus/share_plus.dart';
import '../../functions/functions.dart';
import '../../styles/styles.dart';
import '../../translations/translation.dart';
import '../../widgets/widgets.dart';
import '../loadingPage/loading.dart';
import '../noInternet/noInternet.dart';
import 'package:http/http.dart' as http;

class ReferralPage extends StatefulWidget {
  const ReferralPage({super.key});

  @override
  State<ReferralPage> createState() => _ReferralPageState();
}

class _ReferralPageState extends State<ReferralPage> {
  bool _isLoading = true;
  bool _showToast = false;
  dynamic _package;
  // ignore: prefer_typing_uninitialized_variables
  var androidUrl;
  // ignore: prefer_typing_uninitialized_variables
  var iosUrl;

  @override
  void initState() {
    _getReferral();
    super.initState();
  }

  //get referral code
  _getReferral() async {
    var val = await getReferral();
    _package = await PackageInfo.fromPlatform();

    await getUrls();
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String androidPackage = '';
  String iOSBundle = '';
  var android = '';
  var ios = '';

  getUrls() async {
    var packageName = await FirebaseDatabase.instance
        .ref()
        .child('user_package_name')
        .get();
    if (packageName.value != null) {
      androidPackage = packageName.value.toString();
      android = 'https://play.google.com/store/apps/details?id=$androidPackage';
    }
    var bundleId =
    await FirebaseDatabase.instance.ref().child('user_bundle_id').get();
    if (bundleId.value != null) {
      iOSBundle = bundleId.value.toString();
      var response = await http
          .get(Uri.parse('http://itunes.apple.com/lookup?bundleId=$iOSBundle'));
      if (response.statusCode == 200) {
        if (jsonDecode(response.body)['results'].isNotEmpty) {
          ios = jsonDecode(response.body)['results'][0]['trackViewUrl'];
        }
      }
    }
  }

  //show toast for copied
  showToast() {
    setState(() {
      _showToast = true;
    });
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _showToast = false;
      });
    });
  }


  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Material(
      child: ValueListenableBuilder(
          valueListenable: valueNotifierHome.value,
          builder: (context, value, child) {
            return Directionality(
              textDirection: (languageDirection == 'rtl')
                  ? TextDirection.rtl
                  : TextDirection.ltr,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(media.width * 0.05),
                    height: media.height * 1,
                    width: media.width * 1,
                    color: page,
                    child: (myReferralCode.isNotEmpty)
                        ? Column(
                            children: [
                              Expanded(
                                child: Column(
                                  children: [
                                    SizedBox(
                                        height:
                                            MediaQuery.of(context).padding.top),
                                        Container(
                                          padding: EdgeInsets.fromLTRB(
                                              media.width * 0.05,
                                              media.width * 0.03,
                                              media.width * 0.05,
                                              media.width * 0.03),
                                          decoration: BoxDecoration(
                                            gradient: const LinearGradient(
                                              colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            ),
                                            borderRadius: BorderRadius.circular(15),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.blue.withOpacity(0.3),
                                                blurRadius: 10,
                                                offset: const Offset(0, 5),
                                              ),
                                            ],
                                          ),
                                          child: Row(
                                            children: [
                                              InkWell(
                                                  onTap: () {
                                                    Navigator.pop(context);
                                                  },
                                                  child: Container(
                                                    padding: const EdgeInsets.all(8),
                                                    decoration: BoxDecoration(
                                                      color: Colors.white.withOpacity(0.2),
                                                      shape: BoxShape.circle,
                                                    ),
                                                    child: const Icon(Icons.arrow_back_ios_new,
                                                        color: Colors.white, size: 20),
                                                  )),
                                              Expanded(
                                                child: MyText(
                                                  textAlign: TextAlign.center,
                                                  text: '',
                                                  size: media.width * twenty,
                                                  fontweight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              const SizedBox(width: 36),
                                            ],
                                          ),
                                        ),
                                    SizedBox(
                                      height: media.width * 0.05,
                                    ),
                                    Row(
                                      children: [
                                        MyText(
                                          text: t('text_referral')
                                              .toString()
                                              .toUpperCase(),
                                          size: media.width * sixteen,
                                          fontweight: FontWeight.w500,
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: media.width * 0.03,
                                    ),
                                    SizedBox(
                                      height: media.width * 0.1,
                                    ),
                                    Row(
                                      children: [
                                        MyText(
                                          text: myReferralCode[
                                              'referral_comission_string'],
                                          size: media.width * sixteen,
                                          textAlign: TextAlign.center,
                                          fontweight: FontWeight.w500,
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: media.width * 0.05,
                                    ),
                                    Container(
                                        width: media.width * 0.9,
                                        padding:
                                            EdgeInsets.all(media.width * 0.05),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(16),
                                          border: Border.all(
                                              color: Colors.blue.withOpacity(0.1), width: 1.5),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.grey.withOpacity(0.1),
                                              spreadRadius: 2,
                                              blurRadius: 8,
                                              offset: const Offset(0, 2),
                                            )
                                          ],
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            MyText(
                                              text: myReferralCode[
                                                  'refferal_code'],
                                              size: media.width * sixteen,
                                              fontweight: FontWeight.w500,
                                              color: textColor.withOpacity(0.5),
                                            ),
                                            InkWell(
                                                onTap: () {
                                                  setState(() {
                                                    Clipboard.setData(ClipboardData(
                                                        text: myReferralCode[
                                                            'refferal_code']));
                                                  });
                                                  showToast();
                                                },
                                                child: Icon(Icons.copy,
                                                    color: textColor))
                                          ],
                                        ))
                                  ],
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.only(
                                    top: media.width * 0.05,
                                    bottom: media.width * 0.05),
                                child: Button(
                                    onTap: () async {
                                      await Share.share(
                                        // ignore: prefer_interpolation_to_compose_strings
                                          t('text_invitation_1')
                                              .toString()
                                              .replaceAll(
                                              '55', _package.appName) +
                                              ' ' +
                                              myReferralCode['refferal_code'] +
                                              ' ' +
                                              t('text_invitation_2') +
                                              ' \n \n ' +
                                              android +
                                              '\n \n  ' +
                                              ios);
                                    },
                                    text: t('text_invite')),
                              )
                            ],
                          )
                        : Container(),
                  ),
                  (internet == false)
                      ? Positioned(
                          top: 0,
                          child: NoInternet(
                            onTap: () {
                              setState(() {
                                internetTrue();
                                _isLoading = true;
                                getReferral();
                              });
                            },
                          ))
                      : Container(),

                  //loader
                  (_isLoading == true)
                      ? const Positioned(top: 0, child: Loading())
                      : Container(),

                  //display toast
                  (_showToast == true)
                      ? Positioned(
                          bottom: media.height * 0.2,
                          child: Container(
                            padding: EdgeInsets.all(media.width * 0.025),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.transparent.withOpacity(0.6)),
                            child: MyText(
                              text: t('text_code_copied'),
                              size: media.width * twelve,
                              color: topBar,
                            ),
                          ))
                      : Container()
                ],
              ),
            );
          }),
    );
  }
}
