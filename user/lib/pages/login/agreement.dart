import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../functions/functions.dart';
import '../../styles/styles.dart';
import '../../translations/translation.dart';
import '../../widgets/widgets.dart';
import '../referralcode/referral_code.dart';
import 'login.dart';

class AggreementPage extends StatefulWidget {
  const AggreementPage({super.key});

  @override
  State<AggreementPage> createState() => _AggreementPageState();
}

class _AggreementPageState extends State<AggreementPage> {
  //navigate
  navigate() {
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const Referral()),
            (route) => false);
  }

  bool ischeck = false;
  // ignore: unused_field
  String _error = '';
  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;

    return Material(
      color: page,
      child: Directionality(
        textDirection: (languageDirection == 'rtl')
            ? TextDirection.rtl
            : TextDirection.ltr,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: media.height * 0.01,
            ),
            Container(
              padding: const EdgeInsets.only(top: 15, bottom: 15),
              child: MyText(
                text: t('text_accept_head'),
                size: media.width * twenty,
                fontweight: FontWeight.w500,
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            SizedBox(
                width: media.width * 0.9,
                child: RichText(
                  text: TextSpan(
                    // text: 'Hello ',
                    style: GoogleFonts.poppins(
                      color: textColor,
                      fontSize: media.width * fourteen,
                    ),
                    children: [
                      TextSpan(
                          text: t('text_agree_text1') + ' '),
                      TextSpan(
                          text: t('text_terms_of_use') + ' ',
                          style: GoogleFonts.poppins(
                            color: grad2,
                            fontWeight: FontWeight.w500,
                            fontSize: media.width * fourteen,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              openBrowser(
                                  url + 'terms');
                            }),
                      TextSpan(
                          text: t('text_agree_text2') + ' '),
                      TextSpan(
                          text: t('text_privacy'),
                          style: GoogleFonts.poppins(
                            color: grad2,
                            fontWeight: FontWeight.w500,
                            fontSize: media.width * fourteen,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              openBrowser(url + 'privacy');
                            }),
                    ],
                  ),
                )),
            Container(
              padding: const EdgeInsets.only(top: 15, bottom: 15),
              child: Row(
                children: [
                  MyText(
                      text: t('text_iagree'),
                      size: media.width * sixteen),
                  SizedBox(
                    width: media.width * 0.05,
                  ),
                  InkWell(
                    onTap: () {
                      if (ischeck == false) {
                        setState(() {
                          ischeck = true;
                        });
                      } else {
                        setState(() {
                          ischeck = false;
                        });
                      }
                    },
                    child: Container(
                      height: media.width * 0.05,
                      width: media.width * 0.05,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          border:
                          Border.all(color: buttonColor, width: 2)),
                      child: ischeck == false
                          ? null
                          : Icon(
                        Icons.done,
                        size: media.width * 0.04,
                        color: buttonColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            (_error != '')
                ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                MyText(
                  text: _error,
                  size: media.width * fourteen,
                  color: verifyDeclined,
                ),
              ],
            )
                : Container(),
            (ischeck == true)
                ? Padding(
              padding: const EdgeInsets.only(top: 15, bottom: 15),
              child: Button(
                  onTap: () async {
                    loginLoading = true;
                    _error = '';
                    valueNotifierLogin.incrementNotifier();
                    var register = await registerUser();
                    if (register == 'true') {
                      //referral page
                      navigate();
                    } else {
                      setState(() {
                        _error = register.toString();
                      });
                    }
                    loginLoading = false;
                    valueNotifierLogin.incrementNotifier();
                  },
                  text: t('text_next')),
            )
                : Padding(
              padding: const EdgeInsets.only(top: 15, bottom: 15),
              child: Button(
                  onTap: () async {},
                  text: t('text_next'),
                  color: Colors.grey,
                  textcolor: textColor.withOpacity(0.5)),
            )
          ],
        ),
      ),
    );
  }
}
