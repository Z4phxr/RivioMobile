import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:dio/dio.dart';
import 'core/config/route_config.dart';
import 'core/theme/app_theme.dart';
import 'core/providers/theme_provider.dart';
import 'core/providers/app_theme_provider.dart';
import 'core/network/connectivity_check_service.dart';
import 'core/config/api_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  const environment =
      String.fromEnvironment('ENV', defaultValue: 'development');
  const envFile = '.env.$environment';

  try {
    await dotenv.load(fileName: envFile);
    debugPrint('Loaded environment from: $envFile');
  } catch (e) {
    // Fallback to default if env file doesn't exist
    debugPrint('Warning: Could not load $envFile, using default configuration');
  }

  // Optional: Run connectivity check on startup (only in debug mode)
  // This helps verify the backend connection before the app starts
  try {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.apiBaseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );
    final connectivityService = ConnectivityCheckService(dio);
    final result = await connectivityService.checkBackendConnectivity();
    ConnectivityCheckService.logConnectivityResult(result);
  } catch (e) {
    debugPrint('Connectivity check skipped: $e');
  }

  runApp(
    const ProviderScope(
      child: HabitTrackerApp(),
    ),
  );
}

class HabitTrackerApp extends ConsumerWidget {
  const HabitTrackerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);
    final appTheme = ref.watch(appThemeProvider);

    return MaterialApp.router(
      title: 'Habit Tracker',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(appTheme),
      darkTheme: AppTheme.dark(appTheme),
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
