import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/network/api_client.dart';
import 'core/services/storage_service.dart';
import 'core/theme/app_theme.dart';
import 'providers/rider_auth_provider.dart';
import 'providers/rider_dashboard_provider.dart';
import 'providers/rider_delivery_provider.dart';
import 'screens/auth/rider_login_screen.dart';
import 'screens/shell/rider_shell_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final storageService = await StorageService.init();
  final apiClient = ApiClient(storageService);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => RiderAuthProvider(apiClient, storageService)),
        ChangeNotifierProvider(create: (_) => RiderDashboardProvider(apiClient, storageService)),
        ChangeNotifierProvider(create: (_) => RiderDeliveryProvider(apiClient)),
      ],
      child: const RiderTerminalApp(),
    ),
  );
}

class RiderTerminalApp extends StatelessWidget {
  const RiderTerminalApp({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<RiderAuthProvider>(context);

    return MaterialApp(
      title: 'Victorious Rider',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: auth.isAuthenticated ? const RiderShellScreen() : const RiderLoginScreen(),
    );
  }
}