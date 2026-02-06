import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/providers/pin_lock_provider.dart';

class PinSetupScreen extends ConsumerStatefulWidget {
  final bool isAfterRegistration;

  const PinSetupScreen({
    super.key,
    this.isAfterRegistration = false,
  });

  @override
  ConsumerState<PinSetupScreen> createState() => _PinSetupScreenState();
}

class _PinSetupScreenState extends ConsumerState<PinSetupScreen> {
  final _pinController = TextEditingController();
  final _confirmController = TextEditingController();
  final _pinFocusNode = FocusNode();
  final _confirmFocusNode = FocusNode();
  bool _showConfirm = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _pinFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _pinController.dispose();
    _confirmController.dispose();
    _pinFocusNode.dispose();
    _confirmFocusNode.dispose();
    super.dispose();
  }

  Future<void> _handleSetPin() async {
    if (_confirmController.text.length != 4) {
      return;
    }

    final success = await ref.read(pinLockProvider.notifier).setPin(
          _pinController.text,
          _confirmController.text,
        );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('PIN set successfully'),
          backgroundColor: Colors.green,
        ),
      );

      if (widget.isAfterRegistration) {
        context.go('/habits/day');
      } else {
        context.pop();
      }
    }
  }

  void _handleSkip() {
    if (widget.isAfterRegistration) {
      context.go('/habits/day');
    } else {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final pinState = ref.watch(pinLockProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Set PIN'),
        actions: widget.isAfterRegistration
            ? [
                TextButton(
                  onPressed: _handleSkip,
                  child: const Text('Skip'),
                ),
              ]
            : null,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.lock_outline,
                size: 80,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 24),
              Text(
                _showConfirm ? 'Confirm PIN' : 'Create PIN',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                _showConfirm
                    ? 'Enter your PIN again to confirm'
                    : 'Enter a 4-digit PIN to secure your app',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),

              // PIN Input (first entry)
              if (!_showConfirm) ...[
                TextField(
                  controller: _pinController,
                  focusNode: _pinFocusNode,
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
                    labelText: 'Enter PIN',
                  ),
                  onChanged: (value) {
                    if (value.length == 4) {
                      setState(() {
                        _showConfirm = true;
                      });
                      Future.delayed(const Duration(milliseconds: 100), () {
                        _confirmFocusNode.requestFocus();
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
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
              ],

              // Confirm PIN Input
              if (_showConfirm) ...[
                TextField(
                  controller: _confirmController,
                  focusNode: _confirmFocusNode,
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
                    labelText: 'Confirm PIN',
                  ),
                  onChanged: (value) {
                    if (value.length == 4) {
                      _handleSetPin();
                    }
                  },
                ),
                const SizedBox(height: 16),
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
                        color: _confirmController.text.length > index
                            ? Theme.of(context).colorScheme.primary
                            : Colors.grey.shade300,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _showConfirm = false;
                      _confirmController.clear();
                    });
                    _pinFocusNode.requestFocus();
                  },
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Change PIN'),
                ),
              ],

              if (pinState.error != null) ...[
                const SizedBox(height: 16),
                Text(
                  pinState.error!,
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],

              const Spacer(),

              if (widget.isAfterRegistration)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'You can always set a PIN later from Settings',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
