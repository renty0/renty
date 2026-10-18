import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:renty/core/constant/app_colors.dart';
import 'package:renty/core/services/api_service.dart';
import 'package:renty/core/utils/app_navigator.dart';

/// Wallet Dashboard — uses raw /api/v1/wallet/* endpoints.
/// Mirrors the Web wallet-dashboard.component.ts functionality.
class WalletPage extends StatefulWidget {
  const WalletPage({Key? key}) : super(key: key);

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  bool _isLoading = true;
  double _balance = 0.0;
  double _pendingBalance = 0.0;
  List<_WalletTransaction> _transactions = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadWallet();
  }

  Future<void> _loadWallet() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // ── Fetch balance ──────────────────────────────────────────────────────
      final balanceResponse = await ApiService.client.invokeAPI(
        '/api/v1/wallet/balance', 'GET', [], null, {}, {}, null,
      );
      if (balanceResponse.statusCode == 200 && balanceResponse.body.isNotEmpty) {
        final env = jsonDecode(balanceResponse.body) as Map<String, dynamic>;
        final data = (env['data'] as Map<String, dynamic>?) ?? {};
        _balance = (data['balance'] ?? 0).toDouble();
        _pendingBalance = (data['pendingBalance'] ?? 0).toDouble();
      } else {
        throw Exception('Balance load failed: ${balanceResponse.statusCode}');
      }

      // ── Fetch transactions ─────────────────────────────────────────────────
      final txResponse = await ApiService.client.invokeAPI(
        '/api/v1/wallet/transactions', 'GET', [], null, {}, {}, null,
      );
      if (txResponse.statusCode == 200 && txResponse.body.isNotEmpty) {
        final env = jsonDecode(txResponse.body) as Map<String, dynamic>;
        final data = (env['data'] as Map<String, dynamic>?) ?? {};
        final txList = (data['transactions'] as List?) ?? [];
        _transactions = txList
            .map((e) => _WalletTransaction.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      if (mounted) setState(() => _isLoading = false);
    } catch (e) {
      print('Wallet load error: $e');
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load wallet data'.tr;
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _requestTopUp(double amount) async {
    try {
      final response = await ApiService.client.invokeAPI(
        '/api/v1/wallet/topup',
        'POST',
        [],
        {'amount': amount},
        {},
        {},
        'application/json',
      );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        AppNavigator.showSnackBar('Success'.tr, 'Wallet topped up successfully!'.tr,
            backgroundColor: AppColor.successColor.withOpacity(0.9),
            textColor: Colors.white);
        await _loadWallet();
      } else {
        final errBody = response.body.isNotEmpty ? jsonDecode(response.body) : {};
        final messages = (errBody['messages'] as List?)?.join(', ') ?? 'Top up failed'.tr;
        AppNavigator.showSnackBar('Error'.tr, messages,
            backgroundColor: AppColor.warningColor.withOpacity(0.9),
            textColor: Colors.white);
      }
    } catch (e) {
      AppNavigator.showSnackBar('Error'.tr, 'Top up failed'.tr,
          backgroundColor: AppColor.warningColor.withOpacity(0.9),
          textColor: Colors.white);
    }
  }

  Future<void> _requestWithdrawal(double amount, String mobileWalletNumber) async {
    try {
      final response = await ApiService.client.invokeAPI(
        '/api/v1/wallet/withdraw',
        'POST',
        [],
        {
          'amount': amount,
          'mobileWalletNumber': mobileWalletNumber,
        },
        {},
        {},
        'application/json',
      );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        AppNavigator.showSnackBar('Success'.tr, 'Withdrawal requested successfully!'.tr,
            backgroundColor: AppColor.successColor.withOpacity(0.9),
            textColor: Colors.white);
        await _loadWallet();
      } else {
        final errBody = response.body.isNotEmpty ? jsonDecode(response.body) : {};
        final messages = (errBody['messages'] as List?)?.join(', ') ?? 'Withdrawal failed'.tr;
        AppNavigator.showSnackBar('Error'.tr, messages,
            backgroundColor: AppColor.warningColor.withOpacity(0.9),
            textColor: Colors.white);
      }
    } catch (e) {
      AppNavigator.showSnackBar('Error'.tr, 'Withdrawal request failed'.tr,
          backgroundColor: AppColor.warningColor.withOpacity(0.9),
          textColor: Colors.white);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : AppColor.backgroundcolor,
      appBar: AppBar(
        title: Text('Wallet'.tr, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColor.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: AppColor.primaryColor))
          : _errorMessage != null
              ? _buildError()
              : RefreshIndicator(
                  onRefresh: _loadWallet,
                  color: AppColor.primaryColor,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      children: [
                        _buildBalanceCardsCarousel(isDark),
                        _buildStatsRow(isDark),
                        _buildTransactionsSection(isDark),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildBalanceCardsCarousel(bool isDark) {
    final cardWidth = MediaQuery.of(context).size.width * 0.82;
    final cardHeight = 195.0;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          // ── 1. Available Balance Card (Blue/Indigo Gradient with action buttons) ──
          Container(
            width: cardWidth,
            height: cardHeight,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4F46E5), Color(0xFF6366F1)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4F46E5).withOpacity(0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'AVAILABLE BALANCE'.tr,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(Icons.account_balance_wallet_outlined, color: Colors.white, size: 16),
                    ),
                  ],
                ),
                Text(
                  'EGP ${_balance.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 38,
                        child: ElevatedButton.icon(
                          onPressed: _balance > 0 ? () => _showWithdrawDialog() : null,
                          icon: const Icon(Icons.arrow_upward_rounded, size: 14),
                          label: Text(
                            'Withdraw'.tr,
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF4F46E5),
                            disabledBackgroundColor: Colors.white.withOpacity(0.5),
                            disabledForegroundColor: Colors.white70,
                            elevation: 0,
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: SizedBox(
                        height: 38,
                        child: ElevatedButton.icon(
                          onPressed: () => _showTopUpDialog(),
                          icon: const Icon(Icons.add_rounded, size: 14),
                          label: Text(
                            'Top Up'.tr,
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white.withOpacity(0.2),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: const BorderSide(color: Colors.white30),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // ── 2. Total Balance Card ──
          _buildStaticBalanceCard(
            isDark: isDark,
            width: cardWidth,
            height: cardHeight,
            title: 'TOTAL BALANCE'.tr,
            amount: _balance + _pendingBalance,
            icon: Icons.account_balance_outlined,
          ),
          const SizedBox(width: 12),

          // ── 3. Withdrawable Balance Card ──
          _buildStaticBalanceCard(
            isDark: isDark,
            width: cardWidth,
            height: cardHeight,
            title: 'WITHDRAWABLE BALANCE'.tr,
            amount: _balance,
            icon: Icons.wallet_giftcard_rounded,
          ),
          const SizedBox(width: 12),

          // ── 4. Pending Balance Card ──
          _buildStaticBalanceCard(
            isDark: isDark,
            width: cardWidth,
            height: cardHeight,
            title: 'PENDING BALANCE'.tr,
            amount: _pendingBalance,
            icon: Icons.pending_actions_outlined,
          ),
        ],
      ),
    );
  }

  Widget _buildStaticBalanceCard({
    required bool isDark,
    required double width,
    required double height,
    required String title,
    required double amount,
    required IconData icon,
  }) {
    final cardBgColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : AppColor.darkText;

    return Container(
      width: width,
      height: height,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColor.cardShadow,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title.toUpperCase(),
                style: const TextStyle(
                  color: AppColor.mediumText,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: AppColor.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(icon, color: AppColor.primaryColor, size: 16),
              ),
            ],
          ),
          Text(
            'EGP ${amount.toStringAsFixed(2)}',
            style: TextStyle(
              color: textColor,
              fontSize: 26,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
          Text(
            'Updated just now'.tr,
            style: const TextStyle(color: AppColor.lightText, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(bool isDark) {
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final totalEarnings = _transactions
        .where((t) =>
            t.type == 'RentalEarnings' ||
            t.type == 'RentalIncome' ||
            t.type == 'Adjustment' && t.amount > 0)
        .fold<double>(0, (sum, t) => sum + t.amount);

    final totalSpent = _transactions
        .where((t) => t.amount < 0 || t.type == 'EscrowHold' || t.type == 'Withdrawal')
        .fold<double>(0, (sum, t) => sum + t.amount.abs());

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Row(children: [
        Expanded(child: _buildStatCard(
          isDark: isDark,
          cardColor: cardColor,
          icon: Icons.trending_up_rounded,
          iconColor: AppColor.successColor,
          label: 'Total Earnings'.tr,
          value: 'EGP ${totalEarnings.toStringAsFixed(2)}',
          valueColor: AppColor.successColor,
        )),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard(
          isDark: isDark,
          cardColor: cardColor,
          icon: Icons.trending_down_rounded,
          iconColor: AppColor.warningColor,
          label: 'Total Spent'.tr,
          value: 'EGP ${totalSpent.toStringAsFixed(2)}',
          valueColor: AppColor.warningColor,
        )),
      ]),
    );
  }

  Widget _buildStatCard({
    required bool isDark,
    required Color cardColor,
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    required Color valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: AppColor.cardShadow, blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 20, color: iconColor),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label,
                style: TextStyle(fontSize: 11, color: isDark ? Colors.white54 : AppColor.mediumText)),
            const SizedBox(height: 2),
            Text(value,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: valueColor),
                maxLines: 1, overflow: TextOverflow.ellipsis),
          ]),
        ),
      ]),
    );
  }

  Widget _buildTransactionsSection(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Transaction History'.tr,
              style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppColor.darkText,
              )),
          const SizedBox(height: 12),
          if (_transactions.isEmpty)
            Container(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: Column(children: [
                  Icon(Icons.receipt_long_outlined, size: 48, color: AppColor.borderGray),
                  const SizedBox(height: 12),
                  Text('No transactions yet'.tr,
                      style: TextStyle(color: AppColor.mediumText, fontSize: 14)),
                ]),
              ),
            )
          else
            ...(_transactions.map((tx) => _buildTransactionTile(tx, isDark))),
        ],
      ),
    );
  }

  Widget _buildTransactionTile(_WalletTransaction tx, bool isDark) {
    final isCredit = tx.amount > 0;
    final amountColor = isCredit ? AppColor.successColor : AppColor.warningColor;
    final sign = isCredit ? '+' : '';
    final localizedType = _localizeType(tx.type);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: AppColor.cardShadow, blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: amountColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            isCredit ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
            size: 20, color: amountColor,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              localizedType,
              style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : AppColor.darkText,
              ),
              maxLines: 1, overflow: TextOverflow.ellipsis,
            ),
            if (tx.description.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                tx.description,
                style: TextStyle(fontSize: 12, color: isDark ? Colors.white54 : AppColor.mediumText),
                maxLines: 1, overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 4),
            Text(
              tx.createdAt != null
                  ? DateFormat('MMM dd, yyyy – hh:mm a').format(tx.createdAt!)
                  : '',
              style: TextStyle(fontSize: 11, color: AppColor.lightText),
            ),
          ]),
        ),
        Text(
          '$sign EGP ${tx.amount.abs().toStringAsFixed(2)}',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: amountColor),
        ),
      ]),
    );
  }

  String _localizeType(String type) {
    const map = {
      'Adjustment': 'Adjustment',
      'Withdrawal': 'Withdrawal',
      'EscrowHold': 'Escrow Hold',
      'EscrowRelease': 'Escrow Release',
      'Penalty': 'Penalty',
      'PendingEarnings': 'Pending Earnings',
      'RentalEarnings': 'Rental Earnings',
      'RentalIncome': 'Rental Income',
      'Refund': 'Refund',
    };
    return (map[type] ?? type).tr;
  }

  // ── Top Up Dialog ──────────────────────────────────────────────────────────

  void _showTopUpDialog() {
    final amountController = TextEditingController();
    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          final isDark = Theme.of(ctx).brightness == Brightness.dark;
          return Container(
            padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + MediaQuery.of(ctx).viewInsets.bottom),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40, height: 4,
                    decoration: BoxDecoration(
                      color: AppColor.borderGray,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text('Top Up Wallet'.tr,
                    style: TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AppColor.darkText)),
                const SizedBox(height: 6),
                Text('Simulated top-up for testing purposes.'.tr,
                    style: TextStyle(fontSize: 13, color: AppColor.mediumText)),
                const SizedBox(height: 20),
                Text('Amount'.tr,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : AppColor.darkText)),
                const SizedBox(height: 8),
                TextField(
                  controller: amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: TextStyle(color: isDark ? Colors.white : AppColor.darkText),
                  decoration: InputDecoration(
                    hintText: 'Enter amount'.tr,
                    prefixText: 'EGP ',
                    prefixStyle: TextStyle(color: isDark ? Colors.white70 : AppColor.darkText),
                    filled: true,
                    fillColor: isDark ? const Color(0xFF2A2A2A) : AppColor.backgroundcolor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: AppColor.primaryColor, width: 2),
                    ),
                  ),
                ),
                // Quick amounts
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: [50.0, 100.0, 200.0, 500.0].map((v) => ActionChip(
                    label: Text('EGP ${v.toInt()}'),
                    onPressed: () => amountController.text = v.toStringAsFixed(0),
                    backgroundColor: AppColor.primaryColor.withOpacity(0.1),
                    labelStyle: const TextStyle(color: AppColor.primaryColor, fontWeight: FontWeight.w600),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    side: BorderSide.none,
                  )).toList(),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: isSubmitting
                        ? null
                        : () async {
                            final amount = double.tryParse(amountController.text.trim());
                            if (amount == null || amount <= 0) {
                              AppNavigator.showSnackBar('Error'.tr, 'Please enter a valid amount'.tr);
                              return;
                            }
                            setModalState(() => isSubmitting = true);
                            Navigator.pop(ctx);
                            await _requestTopUp(amount);
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: isSubmitting
                        ? const SizedBox(width: 22, height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : Text('Top Up'.tr,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ── Withdraw Dialog ────────────────────────────────────────────────────────

  void _showWithdrawDialog() {
    final amountController = TextEditingController();
    final accountController = TextEditingController();
    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          final isDark = Theme.of(ctx).brightness == Brightness.dark;
          return Container(
            padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + MediaQuery.of(ctx).viewInsets.bottom),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40, height: 4,
                    decoration: BoxDecoration(
                      color: AppColor.borderGray,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text('Request Withdrawal'.tr,
                    style: TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AppColor.darkText)),
                const SizedBox(height: 6),
                Text('${'Available'.tr}: EGP ${_balance.toStringAsFixed(2)}',
                    style: TextStyle(fontSize: 14, color: AppColor.mediumText)),
                const SizedBox(height: 20),
                Text('Amount'.tr,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : AppColor.darkText)),
                const SizedBox(height: 8),
                TextField(
                  controller: amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: TextStyle(color: isDark ? Colors.white : AppColor.darkText),
                  decoration: InputDecoration(
                    hintText: 'Enter amount'.tr,
                    prefixText: 'EGP ',
                    prefixStyle: TextStyle(color: isDark ? Colors.white70 : AppColor.darkText),
                    filled: true,
                    fillColor: isDark ? const Color(0xFF2A2A2A) : AppColor.backgroundcolor,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: AppColor.primaryColor, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text('Mobile Wallet Number'.tr,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : AppColor.darkText)),
                const SizedBox(height: 8),
                TextField(
                  controller: accountController,
                  style: TextStyle(color: isDark ? Colors.white : AppColor.darkText),
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    hintText: 'Enter mobile wallet number'.tr,
                    filled: true,
                    fillColor: isDark ? const Color(0xFF2A2A2A) : AppColor.backgroundcolor,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: AppColor.primaryColor, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: isSubmitting
                        ? null
                        : () async {
                            final amount = double.tryParse(amountController.text.trim());
                            final mobileNumber = accountController.text.trim();
                            if (amount == null || amount <= 0) {
                              AppNavigator.showSnackBar('Error'.tr, 'Please enter a valid amount'.tr);
                              return;
                            }
                            if (amount > _balance) {
                              AppNavigator.showSnackBar('Error'.tr, 'Amount exceeds available balance'.tr);
                              return;
                            }
                            if (mobileNumber.isEmpty) {
                              AppNavigator.showSnackBar('Error'.tr, 'Please enter mobile wallet number'.tr);
                              return;
                            }
                            setModalState(() => isSubmitting = true);
                            Navigator.pop(ctx);
                            await _requestWithdrawal(amount, mobileNumber);
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: isSubmitting
                        ? const SizedBox(width: 22, height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : Text('Request Withdrawal'.tr,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.account_balance_wallet_outlined, size: 72, color: AppColor.borderGray),
            const SizedBox(height: 16),
            Text(_errorMessage!,
                style: const TextStyle(fontSize: 16, color: AppColor.mediumText),
                textAlign: TextAlign.center),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadWallet,
              icon: const Icon(Icons.refresh_rounded),
              label: Text('Retry'.tr, style: const TextStyle(fontWeight: FontWeight.w600)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Model ──────────────────────────────────────────────────────────────────

class _WalletTransaction {
  final String id;
  final double amount;
  final String type;
  final String description;
  final DateTime? createdAt;

  _WalletTransaction({
    required this.id,
    required this.amount,
    required this.type,
    required this.description,
    this.createdAt,
  });

  factory _WalletTransaction.fromJson(Map<String, dynamic> json) {
    return _WalletTransaction(
      id: json['id']?.toString() ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      type: json['type']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
    );
  }
}
