import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'otp_verification_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  DateTime? _selectedDate;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _dobController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFD4AF37),
              onPrimary: Colors.white,
              onSurface: Color(0xFF1A1C1C),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dobController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  String? _validateAge(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your date of birth';
    }
    if (_selectedDate == null) return null;
    
    final now = DateTime.now();
    int age = now.year - _selectedDate!.year;
    if (now.month < _selectedDate!.month || (now.month == _selectedDate!.month && now.day < _selectedDate!.day)) {
      age--;
    }
    
    if (age < 18) {
      return 'You must be 18+ to register';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Please enter a password';
    if (value.length < 8) return 'Password must be at least 8 characters';
    if (!RegExp(r'[A-Z]').hasMatch(value)) return 'Should contain at least one uppercase letter';
    if (!RegExp(r'[a-z]').hasMatch(value)) return 'Should contain at least one lowercase letter';
    if (!RegExp(r'[0-9]').hasMatch(value)) return 'Should contain at least one number';
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) return 'Should contain at least one special character';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            _buildHeader(context),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Create your account',
                        style: GoogleFonts.inter(
                          color: const Color(0xFF1A1C1C),
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.60,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Please provide your details to begin your journey.',
                        style: GoogleFonts.inter(
                          color: const Color(0xFF4D4635),
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 32),
                      
                      // Full Name
                      _buildTextField(
                        label: 'FULL NAME',
                        hintText: 'Johnathan Silver',
                        controller: _nameController,
                        validator: (value) => value == null || value.isEmpty ? 'Enter full name' : null,
                      ),
                      const SizedBox(height: 20),

                      // DOB (Added per user request)
                      _buildTextField(
                        label: 'DATE OF BIRTH',
                        hintText: 'DD/MM/YYYY',
                        controller: _dobController,
                        readOnly: true,
                        onTap: () => _selectDate(context),
                        validator: _validateAge,
                      ),
                      const SizedBox(height: 20),
                      
                      // Email
                      _buildTextField(
                        label: 'EMAIL ADDRESS',
                        hintText: 'john@vault.com',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Enter email';
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) return 'Enter valid email';
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      
                      // Mobile Number
                      _buildPhoneField(),
                      const SizedBox(height: 32),
                      
                      // Password Field
                      _buildTextField(
                        label: 'PASSWORD',
                        hintText: 'Minimum 8 characters',
                        controller: _passwordController,
                        obscureText: !_isPasswordVisible,
                        validator: _validatePassword,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                            color: const Color(0xFFD0C5AF),
                          ),
                          onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                        ),
                      ),
                      const SizedBox(height: 32),
                      
                      // Create Account Button
                      _buildGradientButton(),
                      
                      const SizedBox(height: 24),
                      
                      // Terms Link
                      Center(
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: GoogleFonts.inter(
                              color: const Color(0xFF4D4635),
                              fontSize: 12,
                            ),
                            children: [
                              const TextSpan(text: 'By joining, you agree to our '),
                              TextSpan(
                                text: 'Terms of Gold Custody',
                                style: GoogleFonts.inter(
                                  color: const Color(0xFF735C00),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            // Footer
            _buildFooter(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1C1C)),
              onPressed: () => Navigator.pop(context),
            ),
            const SizedBox(width: 8),
            Text(
              'SILVRA',
              style: GoogleFonts.inter(
                color: const Color(0xFF1A1C1C),
                fontSize: 18,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.90,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String hintText,
    required TextEditingController controller,
    bool readOnly = false,
    VoidCallback? onTap,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
    Widget? suffixIcon,
    bool obscureText = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            color: const Color(0xFF7F7663),
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.55,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          readOnly: readOnly,
          onTap: onTap,
          validator: validator,
          keyboardType: keyboardType,
          obscureText: obscureText,
          style: GoogleFonts.inter(color: const Color(0xFF1A1C1C)),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: GoogleFonts.inter(color: const Color(0xFFD0C5AF)),
            filled: true,
            fillColor: const Color(0xFFF3F3F3),
            suffixIcon: suffixIcon,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0x4CD0C5AF)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0x4CD0C5AF)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFD4AF37)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'MOBILE NUMBER',
          style: GoogleFonts.inter(
            color: const Color(0xFF7F7663),
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.55,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F3F3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0x4CD0C5AF)),
              ),
              child: Text(
                '+91',
                style: GoogleFonts.inter(
                  color: const Color(0xFF1A1C1C),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                validator: (value) => value == null || value.length < 10 ? 'Enter valid number' : null,
                style: GoogleFonts.inter(color: const Color(0xFF1A1C1C)),
                decoration: InputDecoration(
                  hintText: '(555) 000-0000',
                  hintStyle: GoogleFonts.inter(color: const Color(0xFFD0C5AF)),
                  filled: true,
                  fillColor: const Color(0xFFF3F3F3),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0x4CD0C5AF)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0x4CD0C5AF)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGradientButton() {
    return GestureDetector(
      onTap: () {
        if (_formKey.currentState!.validate()) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OtpVerificationScreen(
                phoneNumber: '+91 ${_phoneController.text}',
              ),
            ),
          );
        }
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment(0.20, -0.99),
            end: Alignment(0.80, 1.99),
            colors: [Color(0xFFD4AF37), Color(0xFFF7E37B)],
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFD4AF37).withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 10),
              spreadRadius: -3,
            )
          ],
        ),
        child: Center(
          child: Text(
            'Create account',
            style: GoogleFonts.inter(
              color: const Color(0xFF241A00),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        const Divider(color: Color(0x33D0C5AF)),
        Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Text(
                '© 2024 The Digital Vault. Secure Institutional Grade\nEncryption.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  color: const Color(0x7F1A1C1C),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _footerLink('Privacy\nPolicy'),
                  _footerLink('Terms of Gold\nCustody'),
                  _footerLink('Security\nGuarantee'),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _footerLink(String text) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: GoogleFonts.inter(
        color: const Color(0x7F1A1C1C),
        fontSize: 12,
      ),
    );
  }
}
