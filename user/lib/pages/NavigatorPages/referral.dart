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
  var android = '';
  var ios = '';

  @override
  void initState() {
    _getReferral();
    super.initState();
  }

  _getReferral() async {
    try {
      var val = await getReferral();
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      _loadBackgroundData();
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  _loadBackgroundData() async {
    try {
      _package = await PackageInfo.fromPlatform();
      await getUrls();
      if (mounted) setState(() {});
    } catch (e) {
      debugPrint('Background data error: $e');
    }
  }

  getUrls() async {
    var pr = await FirebaseDatabase.instance.ref().child('user_package_name').get();
    if (pr.value != null) {
      android = 'https://play.google.com/store/apps/details?id=${pr.value}';
    }
    var bi = await FirebaseDatabase.instance.ref().child('user_bundle_id').get();
    if (bi.value != null) {
      var response = await http.get(Uri.parse('http://itunes.apple.com/lookup?bundleId=${bi.value}'));
      if (response.statusCode == 200 && jsonDecode(response.body)['results'].isNotEmpty) {
        ios = jsonDecode(response.body)['results'][0]['trackViewUrl'];
      }
    }
  }

  showToast() {
    setState(() => _showToast = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _showToast = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Directionality(
        textDirection: languageDirection == 'rtl' ? TextDirection.rtl : TextDirection.ltr,
        child: Stack(
          children: [
            Column(
              children: [
                // Premium Header
                Container(
                  padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 20, bottom: 30, left: 20, right: 20),
                  width: media.width,
                  decoration: BoxDecoration(
                    color: buttonColor,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          InkWell(
                            onTap: () => Navigator.pop(context),
                            child: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
                          ),
                          MyText(
                            text: t('text_referral'),
                            color: Colors.white,
                            size: media.width * 0.05,
                            fontweight: FontWeight.bold,
                          ),
                          const SizedBox(width: 20),
                        ],
                      ),
                      const SizedBox(height: 30),
                      const Icon(Icons.card_giftcard, size: 80, color: Colors.white),
                      const SizedBox(height: 20),
                      MyText(
                        text: t('text_invite_friends'),
                        color: Colors.white.withOpacity(0.9),
                        size: media.width * 0.045,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: _isLoading
                      ? Center(child: CircularProgressIndicator(color: buttonColor))
                      : myReferralCode.isEmpty
                          ? _buildEmptyState(media)
                          : SingleChildScrollView(
                              padding: const EdgeInsets.all(25),
                              child: Column(
                                children: [
                                  const SizedBox(height: 20),
                                  MyText(
                                    text: myReferralCode['referral_comission_string'] ?? '',
                                    size: media.width * 0.045,
                                    textAlign: TextAlign.center,
                                    fontweight: FontWeight.w600,
                                    color: textColor,
                                  ),
                                  const SizedBox(height: 40),
                                  
                                  // Referral Code Box
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[50],
                                      borderRadius: BorderRadius.circular(15),
                                      border: Border.all(color: Colors.grey[200]!, width: 1.5),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            MyText(
                                              text: t('text_referral_code').toUpperCase(),
                                              size: media.width * 0.03,
                                              color: greyText,
                                              fontweight: FontWeight.bold,
                                            ),
                                            const SizedBox(height: 5),
                                            MyText(
                                              text: myReferralCode['refferal_code'] ?? '',
                                              size: media.width * 0.055,
                                              fontweight: FontWeight.bold,
                                              color: textColor,
                                            ),
                                          ],
                                        ),
                                        InkWell(
                                          onTap: () {
                                            Clipboard.setData(ClipboardData(text: myReferralCode['refferal_code'] ?? ''));
                                            showToast();
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                              color: buttonColor.withOpacity(0.1),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(Icons.copy, color: buttonColor, size: 22),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  
                                ],
                              ),
                            ),
                ),

                // Bottom Button
                if (!_isLoading && myReferralCode.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(25),
                    child: Button(
                      onTap: () async {
                        if (_package == null) return;
                        await Share.share(
                          "${t('text_invitation_1').toString().replaceAll('55', _package.appName)} ${myReferralCode['refferal_code']} ${t('text_invitation_2')} \n\n Android: $android \n iOS: $ios",
                        );
                      },
                      text: t('text_invite'),
                    ),
                  ),
              ],
            ),

            // Toast Message
            if (_showToast)
              Positioned(
                bottom: 100,
                child: Container(
                  width: media.width,
                  alignment: Alignment.center,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: MyText(
                      text: t('text_code_copied'),
                      color: Colors.white,
                      size: media.width * 0.035,
                    ),
                  ),
                ),
              ),

            if (internet == false)
              NoInternet(onTap: () {
                internetTrue();
                _getReferral();
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(Size media) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.info_outline, size: 60, color: greyText),
          const SizedBox(height: 20),
          MyText(
            text: t('text_no_referral_data') ?? "No referral data available",
            size: media.width * 0.04,
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 50),
            child: Button(onTap: () => _getReferral(), text: "Retry"),
          )
        ],
      ),
    );
  }
}
