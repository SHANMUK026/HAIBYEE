import '../utils/price_data.dart';

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
  double goldGrams = 0.0;
  double silverGrams = 0.0;

  // KYC Status
  String kycStatus = "Unverified"; // "Unverified", "Pending", "Verified"
  bool get isKycVerified => kycStatus == "Verified";

  // User Details
  String userId = "";
  String userName = "";
  String userPhone = "";
  String userEmail = "";
  int auraPoints = 0;
  String referralCode = "";
  int referralCount = 0;
  double referralEarnings = 0.0;

  // Transactions
  List<Map<String, dynamic>> transactions = [];

  void updateFromMap(Map<String, dynamic> data) {
    if (data.containsKey('user')) {
      final user = data['user'];
      userId = user['id']?.toString() ?? "";
      userName = user['name'] ?? "";
      userPhone = user['phone'] ?? "";
      userEmail = user['email'] ?? "";
      kycStatus = user['kycStatus'] ?? "Unverified";
      auraPoints = user['auraPoints'] ?? 0;
      referralCode = user['referralCode'] ?? "";
      referralCount = user['referralCount'] ?? 0;
      referralEarnings = (user['referralEarnings'] ?? 0.0).toDouble();
      
      if (user.containsKey('portfolio') && user['portfolio'] != null) {
        final portfolio = user['portfolio'];
        goldGrams = (portfolio['goldGrams'] ?? 0.0).toDouble();
        silverGrams = (portfolio['silverGrams'] ?? 0.0).toDouble();
      }
    }
  }

  void updateTransactions(List<dynamic> data) {
    transactions = data.map((t) => t as Map<String, dynamic>).toList();
  }

  void clear() {
    goldGrams = 0.0;
    silverGrams = 0.0;
    kycStatus = "Unverified";
    userId = "";
    userName = "";
    userPhone = "";
    userEmail = "";
    auraPoints = 0;
    transactions = [];
  }

  // Bank Details (Multiple)
  List<BankAccount> bankAccounts = [];

  // Settings State
  Map<String, bool> notificationSettings = {
    'Price Alerts': true,
    'Market Updates': true,
    'Transaction Alerts': true,
    'Security Alerts': true,
    'Promotional Offers': false,
  };

  bool biometricEnabled = true;

  List<Map<String, String>> activeDevices = [];

  // Saved Addresses
  List<String> addresses = [];

  // Helper calculations for summary
  double get totalSavingsThisMonth {
    final now = DateTime.now();
    return _calculateSavingsForMonth(now.month, now.year);
  }

  double get totalSavingsLastMonth {
    final now = DateTime.now();
    int lastMonth = now.month - 1;
    int lastMonthYear = now.year;
    if (lastMonth == 0) {
      lastMonth = 12;
      lastMonthYear--;
    }
    return _calculateSavingsForMonth(lastMonth, lastMonthYear);
  }

  double get savingsPercentageChange {
    final thisMonth = totalSavingsThisMonth;
    final lastMonth = totalSavingsLastMonth;
    if (lastMonth <= 0) return thisMonth > 0 ? 100.0 : 0.0;
    return ((thisMonth - lastMonth) / lastMonth) * 100;
  }

  double _calculateSavingsForMonth(int month, int year) {
    return transactions
      .where((t) => t['type'] == 'BUY' || t['type'] == 'SIP')
      .where((t) {
        final dt = DateTime.tryParse(t['createdAt']?.toString() ?? "");
        return dt != null && dt.month == month && dt.year == year;
      })
      .fold(0.0, (sum, t) => sum + (double.tryParse(t['amount']?.toString() ?? "0") ?? 0.0));
  }

  double get goldWeightRatio {
    final gp = PriceData.goldPrice;
    final sp = PriceData.silverPrice;
    final total = (goldGrams * gp) + (silverGrams * sp);
    if (total <= 0) return 0.0; 
    return (goldGrams * gp) / total;
  }

  List<Map<String, dynamic>> get recentActivity {
    return transactions.take(3).toList();
  }

  double getTotalValue(double goldPrice, double silverPrice) {
    return (goldGrams * goldPrice) + (silverGrams * silverPrice);
  }
}
