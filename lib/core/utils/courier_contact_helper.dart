import 'package:url_launcher/url_launcher.dart';

class CourierContactHelper {
  static const String defaultDispatchHotline = '09118949035';

  static String sanitizePhone(String phone) {
    return phone.replaceAll(RegExp(r'[^0-9+]'), '').trim();
  }

  static String toInternational(String phone) {
    String p = phone.replaceAll(RegExp(r'[^0-9]'), '').trim();
    if (p.startsWith('0') && p.length == 11) {
      return '234${p.substring(1)}';
    } else if (!p.startsWith('234') && p.isNotEmpty) {
      return '234$p';
    }
    return p;
  }

  static Future<bool> callPhone(String phone) async {
    final clean = sanitizePhone(phone);
    if (clean.isEmpty) return false;
    final uri = Uri.parse('tel:$clean');
    if (await canLaunchUrl(uri)) {
      return await launchUrl(uri);
    }
    return false;
  }

  static Future<bool> openWhatsApp(
    String phone, {
    String? orderNumber,
    String? recipientName,
    bool isShop = false,
  }) async {
    final intl = toInternational(phone);
    if (intl.isEmpty) return false;

    final greeting = recipientName != null && recipientName.trim().isNotEmpty
        ? 'Hello ${recipientName.trim()}, '
        : 'Hello, ';
    final subject = isShop
        ? 'I am the Victorious Market courier arriving for pickup'
        : 'I am your Victorious Market dispatch courier on the way';
    final ref = orderNumber != null ? ' for order #$orderNumber' : '';
    final message = '$greeting$subject$ref in Uyo.';

    final uri = Uri.parse('https://wa.me/$intl?text=${Uri.encodeComponent(message)}');
    if (await canLaunchUrl(uri)) {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
    return false;
  }

  static Future<bool> callDispatchHotline({String? hotline}) async {
    return await callPhone(hotline ?? defaultDispatchHotline);
  }
}
