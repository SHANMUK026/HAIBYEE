class PriceData {
  static const double goldPrice = 8012.50;
  static const double silverPrice = 232.98;
  
  static double getPrice(bool isGold) => isGold ? goldPrice : silverPrice;
}
