import 'dart:io';
import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/services/live_camera_service.dart';

class LiveCameraProofCard extends StatefulWidget {
  final File? photo;
  final ValueChanged<File?> onPhotoChanged;
  final String title;
  final String hint;
  final bool isRequired;

  const LiveCameraProofCard({
    super.key,
    required this.photo,
    required this.onPhotoChanged,
    this.title = 'Live Camera Handshake Proof',
    this.hint = 'Snap live photo of parcel condition. Gallery uploads are prohibited for audit security.',
    this.isRequired = false,
  });

  @override
  State<LiveCameraProofCard> createState() => _LiveCameraProofCardState();
}

class _LiveCameraProofCardState extends State<LiveCameraProofCard> {
  bool _isOpening = false;

  Future<void> _snapLive() async {
    setState(() => _isOpening = true);
    final file = await LiveCameraService.captureLiveProof();
    setState(() => _isOpening = false);

    if (file != null) {
      widget.onPhotoChanged(file);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasPhoto = widget.photo != null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: hasPhoto ? AppColors.brandEmerald.withOpacity(0.6) : Colors.white.withOpacity(0.09),
          width: hasPhoto ? 1.5 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                hasPhoto ? Icons.check_circle : Icons.camera_alt_outlined,
                color: hasPhoto ? AppColors.brandEmerald : AppColors.dispatchAmber,
                size: 16,
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  widget.title + (widget.isRequired ? ' *' : ''),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.urgentRed.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'LIVE ONLY',
                  style: TextStyle(
                    color: AppColors.urgentRed,
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            widget.hint,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 10.5,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 10),

          if (hasPhoto) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Stack(
                children: [
                  Image.file(
                    widget.photo!,
                    width: double.infinity,
                    height: 140,
                    fit: BoxFit.cover,
                  ),
                  Positioned(
                    bottom: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.75),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.verified, color: AppColors.brandEmerald, size: 13),
                          SizedBox(width: 4),
                          Text(
                            'Live Camera Capture',
                            style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () => widget.onPhotoChanged(null),
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.65),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close, color: Colors.white, size: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _isOpening ? null : _snapLive,
                icon: const Icon(Icons.refresh, size: 14),
                label: const Text('Retake Live Photo', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.dispatchAmber,
                  side: BorderSide(color: AppColors.dispatchAmber.withOpacity(0.5)),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
          ] else ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isOpening ? null : _snapLive,
                icon: _isOpening
                    ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                    : const Icon(Icons.camera_alt, size: 16),
                label: Text(
                  _isOpening ? 'Launching Camera...' : 'Open Camera to Snap Live Proof',
                  style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.dispatchAmber,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
