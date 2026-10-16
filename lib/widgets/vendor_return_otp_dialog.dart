import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../models/return_case_model.dart';

class VendorReturnOtpDialog extends StatefulWidget {
  final ReturnCaseModel returnCase;
  final Future<bool> Function(String otp) onVerify;

  const VendorReturnOtpDialog({
    super.key,
    required this.returnCase,
    required this.onVerify,
  });

  @override
  State<VendorReturnOtpDialog> createState() => _VendorReturnOtpDialogState();
}

class _VendorReturnOtpDialogState extends State<VendorReturnOtpDialog> {
  final TextEditingController _otpController = TextEditingController();
  bool _isSubmitting = false;
  String? _error;

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final otp = _otpController.text.trim();
    if (otp.length != 6) {
      setState(() => _error = 'Please enter the 6-digit Vendor Shop Return PIN.');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _error = null;
    });

    final success = await widget.onVerify(otp);

    if (mounted) {
      if (success) {
        Navigator.pop(context, true);
      } else {
        setState(() {
          _isSubmitting = false;
          _error = 'Vendor shop return PIN invalid or rejected.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.obsidianCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(color: AppColors.richGold, width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: AppColors.richGold.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.store, color: AppColors.richGold, size: 28),
            ),
            const SizedBox(height: 14),
            const Text(
              'Merchant Return Handover',
              style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 4),
            Text(
              'Case: ${widget.returnCase.caseNumber}',
              style: const TextStyle(color: AppColors.richGold, fontSize: 12, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              'Drop-off at ${widget.returnCase.shopName}.\nAsk the merchant for their 6-digit Return Confirmation PIN.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 11.5, height: 1.4),
            ),
            const SizedBox(height: 18),
            TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.richGold, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: 8),
              decoration: InputDecoration(
                counterText: '',
                hintText: '••••••',
                hintStyle: const TextStyle(color: AppColors.textMuted, letterSpacing: 8),
                filled: true,
                fillColor: Colors.black26,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.obsidianBorder)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.richGold, width: 2)),
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 10),
              Text(_error!, style: const TextStyle(color: AppColors.urgentRed, fontSize: 11)),
            ],
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: _isSubmitting ? null : () => Navigator.pop(context),
                    child: const Text('Cancel', style: TextStyle(color: AppColors.textMuted)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.richGold,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                        : const Text('Certify Return to Shop', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12)),
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
