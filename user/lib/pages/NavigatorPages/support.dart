import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../functions/functions.dart';
import '../../styles/styles.dart';
import '../../translations/translation.dart';
import '../../widgets/widgets.dart';
import 'adminchatpage.dart';
import 'faq.dart';

class SupportPage extends StatefulWidget {
  const SupportPage({super.key});

  @override
  State<SupportPage> createState() => _SupportPageState();
}

class _SupportPageState extends State<SupportPage> {
  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
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
                                text: t('text_support'),
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
                      //Admin chat

                      ValueListenableBuilder(
                          valueListenable: valueNotifierChat.value,
                          builder: (context, value, child) {
                            return InkWell(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const AdminChatPage()));
                              },
                              child: Container(
                                padding: EdgeInsets.all(media.width * 0.04),
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
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.chat,
                                            size: media.width * 0.07,
                                            color: textColor),
                                        SizedBox(
                                          width: media.width * 0.025,
                                        ),
                                        Expanded(
                                          child: MyText(
                                            text: t('text_chat_us'),
                                            overflow: TextOverflow.ellipsis,
                                            size: media.width * sixteen,
                                            color: textColor,
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            (unSeenChatCount == '0')
                                                ? Container()
                                                : Container(
                                                    height: 20,
                                                    width: 20,
                                                    alignment: Alignment.center,
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      color: buttonColor,
                                                    ),
                                                    child: Text(
                                                      unSeenChatCount,
                                                      style:
                                                          GoogleFonts.poppins(
                                                              fontSize:
                                                                  media.width *
                                                                      fourteen,
                                                              color:
                                                                  buttonText),
                                                    ),
                                                  ),
                                            Icon(
                                              Icons.arrow_right_rounded,
                                              size: media.width * 0.05,
                                              color: textColor,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                      SizedBox(
                        height: media.width * 0.02,
                      ),
                      //faq
                      SubMenu(
                        icon: Icons.warning_amber,
                        text: t('text_faq'),
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const Faq()));
                        },
                      ),
                      SizedBox(
                        height: media.width * 0.02,
                      ),
                      //privacy policy

                      SubMenu(
                        onTap: () {
                          openBrowser(url + 'privacy');
                        },
                        text: t('text_privacy'),
                        icon: Icons.privacy_tip_outlined,
                      ),
                    ],
                  )),
            ])));
  }
}
