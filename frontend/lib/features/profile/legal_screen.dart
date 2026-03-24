import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LegalScreen extends StatelessWidget {
  const LegalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF1B1C1E)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Legal & Policies',
          style: GoogleFonts.manrope(fontSize: 18, fontWeight: FontWeight.w800, color: const Color(0xFF1B1C1E)),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildLegalItem(Icons.description_outlined, 'Terms of Service', 'Understand our operating rules'),
          _buildLegalItem(Icons.privacy_tip_outlined, 'Privacy Policy', 'How we handle your data'),
          _buildLegalItem(Icons.verified_user_outlined, 'User Agreement', 'Legal rights and obligations'),
          _buildLegalItem(Icons.info_outline_rounded, 'Open Source Licenses', 'Credits for third-party software'),
          const SizedBox(height: 48),
          Center(
            child: Text(
              'Silvra Version 2.4.0 (Stable)',
              style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF94A3B8), fontWeight: FontWeight.w500),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              '© 2026 Silvra Digital Assets Pvt. Ltd.',
              style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF94A3B8)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegalItem(IconData icon, String title, String subtitle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: ListTile(
        onTap: () {},
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(14)),
          child: Icon(icon, color: const Color(0xFF64748B), size: 22),
        ),
        title: Text(title, style: GoogleFonts.manrope(fontSize: 16, fontWeight: FontWeight.w700)),
        subtitle: Text(subtitle, style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF94A3B8))),
        trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8)),
      ),
    );
  }
}
