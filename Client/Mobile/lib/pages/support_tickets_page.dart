import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:renty/api/lib/api.dart';
import 'package:renty/core/constant/app_colors.dart';
import 'package:renty/core/services/api_service.dart';

class SupportTicketsPage extends StatefulWidget {
  const SupportTicketsPage({super.key});

  @override
  State<SupportTicketsPage> createState() => _SupportTicketsPageState();
}

class _SupportTicketsPageState extends State<SupportTicketsPage> {
  bool _isLoading = true;
  List<TicketListDto> _tickets = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadTickets();
  }

  Future<void> _loadTickets() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final response = await ApiService.support.getSupportTickets();
      if (!mounted) return;
      if (response != null && response.data != null) {
        setState(() {
          _tickets =
              List<TicketListDto>.from(response.data!.tickets);
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Failed to load tickets';
        _isLoading = false;
      });
      print('SupportTickets error: ${e.code} ${e.message}');
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Failed to load tickets';
        _isLoading = false;
      });
    }
  }

  Color _statusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'open':
        return const Color(0xFF2563EB);
      case 'in_progress':
      case 'inprogress':
      case 'awaitingsupport':
        return const Color(0xFFF59E0B);
      case 'awaitingcustomer':
        return const Color(0xFF6366F1);
      case 'resolved':
        return const Color(0xFF10B981);
      case 'closed':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  String _statusLabel(String? status) {
    switch (status?.toLowerCase()) {
      case 'open':
        return 'Open';
      case 'in_progress':
      case 'inprogress':
        return 'In Progress';
      case 'awaitingsupport':
        return 'Awaiting Support';
      case 'awaitingcustomer':
        return 'Awaiting Response';
      case 'resolved':
        return 'Resolved';
      case 'closed':
        return 'Closed';
      default:
        return status ?? 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor =
        isDark ? const Color(0xFF121212) : AppColor.backgroundcolor;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text('Support',
            style: TextStyle(fontWeight: FontWeight.w700)),
        backgroundColor: AppColor.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Get.toNamed('/support/new');
          if (result == true) _loadTickets();
        },
        backgroundColor: AppColor.fourthColor,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('New Ticket',
            style: TextStyle(fontWeight: FontWeight.w600)),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColor.fourthColor))
          : _error != null
              ? _buildError(isDark)
              : _tickets.isEmpty
                  ? _buildEmpty(isDark)
                  : RefreshIndicator(
                      onRefresh: _loadTickets,
                      color: AppColor.fourthColor,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _tickets.length,
                        itemBuilder: (_, i) =>
                            _buildTicketCard(_tickets[i], isDark, cardColor),
                      ),
                    ),
    );
  }

  Widget _buildTicketCard(
      TicketListDto ticket, bool isDark, Color cardColor) {
    final statusColor = _statusColor(ticket.status);
    final date = ticket.createdAt != null
        ? DateFormat('MMM dd, yyyy').format(ticket.createdAt!.toLocal())
        : '';

    return GestureDetector(
      onTap: () async {
        if (ticket.id != null) {
          final result =
              await Get.toNamed('/support/detail', arguments: ticket.id);
          if (result == true) _loadTickets();
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _statusLabel(ticket.status),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: statusColor,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: (isDark ? Colors.white10 : Colors.grey[100])!,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    ticket.type ?? 'General',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white70 : AppColor.mediumText,
                    ),
                  ),
                ),
                const Spacer(),
                Icon(Icons.chevron_right_rounded,
                    color: isDark ? Colors.white30 : Colors.grey[350],
                    size: 22),
              ],
            ),
            const SizedBox(height: 10),
            if (ticket.id != null)
              Text(
                '#${ticket.id!.length > 8 ? ticket.id!.substring(0, 8) : ticket.id!}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white54 : AppColor.lightText,
                ),
              ),
            if (ticket.lastMessage != null &&
                ticket.lastMessage!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                ticket.lastMessage!,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.white70 : AppColor.mediumText,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 8),
            Text(
              date,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.white38 : AppColor.lightText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColor.fourthColor.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.confirmation_number_outlined,
                size: 56, color: AppColor.fourthColor.withOpacity(0.5)),
          ),
          const SizedBox(height: 20),
          Text('No Tickets Yet',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColor.darkText)),
          const SizedBox(height: 8),
          Text('Tap + to create a support ticket',
              style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.white54 : AppColor.mediumText)),
        ],
      ),
    );
  }

  Widget _buildError(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.cloud_off_rounded, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(_error!,
              style: TextStyle(
                  fontSize: 16,
                  color: isDark ? Colors.white70 : AppColor.mediumText)),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _loadTickets,
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.fourthColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }
}
