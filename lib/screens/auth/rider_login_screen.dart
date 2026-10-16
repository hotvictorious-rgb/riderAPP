import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/rider_auth_provider.dart';
import '../shell/rider_shell_screen.dart';

class RiderLoginScreen extends StatefulWidget {
  const RiderLoginScreen({super.key});

  @override
  State<RiderLoginScreen> createState() => _RiderLoginScreenState();
}

class _RiderLoginScreenState extends State<RiderLoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<RiderAuthProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.obsidianBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Center(
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: AppColors.primaryPurple.withOpacity(0.4), blurRadius: 20, spreadRadius: 4),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.asset('assets/images/vm_icon.jpg', fit: BoxFit.cover),
                  ),
                ),
              ),
              const SizedBox(height: 16),
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
              const SizedBox(height: 36),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.obsidianCard,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.obsidianBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('COURIER EMAIL', style: TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _emailController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'courier@fleet.ng',
                        hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                        filled: true,
                        fillColor: Colors.black26,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.obsidianBorder)),
                        prefixIcon: const Icon(Icons.email, color: AppColors.primaryPurple, size: 20),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text('PASSWORD', style: TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _passwordController,
                      obscureText: _obscure,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: '••••••••',
                        hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                        filled: true,
                        fillColor: Colors.black26,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.obsidianBorder)),
                        prefixIcon: const Icon(Icons.lock, color: AppColors.primaryPurple, size: 20),
                        suffixIcon: IconButton(
                          icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off, color: AppColors.textMuted),
                          onPressed: () => setState(() => _obscure = !_obscure),
                        ),
                      ),
                    ),
                    if (auth.errorMessage != null) ...[
                      const SizedBox(height: 12),
                      Text(auth.errorMessage!, style: const TextStyle(color: AppColors.urgentRed, fontSize: 12)),
                    ],
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: auth.isLoading
                            ? null
                            : () async {
                                await auth.login(_emailController.text.trim(), _passwordController.text);
                              },
                        child: auth.isLoading
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Text('Start Shift (Go on Duty)'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text('TEST FLEET ACCOUNTS (DEVELOPMENT QUICK FILL)', style: TextStyle(color: AppColors.richGold, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        _emailController.text = 'musa@speedyfleet.ng';
                        _passwordController.text = 'Password123!';
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.primaryPurple),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Musa (Speedy Fleet)', style: TextStyle(color: AppColors.textPrimary, fontSize: 11, fontWeight: FontWeight.w700)),
                          Text('Speedy Parcel Express', style: TextStyle(color: AppColors.textMuted, fontSize: 9)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        _emailController.text = 'ubong.rider@vanlogistics.ng';
                        _passwordController.text = 'Password123!';
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.richGold),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Ubong (Van Fleet)', style: TextStyle(color: AppColors.richGold, fontSize: 11, fontWeight: FontWeight.w700)),
                          Text('Van Logistics Ltd', style: TextStyle(color: AppColors.textMuted, fontSize: 9)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.35),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.urgentRed.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.shield, color: AppColors.urgentRed, size: 14),
                        SizedBox(width: 6),
                        Text(
                          'SECURITY PROOF: NON-RIDERS BLOCKED',
                          style: TextStyle(color: AppColors.urgentRed, fontSize: 10, fontWeight: FontWeight.w900),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Logistics company administrators, vendors, and customers are strictly denied access to the courier terminal:',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 10),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              _emailController.text = 'logistics@speedyfleet.ng';
                              _passwordController.text = 'Password123!';
                            },
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: AppColors.urgentRed.withOpacity(0.6)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              padding: const EdgeInsets.symmetric(vertical: 8),
                            ),
                            child: const Text('Test Logistics Co', style: TextStyle(color: AppColors.urgentRed, fontSize: 10, fontWeight: FontWeight.w700)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              _emailController.text = 'merchant@apexplaza.ng';
                              _passwordController.text = 'Password123!';
                            },
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: AppColors.urgentRed.withOpacity(0.6)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              padding: const EdgeInsets.symmetric(vertical: 8),
                            ),
                            child: const Text('Test Merchant Acct', style: TextStyle(color: AppColors.urgentRed, fontSize: 10, fontWeight: FontWeight.w700)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}