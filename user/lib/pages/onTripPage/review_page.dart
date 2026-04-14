import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../functions/functions.dart';
import '../../styles/styles.dart';
import '../../translations/translation.dart';
import '../../widgets/widgets.dart';
import '../loadingPage/loading.dart';
import '../login/login.dart';
import 'map_page.dart';
import '../../functions/ride_state.dart';

class Review extends StatefulWidget {
  const Review({super.key});

  @override
  State<Review> createState() => _ReviewState();
}

double review = 0.0;
String feedback = '';

class _ReviewState extends State<Review> {
  bool _loading = false;

  @override
  void initState() {
    debugPrint('📝 [REVIEW] initState called. userRequestData count: ${userRequestData.length}, snapshot count: ${completedRideSnapshot.length}');
    if (userRequestData.isEmpty && completedRideSnapshot.isNotEmpty) {
      userRequestData = Map.from(completedRideSnapshot);
      debugPrint('📝 [REVIEW] Restored userRequestData from completedRideSnapshot.');
    }
    review = 0.0;
    super.initState();
  }

  navigateLogout() {
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const Login()),
        (route) => false);
  }

  //navigate
  navigate() {
    dropStopList.clear();
    addressList.clear();
    completedRideSnapshot.clear(); // Clear the snapshot since the flow is completely done
    userRequestData.clear();
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const Maps()),
        (route) => false);
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
                children: [
                  if (userRequestData.isNotEmpty)
                    Container(
                      height: media.height * 1,
                      width: media.width * 1,
                      padding: EdgeInsets.all(media.width * 0.05),
                      color: page,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: SingleChildScrollView(
                              physics: const BouncingScrollPhysics(),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    height: media.width * 0.15,
                                  ),
                                  MyText(
                                    text: t('text_rate_your_trip') ?? 'Rate your trip',
                                    size: media.width * twenty,
                                    fontweight: FontWeight.w600,
                                    color: textColor,
                                  ),
                                  SizedBox(
                                    height: media.height * 0.04,
                                  ),
                                  (userRequestData.isNotEmpty)
                                      ? Container(
                                          height: media.width * 0.38,
                                          width: media.width * 0.38,
                                          decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              border: Border.all(color: Colors.white, width: 4),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black.withOpacity(0.15),
                                                  blurRadius: 20,
                                                  spreadRadius: 2,
                                                  offset: const Offset(0, 10),
                                                )
                                              ],
                                              image: DecorationImage(
                                                  image: NetworkImage(
                                                      userRequestData['driverDetail']['data']['profile_picture']),
                                                  fit: BoxFit.cover)),
                                        )
                                      : Container(),
                                  SizedBox(
                                    height: media.height * 0.03,
                                  ),
                                  MyText(
                                    text: t('text_how_was_ride') ?? 'How was your ride with ${(userRequestData.isNotEmpty) ? userRequestData['driverDetail']['data']['name'] : ''}?',
                                    size: media.width * sixteen,
                                    color: textColor.withOpacity(0.8),
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(
                                    height: media.height * 0.04,
                                  ),

                                  //stars
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: List.generate(5, (index) {
                                      int starIndex = index + 1;
                                      return GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            review = starIndex.toDouble();
                                          });
                                        },
                                        behavior: HitTestBehavior.opaque,
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(horizontal: media.width * 0.015),
                                          child: AnimatedScale(
                                            scale: review >= starIndex ? 1.15 : 1.0,
                                            duration: const Duration(milliseconds: 200),
                                            child: Icon(
                                              review >= starIndex ? Icons.star_rounded : Icons.star_outline_rounded,
                                              size: media.width * 0.14,
                                              color: (review >= starIndex) ? starColor : Colors.grey.withOpacity(0.4),
                                              shadows: review >= starIndex ? [
                                                Shadow(color: starColor.withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 4))
                                              ] : null,
                                            ),
                                          ),
                                        ),
                                      );
                                    }),
                                  ),
                                  SizedBox(
                                    height: media.height * 0.05,
                                  ),

                                  //feedback text
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: media.width * 0.04, vertical: media.width * 0.02),
                                    width: media.width * 0.9,
                                    decoration: BoxDecoration(
                                        color: Colors.grey.withOpacity(0.05),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                            width: 1.5,
                                            color: Colors.grey.withOpacity(0.15))),
                                    child: TextField(
                                      maxLines: 4,
                                      onChanged: (val) {
                                        setState(() {
                                          feedback = val;
                                        });
                                      },
                                      style: GoogleFonts.poppins(color: textColor, fontSize: media.width * fourteen),
                                      decoration: InputDecoration(
                                          hintText: t('text_feedback') ?? 'Leave some feedback (optional)...',
                                          hintStyle: GoogleFonts.poppins(
                                              color: Colors.grey.withOpacity(0.5), fontSize: media.width * fourteen),
                                          border: InputBorder.none),
                                    ),
                                  ),
                                  SizedBox(
                                    height: media.height * 0.05,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.only(top: media.width * 0.05),
                            child: Button(
                              onTap: () async {
                                if (review >= 1.0) {
                                  setState(() {
                                    _loading = true;
                                  });
                                  var result = await userRating();
                                  if (result == true) {
                                    navigate();
                                    _loading = false;
                                  } else if (result == 'logout') {
                                    navigateLogout();
                                  } else {
                                    setState(() {
                                      _loading = false;
                                    });
                                  }
                                }
                              },
                              text: t('text_submit') ?? 'Submit Review',
                              color: (review >= 1.0)
                                  ? buttonColor
                                  : Colors.grey.withOpacity(0.5),
                              textcolor: (review >= 1.0) ? Colors.white : Colors.white70,
                            ),
                          )
                        ],
                      ),
                    ),
                  //loader
                  (_loading == true)
                      ? const Positioned(child: Loading())
                      : Container()
                ],
              ),
            );
          }),
    );
  }
}
