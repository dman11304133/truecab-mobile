import 'package:flutter/material.dart';
import 'package:flutter_user/pages/login/login.dart';
import 'package:flutter_user/translations/translation.dart';
import '../../functions/functions.dart';
import '../../styles/styles.dart';
import '../../widgets/widgets.dart';
import '../loadingPage/loading.dart';
import 'pickcontacts.dart';

class Sos extends StatefulWidget {
  const Sos({super.key});

  @override
  State<Sos> createState() => _SosState();
}

class _SosState extends State<Sos> {
  bool _isDeleting = false;
  bool _isLoading = false;
  String _deleteId = '';

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
    return PopScope(
      canPop: true,
      child: Material(
        child: ValueListenableBuilder(
            valueListenable: valueNotifierHome.value,
            builder: (context, value, child) {
              return Directionality(
                textDirection: (languageDirection == 'rtl')
                    ? TextDirection.rtl
                    : TextDirection.ltr,
                child: Stack(
                  children: [
                    Container(
                      padding: EdgeInsets.only(
                          left: media.width * 0.05, right: media.width * 0.05),
                      height: media.height * 1,
                      width: media.width * 1,
                      color: page,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                              height: MediaQuery.of(context).padding.top +
                                  media.width * 0.05),
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
                                    text: t('text_sos'),
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
                            text: t('text_add_trust_contact')
                                .toString()
                                .toUpperCase(),
                            size: media.width * twelve,
                            fontweight: FontWeight.w500,
                          ),

                          SizedBox(
                            height: media.width * 0.02,
                          ),
                          MyText(
                            text: t('text_trust_contact_4'),
                            size: media.width * twelve,
                            textAlign: TextAlign.start,
                            color: hintColor,
                          ),
                          SizedBox(
                            height: media.width * 0.05,
                          ),
                          Expanded(
                            child: SingleChildScrollView(
                              physics: const BouncingScrollPhysics(),
                              child: Column(
                                children: [
                                  SizedBox(
                                    height: media.width * 0.025,
                                  ),
                                  (sosData
                                          .where((element) =>
                                              element['user_type'] != 'admin')
                                          .isNotEmpty)
                                      ? Column(
                                          children: sosData
                                              .asMap()
                                              .map((i, value) {
                                                return MapEntry(
                                                    i,
                                                    (sosData[i]['user_type'] !=
                                                            'admin')
                                                        ? Container(
                                                            padding: EdgeInsets
                                                                .all(media
                                                                        .width *
                                                                    0.02),
                                                            decoration: BoxDecoration(
                                                                color: Colors.white,
                                                                borderRadius: BorderRadius.circular(16),
                                                                border: Border.all(
                                                                    color: Colors.blue.withOpacity(0.1),
                                                                    width: 1.5),
                                                                boxShadow: [
                                                                  BoxShadow(
                                                                    color: Colors.grey.withOpacity(0.1),
                                                                    spreadRadius: 2,
                                                                    blurRadius: 8,
                                                                    offset: const Offset(0, 2),
                                                                  )
                                                                ]),
                                                            margin: EdgeInsets.only(
                                                                bottom: media
                                                                        .width *
                                                                    0.02),
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                Container(
                                                                  height: media
                                                                          .width *
                                                                      0.13,
                                                                  width: media
                                                                          .width *
                                                                      0.13,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    shape: BoxShape
                                                                        .circle,
                                                                    color: hintColor
                                                                        .withOpacity(
                                                                            0.2),
                                                                  ),
                                                                  alignment:
                                                                      Alignment
                                                                          .center,
                                                                  child: MyText(
                                                                    text: sosData[i]
                                                                            [
                                                                            'name']
                                                                        .toString()
                                                                        .substring(
                                                                            0,
                                                                            1),
                                                                    size: media
                                                                            .width *
                                                                        twenty,
                                                                    fontweight:
                                                                        FontWeight
                                                                            .w500,
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                  width: media
                                                                          .width *
                                                                      0.05,
                                                                ),
                                                                Column(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    SizedBox(
                                                                      width: media
                                                                              .width *
                                                                          0.6,
                                                                      child:
                                                                          MyText(
                                                                        text: sosData[i]
                                                                            [
                                                                            'name'],
                                                                        size: media.width *
                                                                            sixteen,
                                                                        fontweight:
                                                                            FontWeight.w500,
                                                                      ),
                                                                    ),
                                                                    SizedBox(
                                                                      height: media
                                                                              .width *
                                                                          0.02,
                                                                    ),
                                                                    MyText(
                                                                      text: sosData[
                                                                              i]
                                                                          [
                                                                          'number'],
                                                                      size: media
                                                                              .width *
                                                                          twelve,
                                                                    ),
                                                                    SizedBox(
                                                                      height: media
                                                                              .width *
                                                                          0.01,
                                                                    ),
                                                                  ],
                                                                ),
                                                                InkWell(
                                                                    onTap: () {
                                                                      setState(
                                                                          () {
                                                                        _deleteId =
                                                                            sosData[i]['id'];
                                                                        _isDeleting =
                                                                            true;
                                                                      });
                                                                    },
                                                                    child: Icon(
                                                                        Icons
                                                                            .delete,
                                                                        color:
                                                                            textColor))
                                                              ],
                                                            ),
                                                          )
                                                        : Container());
                                              })
                                              .values
                                              .toList(),
                                        )
                                      : Column(
                                          children: [
                                            InkWell(
                                              onTap: () async {
                                                var nav = await Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            const PickContact(
                                                              from: '1',
                                                            )));
                                                if (nav) {
                                                  setState(() {});
                                                }
                                              },
                                              child: Container(
                                                padding: EdgeInsets.all(
                                                    media.width * 0.04),
                                                width: media.width * 0.9,
                                                decoration: BoxDecoration(
                                                                color: Colors.white,
                                                                borderRadius: BorderRadius.circular(16),
                                                                border: Border.all(
                                                                    color: Colors.blue.withOpacity(0.1),
                                                                    width: 1.5),
                                                                boxShadow: [
                                                                  BoxShadow(
                                                                    color: Colors.grey.withOpacity(0.1),
                                                                    spreadRadius: 2,
                                                                    blurRadius: 8,
                                                                    offset: const Offset(0, 2),
                                                                  )
                                                                ]),
                                                child: Row(
                                                  children: [
                                                    Container(
                                                      decoration: BoxDecoration(
                                                          color: online,
                                                          shape:
                                                              BoxShape.circle),
                                                      child: Icon(
                                                        Icons.add,
                                                        color: Colors.white,
                                                        size: media.width *
                                                            sixteen,
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      width: media.width * 0.05,
                                                    ),
                                                    MyText(
                                                        text: t('text_new_connection'),
                                                        color: textColor
                                                            .withOpacity(0.7),
                                                        size: media.width *
                                                            fourteen)
                                                  ],
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              height: media.width * 0.02,
                                            ),
                                            SizedBox(
                                              height: media.height * 0.6,
                                              child: Column(
                                                children: [
                                                  SizedBox(
                                                    height: media.width * 0.2,
                                                  ),
                                                  Container(
                                                    alignment: Alignment.center,
                                                    height: media.width * 0.6,
                                                    width: media.width * 0.6,
                                                    decoration: const BoxDecoration(
                                                        image: DecorationImage(
                                                            image: AssetImage('assets/images/sos.gif'),
                                                            fit: BoxFit
                                                                .contain)),
                                                  ),
                                                  SizedBox(
                                                    width: media.width * 0.9,
                                                    child: Column(
                                                      children: [
                                                        MyText(
                                                            text: languages[
                                                                    choosenLanguage]
                                                                [
                                                                'text_no_contact'],
                                                            textAlign: TextAlign
                                                                .center,
                                                            fontweight:
                                                                FontWeight.w500,
                                                            color: Colors.black,
                                                            size: media.width *
                                                                sixteen),
                                                        MyText(
                                                            text: languages[
                                                                    choosenLanguage]
                                                                [
                                                                'text_add_contact_safety'],
                                                            textAlign: TextAlign
                                                                .center,
                                                            fontweight:
                                                                FontWeight.w500,
                                                            color: Colors.grey,
                                                            size: media.width *
                                                                fourteen),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        )
                                ],
                              ),
                            ),
                          ),

                          //add sos button
                          (sosData
                                      .where((element) =>
                                          element['user_type'] != 'admin')
                                      .length <
                                  4)
                              ? Container(
                                  padding: EdgeInsets.only(
                                      top: media.width * 0.05,
                                      bottom: media.width * 0.05),
                                  child: Button(
                                      onTap: () async {
                                        var nav = await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    const PickContact(
                                                      from: '1',
                                                    )));
                                        if (nav) {
                                          setState(() {});
                                        }
                                      },
                                      text: t('text_add_contact')))
                              : Container()
                        ],
                      ),
                    ),

                    //delete sos
                    (_isDeleting == true)
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
                                                    _isDeleting = false;
                                                  });
                                                },
                                                child: Icon(
                                                    Icons.cancel_outlined,
                                                    color: textColor))),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.all(media.width * 0.05),
                                    width: media.width * 0.9,
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                            color:
                                                borderLines.withOpacity(0.5)),
                                        borderRadius: BorderRadius.circular(12),
                                        color: page),
                                    child: Column(
                                      children: [
                                        MyText(
                                          text: t('text_removeSos'),
                                          size: media.width * sixteen,
                                          fontweight: FontWeight.w500,
                                          textAlign: TextAlign.center,
                                        ),
                                        SizedBox(
                                          height: media.width * 0.05,
                                        ),
                                        Button(
                                            onTap: () async {
                                              setState(() {
                                                _isLoading = true;
                                              });

                                              var val =
                                                  await deleteSos(_deleteId);
                                              if (val == 'success') {
                                                setState(() {
                                                  _isDeleting = false;
                                                });
                                              } else if (val == 'logout') {
                                                navigateLogout();
                                              }
                                              setState(() {
                                                _isLoading = false;
                                              });
                                            },
                                            text: t('text_confirm'))
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                          )
                        : Container(),

                    //loader
                    (_isLoading == true)
                        ? const Positioned(top: 0, child: Loading())
                        : Container()
                  ],
                ),
              );
            }),
      ),
    );
  }
}
