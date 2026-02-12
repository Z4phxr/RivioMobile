import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/providers/pin_lock_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../habits/presentation/providers/habits_provider.dart';

class PinUnlockScreen extends ConsumerStatefulWidget {
  const PinUnlockScreen({super.key});

  @override
  ConsumerState<PinUnlockScreen> createState() => _PinUnlockScreenState();
}

class _PinUnlockScreenState extends ConsumerState<PinUnlockScreen> {
  final _pinController = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _pinController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _handleUnlock() async {
    if (_pinController.text.length != 4) {
      return;
    }

    final success = await ref
        .read(pinLockProvider.notifier)
        .verifyAndUnlock(_pinController.text);

    if (success && mounted) {
      context.go('/habits/day');
    } else {
      _pinController.clear();
      _focusNode.requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final pinState = ref.watch(pinLockProvider);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.lock,
                size: 80,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 24),
              Text(
                'Enter PIN',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Enter your 4-digit PIN to unlock',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),

              // PIN Input
              TextField(
                controller: _pinController,
                focusNode: _focusNode,
                keyboardType: TextInputType.number,
                obscureText: true,
                textAlign: TextAlign.center,
                maxLength: 4,
                style: const TextStyle(
                  fontSize: 32,
                  letterSpacing: 24,
                  fontWeight: FontWeight.bold,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                decoration: const InputDecoration(
                  counterText: '',
                  border: OutlineInputBorder(),
                  hintText: '••••',
                ),
                onChanged: (value) {
                  if (value.length == 4) {
                    _handleUnlock();
                  }
                },
              ),

              if (pinState.error != null) ...[
                const SizedBox(height: 16),
                Text(
                  pinState.error!,
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],

              const SizedBox(height: 32),

              // PIN Dots Indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  4,
                  (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _pinController.text.length > index
                          ? Theme.of(context).colorScheme.primary
                          : Colors.grey.shade300,
                    ),
                  ),
                ),
              ),

              const Spacer(),

              TextButton(
                onPressed: () async {
                  // Clear habit completions before logout
                  await ref.read(habitsNotifierProvider.notifier).clearCompletions();
                  // Reset PIN state
                  ref.read(pinLockProvider.notifier).reset();
                  // Logout and navigate
                  await ref.read(authNotifierProvider.notifier).logout();
                  if (context.mounted) {
                    context.go('/');
                  }
                },
                child: const Text('Logout'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
