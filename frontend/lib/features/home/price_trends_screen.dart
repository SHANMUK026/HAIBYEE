import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../invest/invest_screen.dart';
import '../../widgets/price_chart.dart';
import '../../theme/app_colors.dart';
import '../../utils/price_data.dart';
import '../../utils/extensions.dart';

class PriceTrendsScreen extends StatefulWidget {
  final bool initialIsGold;
  final bool hideBackButton;
  const PriceTrendsScreen({super.key, this.initialIsGold = true, this.hideBackButton = false});

  @override
  State<PriceTrendsScreen> createState() => _PriceTrendsScreenState();
}

class _PriceTrendsScreenState extends State<PriceTrendsScreen> {
  late bool isGoldSelected;
  String selectedTimeframe = 'Max';
  bool isPriceAlertEnabled = false;
  double? touchX;
  bool isDragging = false;

  @override
  void initState() {
    super.initState();
    isGoldSelected = widget.initialIsGold;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Yellow Header Section
          Container(
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top, bottom: 12),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFF5EDE3), Color(0xFFD2B494)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    if (!widget.hideBackButton)
                      IconButton(
                        icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF111827)),
                        onPressed: () => Navigator.pop(context),
                      )
                    else
                      const SizedBox(width: 48),
                    Expanded(
                      child: Text(
                        'Price Trends',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.manrope(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF111827),
                        ),
                      ),
                    ),
                    const SizedBox(width: 48), // Balance for back button
                  ],
                ),
                const SizedBox(height: 10),
                _buildToggle(),
              ],
            ),
          ),
          
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  _buildPerformanceInfo(),
                  const SizedBox(height: 24),
                  _buildChartArea(),
                  const SizedBox(height: 32),
                  _buildTimeframeSelector(),
                   const SizedBox(height: 32),
                  _buildPriceAlertToggle(),
                  const SizedBox(height: 32),
                  _buildMarketInsights(),
                  const SizedBox(height: 120), // Extra space for bottom nav
                ],
              ),
            ),
          ),
          _buildBottomPriceBar(),
        ],
      ),
    );
  }

  Widget _buildToggle() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 40),
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4)
          )
        ],
      ),
      child: Row(
        children: [
          _buildToggleButton('Gold', isGoldSelected, () => setState(() => isGoldSelected = true)),
          _buildToggleButton('Silver', !isGoldSelected, () => setState(() => isGoldSelected = false)),
        ],
      ),
    );
  }

  Widget _buildToggleButton(String label, bool isSelected, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryBrownGold : Colors.transparent,
            borderRadius: BorderRadius.circular(26),
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.manrope(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: isSelected ? Colors.white : const Color(0xFF64748B),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPerformanceInfo() {
    String labelText;
    switch (selectedTimeframe) {
      case '6M': labelText = '6 month'; break;
      case '1Y': labelText = '1 year'; break;
      case '3Y': labelText = '3 year'; break;
      case '5Y': labelText = '5 year'; break;
      default: labelText = 'Overall';
    }

    return Column(
      children: [
        Text(
          '$labelText annualised performance',
          style: GoogleFonts.inter(
            color: const Color(0xFF94A3B8),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          PriceData.getPerformance(isGoldSelected, selectedTimeframe),
          style: GoogleFonts.manrope(
            color: const Color(0xFF236E35),
            fontSize: 40,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Widget _buildChartArea() {
    return Container(
      height: 240,
      width: double.infinity,
      padding: const EdgeInsets.only(left: 20, right: 35), // Space for vertical 'Price' label
      child: PriceChart(
        isGold: isGoldSelected,
        timeframe: selectedTimeframe,
        lineColor: isGoldSelected ? AppColors.primaryBrownGold : const Color(0xFF64748B),
      ),
    );
  }

  Widget _buildTimeframeSelector() {
    final times = ['6M', '1Y', '3Y', '5Y', 'Max'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: times.map((t) {
        bool isSelected = t == selectedTimeframe;
        return GestureDetector(
          onTap: () => setState(() => selectedTimeframe = t),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 6),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFF1F5F9) : Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected ? AppColors.primaryBrownGold : const Color(0xFFE2E8F0),
                width: 1.5,
              ),
            ),
            child: Text(
              t,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isSelected ? AppColors.primaryBrownGold : const Color(0xFF64748B),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPriceAlertToggle() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Row(
        children: [
          const Icon(Icons.notifications_active_outlined, color: Color(0xFF111827), size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${isGoldSelected ? 'Gold' : 'Silver'} Price Alert',
                  style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700),
                ),
                Text(
                  'Get timely alerts when prices drop',
                  style: GoogleFonts.inter(color: const Color(0xFF64748B), fontSize: 11, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          Switch(
            value: isPriceAlertEnabled,
            activeColor: const Color(0xFF2E7D32),
            onChanged: (val) {
              setState(() => isPriceAlertEnabled = val);
              if (val) _showSetAlertModal();
            },
          ),
        ],
      ),
    );
  }

  void _showSetAlertModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const SetAlertModal(),
    );
  }

  Widget _buildBottomPriceBar() {
    double bottomPadding = MediaQuery.of(context).padding.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(24, 14, 24, 16 + (bottomPadding > 0 ? bottomPadding : 6)),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: const Color(0xFFF1F5F9), width: 1)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Current ${isGoldSelected ? 'gold' : 'silver'} price for\n1gm of ${isGoldSelected ? '24k gold (99.9%)' : '999 pure silver'}',
                  style: GoogleFonts.inter(
                    color: const Color(0xFF94A3B8), 
                    fontSize: 12, 
                    fontWeight: FontWeight.w500,
                    height: 1.5
                  ),
                ),
              ),
              Text(
                '₹${(isGoldSelected ? PriceData.goldPrice : PriceData.silverPrice).toLocaleString()}/gm',
                style: GoogleFonts.manrope(
                  fontSize: 22, 
                  fontWeight: FontWeight.w800, 
                  color: const Color(0xFF111827)
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildBuyButton(),
        ],
      ),
    );
  }

  Widget _buildBuyButton() {
    return SizedBox(
      width: double.infinity,
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => InvestScreen(isGold: isGoldSelected)),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.primaryBrownGold,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: Text(
              'Buy',
              style: GoogleFonts.inter(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMarketInsights() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Market Insights',
                style: GoogleFonts.manrope(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF111827),
                ),
              ),
              Text(
                'View All',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryBrownGold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 160,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              _buildInsightCard(
                'Gold remains robust amid global shifts',
                '5 min read',
                'https://images.unsplash.com/photo-1581091226825-a6a2a5aee158?w=400',
              ),
              _buildInsightCard(
                'Silver demand surges in solar industry',
                '3 min read',
                'https://images.unsplash.com/photo-1554034483-04fda0d3507b?w=400',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInsightCard(String title, String time, String imageUrl) {
    return Container(
      width: 260,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.manrope(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.access_time_rounded, size: 12, color: Color(0xFF64748B)),
                      const SizedBox(width: 4),
                      Text(
                        time,
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
              child: Image.network(
                imageUrl,
                height: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SetAlertModal extends StatefulWidget {
  const SetAlertModal({super.key});

  @override
  State<SetAlertModal> createState() => _SetAlertModalState();
}

class _SetAlertModalState extends State<SetAlertModal> {
  String selectedPercent = '-1%';

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          Text(
            'Alert me when price drops by',
            style: GoogleFonts.manrope(fontSize: 16, fontWeight: FontWeight.w700, color: const Color(0xFF111827)),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: ['-1%', '-1.5%', '-2%'].map((p) {
              bool isSelected = p == selectedPercent;
              return GestureDetector(
                onTap: () => setState(() => selectedPercent = p),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: isSelected ? AppColors.primaryBrownGold : const Color(0xFFE2E8F0), width: 1.5),
                  ),
                  child: Text(
                    p,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? AppColors.primaryBrownGold : const Color(0xFF64748B),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          Text(
            'Compared to last week’s average price',
            style: GoogleFonts.inter(color: const Color(0xFF64748B), fontSize: 13, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.show_chart, color: Colors.red, size: 16),
              const SizedBox(width: 6),
              Text(
                'Last week’s average price: ₹15,603.51/gm',
                style: GoogleFonts.inter(color: const Color(0xFF64748B), fontSize: 11, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 28),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              'You will be notified through App Notifications & whatsapp messages',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(color: const Color(0xFF64748B), fontSize: 12, fontWeight: FontWeight.w500, height: 1.5),
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBrownGold,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text('Set Alert', style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 15)),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}

