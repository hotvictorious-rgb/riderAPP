import 'dart:io';
import 'package:image_picker/image_picker.dart';

/// Sovereign Live Camera Capture Service
/// Enforces physical presence verification across all delivery and pickup OTP handshakes.
/// Gallery access is strictly disallowed to eliminate stale, faked, or internet-downloaded photos.
class LiveCameraService {
  static final ImagePicker _picker = ImagePicker();

  /// Captures a live picture directly from the device rear camera.
  /// Formats and compresses image to ~1280px at 75% quality for rapid transmission
  /// across Nigerian mobile networks (MTN, Airtel, Glo).
  static Future<File?> captureLiveProof() async {
    try {
      final XFile? file = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.rear,
        imageQuality: 75,
        maxWidth: 1280,
        maxHeight: 1280,
      );

      return file != null ? File(file.path) : null;
    } catch (e) {
      // In case camera permission was denied or interrupted
      return null;
    }
  }
}
