import 'dart:async';
import 'package:frontend/utils/formatters.dart';
import 'package:provider/provider.dart';
import '../../core/price_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'payment_screen.dart';
import 'price_trends_screen.dart';
import '../invest/invest_screen.dart';
import '../invest/summary_screen.dart';
import '../rewards/rewards_screen.dart';
import '../history/history_screen.dart';
import '../portfolio/portfolio_screen.dart';
import '../profile/profile_screen.dart';
import '../delivery/delivery_screen.dart';
import '../portfolio/withdraw_screen.dart';
import '../invest/wealth_calculator.dart';
import '../invest/savings_plan_screen.dart';
import '../profile/kyc_screen.dart';
import '../profile/referral_screen.dart';
import '../profile/support_screen.dart';
import '../../utils/price_data.dart';
import '../../utils/extensions.dart';
import '../../utils/app_state.dart';
import '../../widgets/custom_bottom_navbar.dart';
import '../../theme/app_colors.dart';
import '../../core/api_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  bool isGoldSelected = true;
  double get goldBalance => AppState().goldGrams;
  double get silverBalance => AppState().silverGrams;
  String selectedAmount = '₹2,000';
  
  // Dynamic Price Pill Logic
  bool showGoldPrice = true;
  late Timer _priceTimer;

  @override
  void initState() {
    super.initState();
    _startPriceTimer();
    _fetchInitialData();
  }

  Future<void> _fetchInitialData() async {
    try {
      final profileResponse = await ApiService().getUserProfile();
      AppState().updateFromMap({'user': profileResponse.data});
      
      final txResponse = await ApiService().getTransactions();
      AppState().updateTransactions(txResponse.data);
      
      if (mounted) setState(() {});
    } catch (e) {
      debugPrint('Error fetching initial data: $e');
    }
  }

  void _startPriceTimer() {
    _priceTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted) {
        setState(() {
          showGoldPrice = !showGoldPrice;
        });
      }
    });
  }

  @override
  void dispose() {
    _priceTimer.cancel();
    super.dispose();
  }

  Future<void> _checkKycAndNavigate(Widget screen) async {
    if (AppState().isKycVerified) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
    } else {
      _showKycRequiredDialog();
    }
  }

  void _showKycRequiredDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(color: Color(0xFFF5EDE3), shape: BoxShape.circle),
              child: Icon(Icons.verified_user_outlined, color: AppColors.primaryBrownGold, size: 40),
            ),
            const SizedBox(height: 24),
            Text(
              'KYC Required',
              style: GoogleFonts.manrope(fontSize: 20, fontWeight: FontWeight.w800, color: const Color(0xFF111827)),
            ),
            const SizedBox(height: 12),
            Text(
              'Compliance verification is mandatory for investing, withdrawing, or requesting physical delivery.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(color: const Color(0xFF64748B), fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await Navigator.push(context, MaterialPageRoute(builder: (context) => KycScreen()));
                  _fetchInitialData(); // Refresh status after returning
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBrownGold,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text('Verify Now', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Later',
                style: GoogleFonts.inter(color: const Color(0xFF94A3B8), fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _buildCurrentTabContent(),
      bottomNavigationBar: CustomBottomNavbar(
        selectedIndex: _selectedIndex,
        onItemTapped: (index) {
          setState(() => _selectedIndex = index);
        },
      ),
    );
  }

  // Removed _showPortfolio separate push logic to favor tab-based layout

  Widget _buildCurrentTabContent() {
    switch (_selectedIndex) {
      case 0:
        return _buildHomeContent();
      case 1:
        return const PriceTrendsScreen(hideBackButton: true);
      case 2:
        return PortfolioScreen(goldBalance: goldBalance, silverBalance: silverBalance);
      case 3:
        return const RewardsScreen(hideBackButton: true);
      case 4:
        return const ProfileScreen();
      default:
        return _buildHomeContent();
    }
  }

  Widget _buildHomeContent() {
    double topPadding = MediaQuery.of(context).padding.top;
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: topPadding + 10),
          _buildHeader(),
          _buildWelcomeSection(),
          _buildBalanceCard(),
          const SizedBox(height: 12),
          _buildQuickSave(),
          _buildQuickActions(),
          _buildMonthlySummaryCard(),
          _buildSavingPlans(),
          _buildReferralBanner(),
          _buildRecommendedSection(),
          _buildSupportBanner(),
          _buildPartnersFooter(),
          const SizedBox(height: 100), // Space for bottom nav
        ],
      ),
    );
  }

  void _showPortfolioSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Your Portfolio',
              style: GoogleFonts.manrope(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 24),            _portfolioItem('24K Gold', '${AppState().goldGrams}g', '₹${formatRupee(AppState().goldGrams * (Provider.of<PriceProvider>(context, listen: false).goldPrice))}', AppColors.primaryBrownGold),
            _portfolioItem('999 Silver', '${AppState().silverGrams}g', '₹${formatRupee(AppState().silverGrams * (Provider.of<PriceProvider>(context, listen: false).silverPrice))}', Color(0xFF94A3B8)),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF111827),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text('Close', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _portfolioItem(String label, String qty, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: GoogleFonts.manrope(fontWeight: FontWeight.w700, fontSize: 14)),
                  Text(qty, style: GoogleFonts.inter(color: const Color(0xFF64748B), fontSize: 12)),
                ],
              ),
            ],
          ),
          Text(value, style: GoogleFonts.manrope(fontWeight: FontWeight.w800, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final priceProvider = Provider.of<PriceProvider>(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Profile Avatar (Replaces Hamburger)
          GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen())),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFFC8A27B), Color(0xFFD2B494)],
                ),
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: const Icon(Icons.person_rounded, color: Colors.white, size: 20),
            ),
          ),
          
          // Dynamic Highlighted Animated Pill
          GestureDetector(
            onTap: () {
              setState(() {
                _selectedIndex = 1; // Direct jump to Market Tab
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: showGoldPrice ? const Color(0xFFC8A27B).withOpacity(0.5) : const Color(0xFF94A3B8).withOpacity(0.5),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (showGoldPrice ? const Color(0xFFC8A27B) : const Color(0xFF94A3B8)).withOpacity(0.2),
                    blurRadius: 12,
                    spreadRadius: 1,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildPulsatingDot(),
                  const SizedBox(width: 10),
                  Container(
                    height: 18,
                    clipBehavior: Clip.hardEdge,
                    decoration: const BoxDecoration(),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 500),
                      transitionBuilder: (Widget child, Animation<double> animation) {
                        final isEnteringGold = (child.key as ValueKey<bool>).value;
                        return SlideTransition(
                          position: Tween<Offset>(
                            begin: isEnteringGold ? const Offset(0.0, -1.0) : const Offset(0.0, 1.0),
                            end: Offset.zero,
                          ).animate(CurvedAnimation(parent: animation, curve: Curves.easeInOut)),
                          child: FadeTransition(opacity: animation, child: child),
                        );
                      },
                      child: Text(
                        showGoldPrice 
                          ? '₹${formatRupee(priceProvider.goldPrice)}/gm' 
                          : '₹${formatRupee(priceProvider.silverPrice)}/gm',
                        key: ValueKey<bool>(showGoldPrice),
                        style: GoogleFonts.manrope(
                          color: const Color(0xFF111827),
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.headset_mic_outlined, color: Color(0xFF111827), size: 22),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SupportScreen())),
              ),
              const SizedBox(width: 16),
              IconButton(
                icon: const Icon(Icons.notifications_none_outlined, color: Color(0xFF111827), size: 22),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () {},
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Hey ',
                style: GoogleFonts.inter(
                  color: const Color(0xFF6B7280),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                AppState().userName.isNotEmpty ? '${AppState().userName}!' : 'User!',
                style: GoogleFonts.inter(
                  color: AppColors.primaryBrownGold,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (AppState().isKycVerified) ...[
                const SizedBox(width: 4),
                const Icon(Icons.verified, color: Colors.green, size: 14),
              ],
              Text(' 👋', style: GoogleFonts.inter(fontSize: 14)),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            "Let's Start Saving",
            style: GoogleFonts.manrope(
              color: const Color(0xFF111827),
              fontSize: 26,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Build your gold wealth consistently',
            style: GoogleFonts.inter(
              color: const Color(0xFF6B7280),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard() {
    final priceProvider = Provider.of<PriceProvider>(context);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF5EDE3),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE2E8F0).withOpacity(0.35),
            blurRadius: 35,
            offset: const Offset(0, 15),
            spreadRadius: -8,
          )
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5EDE3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primaryBrownGold.withOpacity(0.05)),
                ),
                child: Row(
                  children: [
                    _buildToggleButton('Gold', isGoldSelected, () => setState(() => isGoldSelected = true)),
                    _buildToggleButton('Silver', !isGoldSelected, () => setState(() => isGoldSelected = false)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5EDE3),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '+8.4%',
                  style: GoogleFonts.inter(
                    color: const Color(0xFFD4AF37),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Total Balance',
              style: GoogleFonts.inter(color: const Color(0xFF94A3B8), fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '₹${formatRupee(isGoldSelected ? (AppState().goldGrams * priceProvider.goldPrice) : (AppState().silverGrams * priceProvider.silverPrice))}',
              style: GoogleFonts.manrope(
                color: const Color(0xFF111827), 
                fontSize: 32, 
                fontWeight: FontWeight.w800
              ),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => _checkKycAndNavigate(WithdrawScreen(isGoldInitial: isGoldSelected)),
                  child: _buildButton(
                    'Withdraw', 
                    const Color(0xFFD2B494).withOpacity(0.5), 
                    AppColors.primaryBrownGold, 
                    false,
                    const Icon(Icons.remove_circle_outline, size: 16, color: Color(0xFFC8A27B)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () => _checkKycAndNavigate(InvestScreen(isGold: isGoldSelected)),
                  child: _buildButton(
                    'Start Saving', 
                    AppColors.primaryBrownGold, 
                    Colors.white, 
                    true,
                    const Icon(Icons.add_circle_outline, size: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryBrownGold : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            color: isSelected ? Colors.white : const Color(0xFF94A3B8),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildButton(String label, Color bg, Color text, bool isSolid, Widget icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        boxShadow: isSolid ? [
          BoxShadow(
            color: AppColors.primaryBrownGold.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          )
        ] : [],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          icon,
          const SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.manrope(
              color: text, 
              fontSize: 14, 
              fontWeight: FontWeight.w700
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickSave() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24),
      color: const Color(0xFFFAFAFA),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'QUICK SAVE',
              style: GoogleFonts.inter(
                color: const Color(0xFF94A3B8), 
                fontSize: 10, 
                fontWeight: FontWeight.w800, 
                letterSpacing: 1.5
              ),
            ),
          ),
          const SizedBox(height: 14),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03), 
                  blurRadius: 20, 
                  offset: const Offset(0, 8)
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Swipe to Save in ${isGoldSelected ? 'gold' : 'silver'}',
                  style: GoogleFonts.manrope(
                    fontSize: 18, 
                    fontWeight: FontWeight.w800, 
                    color: const Color(0xFF111827)
                  ),
                ),
                Text(
                  'Instantly move money to your secure vault',
                  style: GoogleFonts.inter(
                    color: const Color(0xFF6B7280), 
                    fontSize: 12,
                    fontWeight: FontWeight.w500
                  ),
                ),
                const SizedBox(height: 24),
                _buildSwipeSlider(),
                const SizedBox(height: 20),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: ['₹1,000', '₹2,000', '₹3,000', '₹5,000'].map((e) {
                      bool isSelected = e == selectedAmount;
                      return GestureDetector(
                        onTap: () => setState(() => selectedAmount = e),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(right: 10),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected ? AppColors.primaryBrownGold : const Color(0xFFE2E8F0),
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            children: [
                              Text(
                                e,
                                style: GoogleFonts.inter(
                                  color: isSelected ? AppColors.primaryBrownGold : const Color(0xFF64748B),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              if (isSelected) ...[
                                const SizedBox(width: 6),
                                Container(
                                  width: 4,
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryBrownGold,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ]
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSwipeSlider() {
    double swipeWidth = MediaQuery.of(context).size.width - 80; 
    return Container(
      height: 56,
      width: swipeWidth,
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Stack(
        children: [
          Center(
            child: Text(
              'Slide to Invest $selectedAmount',
              style: GoogleFonts.inter(
                color: const Color(0xFF94A3B8), 
                fontSize: 14, 
                fontWeight: FontWeight.w600
              ),
            ),
          ),
          const Positioned(
            right: 20,
            top: 0,
            bottom: 0,
            child: Icon(Icons.lock_outline_rounded, size: 20, color: Color(0xFFCBD5E1)),
          ),
          Positioned(
            left: 4,
            top: 4,
            bottom: 4,
            child: Draggable(
              axis: Axis.horizontal,
              onDragEnd: (details) async {
                if (details.offset.dx > swipeWidth * 0.6) {
                  double amountValue = double.parse(selectedAmount.replaceAll('₹', '').replaceAll(',', ''));
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SummaryScreen(
                      isGold: isGoldSelected, 
                      amount: amountValue, 
                      grams: amountValue / (isGoldSelected ? PriceData.goldPrice : PriceData.silverPrice),
                    )),
                  );
                }
              },
              feedback: _buildSwipeHandle(),
              childWhenDragging: Opacity(opacity: 0.5, child: _buildSwipeHandle()),
              child: _buildSwipeHandle(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwipeHandle() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isGoldSelected 
            ? [AppColors.primaryBrownGold, AppColors.accentBrownGold]
            : [const Color(0xFF94A3B8), const Color(0xFF475569)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: (isGoldSelected ? AppColors.primaryBrownGold : const Color(0xFF94A3B8)).withOpacity(0.3), 
            blurRadius: 8, 
            offset: const Offset(0, 4)
          )
        ],
      ),
      child: const Icon(Icons.keyboard_double_arrow_right_rounded, color: Colors.white, size: 24),
    );
  }

  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'QUICK ACTIONS',
                  style: GoogleFonts.inter(
                    color: const Color(0xFF94A3B8), 
                    fontSize: 10, 
                    fontWeight: FontWeight.w800, 
                    letterSpacing: 1.5
                  ),
                ),
                Text(
                  'View All',
                  style: GoogleFonts.inter(
                    color: AppColors.primaryBrownGold,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildActionItem(
                  Icons.savings_rounded, 
                  'Buy Gold', 
                  const Color(0xFFF5EDE3), 
                  AppColors.primaryBrownGold,
                  () => Navigator.push(context, MaterialPageRoute(builder: (context) => InvestScreen(isGold: true))),
                ),
                _buildActionItem(
                  Icons.monetization_on_rounded, 
                  'Buy Silver', 
                  const Color(0xFFF1F5EF), 
                  const Color(0xFF64748B),
                  () => Navigator.push(context, MaterialPageRoute(builder: (context) => InvestScreen(isGold: false))),
                ),
                _buildActionItem(
                  Icons.calculate_rounded, 
                  'Calculator', 
                  const Color(0xFFF0FDF4), 
                  const Color(0xFF22C55E),
                  () => Navigator.push(context, MaterialPageRoute(builder: (context) => WealthCalculator())),
                ),
                _buildActionItem(
                  Icons.local_shipping_rounded, 
                  'Delivery', 
                  const Color(0xFFFEF9C3), 
                  const Color(0xFFA16207),
                  () => _checkKycAndNavigate(const DeliveryScreen()),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionItem(IconData icon, String label, Color bgColor, Color iconColor, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: iconColor.withOpacity(0.05)),
              boxShadow: [
                BoxShadow(
                  color: iconColor.withOpacity(0.06), 
                  blurRadius: 15, 
                  offset: const Offset(0, 6)
                )
              ],
            ),
            child: Icon(icon, color: iconColor, size: 26),
          ),
          const SizedBox(height: 10),
          Text(
            label, 
            style: GoogleFonts.inter(
              fontSize: 11, 
              fontWeight: FontWeight.w700, 
              color: const Color(0xFF111827)
            )
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlySummaryCard() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [const Color(0xFFF5EDE3), AppColors.primaryBrownGold],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBrownGold.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -10,
            top: -10,
            child: Icon(Icons.auto_graph_rounded, color: Colors.white.withOpacity(0.3), size: 80),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'YOUR SAVINGS THIS MONTH',
                style: GoogleFonts.inter(
                  color: Colors.black.withOpacity(0.6),
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 2).format(AppState().totalSavingsThisMonth),
                style: GoogleFonts.manrope(
                  color: Colors.black,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                   Icon(
                    AppState().savingsPercentageChange >= 0 ? Icons.trending_up_rounded : Icons.trending_down_rounded, 
                    color: AppState().savingsPercentageChange >= 0 ? const Color(0xFF16A34A) : Colors.redAccent, 
                    size: 14
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${AppState().savingsPercentageChange >= 0 ? '+' : ''}${AppState().savingsPercentageChange.toStringAsFixed(0)}% from last month',
                    style: GoogleFonts.inter(
                      color: AppState().savingsPercentageChange >= 0 ? const Color(0xFF16A34A) : Colors.redAccent,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSavingPlans() {
    final plans = [
      {'title': 'Save Daily', 'subtitle': 'Starts from just ₹10/day', 'icon': Icons.calendar_today_rounded, 'color': const Color(0xFFF3E8FF), 'freq': 'Daily'},
      {'title': 'Save Weekly', 'subtitle': 'Starts from just ₹50/week', 'icon': Icons.calendar_view_week_rounded, 'color': const Color(0xFFDCFCE7), 'freq': 'Weekly'},
      {'title': 'Save Monthly', 'subtitle': 'Starts from just ₹100/month', 'icon': Icons.calendar_month_rounded, 'color': const Color(0xFFFEF9C3), 'freq': 'Monthly'},
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('${isGoldSelected ? 'Gold' : 'Silver'} ', style: GoogleFonts.manrope(color: isGoldSelected ? AppColors.primaryBrownGold : const Color(0xFF94A3B8), fontSize: 22, fontWeight: FontWeight.w800)),
              Text('Saving Plans', style: GoogleFonts.manrope(color: const Color(0xFF111827), fontSize: 22, fontWeight: FontWeight.w800)),
            ],
          ),
          const SizedBox(height: 20),
          ...plans.map((e) => _buildPlanItem(
                e['title'] as String,
                e['subtitle'] as String,
                e['icon'] as IconData,
                e['color'] as Color,
                () {
                  Navigator.push(
                    context, 
                    MaterialPageRoute(builder: (context) => SavingsPlanScreen(isGoldInitial: isGoldSelected, initialFrequency: e['freq'] as String))
                  );
                },
              )),
        ],
      ),
    );
  }

  Widget _buildPlanItem(String title, String subtitle, IconData icon, Color bg, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02), 
                  blurRadius: 10, 
                  offset: const Offset(0, 4)
                )
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
                  child: Icon(icon, color: const Color(0xFF111827).withOpacity(0.8), size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title, 
                        style: GoogleFonts.inter(
                          fontSize: 15, 
                          fontWeight: FontWeight.w700, 
                          color: const Color(0xFF111827)
                        )
                      ),
                      Text(
                        subtitle, 
                        style: GoogleFonts.inter(
                          color: const Color(0xFF6B7280), 
                          fontSize: 12, 
                          fontWeight: FontWeight.w500
                        )
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8), size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReferralBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 24),
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 20),
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.primaryBrownGold.withOpacity(0.08), 
            const Color(0xFFFAFAF9)
          ],
        ),
      ),
      child: Column(
        children: [
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'Grow Together with ',
                  style: GoogleFonts.manrope(fontSize: 24, fontWeight: FontWeight.w800, color: const Color(0xFF111827)),
                ),
                TextSpan(
                  text: 'Silvra',
                  style: GoogleFonts.manrope(color: AppColors.primaryBrownGold, fontSize: 24, fontWeight: FontWeight.w800),
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Text(
              'Turn your connections into gold. Invite friends and build wealth side by side.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                color: const Color(0xFF6B7280), 
                fontSize: 13, 
                height: 1.5,
                fontWeight: FontWeight.w500
              ),
            ),
          ),
          const SizedBox(height: 28),
          GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ReferralScreen())),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primaryBrownGold, AppColors.accentBrownGold],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryBrownGold.withOpacity(0.3), 
                    blurRadius: 15, 
                    offset: const Offset(0, 6)
                  )
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Start Referring, Start Earning',
                    style: GoogleFonts.inter(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(width: 10),
                  const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendedSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Recommended for you', 
            style: GoogleFonts.manrope(
              fontSize: 18, 
              fontWeight: FontWeight.w800,
              color: const Color(0xFF111827)
            )
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 280,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(left: 20, right: 20),
            children: [
              _buildNewsCard('Top 5 Tech Stocks to Watch in Q3 2024', 'Understand how the latest AI developments are shaping the market...', 'ARTICLE'),
              _buildNewsCard('New Sustainability Trends in Gold Mining', 'Invest in responsible practices and ethical sourcing...', 'INVESTMENT'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNewsCard(String title, String desc, String tag) {
    return Container(
      width: 240,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02), 
            blurRadius: 10, 
            offset: const Offset(0, 4)
          )
        ],
        border: Border.all(color: const Color(0xFFE2E8F0).withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 130,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              image: const DecorationImage(
                image: NetworkImage('https://images.unsplash.com/photo-1618409019667-c107590aa511?ixlib=rb-1.2.1&auto=format&fit=crop&w=400&q=80'),
                fit: BoxFit.cover,
              ),
            ),
            child: Stack(
              children: [
                if (tag == 'ARTICLE') 
                  Center(
                    child: Text(
                      'INSIGHT', 
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.3), 
                        fontSize: 32, 
                        fontWeight: FontWeight.w900,
                        letterSpacing: 4,
                      )
                    )
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFBEB), 
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFFFDE68A)),
                  ),
                  child: Text(
                    tag, 
                    style: GoogleFonts.inter(
                      color: const Color(0xFFB45309), 
                      fontSize: 10, 
                      fontWeight: FontWeight.w800
                    )
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  title, 
                  style: GoogleFonts.manrope(
                    fontSize: 14, 
                    fontWeight: FontWeight.w800, 
                    height: 1.3,
                    color: const Color(0xFF111827)
                  )
                ),
                const SizedBox(height: 8),
                Text(
                  desc, 
                  maxLines: 2, 
                  overflow: TextOverflow.ellipsis, 
                  style: GoogleFonts.inter(
                    color: const Color(0xFF6B7280), 
                    fontSize: 11,
                    fontWeight: FontWeight.w500
                  )
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSupportBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02), 
            blurRadius: 10, 
            offset: const Offset(0, 4)
          )
        ],
        border: Border.all(color: const Color(0xFFE2E8F0).withOpacity(0.5)),
      ),
      child: InkWell(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SupportScreen())),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF5EDE3), 
                shape: BoxShape.circle
              ),
              child: Icon(Icons.chat_bubble_outline_rounded, color: AppColors.primaryBrownGold, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Contact Support', 
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryBrownGold,
                    ),
                  ),
                  Text(
                    "Need help? We're online", 
                    style: GoogleFonts.inter(
                      color: const Color(0xFF6B7280), 
                      fontSize: 11,
                      fontWeight: FontWeight.w500
                    )
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFF5EDE3), 
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.primaryBrownGold.withOpacity(0.3)),
              ),
              child: Text(
                'LIVE CHAT', 
                style: GoogleFonts.inter(
                  color: AppColors.primaryBrownGold, 
                  fontSize: 10, 
                  fontWeight: FontWeight.w800
                )
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPartnersFooter() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildPartnerLogo('AUGMONT', 'Gold Partner'),
              _buildPartnerLogo('SEQUEL', 'Logistics Partner'),
              _buildPartnerLogo('RAZORPAY', 'Payments'),
            ],
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.gpp_good_rounded, size: 18, color: AppColors.primaryBrownGold),
                const SizedBox(width: 8),
                Text(
                  '100% Secure & Trusted', 
                  style: GoogleFonts.inter(
                    color: const Color(0xFF64748B), 
                    fontSize: 11, 
                    fontWeight: FontWeight.w700
                  )
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Save in Gold. Grow with Confidence.',
            style: GoogleFonts.inter(
              color: const Color(0xFF94A3B8), 
              fontSize: 10, 
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPartnerLogo(String name, String sub) {
    return Column(
      children: [
        const Icon(Icons.verified_user_rounded, color: Color(0xFFCBD5E1), size: 16),
        const SizedBox(height: 6),
        Text(
          name, 
          style: GoogleFonts.inter(
            fontSize: 11, 
            fontWeight: FontWeight.w900, 
            color: const Color(0xFF111827),
            letterSpacing: 1
          )
        ),
        Text(
          sub, 
          style: GoogleFonts.inter(
            fontSize: 9, 
            color: const Color(0xFF94A3B8),
            fontWeight: FontWeight.w600
          )
        ),
      ],
    );
  }

  Widget _buildPulsatingDot() {
    return const _PulsatingDot();
  }
}

class _PulsatingDot extends StatefulWidget {
  const _PulsatingDot();

  @override
  State<_PulsatingDot> createState() => _PulsatingDotState();
}

class _PulsatingDotState extends State<_PulsatingDot> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.red,
            boxShadow: [
              BoxShadow(
                color: Colors.red.withOpacity(0.5 * (1 - _controller.value)),
                blurRadius: 10 * _controller.value,
                spreadRadius: 5 * _controller.value,
              )
            ],
          ),
        );
      },
    );
  }
}
