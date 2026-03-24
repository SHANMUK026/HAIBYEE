import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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

    _controller.addStatusListener((status) {
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

  void _spin() {
    if (_isSpinning) return;
    setState(() {
      _isSpinning = true;
    });
    _controller.forward(from: 0.0);
  }

  void _showWinDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF221D10),
        title: Text('Congratulations!', style: GoogleFonts.manrope(color: Colors.white, fontWeight: FontWeight.w800)),
        content: Text('You won 50 Aura Coins! 🎉', style: GoogleFonts.inter(color: const Color(0xFFECB613))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('AWESOME', style: GoogleFonts.inter(color: const Color(0xFFECB613), fontWeight: FontWeight.bold)),
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
                backgroundColor: const Color(0xFF221D10),
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
              border: Border.all(color: const Color(0xFFECB613).withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.stars_rounded, color: Color(0xFFECB613), size: 16),
                const SizedBox(width: 6),
                Text(
                  '1,250',
                  style: GoogleFonts.manrope(
                    color: const Color(0xFFECB613),
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
            Color(0xFFFACC15),
            Color(0xFFFEF08A),
            Color(0xFFB45309),
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
                    '1,250',
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
                      'Tier: Gold Member',
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
                      foregroundColor: const Color(0xFFECB613),
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
                                color: i % 2 == 0 ? const Color(0xFFECB613) : Colors.white,
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
                        border: Border.all(color: const Color(0xFFECB613), width: 8),
                      ),
                      child: const Center(
                        child: Icon(Icons.stars_rounded, color: Color(0xFFECB613), size: 24),
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
                color: const Color(0xFFECB613),
                border: Border.all(color: const Color(0xFF221D10), width: 4),
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
                      backgroundColor: const Color(0xFFECB613),
                      foregroundColor: const Color(0xFF221D10),
                      disabledBackgroundColor: const Color(0xFFECB613).withOpacity(0.5),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      minimumSize: const Size(140, 60), // Wider, shorter for single line
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: _isSpinning ? 0 : 15,
                      shadowColor: const Color(0xFFECB613).withOpacity(0.4),
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
                    color: const Color(0xFFECB613),
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
              imageUrl: 'https://images.unsplash.com/photo-1589118949245-7d48d5045451?w=400&q=80',
              onRedeem: () => _showRedeemDialog('1g 24K Gold Coin'),
            ),
            _RewardItemCard(
              title: '10g Silver Bar',
              points: '2,500',
              retailPrice: 'Retail: ₹1,500',
              imageUrl: 'https://images.unsplash.com/photo-1610375461246-83df859d849d?w=400&q=80',
              onRedeem: () => _showRedeemDialog('10g Silver Bar'),
            ),
            _RewardItemCard(
              title: 'Pro Membership',
              points: '1,000',
              retailPrice: 'Retail: ₹2,400',
              imageUrl: 'https://images.unsplash.com/photo-1550751827-4bd374c3f58b?w=400&q=80',
              onRedeem: () => _showRedeemDialog('Pro Membership'),
            ),
            _RewardItemCard(
              title: '20% Buy Discount',
              points: '800',
              retailPrice: 'One-time use',
              imageUrl: 'https://images.unsplash.com/photo-1607082348824-0a96f2a4b9da?w=400&q=80',
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
        backgroundColor: const Color(0xFF221D10),
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
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFECB613)),
            child: Text('REDEEM', style: GoogleFonts.inter(color: const Color(0xFF221D10), fontWeight: FontWeight.bold)),
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
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                  ),
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
                        color: const Color(0xFFECB613),
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
                        color: const Color(0xFFECB613),
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.stars_rounded, color: Color(0xFFECB613), size: 14),
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
                      backgroundColor: const Color(0xFFECB613),
                      foregroundColor: const Color(0xFF221D10),
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
      ..color = const Color(0xFFECB613)
      ..strokeWidth = 12;
    canvas.drawCircle(center, radius - 6, ringPaint);

    // Subtle radial lines
    final linePaint = Paint()
      ..color = const Color(0xFFECB613).withOpacity(0.3)
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
