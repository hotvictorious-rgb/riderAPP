import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/rider_auth_provider.dart';
import '../shell/rider_shell_screen.dart';

class RiderLoginScreen extends StatefulWidget {
  const RiderLoginScreen({super.key});

  @override
  State<RiderLoginScreen> createState() => _RiderLoginScreenState();
}

class _RiderLoginScreenState extends State<RiderLoginScreen> {
  // SMS OTP State
  final _phoneController = TextEditingController();
  final _smsCodeController = TextEditingController();
  final _smsFormKey = GlobalKey<FormState>();

  bool _isSendingSms = false;
  bool _isVerifyingSms = false;
  bool _smsDispatched = false;
  String? _smsSessionToken;
  String? _smsFeedbackMessage;
  bool _smsFeedbackIsError = false;

  Timer? _smsExpiryTimer;
  int _smsExpirySeconds = 600; // 10 minutes
  Timer? _smsCooldownTimer;
  int _smsCooldownSeconds = 0; // 2 minutes cooldown

  // WhatsApp Auth State
  bool _isStartingWhatsApp = false;
  Timer? _whatsappPollingTimer;
  Timer? _whatsappCountdownTimer;
  int _whatsappRemainingSeconds = 120; // 2 minutes

  @override
  void dispose() {
    _phoneController.dispose();
    _smsCodeController.dispose();
    _smsExpiryTimer?.cancel();
    _smsCooldownTimer?.cancel();
    _whatsappPollingTimer?.cancel();
    _whatsappCountdownTimer?.cancel();
    super.dispose();
  }

  // =========================================================================
  // WHATSAPP 1-TAP COURIER SHIFT AUTHENTICATION (STOREFRONT PARITY)
  // =========================================================================

