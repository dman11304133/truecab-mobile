import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../styles/styles.dart';
import '../../widgets/widgets.dart';
import '../loadingPage/loadingpage.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> with TickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _floatController;

  final List<Map<String, String>> _onboardingData = [
    {
      'title': 'Welcome to TrucabTT',
      'subtitle': 'Drive your way to success with the ultimate ride-sharing community. Your journey, your schedule, your earnings.',
      'image': 'assets/images/onboarding_drive_earn.png',
    },
    {
      'title': 'Smart Navigation',
      'subtitle': 'Optimized routes for TrucabTT drivers. We guide you through every turn to maximize your time and profit.',
      'image': 'assets/images/onboarding_navigation.png',
    },
    {
      'title': 'Join the Family',
      'subtitle': 'Secure payments and endless growth. TrucabTT: Driving the future of ride-sharing together.',
      'image': 'assets/images/onboarding_payments.png',
    },
  ];

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: splashColor,
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: CarouselSlider(
                  options: CarouselOptions(
                    height: media.height,
                    viewportFraction: 1.0,
                    autoPlay: true,
                    autoPlayInterval: const Duration(seconds: 5),
                    onPageChanged: (index, reason) {
                      setState(() {
                        _currentIndex = index;
                      });
                    },
                  ),
                  items: _onboardingData.map((data) {
                    return Builder(
                      builder: (BuildContext context) {
                        return Container(
                          width: media.width * 1,
                          padding: EdgeInsets.symmetric(horizontal: media.width * 0.08),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              AnimatedBuilder(
                                animation: _floatController,
                                builder: (context, child) {
                                  return Transform.translate(
                                    offset: Offset(0, 10 * _floatController.value),
                                    child: child,
                                  );
                                },
                                child: Container(
                                  height: media.height * 0.4,
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: AssetImage(data['image']!),
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: media.height * 0.05),
                              Text(
                                data['title']!,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.outfit(
                                  fontSize: media.width * 0.08,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ).copyWith(fontFamily: 'sans-serif'),
                              ),
                              SizedBox(height: media.height * 0.02),
                              Text(
                                data['subtitle']!,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.outfit(
                                  fontSize: media.width * 0.045,
                                  color: Colors.white.withOpacity(0.8),
                                  height: 1.5,
                                ).copyWith(fontFamily: 'sans-serif'),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  }).toList(),
                ),
              ),
              Container(
                padding: EdgeInsets.only(bottom: media.height * 0.05),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: _onboardingData.asMap().entries.map((entry) {
                        return Container(
                          width: _currentIndex == entry.key ? 24.0 : 8.0,
                          height: 8.0,
                          margin: const EdgeInsets.symmetric(horizontal: 4.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4.0),
                            color: Colors.white.withOpacity(
                              _currentIndex == entry.key ? 0.9 : 0.4,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: media.height * 0.04),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: media.width * 0.1),
                      child: Button(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const LoadingPage()),
                          );
                        },
                        text: 'Get Started',
                        color: Colors.white,
                        textcolor: splashColor,
                        fontweight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            right: 20,
            child: TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoadingPage()),
                );
              },
              child: Text(
                'Skip',
                style: GoogleFonts.outfit(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 16,
                ).copyWith(fontFamily: 'sans-serif'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
