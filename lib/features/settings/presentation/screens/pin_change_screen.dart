import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/providers/pin_lock_provider.dart';

class PinChangeScreen extends ConsumerStatefulWidget {
  const PinChangeScreen({super.key});

  @override
  ConsumerState<PinChangeScreen> createState() => _PinChangeScreenState();
}

class _PinChangeScreenState extends ConsumerState<PinChangeScreen> {
  final _oldPinController = TextEditingController();
  final _newPinController = TextEditingController();
  final _confirmController = TextEditingController();
  final _oldPinFocusNode = FocusNode();
  final _newPinFocusNode = FocusNode();
  final _confirmFocusNode = FocusNode();

  int _step = 0; // 0: old PIN, 1: new PIN, 2: confirm

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _oldPinFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _oldPinController.dispose();
    _newPinController.dispose();
    _confirmController.dispose();
    _oldPinFocusNode.dispose();
    _newPinFocusNode.dispose();
    _confirmFocusNode.dispose();
    super.dispose();
  }

  Future<void> _handleChangePin() async {
    if (_confirmController.text.length != 4) {
      return;
    }

    final success = await ref.read(pinLockProvider.notifier).changePin(
          _oldPinController.text,
          _newPinController.text,
          _confirmController.text,
        );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('PIN changed successfully'),
          backgroundColor: Colors.green,
        ),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final pinState = ref.watch(pinLockProvider);

    String title;
    String subtitle;
    TextEditingController controller;
    FocusNode focusNode;

    switch (_step) {
      case 0:
        title = 'Current PIN';
        subtitle = 'Enter your current PIN';
        controller = _oldPinController;
        focusNode = _oldPinFocusNode;
        break;
      case 1:
        title = 'New PIN';
        subtitle = 'Enter your new 4-digit PIN';
        controller = _newPinController;
        focusNode = _newPinFocusNode;
        break;
      case 2:
        title = 'Confirm New PIN';
        subtitle = 'Enter your new PIN again';
        controller = _confirmController;
        focusNode = _confirmFocusNode;
        break;
      default:
        title = '';
        subtitle = '';
        controller = _oldPinController;
        focusNode = _oldPinFocusNode;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Change PIN'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.lock_reset,
                size: 80,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 24),
              Text(
                title,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),

              // PIN Input
              TextField(
                controller: controller,
                focusNode: focusNode,
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
                decoration: InputDecoration(
                  counterText: '',
                  border: const OutlineInputBorder(),
                  hintText: '••••',
                  labelText: title,
                ),
                onChanged: (value) {
                  if (value.length == 4) {
                    if (_step < 2) {
                      setState(() {
                        _step++;
                      });
                      Future.delayed(const Duration(milliseconds: 100), () {
                        if (_step == 1) {
                          _newPinFocusNode.requestFocus();
                        } else if (_step == 2) {
                          _confirmFocusNode.requestFocus();
                        }
                      });
                    } else {
                      _handleChangePin();
                    }
                  }
                },
              ),

              const SizedBox(height: 16),

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
                      color: controller.text.length > index
                          ? Theme.of(context).colorScheme.primary
                          : Colors.grey.shade300,
                    ),
                  ),
                ),
              ),

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

              const SizedBox(height: 32),

              // Step Indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  3,
                  (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _step == index ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: _step >= index
                          ? Theme.of(context).colorScheme.primary
                          : Colors.grey.shade300,
                    ),
                  ),
                ),
              ),

              if (_step > 0) ...[
                const SizedBox(height: 16),
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _step--;
                      if (_step == 0) {
                        _oldPinController.clear();
                        _oldPinFocusNode.requestFocus();
                      } else if (_step == 1) {
                        _newPinController.clear();
                        _newPinFocusNode.requestFocus();
                      }
                    });
                  },
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Back'),
                ),
              ],

              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
