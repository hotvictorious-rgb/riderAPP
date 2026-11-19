import 'dart:io';
import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import 'live_camera_proof_card.dart';

class CustomerDeliveryOtpDialog extends StatefulWidget {
  final String orderNumber;
  final String customerName;
  final Function(String otp, File? livePhoto) onVerify;

  const CustomerDeliveryOtpDialog({
    super.key,
    required this.orderNumber,
    required this.customerName,
    required this.onVerify,
  });

  @override
  State<CustomerDeliveryOtpDialog> createState() => _CustomerDeliveryOtpDialogState();
}

class _CustomerDeliveryOtpDialogState extends State<CustomerDeliveryOtpDialog> {
  final TextEditingController _otpController = TextEditingController();
  File? _livePhoto;

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
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
                color: AppColors.dispatchEmerald.withOpacity(0.12),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.dispatchEmerald.withOpacity(0.25), width: 1.0),
              ),
              child: const Icon(Icons.pin, color: AppColors.dispatchEmerald, size: 24),
            ),
            const SizedBox(height: 14),
            const Text(
              'Customer Handover OTP',
              style: TextStyle(color: AppColors.textPrimary, fontSize: 17, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 4),
            Text(
              'Ask ${widget.customerName} for their 6-digit delivery security PIN to confirm handover.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, height: 1.3),
            ),
            const SizedBox(height: 16),

            // Live Camera Proof
            LiveCameraProofCard(
              photo: _livePhoto,
              onPhotoChanged: (f) => setState(() => _livePhoto = f),
              title: 'Doorstep Delivery Proof Snap',
              hint: 'Snap live picture of parcel at doorstep or customer handoff. Sealed permanently.',
              isRequired: true,
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.primaryGold,
                fontSize: 22,
                fontWeight: FontWeight.w900,
                letterSpacing: 8,
              ),
              decoration: InputDecoration(
                counterText: '',
                hintText: '••••••',
                hintStyle: const TextStyle(color: AppColors.textMuted, letterSpacing: 8),
                filled: true,
                fillColor: AppColors.surfaceElevated,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.surfaceBorder, width: 1.0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.surfaceBorder, width: 1.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.primaryGold, width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel', style: TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.w700)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: SizedBox(
                    height: 46,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_livePhoto == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              backgroundColor: AppColors.urgentRed,
                              content: Text('Mandatory: Live photo of parcel at doorstep is required before verifying OTP.'),
                            ),
                          );
                          return;
                        }
                        if (_otpController.text.trim().length != 6) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              backgroundColor: AppColors.urgentRed,
                              content: Text('Please enter the full 6-digit Customer Security PIN.'),
                            ),
                          );
                          return;
                        }
                        widget.onVerify(_otpController.text.trim(), _livePhoto);
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.dispatchEmerald,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text('Verify Handover', style: TextStyle(fontWeight: FontWeight.w800)),
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
