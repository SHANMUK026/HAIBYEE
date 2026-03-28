import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'savings_plan_screen.dart';
import '../../utils/price_data.dart';
import '../../theme/app_colors.dart';
import 'summary_screen.dart';

class WealthCalculator extends StatefulWidget {
  final bool isGoldInitial;
  const WealthCalculator({super.key, this.isGoldInitial = true});

  @override
  State<WealthCalculator> createState() => _WealthCalculatorState();
}

class _WealthCalculatorState extends State<WealthCalculator> {
  late bool isGold;
  double amount = 0; // Start at 0 as requested
  double tenureValue = 6; // Current slider value
  bool isMonths = true;

  @override
  void initState() {
    super.initState();
    isGold = widget.isGoldInitial;
  }

  double get rate => 0.14; // 14% per annum

  double get totalInvested => amount; // One-time investment as per screenshot

  double get estimatedProfit {
    if (amount <= 0) return 0;
    // Compound Interest for one-time investment: P * (1 + r)^t - P
    double years = isMonths ? (tenureValue / 12.0) : tenureValue;
    return amount * (math.pow(1 + rate, years) - 1);
  }

  double get maturityValue => totalInvested + estimatedProfit;

  double get metalWeight {
    if (totalInvested <= 0) return 0;
    double pricePerGm = isGold ? 6245.0 : 75.40;
    return totalInvested / pricePerGm;
  }

