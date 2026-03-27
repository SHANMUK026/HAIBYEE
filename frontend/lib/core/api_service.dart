import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class ApiService {
  static const String _ip = 'haibyee.up.railway.app';
  
  static String get _baseUrl => 'https://$_ip/api';

  final Dio _dio = Dio(BaseOptions(
    baseUrl: _baseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 5),
  ));

  // Singleton pattern
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  Dio get dio => _dio;

  // Add interceptors for JWT token
  void setToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  void clearToken() {
    _dio.options.headers.remove('Authorization');
  }

  // Auth Methods
  Future<Response> sendOtp(String phone) async {
    return await _dio.post('/auth/send-otp', data: {'phone': phone});
  }

  Future<Response> verifyOtp(String phone, String code, {String? name, String? email}) async {
    return await _dio.post('/auth/verify-otp', data: {
      'phone': phone,
      'code': code,
      'name': name,
      'email': email,
    });
  }

  // Price Methods
  Future<Response> getLivePrices() async {
    return await _dio.get('/prices/live');
  }

  // Payment Methods
  Future<Response> createOrder(double amount, String assetType, double grams, String userId) async {
    return await _dio.post('/payments/create-order', data: {
      'amount': amount,
      'assetType': assetType,
      'grams': grams,
      'userId': userId,
    });
  }

  Future<Response> verifyPayment(Map<String, dynamic> data) async {
    return await _dio.post('/payments/verify-payment', data: data);
  }

  // KYC Methods
  Future<Response> startKyc(String userId, {String idType = 'AADHAAR', String idNumber = '000000000000'}) async {
    return await _dio.post('/kyc/start', data: {
      'userId': userId,
      'idType': idType,
      'idNumber': idNumber,
    });
  }

  Future<Response> checkKycStatus(String userId) async {
    return await _dio.get('/kyc/status/$userId');
  }
}
