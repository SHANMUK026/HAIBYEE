import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../utils/app_state.dart';
import 'mock_identification_screens.dart';

class KycScreen extends StatefulWidget {
  const KycScreen({super.key});

  @override
  State<KycScreen> createState() => _KycScreenState();
}

class _KycScreenState extends State<KycScreen> {
  bool isDigiLockerStep = true;
  bool isVerifying = false;
  final ImagePicker _picker = ImagePicker();
  Map<String, bool> uploadedDocs = {
    'Aadhaar Card (Front)': false,
    'Aadhaar Card (Back)': false,
    'PAN Card': false,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Color(0xFF1A1C1C)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Identity Verification',
          style: GoogleFonts.manrope(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1A1C1C),
          ),
        ),
        centerTitle: true,
      ),
      body: isVerifying ? _buildVerifyingState() : (isDigiLockerStep ? _buildDigiLockerStep() : _buildManualStep()),
    );
  }

  Widget _buildVerifyingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 60,
            height: 60,
            child: CircularProgressIndicator(
              strokeWidth: 6,
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFD4AF37)),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Verifying Documents...',
            style: GoogleFonts.manrope(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'This usually takes less than a minute',
            style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF64748B)),
          ),
        ],
      ),
    );
  }

  Widget _buildDigiLockerStep() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFDBEAFE)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  child: const Icon(Icons.bolt_rounded, color: Color(0xFF2563EB), size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Recommended',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF2563EB),
                          letterSpacing: 1,
                        ),
                      ),
                      Text(
                        'Fast Track with DigiLocker',
                        style: GoogleFonts.manrope(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF1E3A8A),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          Text(
            'Connect DigiLocker',
            style: GoogleFonts.manrope(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Silvra uses Surepass to securely fetch your Aadhaar & PAN details directly from DigiLocker for instant verification.',
            style: GoogleFonts.inter(fontSize: 15, color: const Color(0xFF64748B), height: 1.5),
          ),
          const Spacer(),
          ElevatedButton(
            onPressed: _startVerification,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF111827),
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 60),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: Text(
              'Continue with DigiLocker',
              style: GoogleFonts.manrope(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: TextButton(
              onPressed: () => setState(() => isDigiLockerStep = false),
              child: Text(
                'Upload Documents Manually',
                style: GoogleFonts.inter(
                  color: const Color(0xFF64748B),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildManualStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Manual Upload',
            style: GoogleFonts.manrope(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Please provide high-quality photos of your government issued ID documents.',
            style: GoogleFonts.inter(fontSize: 15, color: const Color(0xFF64748B), height: 1.5),
          ),
          const SizedBox(height: 32),
          _buildUploadCard('Aadhaar Card (Front)', Icons.badge_outlined),
          const SizedBox(height: 16),
          _buildUploadCard('Aadhaar Card (Back)', Icons.badge_outlined),
          const SizedBox(height: 16),
          _buildUploadCard('PAN Card', Icons.credit_card_outlined),
          const SizedBox(height: 48),
          ElevatedButton(
            onPressed: uploadedDocs.values.every((v) => v) ? _startVerification : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF111827),
              foregroundColor: Colors.white,
              disabledBackgroundColor: const Color(0xFFE2E8F0),
              disabledForegroundColor: const Color(0xFF94A3B8),
              minimumSize: const Size(double.infinity, 60),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: Text(
              'Submit for Verification',
              style: GoogleFonts.manrope(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildUploadCard(String label, IconData icon) {
    bool isUploaded = uploadedDocs[label] ?? false;
    return GestureDetector(
      onTap: () => _showUploadOptions(label),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isUploaded ? const Color(0xFF16A34A) : const Color(0xFFE2E8F0), width: isUploaded ? 2 : 1),
        ),
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isUploaded ? const Color(0xFFF0FDF4) : const Color(0xFFF8FAFC), 
                    borderRadius: BorderRadius.circular(16)
                  ),
                  child: Icon(
                    isUploaded ? Icons.task_alt_rounded : icon, 
                    color: isUploaded ? const Color(0xFF16A34A) : const Color(0xFF94A3B8), 
                    size: 32
                  ),
                ),
                if (isUploaded)
                  Positioned(
                    right: -2,
                    top: -2,
                    child: Container(
                      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                      child: const Icon(Icons.check_circle, color: Color(0xFF16A34A), size: 16),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              label,
              style: GoogleFonts.manrope(
                fontSize: 14, 
                fontWeight: FontWeight.w700, 
                color: isUploaded ? const Color(0xFF16A34A) : const Color(0xFF1E293B)
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isUploaded ? 'Document Ready' : 'Click to capture or upload',
              style: GoogleFonts.inter(
                fontSize: 12, 
                color: isUploaded ? const Color(0xFF16A34A).withOpacity(0.7) : const Color(0xFF64748B)
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _startVerification() {
    setState(() => isVerifying = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        AppState().kycStatus = "Pending";
        _showSuccessDialog();
      }
    });
  }

  void _showUploadOptions(String label) {
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
          children: [
            Text('Upload $label', style: GoogleFonts.manrope(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 32),
            _buildOption(Icons.camera_alt_rounded, 'Take Photo', () async {
              Navigator.pop(context);
              final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
              if (photo != null) _markUploaded(label);
            }),
            const SizedBox(height: 16),
            _buildOption(Icons.photo_library_rounded, 'Choose from Gallery', () async {
              Navigator.pop(context);
              final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
              if (image != null) _markUploaded(label);
            }),
            const SizedBox(height: 16),
            _buildOption(Icons.file_present_rounded, 'Browse Files', () {
              Navigator.pop(context);
              _markUploaded(label);
            }),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildOption(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(12)),
        child: Icon(icon, color: const Color(0xFF64748B), size: 22),
      ),
      title: Text(title, style: GoogleFonts.manrope(fontWeight: FontWeight.w700, fontSize: 16)),
      trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: Color(0xFFF1F5F9))),
    );
  }

  void _markUploaded(String label) {
    setState(() {
      uploadedDocs[label] = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('$label uploaded successfully'),
      backgroundColor: const Color(0xFF16A34A),
      duration: const Duration(seconds: 1),
    ));
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(color: Color(0xFFF0FDF4), shape: BoxShape.circle),
              child: const Icon(Icons.verified_user_rounded, color: Color(0xFF16A34A), size: 48),
            ),
            const SizedBox(height: 24),
            Text(
              'Application Submitted!',
              style: GoogleFonts.manrope(fontSize: 22, fontWeight: FontWeight.w800, color: const Color(0xFF111827)),
            ),
            const SizedBox(height: 12),
            Text(
              'Your documents are being reviewed. This usually takes 24-48 hours. You will be notified once approved.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(color: const Color(0xFF64748B), fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Pop dialog
                  Navigator.pop(context); // Pop KycScreen
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF111827),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text('Awesome!', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
