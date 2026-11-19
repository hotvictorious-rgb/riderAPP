import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/network/api_client.dart';
import 'core/services/push_notification_service.dart';
import 'core/services/storage_service.dart';
import 'core/theme/app_theme.dart';
import 'providers/rider_auth_provider.dart';
import 'providers/rider_dashboard_provider.dart';
import 'providers/rider_delivery_provider.dart';
import 'providers/rider_notification_provider.dart';
import 'screens/auth/rider_login_screen.dart';
import 'screens/shell/rider_shell_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final storageService = await StorageService.init();
  final apiClient = ApiClient(storageService);
  final authProvider = RiderAuthProvider(apiClient, storageService);
  apiClient.onUnauthorizedCallback = () => authProvider.handleUnauthorized();

  // Initialize Firebase Cloud Messaging Push Engine (Fail-safe)
  try {
    await PushNotificationService().initialize(apiClient);
  } catch (e) {
    debugPrint("Failed to initialize push notifications: $e");
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider(create: (_) => RiderDashboardProvider(apiClient, storageService)),
        ChangeNotifierProvider(create: (_) => RiderDeliveryProvider(apiClient, storageService)),
        ChangeNotifierProvider(create: (_) => RiderNotificationProvider(apiClient)),
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