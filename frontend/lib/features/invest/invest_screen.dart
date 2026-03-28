import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../home/home_screen.dart';
import 'package:frontend/utils/formatters.dart';
import '../../utils/price_data.dart';
import '../../widgets/price_chart.dart';
import '../../theme/app_colors.dart';
import 'summary_screen.dart';

class InvestScreen extends StatefulWidget {
  final bool isGold;
  const InvestScreen({super.key, required this.isGold});

  @override
  State<InvestScreen> createState() => _InvestScreenState();
}

class _InvestScreenState extends State<InvestScreen> {
  bool isSIP = true;
  String frequency = 'Daily';
  double amount = 50.0;
  double grams = 0.003; // Initial mock
  bool isAmountfocused = true;
  bool stepUpEnabled = true;
  late TextEditingController _amountController;

  double get currentRate => PriceData.getPrice(widget.isGold);

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(text: amount.toInt().toString());
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _updateGrams(double amt) {
    setState(() {
      amount = amt;
      grams = amt / currentRate;
      _amountController.text = amt.toInt().toString();
    });
  }

  void _updateAmount(double g) {
    setState(() {
      grams = g;
      amount = g * currentRate;
      _amountController.text = amount.toInt().toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              child: Stack(
                children: [
                  _buildGoldBarsImage(),
                  Container(
                    margin: const EdgeInsets.only(top: 100),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(32),
                        topRight: Radius.circular(32),
                      ),
                    ),
                    child: Column(
                      children: [
                        _buildTypeToggle(),
                        const SizedBox(height: 30),
                        if (isSIP) _buildFrequencySelector(),
                        const SizedBox(height: 40),
                        _buildAmountSection(),
                        const SizedBox(height: 30),
                        _buildSlider(),
                        if (!isSIP) ...[
                          const SizedBox(height: 24),
                          _buildQuickQuantityChips(),
                        ],
                        if (isSIP) ...[
                          const SizedBox(height: 30),
                          _buildStepUpToggle(),
                        ],
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: _buildProceedButton(),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 10, 20, 40),
      decoration: BoxDecoration(
        color: widget.isGold ? const Color(0xFFF5EDE3) : const Color(0xFF0F172A), // Premium Cream vs Deep Slate
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back_ios_new_rounded, color: widget.isGold ? const Color(0xFF111827) : Colors.white, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
                  ],
                ),
                child: Row(
                  children: [
                    Icon(Icons.headset_mic_rounded, size: 14, color: AppColors.primaryBrownGold),
                    const SizedBox(width: 8),
                    Text(
                      'Help',
                      style: GoogleFonts.manrope(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.black),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (widget.isGold) ...[
            Text(
              'Projected returns in 5 years',
              style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF475569)),
            ),
            const SizedBox(height: 8),
            Text(
              '₹${formatRupee(amount * 1.29)}', // Dynamic projection (~29% return)
              style: GoogleFonts.manrope(fontSize: 42, fontWeight: FontWeight.w800, color: const Color(0xFF111827)),
            ),
            const SizedBox(height: 12),
            RichText(
              text: TextSpan(
                style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF64748B), fontWeight: FontWeight.w500),
                children: [
                  const TextSpan(text: 'Investment: '),
                  TextSpan(text: '₹${formatRupee(amount)}', style: TextStyle(color: Color(0xFF111827), fontWeight: FontWeight.w700)),
                  const TextSpan(text: '  |  Earning: '),
                  TextSpan(text: '₹${formatRupee(amount * 0.29)} 🥳', style: TextStyle(color: Color(0xFF111827), fontWeight: FontWeight.w700)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _buildViewPerformanceButton(),
          ] else ...[
            Text(
              'Total Amount',
              style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white.withOpacity(0.8)),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF94A3B8), Color(0xFF475569)], // Premium Silver Metallic
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 20, offset: const Offset(0, 10))
                ],
              ),
              child: Column(
                children: [
                  Text(
                    '₹ ${currentRate.toStringAsFixed(2)}',
                    style: GoogleFonts.manrope(fontSize: 32, fontWeight: FontWeight.w800, color: Colors.white),
                  ),
                  Text(
                    'for 1 gm',
                    style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white.withOpacity(0.7)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _buildViewPerformanceButton(),
          ],
        ],
      ),
    );
  }

  Widget _buildViewPerformanceButton() {
    return GestureDetector(
      onTap: () => _showPerformanceModal(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.auto_graph_rounded, 
              size: 14, 
              color: widget.isGold ? AppColors.primaryBrownGold : const Color(0xFF94A3B8)
            ),
            const SizedBox(width: 8),
            Text(
              'View ${widget.isGold ? 'gold' : 'silver'} performance',
              style: GoogleFonts.inter(
                fontSize: 13, 
                fontWeight: FontWeight.w700, 
                color: widget.isGold ? const Color(0xFF111827) : Colors.white
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.arrow_outward_rounded, 
              size: 14, 
              color: widget.isGold ? AppColors.primaryBrownGold : const Color(0xFF94A3B8)
            ),
          ],
        ),
      ),
    );
  }

  void _showPerformanceModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 48), // Balance for close button
                Expanded(
                  child: Center(
                    child: Text(
                      'Annual Returns with ${widget.isGold ? 'Gold' : 'Silver'}',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.manrope(fontSize: 16, fontWeight: FontWeight.w800, color: const Color(0xFF111827)),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                )
              ],
            ),
            const SizedBox(height: 20),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                widget.isGold ? '+19.58%' : '+27.29%',
                style: GoogleFonts.manrope(fontSize: 36, fontWeight: FontWeight.w800, color: const Color(0xFF236E35)),
              ),
            ),
            Text(
              '5 year annualised performance',
              style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF94A3B8), fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 40),
            Expanded(
              child: PriceChart(
                isGold: widget.isGold,
                lineColor: widget.isGold ? AppColors.primaryBrownGold : const Color(0xFF475569),
              ),
            ), 
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.isGold ? AppColors.primaryBrownGold : const Color(0xFF1E293B),
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text('Got it', style: GoogleFonts.manrope(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoldBarsImage() {
    return Container(
      height: 140,
      width: double.infinity,
      color: widget.isGold ? const Color(0xFFF5EDE3) : const Color(0xFF0F172A),
      alignment: Alignment.bottomCenter,
      child: Image.asset(
        widget.isGold ? 'assets/gold_bars_stack.png' : 'assets/silver_bars_stack.png',
        height: 100,
        errorBuilder: (context, _, __) => Icon(
          Icons.layers_rounded, 
          size: 80, 
          color: widget.isGold ? AppColors.primaryBrownGold : const Color(0xFF94A3B8)
        ),
      ),
    );
  }

  Widget _buildTypeToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildToggleItem('Setup SIP', isSIP, () => setState(() => isSIP = true)),
          _buildToggleItem('One Time', !isSIP, () => setState(() => isSIP = false)),
        ],
      ),
    );
  }

  Widget _buildToggleItem(String label, bool isSelected, VoidCallback onTap) {
    final accentColor = widget.isGold ? AppColors.primaryBrownGold : const Color(0xFF1E293B);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? accentColor : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            color: isSelected ? Colors.white : const Color(0xFF64748B),
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _buildFrequencySelector() {
    final frequencies = ['Daily', 'Monthly', 'Weekly'];
    final accentColor = widget.isGold ? AppColors.primaryBrownGold : const Color(0xFF1E293B);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: frequencies.map((f) {
        bool isSelected = frequency == f;
        return GestureDetector(
          onTap: () => setState(() => frequency = f),
          child: Container(
            width: 90, // Reduced from 100 to save space
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: isSelected ? accentColor.withOpacity(0.05) : Colors.white,
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: isSelected ? accentColor : const Color(0xFFE2E8F0),
                width: 1.5,
              ),
            ),
            child: Center(
              child: Text(
                f,
                style: GoogleFonts.inter(
                  color: isSelected ? accentColor : const Color(0xFF64748B),
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAmountSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildCircularIcon(Icons.remove, () => _updateGrams((amount - 10).clamp(10, 1000000))),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '₹',
                        style: GoogleFonts.manrope(
                          fontSize: 32, 
                          fontWeight: FontWeight.w800, 
                          color: const Color(0xFF111827)
                        ),
                      ),
                      const SizedBox(width: 8),
                      IntrinsicWidth(
                        child: TextFormField(
                          controller: _amountController,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          onChanged: (val) {
                            double? d = double.tryParse(val);
                            if (d != null) {
                              setState(() {
                                amount = d;
                                grams = d / currentRate;
                              });
                            }
                          },
                          style: GoogleFonts.manrope(
                            fontSize: 48, 
                            fontWeight: FontWeight.w800, 
                            color: const Color(0xFF111827)
                          ),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (!isSIP)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      'Amount payable: ₹${formatRupee(amount)}',
                      style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF64748B), fontWeight: FontWeight.w500),
                    ),
                  ),
              ],
            ),
          ),
          _buildCircularIcon(Icons.add, () => _updateGrams(amount + 10)),
        ],
      ),
    );
  }

  Widget _buildCircularIcon(IconData icon, VoidCallback onTap) {
    final accentColor = widget.isGold ? AppColors.primaryBrownGold : const Color(0xFF1E293B);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: const BoxDecoration(
          color: Color(0xFFF1F5F9),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 18, color: accentColor),
      ),
    );
  }

  Widget _buildSlider() {
    final accentColor = widget.isGold ? AppColors.primaryBrownGold : const Color(0xFF1E293B);
    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        activeTrackColor: accentColor,
        inactiveTrackColor: const Color(0xFFF1F5F9),
        thumbColor: accentColor,
        overlayColor: accentColor.withOpacity(0.1),
        trackHeight: 6,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
      ),
      child: Slider(
        value: amount.clamp(10, 5000),
        min: 10,
        max: 5000,
        onChanged: (val) => _updateGrams(val),
      ),
    );
  }

  Widget _buildQuickQuantityChips() {
    final quantities = [2.0, 5.0, 10.0];
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: quantities.map((q) => GestureDetector(
        onTap: () => _updateAmount(q),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 6),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Text(
            '${q.toInt()} gm',
            style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF475569)),
          ),
        ),
      )).toList(),
    );
  }

  Widget _buildStepUpToggle() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF5EDE3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Checkbox(
            value: stepUpEnabled, 
            onChanged: (v) => setState(() => stepUpEnabled = v!),
            activeColor: widget.isGold ? AppColors.primaryBrownGold : const Color(0xFF1E293B),
          ),
          Expanded(
            child: Text(
              'Annual SIP Step-up (10%)',
              style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: const Color(0xFF111827)),
            ),
          ),
          Text(
            'Edit',
            style: GoogleFonts.inter(
              fontSize: 13, 
              fontWeight: FontWeight.w700, 
              color: widget.isGold ? AppColors.primaryBrownGold : const Color(0xFF1E293B)
            ),
          ),
          const SizedBox(width: 4),
          Icon(
            Icons.edit, 
            size: 14, 
            color: widget.isGold ? AppColors.primaryBrownGold : const Color(0xFF1E293B)
          ),
        ],
      ),
    );
  }

  Widget _buildProceedButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SummaryScreen(
              isGold: widget.isGold,
              amount: amount,
              grams: grams,
            )),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: widget.isGold ? AppColors.primaryBrownGold : const Color(0xFF1E293B),
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
        child: Text(
          'Proceed',
          style: GoogleFonts.manrope(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white),
        ),
      ),
    );
  }
}
