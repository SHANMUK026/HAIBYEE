import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'api_service.dart';

class PriceProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  double _goldPrice = 0.0;
  double _silverPrice = 0.0;
  bool _isLoading = false;
  Timer? _timer;

  double get goldPrice => _goldPrice;
  double get silverPrice => _silverPrice;
  bool get isLoading => _isLoading;

  PriceProvider() {
    fetchPrices();
    _startPriceUpdates();
  }

  void _startPriceUpdates() {
    _timer = Timer.periodic(Duration(seconds: 30), (timer) {
      fetchPrices();
    });
  }

  Future<void> fetchPrices() async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _apiService.getLivePrices();
      if (response.statusCode == 200) {
        _goldPrice = response.data['gold']['price'].toDouble();
        _silverPrice = response.data['silver']['price'].toDouble();
      }
    } catch (e) {
      debugPrint('Error fetching prices: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
