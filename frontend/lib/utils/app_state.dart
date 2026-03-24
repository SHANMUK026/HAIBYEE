import 'package:flutter/foundation.dart';

class BankAccount {
  String accountHolder;
  String accountNumber;
  String ifsc;
  bool isPrimary;

  BankAccount({
    required this.accountHolder,
    required this.accountNumber,
    required this.ifsc,
    this.isPrimary = false,
  });
}

class AppState {
  static final AppState _instance = AppState._internal();
  factory AppState() => _instance;
  AppState._internal();

  // Portfolio Balances (Grams)
  double goldGrams = 5.24;
  double silverGrams = 124.50;

  // KYC Status
  String kycStatus = "Unverified"; // "Unverified", "Pending", "Verified"
  bool get isKycVerified => kycStatus == "Verified";

  // User Details
  String userName = "Alex Johnson";
  String userPhone = "9876543210";
  String userEmail = "alex.j@example.com";

  // Bank Details (Multiple)
  List<BankAccount> bankAccounts = [
    BankAccount(
      accountHolder: "Alex Johnson",
      accountNumber: "50100412345678",
      ifsc: "HDFC0001234",
      isPrimary: true,
    ),
  ];

  // Settings State
  Map<String, bool> notificationSettings = {
    'Price Alerts': true,
    'Market Updates': true,
    'Transaction Alerts': true,
    'Security Alerts': true,
    'Promotional Offers': false,
  };

  bool biometricEnabled = true;

  List<Map<String, String>> activeDevices = [
    {'name': 'iPhone 15 Pro', 'location': 'Bengaluru, India', 'status': 'Current Device'},
    {'name': 'MacBook Pro 14"', 'location': 'Mumbai, India', 'status': 'Last active: 2 hours ago'},
    {'name': 'Samsung Galaxy S24', 'location': 'Delhi, India', 'status': 'Last active: 1 day ago'},
  ];

  // Saved Addresses
  List<String> addresses = [
    "Home - Flat 402, Sunshine Apts, Bengaluru",
    "Office - Block C, Tech Park, Whitefield",
  ];

  // Helper calculation
  double getTotalValue(double goldPrice, double silverPrice) {
    return (goldGrams * goldPrice) + (silverGrams * silverPrice);
  }
}
