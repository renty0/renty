import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:renty/core/constant/app_colors.dart';
import 'package:renty/core/services/api_service.dart';

/// Wallet Dashboard — uses raw /api/v1/wallet/* endpoints
/// (not in the generated OpenAPI client).
class WalletPage extends StatefulWidget {
  const WalletPage({Key? key}) : super(key: key);

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  bool _isLoading = true;
  double _balance = 0.0;
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
      // Fetch balance
      final balanceResponse = await ApiService.client.invokeAPI(
        '/api/v1/wallet/balance', 'GET', [], null, {}, {}, null,
      );
      if (balanceResponse.statusCode == 200) {
        final balanceData = jsonDecode(balanceResponse.body);
        _balance = (balanceData['balance'] ?? 0).toDouble();
      }

      // Fetch transactions
      final txResponse = await ApiService.client.invokeAPI(
        '/api/v1/wallet/transactions', 'GET', [], null, {}, {}, null,
      );
      if (txResponse.statusCode == 200) {
        final txList = jsonDecode(txResponse.body) as List;
        _transactions = txList.map((e) => _WalletTransaction.fromJson(e)).toList();
      }

      setState(() => _isLoading = false);
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load wallet data';
        _isLoading = false;
      });
    }
  }

  Future<void> _requestWithdrawal(double amount, String mobileNumber) async {
    try {
      final body = jsonEncode({
        'amount': amount,
        'mobileWalletNumber': mobileNumber,
      });
      final response = await ApiService.client.invokeAPI(
        '/api/v1/wallet/withdraw', 'POST', [], body, 
        {'Content-Type': 'application/json'}, {}, 'application/json',
      );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        Get.snackbar('Success', 'Withdrawal requested successfully!',
            backgroundColor: AppColor.successColor.withOpacity(0.9),
            colorText: Colors.white);
        await _loadWallet();
      } else {
        final errBody = jsonDecode(response.body);
        Get.snackbar('Error', errBody['title'] ?? errBody['detail'] ?? 'Withdrawal failed',
            backgroundColor: AppColor.warningColor.withOpacity(0.9),
            colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('Error', 'Withdrawal request failed',
          backgroundColor: AppColor.warningColor.withOpacity(0.9),
          colorText: Colors.white);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : AppColor.backgroundcolor,
      appBar: AppBar(
        title: Text('Wallet', style: TextStyle(fontWeight: FontWeight.bold)),
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
                    physics: AlwaysScrollableScrollPhysics(),
                    child: Column(
                      children: [
                        _buildBalanceCard(isDark),
                        _buildTransactionsSection(isDark),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildBalanceCard(bool isDark) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColor.primaryColor, AppColor.secondColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColor.primaryColor.withOpacity(0.3),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.account_balance_wallet_outlined, color: Colors.white70, size: 20),
              SizedBox(width: 8),
              Text('Available Balance',
                  style: TextStyle(color: Colors.white70, fontSize: 14)),
            ],
          ),
          SizedBox(height: 12),
          Text(
            'EGP ${_balance.toStringAsFixed(2)}',
            style: TextStyle(
              color: Colors.white,
              fontSize: 34,
              fontWeight: FontWeight.bold,
              letterSpacing: -1,
            ),
          ),
          SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton.icon(
              onPressed: () => _showWithdrawDialog(),
              icon: Icon(Icons.arrow_upward_rounded, size: 18),
              label: Text('Withdraw', style: TextStyle(fontWeight: FontWeight.w600)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColor.primaryColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsSection(bool isDark) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Transaction History',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppColor.darkText,
              )),
          SizedBox(height: 12),
          if (_transactions.isEmpty)
            Container(
              padding: EdgeInsets.all(32),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.receipt_long_outlined, size: 48, color: AppColor.borderGray),
                    SizedBox(height: 12),
                    Text('No transactions yet',
                        style: TextStyle(color: AppColor.mediumText, fontSize: 14)),
                  ],
                ),
              ),
            )
          else
            ...(_transactions.map((tx) => _buildTransactionTile(tx, isDark))),
          SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildTransactionTile(_WalletTransaction tx, bool isDark) {
    final isCredit = tx.type.toLowerCase().contains('credit') ||
        tx.type.toLowerCase().contains('deposit') ||
        tx.type.toLowerCase().contains('earning');
    final amountColor = isCredit ? AppColor.successColor : AppColor.warningColor;
    final sign = isCredit ? '+' : '-';

    return Container(
      margin: EdgeInsets.only(bottom: 10),
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: AppColor.cardShadow, blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: amountColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isCredit ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
              size: 20,
              color: amountColor,
            ),
          ),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tx.description,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : AppColor.darkText,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4),
                Text(
                  tx.createdAt != null
                      ? DateFormat('MMM dd, yyyy – hh:mm a').format(tx.createdAt!)
                      : '',
                  style: TextStyle(fontSize: 11, color: AppColor.lightText),
                ),
              ],
            ),
          ),
          Text(
            '$sign EGP ${tx.amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: amountColor,
            ),
          ),
        ],
      ),
    );
  }

  void _showWithdrawDialog() {
    final amountController = TextEditingController();
    final mobileController = TextEditingController();
    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          return Container(
            padding: EdgeInsets.fromLTRB(
              24, 24, 24,
              24 + MediaQuery.of(ctx).viewInsets.bottom,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
                SizedBox(height: 20),
                Text('Request Withdrawal',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold,
                        color: AppColor.darkText)),
                SizedBox(height: 6),
                Text('Available: EGP ${_balance.toStringAsFixed(2)}',
                    style: TextStyle(fontSize: 14, color: AppColor.mediumText)),
                SizedBox(height: 20),
                // Amount
                Text('Amount', style: TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w600, color: AppColor.darkText)),
                SizedBox(height: 8),
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    hintText: 'Enter amount',
                    prefixText: 'EGP ',
                    filled: true,
                    fillColor: AppColor.backgroundcolor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: AppColor.primaryColor, width: 2),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                // Mobile Wallet Number
                Text('Mobile Wallet Number', style: TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w600, color: AppColor.darkText)),
                SizedBox(height: 8),
                TextField(
                  controller: mobileController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    hintText: 'Enter mobile wallet number',
                    filled: true,
                    fillColor: AppColor.backgroundcolor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: AppColor.primaryColor, width: 2),
                    ),
                  ),
                ),
                SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: isSubmitting
                        ? null
                        : () async {
                            final amount = double.tryParse(amountController.text.trim());
                            final mobile = mobileController.text.trim();
                            if (amount == null || amount <= 0) {
                              Get.snackbar('Error', 'Please enter a valid amount');
                              return;
                            }
                            if (amount > _balance) {
                              Get.snackbar('Error', 'Amount exceeds available balance');
                              return;
                            }
                            if (mobile.isEmpty) {
                              Get.snackbar('Error', 'Please enter mobile wallet number');
                              return;
                            }
                            setModalState(() => isSubmitting = true);
                            Navigator.pop(ctx);
                            await _requestWithdrawal(amount, mobile);
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: isSubmitting
                        ? SizedBox(width: 22, height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : Text('Request Withdrawal',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: AppColor.warningColor),
          SizedBox(height: 16),
          Text(_errorMessage!, style: TextStyle(fontSize: 16, color: AppColor.mediumText)),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadWallet,
            style: ElevatedButton.styleFrom(backgroundColor: AppColor.primaryColor),
            child: Text('Retry', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

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
      id: json['id'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      type: json['type'] ?? '',
      description: json['description'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
    );
  }
}
