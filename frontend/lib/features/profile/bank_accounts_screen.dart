import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/app_state.dart';
import '../../theme/app_colors.dart';

class BankAccountsScreen extends StatefulWidget {
  const BankAccountsScreen({super.key});

  @override
  State<BankAccountsScreen> createState() => _BankAccountsScreenState();
}

class _BankAccountsScreenState extends State<BankAccountsScreen> {
  void _showBankDialog({BankAccount? accountToEdit}) {
    final TextEditingController accountController = TextEditingController(text: accountToEdit?.accountNumber ?? '');
    final TextEditingController ifscController = TextEditingController(text: accountToEdit?.ifsc ?? '');
    final TextEditingController holderController = TextEditingController(text: accountToEdit?.accountHolder ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          top: 24,
          left: 24,
          right: 24,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(accountToEdit == null ? 'Add Bank Account' : 'Edit Bank Account', style: GoogleFonts.manrope(fontSize: 20, fontWeight: FontWeight.w800)),
            const SizedBox(height: 24),
            _buildField('Account Holder Name', holderController, Icons.person_outline_rounded),
            const SizedBox(height: 16),
            _buildField('Account Number', accountController, Icons.account_balance_rounded, keyboardType: TextInputType.number),
            const SizedBox(height: 16),
            _buildField('IFSC Code', ifscController, Icons.qr_code_rounded),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                if (accountController.text.isNotEmpty && ifscController.text.isNotEmpty) {
                  setState(() {
                    if (accountToEdit == null) {
                      AppState().bankAccounts.add(BankAccount(
                        accountHolder: holderController.text,
                        accountNumber: accountController.text,
                        ifsc: ifscController.text,
                      ));
                    } else {
                      accountToEdit.accountHolder = holderController.text;
                      accountToEdit.accountNumber = accountController.text;
                      accountToEdit.ifsc = ifscController.text;
                    }
                  });
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBrownGold,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: Text(accountToEdit == null ? 'Add Account' : 'Save Changes', style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: Colors.white)),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller, IconData icon, {TextInputType keyboardType = TextInputType.text}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: GoogleFonts.manrope(fontWeight: FontWeight.w600, fontSize: 16),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.inter(color: const Color(0xFF94A3B8), fontSize: 12),
          prefixIcon: Icon(icon, color: const Color(0xFF64748B), size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF1B1C1E)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Bank Accounts',
          style: GoogleFonts.manrope(fontSize: 18, fontWeight: FontWeight.w800, color: const Color(0xFF1B1C1E)),
        ),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(24),
        itemCount: AppState().bankAccounts.length + 1,
        itemBuilder: (context, index) {
          if (index == AppState().bankAccounts.length) {
            return Padding(
              padding: const EdgeInsets.only(top: 12),
              child: OutlinedButton.icon(
                onPressed: () => _showBankDialog(),
                icon: const Icon(Icons.add_rounded),
                label: Text('Add New Account', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 60),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  side: BorderSide(color: AppColors.primaryBrownGold.withOpacity(0.3)),
                  foregroundColor: AppColors.primaryBrownGold,
                ),
              ),
            );
          }

          final account = AppState().bankAccounts[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 20),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: account.isPrimary 
                  ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppColors.primaryBrownGold, AppColors.secondaryBrownGold],
                    )
                  : null,
              color: account.isPrimary ? null : Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: account.isPrimary ? null : Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: account.isPrimary ? [
                BoxShadow(color: AppColors.primaryBrownGold.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))
              ] : null,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      account.isPrimary ? 'PRIMARY ACCOUNT' : 'SAVED ACCOUNT',
                      style: GoogleFonts.inter(
                        color: account.isPrimary ? Colors.white.withOpacity(0.6) : const Color(0xFF94A3B8),
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.5,
                      ),
                    ),
                    PopupMenuButton(
                      icon: Icon(Icons.more_vert_rounded, color: account.isPrimary ? Colors.white.withOpacity(0.4) : const Color(0xFF94A3B8)),
                      itemBuilder: (context) => [
                        const PopupMenuItem(value: 'edit', child: Text('Edit Details')),
                        if (!account.isPrimary) const PopupMenuItem(value: 'primary', child: Text('Set as Primary')),
                        if (!account.isPrimary) const PopupMenuItem(value: 'delete', child: Text('Remove Account')),
                      ],
                      onSelected: (val) {
                        setState(() {
                          if (val == 'edit') {
                            _showBankDialog(accountToEdit: account);
                          } else if (val == 'primary') {
                            for (var a in AppState().bankAccounts) {
                              a.isPrimary = false;
                            }
                            account.isPrimary = true;
                          } else if (val == 'delete') {
                            AppState().bankAccounts.remove(account);
                            if (account.isPrimary && AppState().bankAccounts.isNotEmpty) {
                              AppState().bankAccounts.first.isPrimary = true;
                            }
                          }
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  account.accountNumber.replaceAll(RegExp(r'.(?=.{4})'), '*'),
                  style: GoogleFonts.sourceCodePro(
                    color: account.isPrimary ? Colors.white : const Color(0xFF1E293B),
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'HOLDER',
                          style: GoogleFonts.inter(color: account.isPrimary ? Colors.white.withOpacity(0.4) : const Color(0xFF94A3B8), fontSize: 9, fontWeight: FontWeight.w700),
                        ),
                        Text(
                          account.accountHolder,
                          style: GoogleFonts.manrope(color: account.isPrimary ? Colors.white : const Color(0xFF1E293B), fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'IFSC',
                          style: GoogleFonts.inter(color: account.isPrimary ? Colors.white.withOpacity(0.4) : const Color(0xFF94A3B8), fontSize: 9, fontWeight: FontWeight.w700),
                        ),
                        Text(
                          account.ifsc.toUpperCase(),
                          style: GoogleFonts.manrope(color: account.isPrimary ? Colors.white : const Color(0xFF1E293B), fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
