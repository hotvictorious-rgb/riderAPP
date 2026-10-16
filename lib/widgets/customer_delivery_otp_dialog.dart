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
      backgroundColor: AppColors.obsidianCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(color: AppColors.primaryPurple, width: 1.5),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.primaryPurple.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.pin, color: AppColors.primaryPurple, size: 28),
            ),
            const SizedBox(height: 16),
            const Text(
              'Customer Handover OTP',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 6),
            Text(
              'Ask  for their 6-digit delivery security PIN to confirm handover.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
            const SizedBox(height: 16),

            // Live Camera Proof
            LiveCameraProofCard(
              photo: _livePhoto,
              onPhotoChanged: (f) => setState(() => _livePhoto = f),
              title: 'Doorstep Delivery Proof Snap',
              hint: 'Snap live picture of parcel at doorstep or customer handoff. Sealed permanently.',
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.richGold,
                fontSize: 24,
                fontWeight: FontWeight.w900,
                letterSpacing: 8,
              ),
              decoration: InputDecoration(
                counterText: '',
                hintText: '••••••',
                hintStyle: const TextStyle(color: AppColors.textMuted, letterSpacing: 8),
                filled: true,
                fillColor: Colors.black26,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.obsidianBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.primaryPurple, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel', style: TextStyle(color: AppColors.textMuted)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (_otpController.text.length == 6) {
                        widget.onVerify(_otpController.text.trim(), _livePhoto);
                        Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.dispatchEmerald),
                    child: const Text('Verify Handover'),
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
