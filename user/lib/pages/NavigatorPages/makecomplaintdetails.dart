import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../functions/functions.dart';
import '../../styles/styles.dart';
import '../../translations/translation.dart';
import '../../widgets/widgets.dart';
import '../loadingPage/loading.dart';
import '../noInternet/nointernet.dart';

class MakeComplaintsDetails extends StatefulWidget {
  final int i;
  const MakeComplaintsDetails({super.key, required this.i});

  @override
  State<MakeComplaintsDetails> createState() => _MakeComplaintsDetailsState();
}

class _MakeComplaintsDetailsState extends State<MakeComplaintsDetails> {
  String complaintDesc = '';
  String _error = '';
  bool _success = false;
  TextEditingController complaintText = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;

    return Material(
      child: Directionality(
          textDirection: (languageDirection == 'rtl')
              ? TextDirection.rtl
              : TextDirection.ltr,
          child: Scaffold(
            body: Stack(
              children: [
                Container(
                  height: media.height * 1,
                  width: media.width * 1,
                  color: page,
                  padding: EdgeInsets.only(
                      left: media.width * 0.05, right: media.width * 0.05),
                  child: Column(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
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
                                        Navigator.pop(context, false);
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
                                      text: t('text_make_complaints'),
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
                            MyText(
                              text: generalComplaintList[widget.i]['title'],
                              size: media.width * sixteen,
                            ),
                            SizedBox(
                              height: media.width * 0.05,
                            ),
                            Container(
                              width: media.width * 0.9,
                              padding: EdgeInsets.all(media.width * 0.05),
                              decoration: BoxDecoration(
                                  color: Colors.white,
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
                                  borderRadius: BorderRadius.circular(16)),
                              child: TextField(
                                controller: complaintText,
                                minLines: 5,
                                maxLines: 5,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintStyle: GoogleFonts.poppins(
                                    color: textColor.withOpacity(0.4),
                                    fontSize: media.width * fourteen,
                                  ),
                                  hintText: t('text_complaint_2') +
                                      ' (' +
                                      t('text_complaint_3') +
                                      ')',
                                ),
                                onChanged: (val) {
                                  complaintDesc = val;
                                  if (val.length >= 10 && _error != '') {
                                    setState(() {
                                      _error = '';
                                    });
                                  }
                                },
                                style: GoogleFonts.poppins(color: textColor),
                              ),
                            ),
                            if (_error != '')
                              Container(
                                width: media.width * 0.8,
                                padding: EdgeInsets.only(
                                    top: media.width * 0.025,
                                    bottom: media.width * 0.025),
                                child: MyText(
                                  text: _error,
                                  size: media.width * fourteen,
                                  color: Colors.red,
                                ),
                              ),
                          ],
                        ),
                      ),
                      Button(
                          onTap: () async {
                            if (complaintText.text.length >= 10) {
                              setState(() {
                                _isLoading = true;
                              });
                              dynamic result;

                              result =
                                  await makeGeneralComplaint(complaintDesc, widget.i);

                              setState(() {
                                if (result == 'success') {
                                  _success = true;
                                }

                                _isLoading = false;
                              });
                            } else {
                              setState(() {
                                _error = t('text_complaint_text_error');
                              });
                            }
                          },
                          text: t('text_submit')),
                      SizedBox(
                        height: media.width * 0.05,
                      ),
                    ],
                  ),
                ),

                (_success == true)
                    ? Positioned(
                        child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        height: media.height * 1,
                        width: media.width * 1,
                        color: Colors.transparent.withOpacity(0.6),
                        child: Column(
                          children: [
                            SizedBox(
                              height: media.height * 0.1,
                            ),
                            Container(
                              padding: EdgeInsets.all(media.width * 0.03),
                              height: media.width * 0.12,
                              width: media.width * 1,
                              color: topBar,
                              child: Row(
                                children: [
                                  InkWell(
                                    onTap: () {
                                      Navigator.pop(context, true);
                                    },
                                    child: MyText(
                                      text: t('text_cancel'),
                                      size: media.width * fourteen,
                                      color: const Color(0xffFF0000),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Container(
                                  width: media.width * 1,
                                  padding: EdgeInsets.all(media.width * 0.04),
                                  color: page,
                                  child: Column(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          children: [
                                            SizedBox(
                                              height: media.width * 0.3,
                                            ),
                                            Container(
                                              alignment: Alignment.center,
                                              height: media.width * 0.13,
                                              width: media.width * 0.13,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: const Color(0xffFF0000),
                                                gradient: LinearGradient(
                                                    colors: <Color>[
                                                      const Color(0xffFF0000),
                                                      Colors.black
                                                          .withOpacity(0.2),
                                                    ],
                                                    begin: FractionalOffset
                                                        .topCenter,
                                                    end: FractionalOffset
                                                        .bottomCenter),
                                              ),
                                              child: Icon(
                                                Icons.done,
                                                size: media.width * 0.09,
                                                color: Colors.white,
                                              ),
                                            ),
                                            SizedBox(
                                              height: media.width * 0.03,
                                            ),
                                            MyText(
                                              text: t('text_thanks_let'),
                                              size: media.width * sixteen,
                                              fontweight: FontWeight.w500,
                                            ),
                                            SizedBox(
                                              height: media.width * 0.03,
                                            ),
                                          ],
                                        ),
                                      ),
                                      Button(
                                          // color: textColor,
                                          textcolor: page,
                                          onTap: () async {
                                            _success = false;
                                            Navigator.pop(context, true);
                                          },
                                          text: t('text_continue'))
                                    ],
                                  )),
                            )
                          ],
                        ),
                      ))
                    : Container(),

                //loader
                (_isLoading == true)
                    ? const Positioned(top: 0, child: Loading())
                    : Container(),

                //no internet
                (internet == false)
                    ? Positioned(
                        top: 0,
                        child: NoInternet(
                          onTap: () {
                            internetTrue();
                          },
                        ))
                    : Container(),
              ],
            ),
          )),
    );
  }
}
