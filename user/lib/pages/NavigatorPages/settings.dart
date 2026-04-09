import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../functions/functions.dart';
import '../../styles/styles.dart';
import '../../translations/translation.dart';
import '../../widgets/widgets.dart';
import '../loadingPage/loading.dart';
import '../login/login.dart';
import 'selectlanguage.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _isLoading = false;
  bool deleteAccount = false;
  navigateLogout() {
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const Login()),
          (route) => false);
    });
  }


  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return ValueListenableBuilder(
        valueListenable: valueNotifierHome.value,
        builder: (context, value, child) {
          return Material(
            child: Directionality(
              textDirection: (languageDirection == 'rtl')
                  ? TextDirection.rtl
                  : TextDirection.ltr,
              child: Stack(children: [
                Container(
                    padding: EdgeInsets.all(media.width * 0.05),
                    height: media.height * 1,
                    width: media.width * 1,
                    color: page,
                    child: Column(
                      children: [
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
                                    Navigator.pop(context, true);
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
                                  text: t('text_settings'),
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
                        SubMenu(
                          icon: Icons.language_outlined,
                          text: t('text_change_language'),
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const SelectLanguage()));
                          },
                        ),
                        SizedBox(
                          height: media.width * 0.02,
                        ),
                        userDetails['owner_id'] == null
                            ? SubMenu(
                                icon: Icons.delete_outline,
                                text: t('text_delete_account'),
                                onTap: () {
                                  setState(() {
                                    deleteAccount = true;
                                  });
                                },
                              )
                            : Container(),
                      ],
                    )),

                //delete account
                (deleteAccount == true)
                    ? Positioned(
                        top: 0,
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
                                    Container(
                                        height: media.height * 0.1,
                                        width: media.width * 0.1,
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                                color: borderLines
                                                    .withOpacity(0.5)),
                                            shape: BoxShape.circle,
                                            color: page),
                                        child: InkWell(
                                            onTap: () {
                                              setState(() {
                                                deleteAccount = false;
                                              });
                                            },
                                            child: Icon(
                                              Icons.cancel_outlined,
                                              color: textColor,
                                            ))),
                                  ],
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.all(media.width * 0.05),
                                width: media.width * 0.9,
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        color: borderLines.withOpacity(0.5)),
                                    borderRadius: BorderRadius.circular(12),
                                    color: page),
                                child: Column(
                                  children: [
                                    Text(
                                      (userDetails['is_deleted_at'] == null)
                                          ? t('text_delete_confirm')
                                          : userDetails['is_deleted_at']
                                              .toString(),
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.poppins(
                                          fontSize: media.width * sixteen,
                                          color: textColor,
                                          fontWeight: FontWeight.w500),
                                    ),
                                    SizedBox(
                                      height: media.width * 0.05,
                                    ),
                                    Button(
                                        onTap: () async {
                                          if (userDetails['is_deleted_at'] ==
                                              null) {
                                            setState(() {
                                              _isLoading = true;
                                            });
                                            var result = await userDelete();
                                            if (result == 'success') {
                                              await getUserDetails();
                                              deleteAccount = false;
                                            } else if (result == 'logout') {
                                              navigateLogout();
                                            } else {
                                              deleteAccount = true;
                                            }
                                            setState(() {
                                              _isLoading = false;
                                            });
                                          } else {
                                            setState(() {
                                              deleteAccount = false;
                                            });
                                          }
                                        },
                                        text: t('text_confirm'))
                                  ],
                                ),
                              )
                            ],
                          ),
                        ))
                    : Container(),
                //loader
                (_isLoading == true)
                    ? const Positioned(top: 0, child: Loading())
                    : Container()
              ]),
            ),
          );
        });
  }
}
