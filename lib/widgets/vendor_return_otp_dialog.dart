import 'dart:io';
import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../models/return_case_model.dart';
import 'live_camera_proof_card.dart';

class VendorReturnOtpDialog extends StatefulWidget {
  final ReturnCaseModel returnCase;
  final Future<bool> Function(String otp, File? livePhoto) onVerify;

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
  File? _livePhoto;
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
    if (_livePhoto == null) {
      setState(() => _error = 'Mandatory: Live photo of returned package at merchant counter is required.');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _error = null;
    });

    final success = await widget.onVerify(otp, _livePhoto);

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
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primaryGold.withOpacity(0.12),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primaryGold.withOpacity(0.25), width: 1.0),
              ),
              child: const Icon(Icons.store, color: AppColors.primaryGold, size: 24),
            ),
            const SizedBox(height: 14),
            const Text(
              'Merchant Return Handover',
              style: TextStyle(color: AppColors.textPrimary, fontSize: 17, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'Case: ${widget.returnCase.caseNumber}',
                style: const TextStyle(color: AppColors.primaryGold, fontSize: 11, fontWeight: FontWeight.w800),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Drop-off at ${widget.returnCase.shopName}.\nAsk the merchant for their 6-digit Return Confirmation PIN.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 11.5, height: 1.4),
            ),
            const SizedBox(height: 16),

            // Live Camera Proof
            LiveCameraProofCard(
              photo: _livePhoto,
              onPhotoChanged: (f) => setState(() => _livePhoto = f),
              title: 'Merchant Return Counter Snap',
              hint: 'Snap live picture of parcel placed on merchant counter.',
              isRequired: true,
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.primaryGold, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: 8),
              decoration: InputDecoration(
                counterText: '',
                hintText: '••••••',
                hintStyle: const TextStyle(color: AppColors.textMuted, letterSpacing: 8),
                filled: true,
                fillColor: AppColors.surfaceElevated,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.surfaceBorder, width: 1.0)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.surfaceBorder, width: 1.0)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.primaryGold, width: 1.5)),
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 10),
              Text(_error!, style: const TextStyle(color: AppColors.urgentRed, fontSize: 11, fontWeight: FontWeight.w700)),
            ],
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: _isSubmitting ? null : () => Navigator.pop(context),
                    child: const Text('Cancel', style: TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.w700)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: SizedBox(
                    height: 46,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGold,
                        foregroundColor: Colors.black,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                          : const Text('Certify Return to Shop', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12.5)),
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
