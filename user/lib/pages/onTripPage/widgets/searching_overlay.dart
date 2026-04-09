import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import '../../../styles/styles.dart';
import '../../../translations/translation.dart';
import '../../../widgets/widgets.dart';

class SearchingOverlay extends StatefulWidget {
  final Map userRequestData;
  final Size media;
  final bool noDriverFound;
  final String choosenLanguage;
  final TextEditingController updateAmount;
  final AudioPlayer audioPlayers;
  final String audio;
  final Function(List) onDriversUpdated;
  final VoidCallback onCancel;

  const SearchingOverlay({
    super.key,
    required this.userRequestData,
    required this.media,
    required this.noDriverFound,
    required this.choosenLanguage,
    required this.updateAmount,
    required this.audioPlayers,
    required this.audio,
    required this.onDriversUpdated,
    required this.onCancel,
  });

  @override
  State<SearchingOverlay> createState() => _SearchingOverlayState();
}

class _SearchingOverlayState extends State<SearchingOverlay> {
  @override
  Widget build(BuildContext context) {
    if (widget.noDriverFound == true || widget.userRequestData.isEmpty || widget.userRequestData['accepted_at'] != null) {
      return Container();
    }

    return Positioned(
      bottom: 0,
      child: StreamBuilder<Object>(
          stream: FirebaseDatabase.instance
              .ref()
              .child('bid-meta/${widget.userRequestData["id"]}')
              .onValue
              .asBroadcastStream(),
          builder: (context, AsyncSnapshot event) {
            List driverList = [];
            Map rideList = {};

            if (event.data != null) {
              DataSnapshot snapshots = event.data!.snapshot;
              if (snapshots.value != null) {
                rideList = jsonDecode(jsonEncode(snapshots.value));
                if (widget.updateAmount.text.isEmpty) {
                  widget.updateAmount.text = rideList['price'].toString();
                }
                if (rideList['drivers'] != null) {
                  Map driver = rideList['drivers'];
                  driver.forEach((key, value) {
                    if (driver[key]['is_rejected'] == 'none') {
                      driverList.add(value);
                      if (driverList.isNotEmpty) {
                        widget.audioPlayers.play(AssetSource(widget.audio));
                      }
                    }
                  });
                  // Update drivers list via callback
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    widget.onDriversUpdated(driverList);
                  });
                }
              }
            }

            return Container(
              width: widget.media.width * 1,
              height: widget.media.height * 1,
              alignment: Alignment.bottomCenter,
              child: Container(
                width: widget.media.width * 1,
                height: (driverList.isNotEmpty) ? widget.media.height * 1 : widget.media.width * 0.72,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12)),
                  color: page,
                ),
                padding: (driverList.isNotEmpty)
                    ? EdgeInsets.fromLTRB(0, widget.media.width * 0.1 + MediaQuery.of(context).padding.top, 0, 0)
                    : EdgeInsets.fromLTRB(0, widget.media.width * 0.05, 0, widget.media.width * 0.05),
                child: Column(
                  children: [
                    Container(
                      width: widget.media.width * 0.9,
                      alignment: Alignment.centerRight,
                      child: InkWell(
                        onTap: widget.onCancel,
                        child: Text(
                          languages[widget.choosenLanguage]['text_cancel'],
                          style: GoogleFonts.poppins(
                              fontSize: widget.media.width * sixteen,
                              color: Colors.red),
                        ),
                      ),
                    ),
                    SizedBox(height: widget.media.width * 0.02),
                    Text(
                      languages[widget.choosenLanguage]['text_findingdriver'],
                      style: GoogleFonts.poppins(
                          fontSize: widget.media.width * sixteen,
                          color: textColor,
                          fontWeight: FontWeight.w500),
                    ),
                    (driverList.isNotEmpty)
                        ? Expanded(
                            child: Container(
                              width: widget.media.width * 1,
                              padding: EdgeInsets.fromLTRB(widget.media.width * 0.05, widget.media.width * 0.05, widget.media.width * 0.05, 0),
                              child: SingleChildScrollView(
                                child: Column(
                                  children: driverList.map((e) {
                                    return Container(
                                      width: widget.media.width * 0.9,
                                      padding: EdgeInsets.all(widget.media.width * 0.025),
                                      margin: EdgeInsets.only(bottom: widget.media.width * 0.025),
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(12),
                                          color: page,
                                          boxShadow: [
                                            BoxShadow(
                                                blurRadius: 2,
                                                color: Colors.black.withOpacity(0.2),
                                                spreadRadius: 2)
                                          ]),
                                      child: Row(
                                        children: [
                                          Container(
                                            height: widget.media.width * 0.12,
                                            width: widget.media.width * 0.12,
                                            decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                image: DecorationImage(
                                                    image: NetworkImage(e['profile_pic']),
                                                    fit: BoxFit.cover)),
                                          ),
                                          SizedBox(width: widget.media.width * 0.025),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  e['name'],
                                                  style: GoogleFonts.poppins(
                                                      fontSize: widget.media.width * fourteen,
                                                      fontWeight: FontWeight.w600,
                                                      color: textColor),
                                                ),
                                                Row(
                                                  children: [
                                                    Icon(Icons.star, color: Colors.orange, size: widget.media.width * 0.04),
                                                    Text(
                                                      e['rating'].toString(),
                                                      style: GoogleFonts.poppins(
                                                          fontSize: widget.media.width * twelve,
                                                          color: textColor),
                                                    )
                                                  ],
                                                )
                                              ],
                                            ),
                                          ),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.end,
                                            children: [
                                              Text(
                                                '${widget.userRequestData['requested_currency_symbol']}${e['offered_ride_fare']}',
                                                style: GoogleFonts.poppins(
                                                    fontSize: widget.media.width * fourteen,
                                                    fontWeight: FontWeight.w600,
                                                    color: textColor),
                                              ),
                                              SizedBox(height: widget.media.width * 0.01),
                                              InkWell(
                                                onTap: () {
                                                  // Acceptance handled by callback or firebase
                                                },
                                                child: Container(
                                                  padding: EdgeInsets.symmetric(horizontal: widget.media.width * 0.03, vertical: widget.media.width * 0.01),
                                                  decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.circular(20),
                                                      color: theme),
                                                  child: Text(
                                                    languages[widget.choosenLanguage]['text_accept'],
                                                    style: GoogleFonts.poppins(
                                                        fontSize: widget.media.width * twelve,
                                                        color: page,
                                                        fontWeight: FontWeight.w600),
                                                  ),
                                                ),
                                              )
                                            ],
                                          )
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                          )
                        : Container(
                            height: widget.media.width * 0.5,
                            alignment: Alignment.center,
                            child: const CircularProgressIndicator(),
                          )
                  ],
                ),
              ),
            );
          }),
    );
  }
}
