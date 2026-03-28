import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/app_state.dart';
import '../../theme/app_colors.dart';
import '../../core/api_service.dart';
import 'kyc_screen.dart';
import 'edit_profile_screen.dart';
import 'addresses_screen.dart';
import 'bank_accounts_screen.dart';
import 'settings_detail_screens.dart';
import 'referral_screen.dart';
import 'support_screen.dart';
import 'legal_screen.dart';
import '../onboarding/onboarding_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
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
          'My Profile',
          style: GoogleFonts.manrope(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1A1C1C),
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 24),
            
            // Profile Header
            _buildProfileHeader(),
            
            const SizedBox(height: 32),
            
            // Account Section
            _buildSectionHeader('ACCOUNT SETTINGS'),
            _buildMenuItem(Icons.person_outline_rounded, 'Edit Profile', 'Update your personal details', () async {
              final updated = await Navigator.push(context, MaterialPageRoute(builder: (context) => const EditProfileScreen()));
              if (updated == true) setState(() {});
            }),
            _buildMenuItem(
              Icons.verified_user_outlined, 
              'KYC Verification', 
              AppState().kycStatus == "Verified" ? 'Verified' : (AppState().kycStatus == "Pending" ? 'Pending Approval' : 'Complete your verification for investing'), 
              () async {
                await Navigator.push(context, MaterialPageRoute(builder: (context) => const KycScreen()));
                setState(() {}); // Rebuild when returning to update status
              },
              trailing: AppState().kycStatus == "Verified" 
                ? const Icon(Icons.check_circle_rounded, color: Color(0xFF16A34A), size: 20)
                : (AppState().kycStatus == "Pending" 
                    ? Icon(Icons.hourglass_empty_rounded, color: AppColors.primaryBrownGold, size: 20)
                    : const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8))),
            ),
            _buildMenuItem(Icons.location_on_outlined, 'Saved Addresses', 'Manage your delivery locations', () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const AddressesScreen()));
            }),
            _buildMenuItem(Icons.account_balance_outlined, 'Bank Accounts', 'Manage your withdrawal destinations', () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const BankAccountsScreen()));
            }),
            
            const SizedBox(height: 24),
            
            // Preferences Section
            _buildSectionHeader('PREFERENCES'),
            _buildMenuItem(Icons.notifications_none_rounded, 'Notifications', 'Manage your alert settings', () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationsScreen()));
            }),
            _buildMenuItem(Icons.security_rounded, 'Security', 'Password and biometric settings', () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const SecurityScreen()));
            }),
            _buildMenuItem(Icons.share_outlined, 'Refer & Earn', 'Invite friends and earn gold rewards', () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const ReferralScreen()));
            }),
            _buildMenuItem(Icons.help_outline_rounded, 'Help & Support', 'Get assistance with your account', () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const SupportScreen()));
            }),
            _buildMenuItem(Icons.gavel_rounded, 'Legal', 'Privacy policy and terms of service', () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const LegalScreen()));
            }),
            
            const SizedBox(height: 24),
            
            // Logout
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: TextButton(
                onPressed: _showLogoutDialog,
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFFEF4444),
                  minimumSize: const Size(double.infinity, 54),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: Color(0xFFFEE2E2)),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.logout_rounded, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'Logout',
                      style: GoogleFonts.manrope(fontWeight: FontWeight.w700, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [AppColors.primaryBrownGold, AppColors.accentBrownGold],
              ),
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryBrownGold.withOpacity(0.2),
                  blurRadius: 15,
                  offset: const Offset(0, 6),
                )
              ],
            ),
            child: const Icon(Icons.person_rounded, color: Colors.white, size: 36),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppState().userName,
                  style: GoogleFonts.manrope(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5EDE3),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'GOLD MEMBER',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryBrownGold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (AppState().kycStatus == "Pending")
            _buildSimulateApprovalButton(),
          IconButton(
            onPressed: () async {
              final updated = await Navigator.push(context, MaterialPageRoute(builder: (context) => const EditProfileScreen()));
              if (updated == true) setState(() {});
            },
            icon: const Icon(Icons.edit_note_rounded, color: Color(0xFF94A3B8)),
          ),
        ],
      ),
    );
  }

  Widget _buildSimulateApprovalButton() {
    return TextButton(
      onPressed: () {
        setState(() {
          AppState().kycStatus = "Verified";
        });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('KYC Simulation: Approved!'),
          backgroundColor: Color(0xFF16A34A),
        ));
      },
      style: TextButton.styleFrom(
        backgroundColor: const Color(0xFFF0FDF4),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text('Simulate Approve', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: const Color(0xFF16A34A))),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 32, bottom: 12),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: GoogleFonts.inter(
            color: const Color(0xFF94A3B8),
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.5,
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, String subtitle, VoidCallback onTap, {Widget? trailing}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        tileColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFF1F5F9)),
        ),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: const Color(0xFF64748B), size: 22),
        ),
        title: Text(
          title,
          style: GoogleFonts.manrope(fontWeight: FontWeight.w700, fontSize: 16, color: const Color(0xFF1E293B)),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF94A3B8)),
        ),
        trailing: trailing ?? const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8)),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text('Logout', style: GoogleFonts.manrope(fontWeight: FontWeight.w800)),
        content: Text('Are you sure you want to logout? You will need to sign in again to access your vault.', 
          style: GoogleFonts.inter(color: const Color(0xFF64748B), fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.inter(color: const Color(0xFF64748B), fontWeight: FontWeight.w600)),
          ),
          TextButton(
            onPressed: () {
              // Full Logout - Clear all state
              AppState().clear();
              ApiService().clearToken();
              Navigator.pushAndRemoveUntil(
                context, 
                MaterialPageRoute(builder: (context) => const OnboardingScreen()), 
                (route) => false
              );
            },
            child: Text('Logout', style: GoogleFonts.inter(color: const Color(0xFFEF4444), fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}
