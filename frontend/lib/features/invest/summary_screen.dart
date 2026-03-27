import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../home/home_screen.dart';
import '../../utils/extensions.dart';
import 'checkout_screen.dart';
import '../../theme/app_colors.dart';

class SummaryScreen extends StatelessWidget {
  final bool isGold;
  final double amount;
  final double grams;

  const SummaryScreen({
    super.key, 
    required this.isGold, 
    required this.amount, 
    required this.grams
  });

  @override
  Widget build(BuildContext context) {
    double gst = amount * 0.03;
    double total = amount + gst;
    String metal = isGold ? 'gold' : 'silver';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Summary',
          style: GoogleFonts.manrope(fontSize: 24, fontWeight: FontWeight.w800, color: const Color(0xFF111827)),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              color: const Color(0xFFF5EDE3),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '₹${(amount/grams).toStringAsFixed(2)}/gm + 3% GST',
                    style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF64748B)),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE57373).withOpacity(0.85),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.sensors_rounded, size: 12, color: Colors.white),
                        const SizedBox(width: 4),
                        Text(
                          'Live price',
                          style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  _buildRow('${metal.characters.first.toUpperCase() + metal.substring(1)} quantity', '${grams.toStringAsFixed(isGold ? 3 : 1)}gm'),
                  const SizedBox(height: 24),
                  _buildRow('${metal.characters.first.toUpperCase() + metal.substring(1)} value', '₹${amount.toLocaleString()}'),
                  const SizedBox(height: 24),
                  _buildRow('GST (3%)', '₹${gst.toLocaleString()}'),
                  const SizedBox(height: 30),
                  const Divider(color: Color(0xFFF1F5F9), thickness: 2),
                  const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total payable amount',
                          style: GoogleFonts.manrope(fontSize: 16, fontWeight: FontWeight.w700, color: const Color(0xFF111827)),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              '₹${total.toLocaleString()}',
                              style: GoogleFonts.manrope(fontSize: 20, fontWeight: FontWeight.w800, color: const Color(0xFF111827)),
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CheckoutScreen(
                  isGold: isGold,
                  totalAmount: total,
                  metalType: metal,
                )),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isGold ? AppColors.primaryBrownGold : const Color(0xFF1E293B),
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
            child: Text(
              'Next',
              style: GoogleFonts.manrope(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w500, color: const Color(0xFF94A3B8)),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: GoogleFonts.manrope(fontSize: 16, fontWeight: FontWeight.w700, color: const Color(0xFF111827)),
            ),
          ),
        ),
      ],
    );
  }
}
