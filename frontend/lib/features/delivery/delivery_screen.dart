import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/price_data.dart';
import '../../utils/extensions.dart';
import '../../utils/app_state.dart';
import '../../theme/app_colors.dart';

class DeliveryScreen extends StatefulWidget {
  final bool isGoldInitial;
  const DeliveryScreen({super.key, this.isGoldInitial = true});

  @override
  State<DeliveryScreen> createState() => _DeliveryScreenState();
}

class _DeliveryScreenState extends State<DeliveryScreen> {
  late bool isGold;
  final TextEditingController _gramsController = TextEditingController();
  String _selectedAddress = AppState().addresses.isEmpty ? "No address added" : AppState().addresses[0];
  bool payWithVault = true; 

  @override
  void initState() {
    super.initState();
    isGold = widget.isGoldInitial;
  }

  @override
  void dispose() {
    _gramsController.dispose();
    super.dispose();
  }

  double get requestedGrams => double.tryParse(_gramsController.text) ?? 0;
  double get vaultBalance => isGold ? AppState().goldGrams : AppState().silverGrams;
  double get metalValue => requestedGrams * (isGold ? PriceData.goldPrice : PriceData.silverPrice);
  
  double get gramsFromVault => payWithVault ? (requestedGrams > vaultBalance ? vaultBalance : requestedGrams) : 0;
  double get remainingGrams => requestedGrams - gramsFromVault;
  double get totalToPay => payWithVault ? (remainingGrams * (isGold ? PriceData.goldPrice : PriceData.silverPrice)) : metalValue;

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
          'Physical Delivery',
          style: GoogleFonts.manrope(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1A1C1C),
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Metal Selection
            _buildSectionHeader('SELECT METAL TYPE'),
            Row(
              children: [
                Expanded(child: _buildMetalCard('Gold', Icons.workspace_premium_rounded, AppColors.primaryBrownGold, true)),
                const SizedBox(width: 16),
                Expanded(child: _buildMetalCard('Silver', Icons.layers_rounded, const Color(0xFF64748B), false)),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // Quantity Input
            _buildSectionHeader('QUANTITY TO DELIVER'),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFF1F5F9)),
              ),
              child: Column(
                children: [
                   TextField(
                    controller: _gramsController,
                    keyboardType: TextInputType.number,
                    style: GoogleFonts.manrope(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF111827),
                    ),
                    decoration: InputDecoration(
                      hintText: '0.00',
                      hintStyle: GoogleFonts.manrope(color: const Color(0xFFCBD5E1)),
                      suffixText: 'GRAMS',
                      suffixStyle: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF94A3B8),
                        letterSpacing: 1,
                      ),
                      border: InputBorder.none,
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                  const Divider(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Available in Vault',
                        style: GoogleFonts.inter(color: const Color(0xFF64748B), fontSize: 13),
                      ),
                      Text(
                        '${vaultBalance.toStringAsFixed(2)} g',
                        style: GoogleFonts.manrope(
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF111827),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Settlement Type
            _buildSectionHeader('SETTLEMENT METHOD'),
            GestureDetector(
              onTap: () => setState(() => payWithVault = true),
              child: _buildSettlementOption(
                'Deduct from Vault',
                'Use your existing ${isGold ? 'gold' : 'silver'} savings',
                Icons.account_balance_wallet_rounded,
                payWithVault,
              ),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => setState(() => payWithVault = false),
              child: _buildSettlementOption(
                'Pay with NetBanking/UPI',
                'Buy fresh and request immediate delivery',
                Icons.payments_rounded,
                !payWithVault,
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Address Selection
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSectionHeader('DELIVERY ADDRESS'),
                TextButton(
                  onPressed: _showAddressPicker,
                  child: Text(
                    'Change',
                    style: GoogleFonts.manrope(
                      color: AppColors.primaryBrownGold,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFF1F5F9)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5EDE3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.location_on_rounded, color: AppColors.primaryBrownGold, size: 20),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      _selectedAddress,
                      style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF1E293B), fontWeight: FontWeight.w500),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Summary Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF111827),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                   _buildSummaryRow('Weight Request', '${requestedGrams.toStringAsFixed(2)} g'),
                   _buildSummaryRow('Payment Method', payWithVault ? (remainingGrams > 0 ? 'Hybrid (Vault + UPI)' : 'Vault Deduction') : 'External Payment'),
                   if (payWithVault && gramsFromVault > 0) _buildSummaryRow('Deducted from Vault', '${gramsFromVault.toStringAsFixed(2)} g'),
                   if (totalToPay > 0) _buildSummaryRow('Metal Value' + (payWithVault ? ' (Remaining)' : ''), '₹${totalToPay.toLocaleString()}'),
                   const Divider(color: Colors.white24, height: 32),
                   Row(
                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                     children: [
                       Text(
                         'Total Payable',
                         style: GoogleFonts.manrope(
                           color: Colors.white,
                           fontSize: 16,
                           fontWeight: FontWeight.w800,
                         ),
                       ),
                       Text(
                         totalToPay > 0 ? '₹${totalToPay.toLocaleString()}' : '0.00 g',
                         style: GoogleFonts.manrope(
                           color: AppColors.primaryBrownGold,
                           fontSize: 20,
                           fontWeight: FontWeight.w800,
                         ),
                       ),
                     ],
                   ),
                ],
              ),
            ),
            
            const SizedBox(height: 48),
            
            // Action Button
            ElevatedButton(
              onPressed: _processDelivery,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBrownGold,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 64),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                elevation: 0,
              ),
              child: Text(
                'Confirm Delivery Request',
                style: GoogleFonts.manrope(fontSize: 18, fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        title,
        style: GoogleFonts.inter(
          color: const Color(0xFF94A3B8),
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildMetalCard(String label, IconData icon, Color color, bool value) {
    bool active = isGold == value;
    return GestureDetector(
      onTap: () => setState(() => isGold = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: active ? color.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: active ? color : const Color(0xFFF1F5F9),
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: active ? color : const Color(0xFF94A3B8), size: 32),
            const SizedBox(height: 12),
            Text(
              label,
              style: GoogleFonts.manrope(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: active ? color : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettlementOption(String title, String subtitle, IconData icon, bool selected) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: selected ? Colors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: selected ? AppColors.primaryBrownGold : const Color(0xFFE2E8F0),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: selected ? const Color(0xFFF5EDE3) : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: selected ? AppColors.primaryBrownGold : const Color(0xFF94A3B8), size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.manrope(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: selected ? const Color(0xFF111827) : const Color(0xFF64748B),
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF94A3B8)),
                ),
              ],
            ),
          ),
          if (selected) Icon(Icons.check_circle_rounded, color: AppColors.primaryBrownGold, size: 24),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.inter(color: Colors.white60, fontSize: 13, fontWeight: FontWeight.w500)),
          Text(value, style: GoogleFonts.manrope(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  void _showAddressPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(32),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Address',
              style: GoogleFonts.manrope(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 24),
            ...AppState().addresses.map((addr) => ListTile(
              leading: const Icon(Icons.location_on_outlined),
              title: Text(addr, style: GoogleFonts.inter(fontSize: 14)),
              onTap: () {
                setState(() => _selectedAddress = addr);
                Navigator.pop(context);
              },
            )).toList(),
            const Divider(),
            ListTile(
              leading: Icon(Icons.add_location_alt_outlined, color: AppColors.primaryBrownGold),
              title: Text('Add New Address', style: GoogleFonts.manrope(color: AppColors.primaryBrownGold, fontWeight: FontWeight.w700)),
              onTap: () {
                // Mock add logic
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _processDelivery() {
    if (requestedGrams <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter quantity')));
      return;
    }
    // Removed strict vault balance check to allow hybrid payment
    _showConfirmation();
  }

  void _showConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(color: Color(0xFFF0FDF4), shape: BoxShape.circle),
              child: const Icon(Icons.check_circle_rounded, color: Color(0xFF16A34A), size: 48),
            ),
            const SizedBox(height: 24),
            Text(
              'Order Placed!',
              style: GoogleFonts.manrope(fontSize: 22, fontWeight: FontWeight.w800, color: const Color(0xFF111827)),
            ),
            const SizedBox(height: 12),
            Text(
              'Your physical ${isGold ? 'gold' : 'silver'} order is being processed for minting and dispatch.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(color: const Color(0xFF64748B), fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (totalToPay > 0) {
                    // Logic for initiating payment
                  }
                  Navigator.pop(context); // Pop dialog
                  Navigator.pop(context); // Pop DeliveryScreen
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBrownGold,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text('Done', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
