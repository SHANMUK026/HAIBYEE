import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../invest/invest_screen.dart';
import '../home/price_trends_screen.dart';
import '../invest/wealth_calculator.dart';
import '../invest/savings_plan_screen.dart';
import 'withdraw_screen.dart';
import '../profile/kyc_screen.dart';
import '../../utils/app_state.dart';
import '../../utils/price_data.dart';
import '../../utils/extensions.dart';

class PortfolioScreen extends StatefulWidget {
  final double goldBalance;
  final double silverBalance;
  const PortfolioScreen({
    super.key, 
    this.goldBalance = 42850.20, 
    this.silverBalance = 12450.75,
  });

  @override
  State<PortfolioScreen> createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends State<PortfolioScreen> {
  String selectedPeriod = '1M';

  void _checkKycAndNavigate(Widget screen) {
    if (AppState().isKycVerified) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
    } else {
      _showKycRequiredDialog();
    }
  }

  void _showKycRequiredDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(color: Color(0xFFFFF7ED), shape: BoxShape.circle),
              child: const Icon(Icons.verified_user_outlined, color: Color(0xFFD4AF37), size: 40),
            ),
            const SizedBox(height: 24),
            Text(
              'KYC Required',
              style: GoogleFonts.manrope(fontSize: 20, fontWeight: FontWeight.w800, color: const Color(0xFF111827)),
            ),
            const SizedBox(height: 12),
            Text(
              'Compliance verification is mandatory for investing, withdrawing, or requesting physical delivery.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(color: const Color(0xFF64748B), fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const KycScreen()));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF111827),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text('Verify Now', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double goldGrams = AppState().goldGrams;
    final double silverGrams = AppState().silverGrams;
    final double goldValue = goldGrams * PriceData.goldPrice;
    final double silverValue = silverGrams * PriceData.silverPrice;
    final double totalValue = goldValue + silverValue;
    final double goldPercent = totalValue > 0 ? goldValue / totalValue : 0.7;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const Icon(Icons.menu_rounded, color: Color(0xFF1F2937)),
        title: Text(
          'DIGITAL VAULT',
          style: GoogleFonts.inter(
            color: const Color(0xFF1F2937),
            fontSize: 16,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 32),
              _buildAssetValueCard(context, totalValue),
              const SizedBox(height: 24),
              _buildAssetAllocation(goldPercent),
              const SizedBox(height: 24),
              _buildMetalGrid(widget.goldBalance, widget.silverBalance, goldValue, silverValue),
              const SizedBox(height: 24),
              _buildPerformanceChart(),
              const SizedBox(height: 24),
              _buildQuickActions(context),
              const SizedBox(height: 24),
              _buildPortfolioTip(),
              const SizedBox(height: 32),
              _buildRecentActivity(),
              const SizedBox(height: 32),
              _buildMarketInsights(),
              const SizedBox(height: 48),
              _buildFooter(),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
      floatingActionButton: _buildFloatingWalletButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildFloatingWalletButton() {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [Color(0xFF111827), Color(0xFF1F2937)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Navigator.pop(context),
          customBorder: const CircleBorder(),
          child: const Center(
            child: Icon(Icons.account_balance_wallet_rounded, color: Color(0xFFD4AF37), size: 28),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return BottomAppBar(
      height: 80,
      color: Colors.white,
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(Icons.home_outlined, 'Home', 0),
          _navItem(Icons.trending_up_rounded, 'Market', 1),
          const SizedBox(width: 48), // Space for notched FAB
          _navItem(Icons.card_giftcard_rounded, 'Rewards', 2),
          _navItem(Icons.history_rounded, 'History', 3),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, String label, int index) {
    return InkWell(
      onTap: () => Navigator.pop(context, index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: const Color(0xFF94A3B8),
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.inter(
              color: const Color(0xFF94A3B8),
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Portfolio',
          style: GoogleFonts.manrope(
            color: const Color(0xFF1A1C1C),
            fontSize: 32,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.8,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Track your gold and silver wealth',
          style: GoogleFonts.inter(
            color: const Color(0xFF626363).withOpacity(0.7),
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildAssetValueCard(BuildContext context, double totalValue) {
    final formatter = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 2);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'TOTAL ASSET VALUE',
            style: GoogleFonts.inter(
              color: const Color(0xFF5A5C5C),
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            formatter.format(totalValue).split('.')[0],
            style: GoogleFonts.manrope(
              color: const Color(0xFF2D2F2F),
              fontSize: 42,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFDCFCE7),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.arrow_upward_rounded, size: 14, color: Color(0xFF15803D)),
                const SizedBox(width: 4),
                Text(
                  '+₹12,450 (8.2%)',
                  style: GoogleFonts.inter(
                    color: const Color(0xFF15803D),
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const InvestScreen(isGold: true))),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFD709),
                    foregroundColor: const Color(0xFF453900),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  child: const FittedBox(child: Text('Invest More', style: TextStyle(fontWeight: FontWeight.bold))),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2D2F2F),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  child: const FittedBox(child: Text('Withdraw', style: TextStyle(fontWeight: FontWeight.bold))),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAssetAllocation(double goldPercent) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: const Color(0xFFF1F1F1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Asset Allocation',
            style: GoogleFonts.manrope(
              color: const Color(0xFF2D2F2F),
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            'Diversification across precious metals',
            style: GoogleFonts.inter(
              color: const Color(0xFF5A5C5C),
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 48),
          Center(
            child: SizedBox(
              width: 220,
              height: 220,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CustomPaint(
                    size: const Size(220, 220),
                    painter: DonutChartPainter(
                      goldPercent: goldPercent,
                      goldColor: const Color(0xFFFFD709),
                      silverColor: const Color(0xFFE5E7EB),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${(goldPercent * 100).round()}%',
                        style: GoogleFonts.manrope(
                          color: const Color(0xFF2D2F2F),
                          fontSize: 40,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        'GOLD WEIGHT',
                        style: GoogleFonts.inter(
                          color: const Color(0xFF5A5C5C),
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 48),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem('Gold (${(goldPercent * 100).round()}%)', const Color(0xFFFFD709)),
              const SizedBox(width: 24),
              _buildLegendItem('Silver (${((1 - goldPercent) * 100).round()}%)', const Color(0xFFE5E7EB)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Text(
          label,
          style: GoogleFonts.inter(
            color: const Color(0xFF5A5C5C),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildMetalGrid(double goldBalance, double silverBalance, double goldValue, double silverValue) {
    final formatter = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
    final goldGm = goldBalance / 6200.0;
    final silverGm = silverBalance / 75.0;

    return Row(
      children: [
        Expanded(
          child: _buildMetalSmallCard(
            'GOLD (${goldGm.toStringAsFixed(2)} GM)',
            formatter.format(goldValue),
            '77%',
            const Color(0xFFFFFBEB),
            const Color(0xFFD4AF37),
            Icons.savings_rounded,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildMetalSmallCard(
            'SILVER (${silverGm.toStringAsFixed(2)} GM)',
            formatter.format(silverValue),
            '23%',
            const Color(0xFFF3F4F6),
            const Color(0xFF94A3B8),
            Icons.monetization_on_rounded,
          ),
        ),
      ],
    );
  }

  Widget _buildMetalSmallCard(String label, String value, String percent, Color bg, Color accent, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: accent, size: 20),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  percent,
                  style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: const Color(0xFF1F2937)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Text(
            label,
            style: GoogleFonts.inter(
              color: const Color(0xFF9CA3AF),
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.manrope(
              color: const Color(0xFF1F2937),
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceChart() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'PERFORMANCE',
                style: TextStyle(
                  fontFamily: 'Inter',
                  color: Color(0xFF1F2937),
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: ['1M', '3M', '6M', '1Y'].map((e) {
                      bool isSelected = e == selectedPeriod;
                      return GestureDetector(
                        onTap: () => setState(() => selectedPeriod = e),
                        child: Container(
                          margin: const EdgeInsets.only(left: 6),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFFFFD709) : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            e,
                            style: GoogleFonts.inter(
                              color: isSelected ? const Color(0xFF1F2937) : const Color(0xFF9CA3AF),
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          SizedBox(
            height: 180,
            child: CustomPaint(
              size: Size.infinite,
              painter: SimpleLineChartPainter(
                color: const Color(0xFFFFD709),
                period: selectedPeriod,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildActionRound('BUY GOLD', Icons.account_balance_wallet_outlined, () => _checkKycAndNavigate(const InvestScreen(isGold: true))),
        _buildActionRound('BUY SILVER', Icons.shopping_bag_outlined, () => _checkKycAndNavigate(const InvestScreen(isGold: false))),
        _buildActionRound('WITHDRAW', Icons.file_download_outlined, () => _checkKycAndNavigate(const WithdrawScreen())),
        _buildActionRound('CALCULATOR', Icons.calculate_outlined, () => Navigator.push(context, MaterialPageRoute(builder: (context) => const WealthCalculator()))),
      ],
    );
  }

  Widget _buildActionRound(String label, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFF1F1F1)),
            ),
            child: Icon(icon, color: const Color(0xFF1F2937), size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.inter(fontSize: 8, fontWeight: FontWeight.w700, color: const Color(0xFF9CA3AF)),
          ),
        ],
      ),
    );
  }

  Widget _buildPortfolioTip() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          const Icon(Icons.lightbulb_outline_rounded, color: Color(0xFFD4AF37), size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'Gold contributes 48% of your total portfolio. Consider balancing with more silver for long-term growth.',
              style: GoogleFonts.inter(
                color: const Color(0xFF92400E),
                fontSize: 12,
                height: 1.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'RECENT ACTIVITY',
          style: GoogleFonts.inter(
            color: const Color(0xFF1F2937),
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 24),
        _buildActivityItem('Bought Gold', '12 Oct • 10:45 AM', '+ ₹2,500', '0.14 GM', Icons.shopping_bag_rounded, Colors.amber),
        _buildActivityItem('Saved Weekly', '05 Oct • 02:20 AM', '+ ₹500', 'SYSTEMIC', Icons.auto_graph_rounded, Colors.blue),
        _buildActivityItem('Withdrawn', '28 Sep • 04:30 PM', '- ₹1,200', 'TO BANK', Icons.account_balance_rounded, Colors.red),
        const SizedBox(height: 24),
        Center(
          child: Text(
            'VIEW ALL TRANSACTIONS',
            style: GoogleFonts.inter(
              color: const Color(0xFFD4AF37),
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActivityItem(String title, String time, String amount, String sub, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 14, color: const Color(0xFF1F2937))),
                Text(time, style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF9CA3AF))),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(amount, style: GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 14, color: amount.startsWith('+') ? const Color(0xFF15803D) : const Color(0xFFB91C1C))),
              Text(sub, style: GoogleFonts.inter(fontSize: 10, color: const Color(0xFF9CA3AF), fontWeight: FontWeight.w700)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMarketInsights() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: const Color(0xFFF1F1F1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: const Color(0xFFFFD709), borderRadius: BorderRadius.circular(16)),
                child: const Icon(Icons.lightbulb_rounded, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 16),
              Text(
                'Recent Market\nInsights',
                style: GoogleFonts.manrope(
                  color: const Color(0xFF1F2937),
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  height: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
          _buildMarketPoint(Icons.auto_graph_rounded, 'Central Bank Accumulation', 'Central banks globally have increased gold reserves by 12% this quarter, signaling strong long-term support for prices.'),
          const SizedBox(height: 32),
          _buildMarketPoint(Icons.account_balance_rounded, 'Inflation Hedge Demand', 'With revised inflation forecasts, physical gold demand in retail markets has surged by 8.4% since the previous month.'),
          const SizedBox(height: 40),
          Center(
            child: Text(
              'View Detailed Report →',
              style: GoogleFonts.inter(
                color: const Color(0xFFB59310),
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMarketPoint(IconData icon, String title, String desc) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: const Color(0xFFB59310), size: 20),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 14, color: const Color(0xFF1F2937))),
              const SizedBox(height: 8),
              Text(desc, style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF6B7280), height: 1.5)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Center(
      child: Column(
        children: [
          const Icon(Icons.shield_outlined, color: Color(0xFFD1D5DB), size: 20),
          const SizedBox(height: 8),
          Text(
            'YOUR ASSETS ARE SECURELY STORED AND INSURED BY SILVRA TRUST',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              color: const Color(0xFFD1D5DB),
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

class DonutChartPainter extends CustomPainter {
  final double goldPercent;
  final Color goldColor;
  final Color silverColor;

  DonutChartPainter({required this.goldPercent, required this.goldColor, required this.silverColor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final strokeWidth = 32.0;

    final paintBg = Paint()
      ..color = silverColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final paintFg = Paint()
      ..color = goldColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
      -0.5 * 3.14159,
      2 * 3.14159,
      false,
      paintBg,
    );

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
      -0.5 * 3.14159,
      goldPercent * 2 * 3.14159,
      false,
      paintFg,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

class SimpleLineChartPainter extends CustomPainter {
  final Color color;
  final String period;

  SimpleLineChartPainter({required this.color, required this.period});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    final path = Path();
    
    if (period == '1M') {
      path.moveTo(0, size.height * 0.8);
      path.quadraticBezierTo(size.width * 0.2, size.height * 0.6, size.width * 0.4, size.height * 0.7);
      path.quadraticBezierTo(size.width * 0.6, size.height * 0.9, size.width * 0.8, size.height * 0.1);
      path.quadraticBezierTo(size.width * 0.9, size.height * 0.3, size.width, size.height * 0.2);
    } else if (period == '3M') {
      path.moveTo(0, size.height * 0.7);
      path.quadraticBezierTo(size.width * 0.3, size.height * 0.8, size.width * 0.5, size.height * 0.4);
      path.quadraticBezierTo(size.width * 0.7, size.height * 0.2, size.width, size.height * 0.5);
    } else if (period == '6M') {
      path.moveTo(0, size.height * 0.9);
      path.lineTo(size.width * 0.2, size.height * 0.8);
      path.lineTo(size.width * 0.4, size.height * 0.6);
      path.lineTo(size.width * 0.6, size.height * 0.7);
      path.lineTo(size.width * 0.8, size.height * 0.3);
      path.lineTo(size.width, size.height * 0.2);
    } else {
      path.moveTo(0, size.height * 0.8);
      path.quadraticBezierTo(size.width * 0.1, size.height * 0.9, size.width * 0.3, size.height * 0.7);
      path.quadraticBezierTo(size.width * 0.5, size.height * 0.4, size.width * 0.7, size.height * 0.6);
      path.quadraticBezierTo(size.width * 0.9, size.height * 0.1, size.width, size.height * 0.2);
    }

    canvas.drawPath(path, paint);

    final fillPath = Path.from(path);
    fillPath.lineTo(size.width, size.height);
    fillPath.lineTo(0, size.height);
    fillPath.close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [color.withOpacity(0.3), color.withOpacity(0.0)],
      ).createShader(Rect.fromLTRB(0, 0, size.width, size.height));

    canvas.drawPath(fillPath, fillPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
