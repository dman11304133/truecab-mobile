import 'package:flutter/material.dart';
import 'package:flutter_user/pages/NavigatorPages/makecomplaintdetails.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../functions/functions.dart';
import '../../styles/styles.dart';
import '../../translations/translation.dart';
import '../../widgets/widgets.dart';
import '../noInternet/noInternet.dart';

class MakeComplaint extends StatefulWidget {
  const MakeComplaint({super.key});

  @override
  State<MakeComplaint> createState() => _MakeComplaintState();
}

int complaintType = 0;

class _MakeComplaintState extends State<MakeComplaint> {
  bool isShimmer = true;

  @override
  void initState() {
    getData();
    shimmer = AnimationController.unbounded(vsync: MyTickerProvider())
      ..repeat(min: -0.5, max: 1.5, period: const Duration(milliseconds: 1000));
    super.initState();
  }

  getData() async {
    setState(() {
      complaintType = 0;
      // complaintDesc = '';
      generalComplaintList = [];
    });

    var res = await getGeneralComplaint("general");
    if (res == 'success') {
      setState(() {
        isShimmer = false;
        if (generalComplaintList.isNotEmpty) {
          complaintType = 0;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return PopScope(
      canPop: true,
      // onWillPop: () async {
      //   Navigator.pop(context, false);
      //   return true;
      // },
      child: Material(
        child: Directionality(
          textDirection: (languageDirection == 'rtl')
              ? TextDirection.rtl
              : TextDirection.ltr,
          child: Stack(
            children: [
              Container(
                height: media.height * 1,
                width: media.width * 1,
                color: page,
                padding: EdgeInsets.only(
                    left: media.width * 0.05, right: media.width * 0.05),
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.fromLTRB(
                          media.width * 0.05,
                          media.width * 0.00,
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
                    (generalComplaintList.isNotEmpty)
                        ? Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                MyText(
                                  text: t('text_choose_complaint'),
                                  size: media.width * sixteen,
                                  color: hintColor.withOpacity(0.5),
                                ),
                                SizedBox(
                                  height: media.width * 0.05,
                                ),
                                Column(
                                  children: generalComplaintList
                                      .asMap()
                                      .map((i, value) {
                                        return MapEntry(
                                          i,
                                          InkWell(
                                            onTap: () {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          MakeComplaintsDetails(
                                                            i: i,
                                                          )));
                                            },
                                            child: Container(
                                              width: media.width * 1,
                                              margin: EdgeInsets.only(
                                                  top: media.width * 0.02,
                                                  bottom: media.width * 0.02),
                                              padding: EdgeInsets.all(media.width * 0.04),
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                    color: Colors.blue.withOpacity(0.1), width: 1.5),
                                                borderRadius: BorderRadius.circular(16),
                                                color: Colors.white,
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
                                                  SizedBox(
                                                    width: media.width * 0.9,
                                                    child: Row(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .end,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        SizedBox(
                                                            // color: Colors.red,
                                                            width: media.width *
                                                                0.8,
                                                            child: Text(
                                                              generalComplaintList[
                                                                          i]
                                                                      ['title']
                                                                  .toString(),
                                                              maxLines: 1,
                                                              style: GoogleFonts.poppins(
                                                                  fontSize: media
                                                                          .width *
                                                                      sixteen,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  color:
                                                                      textColor),
                                                            )),
                                                        RotatedBox(
                                                            quarterTurns: 0,
                                                            child: Icon(
                                                              Icons
                                                                  .arrow_forward_ios_sharp,
                                                              color:
                                                                  loaderColor,
                                                            ))
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      })
                                      .values
                                      .toList(),
                                ),
                              ],
                            ),
                          )
                        : (isShimmer)
                            ? Expanded(
                                child: SingleChildScrollView(
                                  child: Column(
                                    children: [
                                      for (var i = 0; i <= 20; i++)
                                        AnimatedBuilder(
                                            animation: shimmer,
                                            builder: (context, widget) {
                                              return ShaderMask(
                                                blendMode: BlendMode.srcATop,
                                                shaderCallback: (bounds) {
                                                  return LinearGradient(
                                                          colors: shaderColor,
                                                          stops: shaderStops,
                                                          begin: shaderBegin,
                                                          end: shaderEnd,
                                                          tileMode:
                                                              TileMode.clamp,
                                                          transform:
                                                              SlidingGradientTransform(
                                                                  slidePercent:
                                                                      shimmer
                                                                          .value))
                                                      .createShader(bounds);
                                                },
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Container(
                                                      width: media.width * 0.75,
                                                      height: media.width * 0.1,
                                                      margin: EdgeInsets.only(
                                                          top: media.width *
                                                              0.02,
                                                          bottom: media.width *
                                                              0.02),
                                                      padding: EdgeInsets.only(
                                                          bottom: media.width *
                                                              0.05),
                                                      decoration: BoxDecoration(
                                                        border: Border(
                                                            bottom: BorderSide(
                                                                width: 1,
                                                                color: borderLines
                                                                    .withOpacity(
                                                                        0.5))),
                                                      ),
                                                      child: Container(
                                                        height:
                                                            media.width * 0.05,
                                                        width:
                                                            media.width * 0.75,
                                                        color: hintColor,
                                                      ),
                                                    ),
                                                    Icon(
                                                      Icons
                                                          .arrow_forward_ios_sharp,
                                                      color: loaderColor,
                                                    )
                                                  ],
                                                ),
                                              );
                                            })
                                    ],
                                  ),
                                ),
                              )
                            : Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
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
                                              image: AssetImage('assets/images/nodatafound.gif'),
                                              fit: BoxFit.contain)),
                                    ),
                                    SizedBox(
                                      width: media.width * 0.6,
                                      child: MyText(
                                          text: t('text_noDataFound'),
                                          textAlign: TextAlign.center,
                                          fontweight: FontWeight.w500,
                                          size: media.width * sixteen),
                                    ),
                                  ],
                                ),
                              ),
                  ],
                ),
              ),

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
        ),
      ),
    );
  }
}
