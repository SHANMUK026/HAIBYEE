import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../widgets/swipe_button.dart';
import 'login_screen.dart';
import 'onboarding_carousel_screen.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SizedBox(
        height: screenHeight,
        width: screenWidth,
        child: Stack(
          children: [
            // Background Gradient Section
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: screenHeight * 0.45,
              child: Container(
                clipBehavior: Clip.antiAlias,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment(-0.02, 0.98),
                    end: Alignment(1.02, 0.02),
                    colors: [Color(0xFFFAF5FF), Colors.white, Color(0xFFECFDF5)],
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      left: 32,
                      top: 48,
                      child: Container(
                        width: 64,
                        height: 64,
                        decoration: ShapeDecoration(
                          shape: RoundedRectangleBorder(
                            side: const BorderSide(width: 5, color: Color(0xFFD4AF35)),
                            borderRadius: BorderRadius.circular(9999),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 40,
                      top: 37,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: ShapeDecoration(
                          shape: RoundedRectangleBorder(
                            side: const BorderSide(width: 5, color: Color(0xFFD4AF35)),
                            borderRadius: BorderRadius.circular(9999),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: -24,
                      bottom: 20,
                      child: Container(
                        width: 96,
                        height: 96,
                        decoration: ShapeDecoration(
                          shape: RoundedRectangleBorder(
                            side: const BorderSide(width: 5, color: Color(0xFFECB613)),
                            borderRadius: BorderRadius.circular(9999),
                          ),
                        ),
                      ),
                    ),
                    Center(
                      child: Container(
                        width: 96,
                        height: 192,
                        decoration: ShapeDecoration(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            side: const BorderSide(width: 5, color: Color(0xFFECC813)),
                            borderRadius: BorderRadius.circular(9999),
                          ),
                          shadows: const [
                            BoxShadow(
                              color: Color(0x3F000000),
                              blurRadius: 50,
                              offset: Offset(0, 25),
                              spreadRadius: -12,
                            )
                          ],
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.insights_rounded,
                            size: 40,
                            color: Color(0xFFECC813),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Content Section
            Positioned(
              top: screenHeight * 0.45,
              left: 0,
              right: 0,
              bottom: 0,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        style: GoogleFonts.inter(
                          color: const Color(0xFF0F172A),
                          fontSize: 36,
                          fontWeight: FontWeight.w400,
                          height: 1.15,
                          letterSpacing: -0.90,
                        ),
                        children: const [
                          TextSpan(text: 'Easy ways to\n'),
                          TextSpan(
                            text: 'manage your\n',
                            style: TextStyle(fontWeight: FontWeight.w800),
                          ),
                          TextSpan(
                            text: 'finances ✨',
                            style: TextStyle(fontFamily: 'Noto Color Emoji'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      'Smart tools to track, save and grow\nyour wealth in one place.',
                      style: TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 14,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                        height: 1.63,
                      ),
                    ),
                    const Spacer(),
                    Center(
                      child: SwipeButton(
                        onSwipeCompleted: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const OnboardingCarouselScreen()),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 24,
                          height: 6,
                          decoration: ShapeDecoration(
                            color: const Color(0xFFECC813),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(9999),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 6,
                          height: 6,
                          decoration: ShapeDecoration(
                            color: const Color(0xFFE5E7EB),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(9999),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 6,
                          height: 6,
                          decoration: ShapeDecoration(
                            color: const Color(0xFFE5E7EB),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(9999),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 48),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
