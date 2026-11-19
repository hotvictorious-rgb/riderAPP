import 'dart:io';
import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import 'live_camera_proof_card.dart';

class DeliveryAttemptFailedDialog extends StatefulWidget {
  final String orderNumber;
  final String customerName;
  final Future<Map<String, dynamic>> Function(String reason, String? notes, File? livePhoto) onSubmit;

  const DeliveryAttemptFailedDialog({
    super.key,
    required this.orderNumber,
    required this.customerName,
    required this.onSubmit,
  });

  @override
  State<DeliveryAttemptFailedDialog> createState() => _DeliveryAttemptFailedDialogState();
}

class _DeliveryAttemptFailedDialogState extends State<DeliveryAttemptFailedDialog> {
  String _selectedReason = 'customer_unreachable';
  final TextEditingController _notesController = TextEditingController();
  File? _livePhoto;
  bool _isSubmitting = false;
  String? _error;

  final Map<String, String> _reasons = {
    'customer_unreachable': 'Customer Phone Unreachable / Switched Off',
    'gate_locked': 'Estate Security Gate Locked / Denied Access',
    'customer_rescheduled': 'Customer Requested Later Delivery',
    'wrong_address': 'Address Inaccurate / Destination Not Found',
    'recipient_unavailable': 'No Recipient Available at Premises',
  };

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (_livePhoto == null) {
      setState(() => _error = 'Mandatory: Live camera photo of premises / locked gate is required as proof of attempt.');
      return;
    }
    setState(() {
      _isSubmitting = true;
      _error = null;
    });

    final notes = _notesController.text.trim();
    final result = await widget.onSubmit(_selectedReason, notes.isNotEmpty ? notes : null, _livePhoto);

    if (mounted) {
      if (result['success'] == true) {
        Navigator.pop(context, result);
      } else {
        setState(() {
          _isSubmitting = false;
          _error = result['message'] as String? ?? 'Failed to log delivery attempt.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.surfaceBorder, width: 1.0),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.urgentRed.withOpacity(0.12),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.urgentRed.withOpacity(0.25), width: 1.0),
                ),
                child: const Icon(Icons.report_problem_outlined, color: AppColors.urgentRed, size: 24),
              ),
            ),
            const SizedBox(height: 14),

            Center(
              child: const Text(
                'Report Delivery Issue',
                style: TextStyle(color: AppColors.textPrimary, fontSize: 17, fontWeight: FontWeight.w900),
              ),
            ),
            const SizedBox(height: 3),
            Center(
              child: Text(
                'Order ${widget.orderNumber} • ${widget.customerName}',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 16),

            // Live Camera Proof
            LiveCameraProofCard(
              photo: _livePhoto,
              onPhotoChanged: (f) => setState(() => _livePhoto = f),
              title: 'Estate Gate / Premises Proof Snap',
              hint: 'Snap live photo of closed gate or premises. Verifies physical courier presence.',
              isRequired: true,
            ),
            const SizedBox(height: 14),

            const Text(
              'REASON FOR FAILED ATTEMPT',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 10.5, fontWeight: FontWeight.w800, letterSpacing: 0.5),
            ),
            const SizedBox(height: 8),

            ..._reasons.entries.map((entry) {
              final isSelected = _selectedReason == entry.key;
              return GestureDetector(
                onTap: () => setState(() => _selectedReason = entry.key),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.urgentRed.withOpacity(0.12) : AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? AppColors.urgentRed.withOpacity(0.5) : AppColors.surfaceBorder,
                      width: 1.0,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                        color: isSelected ? AppColors.urgentRed : AppColors.textMuted,
                        size: 16,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          entry.value,
                          style: TextStyle(
                            color: isSelected ? Colors.white : AppColors.textSecondary,
                            fontSize: 11.5,
                            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),

            const SizedBox(height: 8),
            const Text(
              'INCIDENT NOTES (OPTIONAL)',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 10.5, fontWeight: FontWeight.w800, letterSpacing: 0.5),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _notesController,
              maxLines: 2,
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 12),
              decoration: InputDecoration(
                hintText: 'e.g., Called recipient 3 times, phone switched off...',
                hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 11.5),
                filled: true,
                fillColor: AppColors.surfaceElevated,
                contentPadding: const EdgeInsets.all(12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.surfaceBorder, width: 1.0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.surfaceBorder, width: 1.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.urgentRed, width: 1.5),
                ),
              ),
            ),

            if (_error != null) ...[
              const SizedBox(height: 10),
              Text(
                _error!,
                style: const TextStyle(color: AppColors.urgentRed, fontSize: 11, fontWeight: FontWeight.w700),
              ),
            ],
            const SizedBox(height: 18),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isSubmitting ? null : () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textMuted,
                      side: const BorderSide(color: AppColors.surfaceBorder, width: 1.0),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 46,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _handleSubmit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.urgentRed,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Text('Log Attempt', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12.5)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
