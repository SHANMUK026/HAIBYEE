import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../widgets/swipe_button.dart';
import 'login_screen.dart';
import 'onboarding_carousel_screen.dart';
import '../../theme/app_colors.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
        height: screenHeight,
        width: screenWidth,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment(-0.02, 0.98),
            end: Alignment(1.02, 0.02),
            colors: [Color(0xFFFAF5FF), Colors.white, Color(0xFFECFDF5)],
          ),
        ),
        child: Stack(
          children: [
            // Precision Background Rings from Figma Reference
            Positioned(
              left: -screenWidth * 0.1,
              top: -screenHeight * 0.05,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    width: 12,
                    color: AppColors.primaryBrownGold.withOpacity(0.15),
                  ),
                ),
              ),
            ),
            Positioned(
              right: screenWidth * 0.1,
              top: screenHeight * 0.04,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    width: 8,
                    color: AppColors.primaryBrownGold.withOpacity(0.15),
                  ),
                ),
              ),
            ),
            Positioned(
              left: -screenWidth * 0.2,
              top: screenHeight * 0.28,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    width: 10,
                    color: AppColors.primaryBrownGold.withOpacity(0.15),
                  ),
                ),
              ),
            ),

            // Top Logo Area Fix - 1:1 Figma Match
            Positioned(
              top: screenHeight * 0.1,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      // Concentric halo rings
                      Container(
                        width: 280,
                        height: 280,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            width: 0.5,
                            color: AppColors.primaryBrownGold.withOpacity(0.1),
                          ),
                        ),
                      ),
                      Container(
                        width: 220,
                        height: 220,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            width: 1,
                            color: AppColors.primaryBrownGold.withOpacity(0.15),
                          ),
                        ),
                      ),
                      // Logo Container - Robust circular clipping
                      Container(
                        width: 190,
                        height: 190,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          // color: Colors.white removed to prevent boxy artifacts
                          image: const DecorationImage(
                            image: AssetImage('assets/images/logo.png'),
                            fit: BoxFit.cover,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 40,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  // Industrial Design: Maximum circular fidelity achieved.
                ],
              ),
            ),

            // Content Section
            Positioned(
              top: screenHeight * 0.44,
              left: 40,
              right: 40,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: 'Easy ways to\n',
                          style: GoogleFonts.inter(
                            color: const Color(0xFF0F172A),
                            fontSize: 42,
                            fontWeight: FontWeight.w400,
                            height: 1.1,
                            letterSpacing: -1.0,
                          ),
                        ),
                        TextSpan(
                          text: 'manage your\nfinances',
                          style: GoogleFonts.inter(
                            color: const Color(0xFF0F172A),
                            fontSize: 42,
                            fontWeight: FontWeight.w800,
                            height: 1.1,
                            letterSpacing: -1.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: 260,
                    child: Text(
                      'Buy, track, and grow your gold and silver investments in one place',
                      style: GoogleFonts.inter(
                        color: const Color(0xFF64748B),
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.only(left: 24, right: 24, bottom: 48, top: 12),
        decoration: const BoxDecoration(
          color: Colors.transparent,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SwipeButton(
              text: 'Swipe To Get Started',
              onSwipeCompleted: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const OnboardingCarouselScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Already have an account?',
                  style: GoogleFonts.inter(
                    color: const Color(0xFF94A3B8),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                    );
                  },
                  child: Text(
                    'Login',
                    style: GoogleFonts.inter(
                      color: AppColors.primaryBrownGold,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
