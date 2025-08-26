import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:office_management/core/services/supabase_service.dart';

class SubscriptionStatusDialog extends StatefulWidget {
  final Map<String, dynamic> companyData;
  final VoidCallback onLogout;

  const SubscriptionStatusDialog({
    super.key,
    required this.companyData,
    required this.onLogout,
  });

  @override
  State<SubscriptionStatusDialog> createState() =>
      _SubscriptionStatusDialogState();
}

class _SubscriptionStatusDialogState extends State<SubscriptionStatusDialog> {
  bool _canClose = true;

  @override
  void initState() {
    super.initState();
    // Determine if the dialog can be closed based on company status
    final status = widget.companyData['status'] as String?;
    _canClose = status != 'canceled' && status != 'expired';
  }

  @override
  Widget build(BuildContext context) {
    final status = widget.companyData['status'] as String?;
    final isActive = widget.companyData['is_active'] as bool?;
    final trialEndDate = _parseDate(widget.companyData['trial_end_date']);

    return WillPopScope(
      onWillPop: () async => _canClose,
      child: ShadDialog(
        title: Text(_getTitle(status)),
        description: Text(_getDescription(status, trialEndDate)),
        actions: [
          if (status == 'trialing') ...[
            ShadButton.outline(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ] else if (status == 'canceled' || status == 'expired') ...[
            ShadButton(onPressed: widget.onLogout, child: const Text('Logout')),
          ] else if (isActive == false) ...[
            ShadButton(onPressed: widget.onLogout, child: const Text('Logout')),
          ],
        ],
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (status == 'trialing' && trialEndDate != null) ...[
              const SizedBox(height: 16),
              Text(
                'Trial ends on: ${_formatDate(trialEndDate)}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ] else if (isActive == false) ...[
              const SizedBox(height: 16),
              const Text(
                'Please contact Cendra Softwares for assistance.',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ],
        ),
      ),
    );
  }

  DateTime? _parseDate(dynamic date) {
    if (date == null) return null;
    if (date is DateTime) return date;
    if (date is String) {
      try {
        return DateTime.parse(date);
      } catch (e) {
        print('Error parsing date: $e');
        return null;
      }
    }
    return null;
  }

  String _getTitle(String? status) {
    switch (status) {
      case 'trialing':
        return 'Trial Period';
      case 'active':
        return 'Subscription Active';
      case 'canceled':
        return 'Subscription Canceled';
      case 'expired':
        return 'Subscription Expired';
      default:
        return 'Subscription Status';
    }
  }

  String _getDescription(String? status, DateTime? trialEndDate) {
    switch (status) {
      case 'trialing':
        return 'You are currently using the trial version of our software.';
      case 'active':
        return 'Your subscription is active.';
      case 'canceled':
        return 'Your subscription has been canceled. Please renew to continue using the service.';
      case 'expired':
        return 'Your subscription has expired. Please renew to continue using the service.';
      default:
        if (widget.companyData['is_active'] == false) {
          return 'Your account is currently inactive. Please contact support.';
        }
        return 'Unknown subscription status.';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
