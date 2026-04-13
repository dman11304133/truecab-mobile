import 'dart:async';
import 'dart:convert';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_driver/pages/onTripPage/map_page.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../styles/styles.dart';
import '../../functions/functions.dart';
import 'package:http/http.dart' as http;
import '../../widgets/widgets.dart';
import '../language/languages.dart';
import '../login/landingpage.dart';
import '../login/login.dart';
import '../login/requiredinformation.dart';
import '../noInternet/nointernet.dart';
import '../onTripPage/rides.dart';
import 'loading.dart';

class LoadingPage extends StatefulWidget {
  const LoadingPage({super.key});

  @override
  State<LoadingPage> createState() => _LoadingPageState();
}

dynamic package;

class _LoadingPageState extends State<LoadingPage> {
  String dot = '.';
  bool updateAvailable = false;
  dynamic _package;
  dynamic _version;
  bool _error = false;
  bool _isLoading = false;

  var demopage = TextEditingController();

  //navigate
  navigate() {
    if (userDetails['uploaded_document'] == true &&
        userDetails['approve'] == true) {
      //status approved
      if (userDetails['role'] != 'owner' &&
          userDetails['enable_bidding'] == true) {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const RidePage()),
                (route) => false);
      } else if (userDetails['role'] != 'owner' &&
          userDetails['enable_bidding'] == false) {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const Maps()),
                (route) => false);
      } else {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const Maps()),
                (route) => false);
      }
    } else {
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => const RequiredInformation()));
    }
  }

  @override
  void initState() {
    getLanguageDone();
    getOwnermodule();
    getLandingImages();
    super.initState();
  }

  getData() async {
    for (var i = 0; _error == true; i++) {
      await getLanguageDone();
    }
  }

//get language json and data saved in local (bearer token , choosen language) and find users current status
  getLanguageDone() async {
    _package = await PackageInfo.fromPlatform();
    try {
      if (platform == TargetPlatform.android) {
        _version = await FirebaseDatabase.instance
            .ref()
            .child('driver_android_version')
            .get();
      } else {
        _version = await FirebaseDatabase.instance
            .ref()
            .child('driver_ios_version')
            .get();
      }
      _error = false;
      if (_version.value != null) {
        var version = _version.value.toString().split('.');
        var package = _package.version.toString().split('.');

        for (var i = 0; i < version.length || i < package.length; i++) {
          if (i < version.length && i < package.length) {
            if (int.parse(package[i]) < int.parse(version[i])) {
              setState(() {
                updateAvailable = true;
              });
              break;
            } else if (int.parse(package[i]) > int.parse(version[i])) {
              setState(() {
                updateAvailable = false;
              });
              break;
            }
          } else if (i >= version.length && i < package.length) {
            setState(() {
              updateAvailable = false;
            });
            break;
          } else if (i < version.length && i >= package.length) {
            setState(() {
              updateAvailable = true;
            });
            break;
          }
        }
      }

      if (updateAvailable == false) {
        await getDetailsOfDevice();
        debugPrint('LoadingPage: internet=$internet');
        if (internet == true) {
          var val = await getLocalData();
          debugPrint('LoadingPage: getLocalData=$val, ownermodule=$ownermodule, choosenLanguage=$choosenLanguage');

          //if user is login and check waiting for approval status and send accordingly
          if (val == '3') {
            debugPrint('LoadingPage: navigating to main app (val=3)');
            navigate();
          } else if (choosenLanguage == '') {
            // ignore: use_build_context_synchronously
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => const Languages()));
          } else if (val == '2') {
            Future.delayed(const Duration(seconds: 2), () {
              debugPrint('LoadingPage: val=2 delayed, ownermodule=$ownermodule, driverReq.isEmpty=${driverReq.isEmpty}');
              if (driverReq.isEmpty) {
                debugPrint('LoadingPage: -> LandingPage (partner/driver selection)');
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const LandingPage()));
              } else {
                Future.delayed(const Duration(seconds: 2), () {
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const Maps()),
                          (route) => false);
                });
              }
            });
          } else {
            Future.delayed(const Duration(seconds: 2), () {
              //choose language page
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => const Languages()));
            });
          }
          setState(() {});
        }
      }
    } catch (e) {
      if (internet == true) {
        if (_error == false) {
          setState(() {
            _error = true;
          });
          getData();
        }
      } else {
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;

    return Material(
      child: Scaffold(
        body: Stack(
          children: [
            Container(
              height: media.height * 1,
              width: media.width * 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xff309700), // Primary Driver Green
                    const Color(0xff123e00), // Deep Forest Green
                  ],
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ShowUp(
                    delay: 300,
                    child: Container(
                      padding: EdgeInsets.all(media.width * 0.05),
                      width: media.width * 0.45,
                      height: media.width * 0.45,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 30,
                                spreadRadius: 2),
                            BoxShadow(
                                color: Colors.white.withOpacity(0.1),
                                blurRadius: 15,
                                spreadRadius: -5),
                          ]),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/images/logo.png',
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) =>
                              Icon(Icons.taxi_alert,
                                  size: media.width * 0.15, color: buttonColor),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: media.height * 0.06),
                  ShowUp(
                    delay: 600,
                    child: MyText(
                      text: "DRIVERS",
                      size: media.width * 0.06,
                      fontweight: FontWeight.bold,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),

            //update available

            (updateAvailable == true)
                ? Positioned(
                top: 0,
                child: Container(
                  height: media.height * 1,
                  width: media.width * 1,
                  color: Colors.transparent.withOpacity(0.6),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                          width: media.width * 0.9,
                          padding: EdgeInsets.all(media.width * 0.05),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: page,
                          ),
                          child: Column(
                            children: [
                              SizedBox(
                                  width: media.width * 0.8,
                                  child: MyText(
                                    text:
                                    'New version of this app is available in store, please update the app for continue using',
                                    size: media.width * sixteen,
                                    fontweight: FontWeight.w600,
                                  )),
                              SizedBox(
                                height: media.width * 0.05,
                              ),
                              Button(
                                  onTap: () async {
                                    if (platform ==
                                        TargetPlatform.android) {
                                      openBrowser(
                                          'https://play.google.com/store/apps/details?id=${_package.packageName}');
                                    } else {
                                      setState(() {
                                        _isLoading = true;
                                      });
                                      var response = await http.get(Uri.parse(
                                          'http://itunes.apple.com/lookup?bundleId=${_package.packageName}'));
                                      if (response.statusCode == 200) {
                                        openBrowser(jsonDecode(
                                            response.body)['results'][0]
                                        ['trackViewUrl']);
                                      }

                                      setState(() {
                                        _isLoading = false;
                                      });
                                    }
                                  },
                                  text: 'Update')
                            ],
                          ))
                    ],
                  ),
                ))
                : Container(),
            //internet is not connected
            (internet == false)
                ? Positioned(
                top: 0,
                child: NoInternet(
                  onTap: () {
                    //try again
                    setState(() {
                      internetTrue();
                      getLanguageDone();
                    });
                  },
                ))
                : Container(),

            //loader
            (_isLoading == true && internet == true)
                ? const Positioned(top: 0, child: Loading())
                : Container(),
          ],
        ),
      ),
    );
  }
}