  void _reset() {
    setState(() {
      amount = 0;
      tenureValue = isMonths ? 6 : 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = isGold ? AppColors.primaryBrownGold : const Color(0xFF1F2937);
    final bgFade = isGold ? const Color(0xFFF5EDE3) : const Color(0xFFF3F4F6);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Color(0xFF1F2937)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Wealth Calculator',
          style: GoogleFonts.manrope(
            color: const Color(0xFF1F2937),
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            _buildTypeToggle(),
            const SizedBox(height: 32),
            _buildResultHeader(themeColor),
            const SizedBox(height: 32),
            _buildInputCard(bgFade, themeColor),
            const SizedBox(height: 32),
            _buildTenureSection(themeColor),
            const SizedBox(height: 40),
            _buildMetalWeightCard(themeColor),
            const SizedBox(height: 24),
            _buildAutoInvestCard(),
            const SizedBox(height: 32),
            _buildActionButtons(themeColor),
            const SizedBox(height: 24),
            _buildBottomControls(themeColor),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeToggle() {
    return Container(
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          _toggleItem('GOLD', isGold, () => setState(() => isGold = true)),
          _toggleItem('SILVER', !isGold, () => setState(() => isGold = false)),
        ],
      ),
    );
  }

  Widget _toggleItem(String label, bool active, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: active ? (label == 'GOLD' ? AppColors.primaryBrownGold : const Color(0xFF111827)) : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: GoogleFonts.inter(
              color: active ? (label == 'GOLD' ? Colors.white : Colors.white) : const Color(0xFF9CA3AF),
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResultHeader(Color themeColor) {
    final formatter = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
    return Column(
      children: [
        Text(
          'ESTIMATED PROFIT',
          style: GoogleFonts.inter(
            color: const Color(0xFF9CA3AF),
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            '+${formatter.format(estimatedProfit)}',
            style: GoogleFonts.manrope(
              color: const Color(0xFF059669),
              fontSize: 48,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFD1FAE5),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            'YOU EARN ${formatter.format(estimatedProfit)} EXTRA',
            style: GoogleFonts.inter(
              color: const Color(0xFF065F46),
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildMetric('TOTAL INVESTED', formatter.format(totalInvested)),
            _buildMetric('MATURITY VALUE', formatter.format(maturityValue)),
          ],
        ),
      ],
    );
  }

  Widget _buildMetric(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            color: const Color(0xFF9CA3AF),
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: GoogleFonts.manrope(
            color: const Color(0xFF1F2937),
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Widget _buildInputCard(Color bgFade, Color themeColor) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: const Color(0xFFF1F1F1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'INVESTMENT AMOUNT',
            style: GoogleFonts.inter(
              color: const Color(0xFF9CA3AF),
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                '₹ ',
                style: GoogleFonts.manrope(
                  color: const Color(0xFF1F2937),
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Expanded(
                child: TextField(
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: '0',
                    contentPadding: EdgeInsets.zero,
                  ),
                  style: GoogleFonts.manrope(
                    color: const Color(0xFF1F2937),
                    fontSize: 40,
                    fontWeight: FontWeight.w800,
                  ),
                  onChanged: (val) {
                    setState(() {
                      amount = double.tryParse(val) ?? 0;
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Most users invest ₹2,000',
            style: GoogleFonts.inter(
              color: const Color(0xFF9CA3AF),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTenureSection(Color themeColor) {
    double maxVal = isMonths ? 12 : 10;
    int divisions = isMonths ? 11 : 9;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'SELECT TENURE',
              style: GoogleFonts.inter(
                color: const Color(0xFF9CA3AF),
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
            Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  _buildTenureToggle('Mo', isMonths, () {
                    setState(() {
                      isMonths = true;
                      tenureValue = 6;
                    });
                  }),
                  _buildTenureToggle('Yr', !isMonths, () {
                    setState(() {
                      isMonths = false;
                      tenureValue = 1;
                    });
                  }),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 48),
        Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: themeColor,
                inactiveTrackColor: const Color(0xFFF3F4F6),
                thumbColor: themeColor,
                overlayColor: themeColor.withOpacity(0.12),
                trackHeight: 4,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10, elevation: 5),
              ),
              child: Slider(
                value: tenureValue,
                min: 1,
                max: maxVal,
                divisions: divisions,
                onChanged: (val) {
                  setState(() => tenureValue = val);
                },
              ),
            ),
            _buildSliderTooltip(themeColor, maxVal),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(8, (index) => Text(
            '${index + 1}${isMonths ? "MO" : "YR"}',
            style: GoogleFonts.inter(color: const Color(0xFF9CA3AF), fontSize: 8, fontWeight: FontWeight.w600),
          )),
        ),
      ],
    );
  }

  Widget _buildSliderTooltip(Color themeColor, double maxVal) {
    double screenWidth = MediaQuery.of(context).size.width - 48; // Total padding horizontal
    double thumbPos = (tenureValue - 1) / (maxVal - 1);
    
    return Positioned(
      top: -38,
      left: 10 + thumbPos * (screenWidth - 44),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFF1F2937),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              '${tenureValue.round()} ${isMonths ? "Mo" : "Yr"}',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTenureToggle(String label, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: active ? (label == 'Mo' ? const Color(0xFF111827) : const Color(0xFF111827)) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            color: active ? Colors.white : const Color(0xFF9CA3AF),
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _buildMetalWeightCard(Color themeColor) {
    final formatter = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: const Color(0xFFF1F1F1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'ESTIMATED ${isGold ? "GOLD" : "SILVER"} WEIGHT',
                style: GoogleFonts.inter(
                  color: const Color(0xFF9CA3AF),
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Pure 999 r ${isGold ? "Gold" : "Silver"}',
                  style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                metalWeight.toStringAsFixed(2),
                style: GoogleFonts.manrope(
                  color: const Color(0xFF1F2937),
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                'gm',
                style: GoogleFonts.manrope(
                  color: const Color(0xFF9CA3AF),
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const Divider(height: 32, color: Color(0xFFF1F1F1)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Worth ${formatter.format(amount)} today',
                style: GoogleFonts.inter(
                  color: const Color(0xFF1F2937),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.circle, size: 6, color: Color(0xFF10B981)),
                  const SizedBox(width: 4),
                  Text(
                    'LIVE PRICE UPDATED',
                    style: GoogleFonts.inter(
                      color: const Color(0xFF10B981),
                      fontSize: 8,
                      fontWeight: FontWeight.w800,
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

  Widget _buildAutoInvestCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          const Icon(Icons.auto_graph_rounded, color: Color(0xFF9CA3AF)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Auto-Invest Plan',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 14),
                ),
                Text(
                  'Recommended for better returns',
                  style: GoogleFonts.inter(color: const Color(0xFF9CA3AF), fontSize: 11),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Color(0xFF9CA3AF)),
        ],
      ),
    );
  }

  Widget _buildActionButtons(Color themeColor) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: isGold 
                ? [AppColors.primaryBrownGold, AppColors.accentBrownGold]
                : [const Color(0xFF1F2937), const Color(0xFF374151)],
            ),
            boxShadow: [
              BoxShadow(
                color: (isGold ? AppColors.primaryBrownGold : const Color(0xFF1F2937)).withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 8),
              )
            ],
          ),
          child: ElevatedButton(
            onPressed: () {
              if (amount <= 0) return;
              double price = PriceData.getPrice(isGold);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SummaryScreen(
                  isGold: isGold,
                  amount: amount,
                  grams: amount / price,
                )),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Start Investing', style: TextStyle(fontWeight: FontWeight.w800, color: Colors.white, fontSize: 16)),
                const SizedBox(width: 12),
                const Icon(Icons.trending_up_rounded, size: 20, color: Colors.white),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SavingsPlanScreen())),
          style: TextButton.styleFrom(
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: const Color(0xFFE2E8F0)),
            ),
          ),
          child: Text(
            'Create Savings Plan', 
            style: GoogleFonts.manrope(fontWeight: FontWeight.w800, color: const Color(0xFF1F2937)),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomControls(Color themeColor) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: _reset,
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(28),
              ),
              alignment: Alignment.center,
              child: Text(
                'RESET',
                style: GoogleFonts.inter(
                  color: const Color(0xFF9CA3AF),
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
