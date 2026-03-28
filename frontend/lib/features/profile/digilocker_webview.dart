import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../core/api_service.dart';
import '../../utils/app_state.dart';
import '../../theme/app_colors.dart';

class DigiLockerWebView extends StatefulWidget {
  const DigiLockerWebView({super.key});

  @override
  State<DigiLockerWebView> createState() => _DigiLockerWebViewState();
}

class _DigiLockerWebViewState extends State<DigiLockerWebView> {
  late final WebViewController _controller;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initializeDigiLocker();
  }

  Future<void> _initializeDigiLocker() async {
    try {
      final response = await ApiService().post('/kyc/digilocker-init', {});
      
      if (response.data['success']) {
        final token = response.data['data']['token'];
        final baseUrl = ApiService().dio.options.baseUrl.replaceAll('/api', '');
        final url = '$baseUrl/digiboost.html?token=$token';

        _controller = WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..addJavaScriptChannel(
            'FlutterChannel',
            onMessageReceived: (message) {
              final data = jsonDecode(message.message);
              if (data['status'] == 'success') {
                _handleSuccess(data['clientId']);
              } else {
                _handleFailure(data['error']);
              }
            },
          )
          ..setNavigationDelegate(
            NavigationDelegate(
              onPageFinished: (url) => setState(() => _isLoading = false),
              onWebResourceError: (error) => setState(() => _error = "Failed to load verification page"),
            ),
          )
          ..loadRequest(Uri.parse(url));
        
        setState(() {});
      } else {
        throw "Failed to initialize DigiLocker session";
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _handleSuccess(String? clientId) async {
    if (clientId == null) {
      _handleFailure("Missing Client ID from SDK");
      return;
    }

    try {
      setState(() => _isLoading = true);
      // Finalize on our backend to sync identity data
      await ApiService().get('kyc/digilocker-verify/$clientId');
      
      AppState().kycStatus = "Verified";
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      _handleFailure("Failed to sync identity: $e");
    }
  }

  void _handleFailure(dynamic error) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Verification failed: $error')),
      );
      Navigator.pop(context, false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('DigiLocker Verification', style: GoogleFonts.manrope(fontWeight: FontWeight.w700)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _error != null
          ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
          : Stack(
              children: [
                if (!_isLoading) WebViewWidget(controller: _controller),
                if (_isLoading)
                  const Center(
                    child: CircularProgressIndicator(color: AppColors.primaryBrownGold),
                  ),
              ],
            ),
    );
  }
}
