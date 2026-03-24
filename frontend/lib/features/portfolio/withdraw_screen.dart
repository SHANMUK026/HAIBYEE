import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/price_data.dart';
import '../../utils/extensions.dart';
import '../../utils/app_state.dart';

class WithdrawScreen extends StatefulWidget {
  final bool isGoldInitial;
  const WithdrawScreen({super.key, this.isGoldInitial = true});

  @override
  State<WithdrawScreen> createState() => _WithdrawScreenState();
}

class _WithdrawScreenState extends State<WithdrawScreen> {
  late bool isGold;
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _bankAccountController = TextEditingController();
  final TextEditingController _ifscController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    isGold = widget.isGoldInitial;
    
    if (AppState().bankAccounts.isNotEmpty) {
      final primaryBank = AppState().bankAccounts.firstWhere(
        (a) => a.isPrimary, 
        orElse: () => AppState().bankAccounts.first
      );
      _bankAccountController.text = primaryBank.accountNumber;
      _ifscController.text = primaryBank.ifsc;
      _nameController.text = primaryBank.accountHolder;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _bankAccountController.dispose();
    _ifscController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  double get currentBalance => isGold ? AppState().goldGrams : AppState().silverGrams;
  double get currentPrice => isGold ? PriceData.goldPrice : PriceData.silverPrice;
  double get estimatedValue => (double.tryParse(_amountController.text) ?? 0) * currentPrice;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF1A1C1C)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Withdraw',
          style: GoogleFonts.manrope(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1A1C1C),
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            
            // Metal Toggle
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Expanded(child: _buildToggleItem('Gold', true)),
                  Expanded(child: _buildToggleItem('Silver', false)),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Balance Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isGold 
                    ? [const Color(0xFFD4AF37), const Color(0xFFF7E37B)]
                    : [const Color(0xFF334155), const Color(0xFF475569)],
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: (isGold ? const Color(0xFFD4AF37) : const Color(0xFF334155)).withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AVAILABLE BALANCE',
                    style: GoogleFonts.inter(
                      color: isGold ? const Color(0xFF5B4B00) : Colors.white70,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${currentBalance.toStringAsFixed(2)} g',
                        style: GoogleFonts.manrope(
                          color: isGold ? const Color(0xFF241A00) : Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 5),
                        child: Text(
                          '≈ ₹${(currentBalance * currentPrice).toLocaleString()}',
                          style: GoogleFonts.inter(
                            color: isGold ? const Color(0xFF5B4B00).withOpacity(0.7) : Colors.white60,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Withdrawal Details
            Text(
              'WITHDRAWAL DETAILS',
              style: GoogleFonts.inter(
                color: const Color(0xFF64748B),
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 16),
            
            _buildInputField(
              label: 'AMOUNT TO WITHDRAW (GRAMS)',
              hintText: '0.00',
              controller: _amountController,
              keyboardType: TextInputType.number,
              suffix: Text(
                'MAX',
                style: GoogleFonts.inter(
                  color: const Color(0xFFB59310),
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Bank Acc Details
            _buildInputField(
              label: 'ACCOUNT HOLDER NAME',
              hintText: 'John Doe',
              controller: _nameController,
            ),
            const SizedBox(height: 20),
            _buildInputField(
              label: 'BANK ACCOUNT NUMBER',
              hintText: '0000 0000 0000',
              controller: _bankAccountController,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            _buildInputField(
              label: 'IFSC CODE',
              hintText: 'SBIN0001234',
              controller: _ifscController,
            ),
            
            const SizedBox(height: 48),
            
            // Withdraw Button
            GestureDetector(
              onTap: () {
                if (_amountController.text.isNotEmpty && _bankAccountController.text.isNotEmpty) {
                  _showSuccessDialog();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill in all details')),
                  );
                }
              },
              child: Container(
                width: double.infinity,
                height: 60,
                decoration: BoxDecoration(
                  color: const Color(0xFF111827),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 15,
                      offset: const Offset(0, 10),
                    )
                  ],
                ),
                child: Center(
                  child: Text(
                    'Process Withdrawal',
                    style: GoogleFonts.manrope(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleItem(String label, bool value) {
    bool active = isGold == value;
    return GestureDetector(
      onTap: () => setState(() => isGold = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: active ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: active ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)] : null,
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.manrope(
              color: active ? const Color(0xFF111827) : const Color(0xFF64748B),
              fontWeight: active ? FontWeight.w800 : FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required String hintText,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    Widget? suffix,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            color: const Color(0xFF475569),
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: GoogleFonts.inter(
              color: const Color(0xFF1E293B),
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: GoogleFonts.inter(color: const Color(0xFF94A3B8), fontWeight: FontWeight.w400),
              suffixIcon: suffix != null ? Padding(
                padding: const EdgeInsets.all(12),
                child: suffix,
              ) : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  void _showSuccessDialog() {
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
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_rounded, color: Color(0xFF16A34A), size: 48),
            ),
            const SizedBox(height: 24),
            Text(
              'Withdrawal Initiated',
              style: GoogleFonts.manrope(fontSize: 20, fontWeight: FontWeight.w800, color: const Color(0xFF111827)),
            ),
            const SizedBox(height: 12),
            Text(
              'Your request for withdrawal of ${_amountController.text}g ${isGold ? 'Gold' : 'Silver'} has been received. Funds will be credited to your bank account within 2-3 business days.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(color: const Color(0xFF64748B), fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF111827),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text('Back to Portfolio', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