  Future<void> _handleWhatsAppShiftLogin() async {
    setState(() => _isStartingWhatsApp = true);
    final auth = context.read<RiderAuthProvider>();

    try {
      final res = await auth.initiateWhatsAppAuth(action: 'login');
      if (!mounted) return;
      setState(() => _isStartingWhatsApp = false);

      if (res != null && res['whatsapp_url'] != null) {
        final sessionToken = res['session_token'] as String;
        final challengeCode = res['challenge_code'] as String;
        final whatsappUrl = res['whatsapp_url'] as String;

        final uri = Uri.parse(whatsappUrl);
        await launchUrl(uri, mode: LaunchMode.externalApplication);

        if (!mounted) return;
        _showWhatsAppWaitingDialog(sessionToken, challengeCode);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(auth.errorMessage ?? 'Unable to initiate WhatsApp dispatch handshake.'),
            backgroundColor: AppColors.urgentRed,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isStartingWhatsApp = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error connecting to WhatsApp dispatch service: $e'),
            backgroundColor: AppColors.urgentRed,
          ),
        );
      }
    }
  }

  void _showWhatsAppWaitingDialog(String sessionToken, String challengeCode) {
    _whatsappRemainingSeconds = 120;
    void Function(void Function())? sheetSetState;

    _whatsappCountdownTimer?.cancel();
    _whatsappCountdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_whatsappRemainingSeconds > 0) {
        _whatsappRemainingSeconds--;
        if (mounted) setState(() {});
        sheetSetState?.call(() {});
      } else {
        timer.cancel();
      }
    });

    _whatsappPollingTimer?.cancel();
    _whatsappPollingTimer = Timer.periodic(const Duration(milliseconds: 2500), (timer) async {
      final auth = context.read<RiderAuthProvider>();
      final verified = await auth.pollWhatsAppStatus(sessionToken);
      if (verified && mounted) {
        timer.cancel();
        _whatsappCountdownTimer?.cancel();
        Navigator.of(context, rootNavigator: true).pop(); // dismiss sheet
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const RiderShellScreen()),
        );
      } else if (auth.errorMessage != null && mounted) {
        timer.cancel();
        _whatsappCountdownTimer?.cancel();
        Navigator.of(context, rootNavigator: true).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(auth.errorMessage!),
            backgroundColor: AppColors.urgentRed,
          ),
        );
      }
    });

    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: AppColors.obsidianCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            sheetSetState = setSheetState;
            final min = (_whatsappRemainingSeconds ~/ 60).toString().padLeft(2, '0');
            final sec = (_whatsappRemainingSeconds % 60).toString().padLeft(2, '0');

            return Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 36),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: const Color(0xFF25D366).withOpacity(0.15),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF25D366), width: 1.5),
                    ),
                    child: const Center(
                      child: Icon(Icons.mark_chat_read, color: Color(0xFF25D366), size: 36),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Confirming Courier Shift',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Tap "Send" in WhatsApp with your pre-filled dispatch message. Your terminal will go on duty automatically.',
                    style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 18),

                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.black38,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.obsidianBorder, width: 1.5),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Challenge Code: ',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                        ),
                        Text(
                          challengeCode,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 4,
                            color: AppColors.richGold,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.richGold),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Listening for dispatch webhook ($min:$sec)...',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            _whatsappPollingTimer?.cancel();
                            _whatsappCountdownTimer?.cancel();
                            context.read<RiderAuthProvider>().cancelWhatsAppAuth(sessionToken);
                            Navigator.of(sheetContext).pop();
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.obsidianBorder),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            final authProv = context.read<RiderAuthProvider>();
                            final done = await authProv.pollWhatsAppStatus(sessionToken);
                            if (done && mounted) {
                              _whatsappPollingTimer?.cancel();
                              _whatsappCountdownTimer?.cancel();
                              Navigator.of(sheetContext).pop();
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(builder: (context) => const RiderShellScreen()),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Not received yet. Please send the prefilled WhatsApp message.'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF25D366),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text('I Sent It ➔', style: TextStyle(fontWeight: FontWeight.w800)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    ).whenComplete(() {
      _whatsappPollingTimer?.cancel();
      _whatsappCountdownTimer?.cancel();
    });
  }

  // =========================================================================
  // CELLULAR SMS OTP COURIER AUTHENTICATION (STOREFRONT FALLBACK)
  // =========================================================================

  Future<void> _handleSendSmsOtp() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty || phone.length < 10) {
      setState(() {
        _smsFeedbackMessage = 'Please enter a valid courier phone number (e.g. 08077776601).';
        _smsFeedbackIsError = true;
      });
      return;
    }

    setState(() {
      _isSendingSms = true;
      _smsFeedbackMessage = null;
    });

    final auth = context.read<RiderAuthProvider>();

    try {
      final res = await auth.sendSmsOtp(phone);
      if (!mounted) return;

      setState(() {
        _isSendingSms = false;
        _smsDispatched = true;
        _smsSessionToken = res['session_token'] as String?;
        _smsExpirySeconds = res['expires_in'] is int ? res['expires_in'] : 600;
        _smsCooldownSeconds = res['cooldown'] is int ? res['cooldown'] : 120;
        _smsFeedbackMessage = res['message'] ?? 'A 6-digit shift code has been dispatched via SMS. Valid for 10 minutes.';
        _smsFeedbackIsError = false;
      });

      _startSmsExpiryTimer();
      _startSmsCooldownTimer();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSendingSms = false;
        _smsFeedbackMessage = auth.errorMessage ?? e.toString();
        _smsFeedbackIsError = true;
      });
    }
  }

  void _startSmsExpiryTimer() {
    _smsExpiryTimer?.cancel();
    _smsExpiryTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_smsExpirySeconds > 0) {
        if (mounted) setState(() => _smsExpirySeconds--);
      } else {
        timer.cancel();
      }
    });
  }

  void _startSmsCooldownTimer() {
    _smsCooldownTimer?.cancel();
    _smsCooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_smsCooldownSeconds > 0) {
        if (mounted) setState(() => _smsCooldownSeconds--);
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> _handleVerifySmsOtp() async {
    final code = _smsCodeController.text.trim();
    if (code.length != 6) {
      setState(() {
        _smsFeedbackMessage = 'Please enter the complete 6-digit SMS code.';
        _smsFeedbackIsError = true;
      });
      return;
    }

    if (_smsSessionToken == null) {
      setState(() {
        _smsFeedbackMessage = 'Session expired. Please request a new SMS code.';
        _smsFeedbackIsError = true;
      });
      return;
    }

    setState(() {
      _isVerifyingSms = true;
      _smsFeedbackMessage = null;
    });

    final auth = context.read<RiderAuthProvider>();
    final success = await auth.verifySmsOtp(
      sessionToken: _smsSessionToken!,
      code: code,
    );

    if (!mounted) return;

    setState(() => _isVerifyingSms = false);

    if (success) {
      _smsExpiryTimer?.cancel();
      _smsCooldownTimer?.cancel();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const RiderShellScreen()),
      );
    } else {
      setState(() {
        _smsFeedbackMessage = auth.errorMessage ?? 'Verification failed. Please check the code.';
        _smsFeedbackIsError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<RiderAuthProvider>(context);

    final expiryMin = (_smsExpirySeconds ~/ 60).toString().padLeft(2, '0');
    final expirySec = (_smsExpirySeconds % 60).toString().padLeft(2, '0');

    return Scaffold(
      backgroundColor: AppColors.obsidianBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Center(
                child: Container(
                  width: 74,
                  height: 74,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.richGold, width: 2),
                    boxShadow: [
                      BoxShadow(color: AppColors.primaryPurple.withOpacity(0.45), blurRadius: 22, spreadRadius: 3),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.asset('assets/images/vm_icon.jpg', fit: BoxFit.cover),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              const Center(
                child: Text(
                  'VICTORIOUS MARKET',
                  style: TextStyle(
                    color: AppColors.richGold,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                  ),
                ),
              ),
              const Center(
                child: Text(
                  'Rider Dispatch Terminal',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              const Center(
                child: Text(
                  "Nigeria's 100% phone-native courier dispatch terminal.\nZero passwords required.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12, height: 1.4),
                ),
              ),
              const SizedBox(height: 20),

              // Role Protection Notice
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.35),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.obsidianBorder),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.shield_outlined, color: AppColors.richGold, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Courier Access Only: Customer and merchant accounts will be automatically rejected by the terminal.',
                        style: TextStyle(color: AppColors.textMuted, fontSize: 11, height: 1.35),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // PRIMARY METHOD: WHATSAPP 1-TAP SHIFT LOGIN
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isStartingWhatsApp ? null : _handleWhatsAppShiftLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF25D366),
                    foregroundColor: Colors.white,
                    elevation: 3,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: _isStartingWhatsApp
                      ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.mark_chat_read, color: Colors.white, size: 22),
                            const SizedBox(width: 10),
                            Text(
                              'Start Shift with WhatsApp (1-Tap)',
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
                            ),
                          ],
                        ),
                ),
              ),

              const SizedBox(height: 20),

              // Divider
              Row(
                children: [
                  Expanded(child: Divider(color: AppColors.obsidianBorder, thickness: 1)),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'OR IF WHATSAPP IS UNREACHABLE',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.textMuted, letterSpacing: 0.5),
                    ),
                  ),
                  Expanded(child: Divider(color: AppColors.obsidianBorder, thickness: 1)),
                ],
              ),

              const SizedBox(height: 18),

              // FALLBACK METHOD: DIRECT CELLULAR SMS OTP BOX
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.obsidianCard,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.obsidianBorder),
                ),
                child: Form(
                  key: _smsFormKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppColors.primaryPurple.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.sms_outlined, color: AppColors.richGold, size: 18),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            'Direct Cellular SMS Shift OTP',
                            style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w900),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Enter your registered courier phone number to receive a 6-digit code via direct cellular SMS (MTN, Airtel, Glo, 9mobile).',
                        style: TextStyle(color: AppColors.textMuted, fontSize: 11, height: 1.35),
                      ),
                      const SizedBox(height: 14),

                      if (_smsFeedbackMessage != null || auth.errorMessage != null) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: (_smsFeedbackIsError || auth.errorMessage != null)
                                ? AppColors.urgentRed.withOpacity(0.12)
                                : AppColors.dispatchEmerald.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: (_smsFeedbackIsError || auth.errorMessage != null)
                                  ? AppColors.urgentRed.withOpacity(0.4)
                                  : AppColors.dispatchEmerald.withOpacity(0.4),
                            ),
                          ),
                          child: Text(
                            auth.errorMessage ?? _smsFeedbackMessage!,
                            style: TextStyle(
                              color: (_smsFeedbackIsError || auth.errorMessage != null)
                                  ? AppColors.urgentRed
                                  : AppColors.dispatchEmerald,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],

                      const Text(
                        'COURIER PHONE NUMBER *',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'e.g. 08077776601 or +234...',
                          hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                          filled: true,
                          fillColor: Colors.black26,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.obsidianBorder)),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.obsidianBorder)),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primaryPurple, width: 2)),
                          prefixIcon: const Icon(Icons.phone, color: AppColors.primaryPurple, size: 20),
                        ),
                      ),
                      const SizedBox(height: 10),

                      SizedBox(
                        height: 46,
                        child: ElevatedButton(
                          onPressed: (_isSendingSms || (_smsDispatched && _smsCooldownSeconds > 0)) ? null : _handleSendSmsOtp,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryPurple,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: _isSendingSms
                              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : Text(
                                  _smsDispatched && _smsCooldownSeconds > 0
                                      ? 'Resend SMS in ${_smsCooldownSeconds}s'
                                      : (_smsDispatched ? 'Resend SMS Shift Code' : 'Send SMS Shift Code'),
                                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                                ),
                        ),
                      ),

                      if (_smsDispatched) ...[
                        const SizedBox(height: 16),
                        Container(height: 1, color: AppColors.obsidianBorder),
                        const SizedBox(height: 14),
                        const Text(
                          'ENTER 6-DIGIT SMS CODE:',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _smsCodeController,
                          keyboardType: TextInputType.number,
                          maxLength: 6,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 8,
                            fontFamily: 'monospace',
                            color: AppColors.richGold,
                          ),
                          decoration: InputDecoration(
                            counterText: '',
                            hintText: '000000',
                            hintStyle: const TextStyle(color: AppColors.textMuted, letterSpacing: 8),
                            filled: true,
                            fillColor: Colors.black45,
                            contentPadding: const EdgeInsets.symmetric(vertical: 12),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.obsidianBorder)),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.richGold, width: 2)),
                          ),
                        ),
                        const SizedBox(height: 10),

                        SizedBox(
                          height: 48,
                          child: ElevatedButton(
                            onPressed: _isVerifyingSms ? null : _handleVerifySmsOtp,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.richGold,
                              foregroundColor: const Color(0xFF080414),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: _isVerifyingSms
                                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Color(0xFF080414), strokeWidth: 2.5))
                                : const Text(
                                    'Verify Code & Start Shift ➔',
                                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 8),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '⏱️ Code expires in: $expiryMin:$expirySec',
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textMuted),
                            ),
                            if (_smsCooldownSeconds <= 0)
                              GestureDetector(
                                onTap: _handleSendSmsOtp,
                                child: const Text(
                                  'Resend Code',
                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.richGold, decoration: TextDecoration.underline),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
