import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/screens/landing_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/habits/presentation/screens/habit_day_screen.dart';
import '../../features/habits/presentation/screens/habit_week_screen.dart';
import '../../features/habits/presentation/screens/habit_month_screen.dart';
import '../../features/habits/presentation/screens/edit_habits_screen.dart';
import '../../features/sleep/presentation/screens/sleep_day_screen_simple.dart';
import '../../features/sleep/presentation/screens/sleep_week_screen.dart';
import '../../features/sleep/presentation/screens/sleep_month_screen.dart';
import '../../features/mood/presentation/screens/mood_day_screen.dart';
import '../../features/mood/presentation/screens/mood_week_screen.dart';
import '../../features/mood/presentation/screens/mood_month_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/settings/presentation/screens/theme_selection_screen.dart';
import '../../features/settings/presentation/screens/pin_management_screen.dart';
import '../../features/settings/presentation/screens/pin_unlock_screen.dart';
import '../../features/settings/presentation/screens/pin_setup_screen.dart';
import '../../features/settings/presentation/screens/pin_change_screen.dart';
import '../../features/settings/presentation/screens/pin_remove_screen.dart';
import '../providers/pin_lock_provider.dart';
import '../widgets/app_shell.dart';

DateTime? _parseDateParam(String? value) {
  if (value == null || value.isEmpty) return null;
  try {
    return DateTime.parse(value);
  } catch (_) {
    return null;
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authNotifierProvider);
  final pinState = ref.watch(pinLockProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final isAuthenticated = authState.isAuthenticated;
      final isAuthRoute = state.matchedLocation == '/' ||
          state.matchedLocation == '/login' ||
          state.matchedLocation == '/register';
      final isPinRoute = state.matchedLocation == '/pin' ||
          state.matchedLocation == '/pin/setup';
      final isPinSetupAfterReg = state.matchedLocation == '/pin/setup' &&
          state.uri.queryParameters['afterRegistration'] == 'true';

      // If authenticated and PIN is set but not unlocked
      if (isAuthenticated &&
          pinState.hasPinSet &&
          !pinState.isUnlocked &&
          !isPinRoute) {
        return '/pin';
      }

      // Allow PIN setup after registration even if locked
      if (isPinSetupAfterReg) {
        return null;
      }

      // If not authenticated and trying to access protected route
      if (!isAuthenticated && !isAuthRoute) {
        return '/';
      }

      // If authenticated and on auth route, redirect to home
      if (isAuthenticated && isAuthRoute) {
        return '/habits/day';
      }

      return null;
    },
    routes: [
      // Unauthenticated routes
      GoRoute(path: '/', builder: (context, state) => const LandingScreen()),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),

      // PIN unlock route (outside shell to prevent navigation bar)
      GoRoute(
        path: '/pin',
        builder: (context, state) => const PinUnlockScreen(),
      ),

      // PIN setup after registration (outside shell)
      GoRoute(
        path: '/pin/setup',
        builder: (context, state) {
          final isAfterRegistration =
              state.uri.queryParameters['afterRegistration'] == 'true';
          return PinSetupScreen(isAfterRegistration: isAfterRegistration);
        },
      ),

      // Authenticated shell with bottom navigation
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          // Habits routes
          GoRoute(
            path: '/habits/day',
            builder: (context, state) => HabitDayScreen(
              initialDate: _parseDateParam(state.uri.queryParameters['date']),
            ),
          ),
          GoRoute(
            path: '/habits/week',
            builder: (context, state) => const HabitWeekScreen(),
          ),
          GoRoute(
            path: '/habits/month',
            builder: (context, state) => const HabitMonthScreen(),
          ),
          GoRoute(
            path: '/habits/edit',
            builder: (context, state) => const EditHabitsScreen(),
          ),

          // Sleep routes
          GoRoute(
            path: '/sleep/day',
            builder: (context, state) => SleepDayScreenSimple(
              initialDate: _parseDateParam(state.uri.queryParameters['date']),
            ),
          ),
          GoRoute(
            path: '/sleep/week',
            builder: (context, state) => const SleepWeekScreen(),
          ),
          GoRoute(
            path: '/sleep/month',
            builder: (context, state) => const SleepMonthScreen(),
          ),

          // Mood routes
          GoRoute(
            path: '/mood/day',
            builder: (context, state) => MoodDayScreen(
              initialDate: _parseDateParam(state.uri.queryParameters['date']),
            ),
          ),
          GoRoute(
            path: '/mood/week',
            builder: (context, state) => const MoodWeekScreen(),
          ),
          GoRoute(
            path: '/mood/month',
            builder: (context, state) => const MoodMonthScreen(),
          ),

          // Settings routes
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsScreen(),
          ),
          GoRoute(
            path: '/settings/theme',
            builder: (context, state) => const ThemeSelectionScreen(),
          ),
          GoRoute(
            path: '/settings/pin',
            builder: (context, state) => const PinManagementScreen(),
          ),
          GoRoute(
            path: '/settings/pin/change',
            builder: (context, state) => const PinChangeScreen(),
          ),
          GoRoute(
            path: '/settings/pin/remove',
            builder: (context, state) => const PinRemoveScreen(),
          ),
          GoRoute(
            path: '/settings/pin/setup',
            builder: (context, state) => const PinSetupScreen(),
          ),
        ],
      ),
    ],
  );
});
