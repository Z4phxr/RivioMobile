import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/providers/pin_lock_provider.dart';

class PinManagementScreen extends ConsumerWidget {
  const PinManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pinState = ref.watch(pinLockProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('App Lock'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        pinState.hasPinSet ? Icons.lock : Icons.lock_open,
                        color: pinState.hasPinSet ? Colors.green : Colors.grey,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        pinState.hasPinSet ? 'PIN Enabled' : 'PIN Disabled',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    pinState.hasPinSet
                        ? 'Your app is protected with a 4-digit PIN'
                        : 'Set a PIN to protect your app',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey,
                        ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          if (!pinState.hasPinSet) ...[
            ListTile(
              leading: const Icon(Icons.add_circle, color: Colors.blue),
              title: const Text('Set PIN'),
              subtitle: const Text('Create a 4-digit PIN to lock your app'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/settings/pin/setup'),
            ),
          ] else ...[
            ListTile(
              leading: const Icon(Icons.edit, color: Colors.orange),
              title: const Text('Change PIN'),
              subtitle: const Text('Update your current PIN'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/settings/pin/change'),
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Remove PIN'),
              subtitle: const Text('Disable app lock'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/settings/pin/remove'),
            ),
          ],
          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'About PIN Security',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              '• Your PIN is stored securely on your device\n'
              '• The app will require your PIN when opened\n'
              '• PIN must be exactly 4 digits\n'
              '• Keep your PIN private and secure',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
