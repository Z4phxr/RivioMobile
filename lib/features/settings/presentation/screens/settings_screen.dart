import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../../../core/providers/app_theme_provider.dart';
import '../../../../core/providers/pin_lock_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../habits/presentation/providers/habits_provider.dart';
import '../../../sleep/presentation/providers/sleep_provider.dart';
import '../../../mood/presentation/providers/mood_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final appTheme = ref.watch(appThemeProvider);
    final pinState = ref.watch(pinLockProvider);
    final authState = ref.watch(authNotifierProvider);

    return Scaffold(
      body: ListView(
        children: [
          // Appearance Section
          _buildSectionHeader('Appearance'),
          ListTile(
            leading: const Icon(Icons.palette),
            title: const Text('Theme'),
            subtitle: Text(appTheme.displayName),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/settings/theme'),
          ),
          SwitchListTile(
            title: const Text('Dark Mode'),
            subtitle: Text(
              themeMode == ThemeMode.dark
                  ? 'Dark theme enabled'
                  : 'Light theme enabled',
            ),
            value: themeMode == ThemeMode.dark,
            onChanged: (value) {
              ref.read(themeModeProvider.notifier).toggle();
            },
            secondary: Icon(
              themeMode == ThemeMode.dark ? Icons.dark_mode : Icons.light_mode,
            ),
          ),
          const Divider(),

          // Security Section
          _buildSectionHeader('Security'),
          ListTile(
            leading: const Icon(Icons.lock),
            title: const Text('App Lock (PIN)'),
            subtitle: Text(
              pinState.hasPinSet ? 'Enabled' : 'Disabled',
              style: TextStyle(
                color: pinState.hasPinSet ? Colors.green : Colors.grey,
              ),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/settings/pin'),
          ),
          const Divider(),

          // Account Section
          _buildSectionHeader('Account'),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Username'),
            subtitle: Text(authState.user?.username ?? 'Unknown'),
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () => _handleLogout(context, ref),
          ),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: const Text(
              'Delete Account',
              style: TextStyle(color: Colors.red),
            ),
            subtitle: const Text(
              'Permanently delete your account and all data',
              style: TextStyle(fontSize: 12),
            ),
            onTap: () => _handleDeleteAccount(context, ref),
          ),
          const SizedBox(height: 32),

          // App Info
          Center(
            child: Text(
              'Habit Tracker v1.0.0',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      // Clear habit completions before logout
      await ref.read(habitsNotifierProvider.notifier).clearCompletions();

      // Reset PIN state
      ref.read(pinLockProvider.notifier).reset();

      // Invalidate all domain providers to clear cached data
      ref.invalidate(habitsNotifierProvider);
      ref.invalidate(sleepNotifierProvider);
      ref.invalidate(moodNotifierProvider);

      // Logout (clears auth tokens)
      await ref.read(authNotifierProvider.notifier).logout();

      // Force immediate navigation
      if (context.mounted) {
        context.go('/');
      }
    }
  }

  Future<void> _handleDeleteAccount(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to delete your account? This action cannot be undone. All your data (habits, sleep logs, mood entries) will be permanently deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete Account'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        // Call delete account API
        await ref.read(authNotifierProvider.notifier).deleteAccount();

        if (context.mounted) {
          // Clear habit completions
          await ref.read(habitsNotifierProvider.notifier).clearCompletions();

          // Reset PIN state
          ref.read(pinLockProvider.notifier).reset();

          // Invalidate all domain providers
          ref.invalidate(habitsNotifierProvider);
          ref.invalidate(sleepNotifierProvider);
          ref.invalidate(moodNotifierProvider);

          // Show success message
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Account deleted successfully')),
          );

          // Navigate to landing page
          // ignore: use_build_context_synchronously
          context.go('/');
        }
      } catch (e) {
        if (context.mounted) {
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete account: $e')),
          );
        }
      }
    }
  }
}
