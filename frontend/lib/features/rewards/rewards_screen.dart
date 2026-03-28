import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';
import '../../utils/app_state.dart';
import '../../core/api_service.dart';

class RewardsScreen extends StatefulWidget {
  final bool hideBackButton;
  const RewardsScreen({super.key, this.hideBackButton = false});

  @override
  State<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends State<RewardsScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double _rotation = 0.0;
  bool _isSpinning = false;
  int _wonPoints = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );

    _controller.addListener(() {
      setState(() {
        _rotation = _animation.value * 15.0; // Multiple rotations
      });
    });

    _controller.addStatusListener((status) async {
      if (status == AnimationStatus.completed) {
        setState(() {
          _isSpinning = false;
        });
        _showWinDialog();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _spin() async {
    if (_isSpinning) return;
    
    setState(() {
      _isSpinning = true;
    });

    try {
      // 1. Fetch backend reward first
      final response = await ApiService().dio.post('profile/rewards/spin');
      final result = response.data;
      _wonPoints = result['wonPoints'] ?? 0;
      
      // 2. Map points to segment index
      // Wheel labels: [ '10%', 'GOLD', '25', 'FREE', '10%', '100', '5%', '50']
      // Indices:        0      1       2      3       4       5      6     7
      int targetIndex = 2; // Default to 25
      if (_wonPoints == 50) targetIndex = 7;
      if (_wonPoints == 100) targetIndex = 5;
      if (_wonPoints == 25) targetIndex = 2;

      // 3. Calculate target rotation
      // Pointer is at the TOP (North / -90 degrees / -pi/2)
      double segmentAngle = (2 * math.pi / 8); // 8 segments
      double pointerAngle = - (math.pi / 2); // North
      
      // Calculate how much we need to rotate to bring targetIndex to the top
      // We subtract (targetIndex * segmentAngle) to rotate the wheel backwards
      // We subtract (segmentAngle / 2) to center the segment under the pointer
      double targetAngle = pointerAngle - (targetIndex * segmentAngle) - (segmentAngle / 2);
      
      // Add multiple full rotations (5 full spins)
      double totalRotation = (10 * math.pi) + targetAngle;

      // 4. Start animation to THAT specific value
      _animation = Tween<double>(begin: _rotation % (2 * math.pi), end: totalRotation).animate(
        CurvedAnimation(parent: _controller, curve: Curves.linearToEaseOut)
      );

      _controller.forward(from: 0.0);
    } catch (e) {
      debugPrint('Spin Error: $e');
      setState(() {
        _isSpinning = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to start spin. Please try again.')),
      );
    }
  }

  void _showWinDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1612),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text('Congratulations!', style: GoogleFonts.manrope(color: Colors.white, fontWeight: FontWeight.w800)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.stars_rounded, color: Color(0xFFC8A27B), size: 64),
            const SizedBox(height: 16),
            Text('You won $_wonPoints Aura Coins! 🎉', 
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('AWESOME', style: GoogleFonts.inter(color: AppColors.primaryBrownGold, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0E0A),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              _buildPointsCard(),
              _buildDailySpinSection(),
              _buildSpendRewardsSection(),
              const SizedBox(height: 100), // Space for bottom nav
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (!widget.hideBackButton)
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              style: IconButton.styleFrom(
                backgroundColor: const Color(0xFF1E1C16),
                shape: const CircleBorder(),
              ),
            )
          else
            const SizedBox(width: 48),
          Text(
            'Rewards',
            style: GoogleFonts.manrope(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1C16),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.primaryBrownGold.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.stars_rounded, color: Color(0xFFC8A27B), size: 16),
                const SizedBox(width: 6),
                Text(
                  AppState().auraPoints.toString(),
                  style: GoogleFonts.manrope(
                    color: const Color(0xFFC8A27B),
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPointsCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFC8A27B),
            Color(0xFFD2B494),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Watermark badge
          Positioned(
            right: -20,
            top: -20,
            child: Icon(
              Icons.stars_rounded,
              size: 140,
              color: Colors.white.withOpacity(0.12),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min, // Use min size to avoid overflow
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'TOTAL AURA COINS',
                style: GoogleFonts.manrope(
                  color: const Color(0xFF451A03).withOpacity(0.6),
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    AppState().auraPoints.toString(),
                    style: GoogleFonts.manrope(
                      color: const Color(0xFF451A03),
                      fontSize: 48,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'pts',
                    style: GoogleFonts.manrope(
                      color: const Color(0xFF451A03),
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Tier: ${AppState().auraPoints >= 1000 ? 'Gold' : 'Silver'} Member',
                      style: GoogleFonts.inter(
                        color: const Color(0xFF451A03).withOpacity(0.7),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Rewards history coming soon!')),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2D240E),
                      foregroundColor: AppColors.primaryBrownGold,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'HISTORY',
                      style: GoogleFonts.manrope(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDailySpinSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          // The Big Decorative Wheel (Partially visible on the left)
          Transform.translate(
            offset: const Offset(-250, 0), // Brought back out for better visibility
            child: Transform.rotate(
              angle: _rotation,
              child: Container(
                width: 500, // Slightly bigger
                height: 500,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Detailed Segmented Wheel Painter
                    CustomPaint(
                      size: const Size(500, 500),
                      painter: _WheelPainter(),
                    ),
                    
                    // Wheel Text
                    for (int i = 0; i < 8; i++)
                      Transform.rotate(
                        angle: i * (math.pi / 4) + (math.pi / 8),
                        child: Transform.translate(
                          offset: const Offset(140, 0), // Pulled closer to center
                          child: Transform.rotate(
                            angle: math.pi / 2, // Perpendicular
                            child: Text(
                              [ '10%', 'GOLD', '25', 'FREE', '10%', '100', '5%', '50'][i],
                              textAlign: TextAlign.center,
                              style: GoogleFonts.manrope(
                                color: i % 2 == 0 ? AppColors.primaryBrownGold : Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ),
                      ),

                    // Center ring
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1612),
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.primaryBrownGold, width: 8),
                      ),
                      child: Center(
                        child: Icon(Icons.stars_rounded, color: AppColors.primaryBrownGold, size: 24),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Selection Pointer
          Positioned(
            left: 185, // Balanced position: visible but clears text
            child: Container(
              width: 36,
              height: 36,
              transform: Matrix4.rotationZ(math.pi / 4),
              decoration: BoxDecoration(
                color: AppColors.primaryBrownGold,
                border: Border.all(color: const Color(0xFF1A1612), width: 4),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          
          // Right Side Content
          Positioned(
            right: 12, // Maximized space
            child: Container(
              width: 130, // Narrowed for text safety
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'DAILY\nSPIN & WIN',
                    style: GoogleFonts.manrope(
                      color: Colors.white,
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                      height: 0.9,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Try your luck to win pure gold coins!',
                    style: GoogleFonts.inter(
                      color: Colors.white60,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _isSpinning ? null : _spin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBrownGold,
                      foregroundColor: const Color(0xFF1A1612),
                      disabledBackgroundColor: AppColors.primaryBrownGold.withOpacity(0.5),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      minimumSize: const Size(140, 60), // Wider, shorter for single line
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: _isSpinning ? 0 : 15,
                      shadowColor: AppColors.primaryBrownGold.withOpacity(0.4),
                    ),
                    child: Text(
                      _isSpinning ? 'SPINNING' : 'SPIN NOW',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.manrope(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Invisible spacer to take up height in the Column
          const SizedBox(height: 380, width: double.infinity),
        ],
      ),
    );
  }

  Widget _buildSpendRewardsSection() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Spend Your Rewards',
                style: GoogleFonts.manrope(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('All rewards section coming soon!')),
                  );
                },
                child: Text(
                  'View All',
                  style: GoogleFonts.inter(
                    color: AppColors.primaryBrownGold,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 0.52, // Maximum safety for smaller devices
          children: [
            _RewardItemCard(
              title: '1g 24K Gold Coin',
              points: '5,000',
              retailPrice: 'Retail: ₹8,200',
              isExclusive: true,
              imageUrl: 'C:/Users/user/.gemini/antigravity/brain/20e98837-fa08-4495-a211-5f9afe70b64f/gold_coin_reward_1774645258242.png',
              onRedeem: () => _showRedeemDialog('1g 24K Gold Coin'),
            ),
            _RewardItemCard(
              title: '10g Silver Bar',
              points: '2,500',
              retailPrice: 'Retail: ₹1,500',
              imageUrl: 'C:/Users/user/.gemini/antigravity/brain/20e98837-fa08-4495-a211-5f9afe70b64f/silver_bar_reward_1774645279405.png',
              onRedeem: () => _showRedeemDialog('10g Silver Bar'),
            ),
            _RewardItemCard(
              title: 'Pro Membership',
              points: '1,000',
              retailPrice: 'Retail: ₹2,400',
              imageUrl: 'C:/Users/user/.gemini/antigravity/brain/20e98837-fa08-4495-a211-5f9afe70b64f/pro_membership_badge_1774645309947.png',
              onRedeem: () => _showRedeemDialog('Pro Membership'),
            ),
            _RewardItemCard(
              title: '20% Buy Discount',
              points: '800',
              retailPrice: 'One-time use',
              imageUrl: 'C:/Users/user/.gemini/antigravity/brain/20e98837-fa08-4495-a211-5f9afe70b64f/discount_coupon_reward_1774645331757.png',
              onRedeem: () => _showRedeemDialog('20% Buy Discount'),
            ),
          ],
        ),
      ],
    );
  }

  void _showRedeemDialog(String item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1612),
        title: Text('Confirm Redemption', style: GoogleFonts.manrope(color: Colors.white, fontWeight: FontWeight.w800)),
        content: Text('Would you like to redeem your points for $item?', style: GoogleFonts.inter(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('CANCEL', style: GoogleFonts.inter(color: Colors.white38)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Successfully redeemed $item!')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBrownGold),
            child: Text('REDEEM', style: GoogleFonts.inter(color: const Color(0xFF1A1612), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

class _RewardItemCard extends StatelessWidget {
  final String title;
  final String points;
  final String retailPrice;
  final String imageUrl;
  final bool isExclusive;
  final VoidCallback onRedeem;

  const _RewardItemCard({
    required this.title,
    required this.points,
    required this.retailPrice,
    required this.imageUrl,
    this.isExclusive = false,
    required this.onRedeem,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF322A16).withOpacity(0.4),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Container with light background
          Stack(
            children: [
              Container(
                height: 130,
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFFDED3C4),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  child: imageUrl.startsWith('http') 
                    ? Image.network(imageUrl, fit: BoxFit.cover)
                    : Image.file(File(imageUrl), fit: BoxFit.cover),
                ),
              ),
              if (isExclusive)
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2D240E).withOpacity(0.8),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'EXCLUSIVE',
                      style: GoogleFonts.manrope(
                        color: AppColors.primaryBrownGold,
                        fontSize: 8,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.manrope(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      points,
                      style: GoogleFonts.manrope(
                        color: AppColors.primaryBrownGold,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.stars_rounded, color: AppColors.primaryBrownGold, size: 14),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  retailPrice,
                  style: GoogleFonts.inter(
                    color: Colors.white38,
                    fontSize: 10,
                    decoration: retailPrice.contains('Retail') ? TextDecoration.lineThrough : null,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onRedeem,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBrownGold,
                      foregroundColor: const Color(0xFF1A1612),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'REDEEM',
                      style: GoogleFonts.manrope(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WheelPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final paint = Paint()..style = PaintingStyle.fill;
    
    // Draw 8 segments
    for (int i = 0; i < 8; i++) {
      paint.color = i % 2 == 0 ? const Color(0xFF221D10) : const Color(0xFF3D341D);
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        i * (math.pi / 4),
        math.pi / 4,
        true,
        paint,
      );
    }

    // Outer gold ring
    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = AppColors.primaryBrownGold
      ..strokeWidth = 12;
    canvas.drawCircle(center, radius - 6, ringPaint);

    // Subtle radial lines
    final linePaint = Paint()
      ..color = AppColors.primaryBrownGold.withOpacity(0.3)
      ..strokeWidth = 1;
    // Correct radial lines logic
    for (int i = 0; i < 8; i++) {
      final angle = i * (math.pi / 4);
      canvas.drawLine(
        center,
        Offset(
          center.dx + radius * math.cos(angle),
          center.dy + radius * math.sin(angle),
        ),
        linePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
