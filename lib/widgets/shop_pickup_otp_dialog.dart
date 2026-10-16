import 'dart:io';
import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import 'live_camera_proof_card.dart';

class ShopPickupOtpDialog extends StatefulWidget {
  final String orderNumber;
  final String shopName;
  final Future<bool> Function(String otp, File? livePhoto) onVerify;

  const ShopPickupOtpDialog({
    super.key,
    required this.orderNumber,
    required this.shopName,
    required this.onVerify,
  });

  @override
  State<ShopPickupOtpDialog> createState() => _ShopPickupOtpDialogState();
}

class _ShopPickupOtpDialogState extends State<ShopPickupOtpDialog> {
  final TextEditingController _pinController = TextEditingController();
  File? _livePhoto;
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final pin = _pinController.text.trim();
    if (pin.length != 6) {
      setState(() => _error = 'Please enter the 6-digit Shop Handover PIN.');
      return;
    }
    if (_livePhoto == null) {
      setState(() => _error = 'Mandatory: Live photo of package at merchant counter is required before verifying OTP.');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    final success = await widget.onVerify(pin, _livePhoto);
    if (mounted) {
      if (success) {
        Navigator.pop(context, true);
      } else {
        setState(() {
          _isLoading = false;
          _error = 'Invalid merchant pickup PIN. Please ask shop staff to check their dashboard.';
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
        side: BorderSide(color: AppColors.dispatchAmber.withOpacity(0.5), width: 1.5),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon Header
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: AppColors.dispatchAmber.withOpacity(0.15),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.dispatchAmber.withOpacity(0.4)),
              ),
              child: const Icon(Icons.store, color: AppColors.dispatchAmber, size: 28),
            ),
            const SizedBox(height: 16),

            const Text(
              'Merchant Shop Handover',
              style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 4),
            Text(
              'Order ',
              style: const TextStyle(color: AppColors.dispatchAmber, fontSize: 12, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.04),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.06)),
              ),
              child: Text(
                'Collect package at . Ask merchant staff for their 6-digit Pickup Handover PIN to certify collection.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 11.5, height: 1.45),
              ),
            ),
            const SizedBox(height: 16),

            // Live Camera Proof
            LiveCameraProofCard(
              photo: _livePhoto,
              onPhotoChanged: (f) => setState(() => _livePhoto = f),
              title: 'Merchant Counter Parcel Snap',
              hint: 'Snap live photo of package at merchant counter. Live proof permanently protects you from transit damage claims.',
            ),
            const SizedBox(height: 16),

            // 6-digit PIN Input
            TextField(
              controller: _pinController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.dispatchAmber,
                fontSize: 24,
                fontWeight: FontWeight.w900,
                letterSpacing: 10,
              ),
              decoration: InputDecoration(
                hintText: '••••••',
                hintStyle: TextStyle(color: AppColors.textMuted.withOpacity(0.4), letterSpacing: 10),
                counterText: '',
                filled: true,
                fillColor: Colors.black.withOpacity(0.35),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: AppColors.dispatchAmber.withOpacity(0.4)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.dispatchAmber, width: 2),
                ),
              ),
            ),

            if (_error != null) ...[
              const SizedBox(height: 10),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.urgentRed, fontSize: 11, fontWeight: FontWeight.w700),
              ),
            ],
            const SizedBox(height: 20),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isLoading ? null : () => Navigator.pop(context, false),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textMuted,
                      side: const BorderSide(color: AppColors.obsidianBorder),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.dispatchAmber,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isLoading
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                        : const Text('Verify Pickup', style: TextStyle(fontWeight: FontWeight.w900)),
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
