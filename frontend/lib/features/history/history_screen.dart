import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String selectedFilter = 'All';
  String searchQuery = '';

  final List<Map<String, dynamic>> _allTransactions = [
    {
      'title': 'Gold Delivery',
      'time': '11:30 AM',
      'amount': '2.00 g',
      'type': 'Delivery',
      'status': 'Minting',
      'date': 'TODAY',
      'icon': Icons.local_shipping_outlined,
      'color': AppColors.primaryBrownGold,
      'tracking': ['Ordered', 'Minting', 'Dispatched', 'Delivered'],
      'currentStep': 1,
    },
    {
      'title': 'Silver Delivery',
      'time': '04:15 PM',
      'amount': '50.00 g',
      'type': 'Delivery',
      'status': 'Delivered',
      'date': 'YESTERDAY',
      'icon': Icons.local_shipping_outlined,
      'color': const Color(0xFF94A3B8),
      'tracking': ['Ordered', 'Minting', 'Dispatched', 'Delivered'],
      'currentStep': 3,
    },
  ];

  List<Map<String, dynamic>> get _filteredTransactions {
    return _allTransactions.where((t) {
      bool categoryMatch = selectedFilter == 'All' || t['type'] == selectedFilter;
      bool searchMatch = t['title'].toString().toLowerCase().contains(searchQuery.toLowerCase()) ||
                        t['amount'].toString().toLowerCase().contains(searchQuery.toLowerCase());
      return categoryMatch && searchMatch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F6F6),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildSearchBar(),
            _buildFilters(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  ..._buildGroupedList(),
                  const SizedBox(height: 16),
                  _buildMonthlySummary(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _circleIcon(Icons.arrow_back_rounded),
          Text(
            'Transaction History',
            style: GoogleFonts.manrope(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0F172A),
            ),
          ),
          _circleIcon(Icons.tune_rounded),
        ],
      ),
    );
  }

  Widget _circleIcon(IconData icon) {
    return Container(
      width: 44,
      height: 44,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: const Color(0xFF64748B), size: 20),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        height: 54,
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: TextField(
          onChanged: (val) => setState(() => searchQuery = val),
          decoration: InputDecoration(
            hintText: 'Search transactions',
            hintStyle: GoogleFonts.inter(color: const Color(0xFF94A3B8), fontSize: 16),
            prefixIcon: const Icon(Icons.search, color: Color(0xFF94A3B8)),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 15),
          ),
        ),
      ),
    );
  }

  Widget _buildFilters() {
    final filters = ['All', 'Gold', 'Silver', 'Withdraw', 'Delivery'];
    return Container(
      margin: const EdgeInsets.only(top: 12, bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: filters.map((f) {
          bool isSelected = f == selectedFilter;
          return GestureDetector(
            onTap: () => setState(() => selectedFilter = f),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                border: isSelected 
                  ? Border(bottom: BorderSide(color: AppColors.primaryBrownGold, width: 3))
                  : null,
              ),
              child: Text(
                f,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? AppColors.primaryBrownGold : const Color(0xFF64748B),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  List<Widget> _buildGroupedList() {
    final filtered = _filteredTransactions;
    if (filtered.isEmpty) {
      return [
        Padding(
          padding: const EdgeInsets.all(40.0),
          child: Center(child: Text('No transactions found', style: GoogleFonts.inter(color: Colors.grey))),
        )
      ];
    }

    Map<String, List<Map<String, dynamic>>> groups = {};
    for (var t in filtered) {
      String dateLabel = t['date'];
      groups.putIfAbsent(dateLabel, () => []).add(t);
    }

    List<Widget> children = [];
    final order = ['TODAY', 'YESTERDAY'];
    
    for (var label in order) {
      if (groups.containsKey(label)) {
        children.add(
          Padding(
            padding: const EdgeInsets.only(top: 24, bottom: 12),
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF64748B),
                letterSpacing: 0.6,
              ),
            ),
          ),
        );
        children.addAll(groups[label]!.map((t) => _buildTransactionItem(t)));
      }
    }
    return children;
  }

  Widget _buildTransactionItem(Map<String, dynamic> t) {
    bool isCredit = t['status'] == 'Credited';
    
    return GestureDetector(
      onTap: t['type'] == 'Delivery' ? () => _showTrackingDetails(t) : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFF1F5F9)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: t['color'].withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(t['icon'], color: t['color'], size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t['title'],
                    style: GoogleFonts.manrope(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  Text(
                    t['time'],
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: const Color(0xFF64748B),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  (isCredit ? '+' : (t['type'] == 'Delivery' ? '' : '-')) + t['amount'],
                  style: GoogleFonts.manrope(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: isCredit ? const Color(0xFF16A34A) : const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 4),
                _buildBadge(t['status']),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showTrackingDetails(Map<String, dynamic> t) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order Tracking',
                  style: GoogleFonts.manrope(fontSize: 22, fontWeight: FontWeight.w800),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: t['color'].withOpacity(0.1), shape: BoxShape.circle),
                    child: Icon(t['icon'], color: t['color']),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(t['title'], style: GoogleFonts.manrope(fontWeight: FontWeight.w800, fontSize: 16)),
                      Text(t['amount'], style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF64748B))),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Expanded(
              child: ListView.builder(
                itemCount: t['tracking'].length,
                itemBuilder: (context, index) {
                  bool isCompleted = index <= t['currentStep'];
                  bool isLast = index == t['tracking'].length - 1;
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        children: [
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isCompleted ? const Color(0xFF16A34A) : Colors.white,
                              border: Border.all(color: isCompleted ? const Color(0xFF16A34A) : const Color(0xFFE2E8F0), width: 2),
                            ),
                            child: isCompleted ? const Icon(Icons.check, size: 12, color: Colors.white) : null,
                          ),
                          if (!isLast)
                            Container(
                              width: 2,
                              height: 40,
                              color: isCompleted ? const Color(0xFF16A34A) : const Color(0xFFE2E8F0),
                            ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          t['tracking'][index],
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: isCompleted ? FontWeight.w700 : FontWeight.w500,
                            color: isCompleted ? const Color(0xFF1E293B) : const Color(0xFF94A3B8),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(String status) {
    Color bg;
    Color text;
    bool isGradient = false;

    if (status == 'Debited') {
      bg = AppColors.primaryBrownGold.withOpacity(0.1);
      text = AppColors.primaryBrownGold;
    } else if (status == 'Credited') {
      bg = Colors.transparent;
      text = const Color(0xFFFFFFFF);
      isGradient = true;
    } else {
      bg = const Color(0xFFE2E8F0);
      text = const Color(0xFF475569);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: isGradient ? null : bg,
        gradient: isGradient 
          ? const LinearGradient(
              colors: [Color(0xFF37D44E), Color(0xFF1C6E2B)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            )
          : null,
        borderRadius: BorderRadius.circular(99),
        border: isGradient ? null : Border.all(color: text.withOpacity(0.2)),
      ),
      child: Text(
        status,
        style: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: isGradient ? Colors.white : text,
        ),
      ),
    );
  }

  Widget _buildMonthlySummary() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF5EDE3), Color(0xFFC8A27B)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFC8A27B).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            top: -20,
            child: Icon(Icons.show_chart_rounded, color: Colors.white.withOpacity(0.2), size: 100),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'MONTHLY SUMMARY',
                style: GoogleFonts.inter(
                  color: Colors.black.withOpacity(0.6),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '₹1,12,450.00',
                style: GoogleFonts.manrope(
                  color: Colors.black,
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                'Total Expenses Oct 2025',
                style: GoogleFonts.inter(
                  color: Colors.black.withOpacity(0.6),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
