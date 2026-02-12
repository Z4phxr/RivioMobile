import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../storage/pin_storage_service.dart';
import '../storage/secure_storage_service.dart';

/// Provider for PIN storage service
final pinStorageServiceProvider = Provider<PinStorageService>((ref) {
  final secureStorage = ref.watch(secureStorageServiceProvider);
  return PinStorageService(secureStorage.storage);
});

/// State for PIN lock feature
class PinLockState {
  final bool hasPinSet;
  final bool isUnlocked;
  final String? error;

  const PinLockState({
    this.hasPinSet = false,
    this.isUnlocked = true,
    this.error,
  });

  PinLockState copyWith({bool? hasPinSet, bool? isUnlocked, String? error}) {
    return PinLockState(
      hasPinSet: hasPinSet ?? this.hasPinSet,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      error: error,
    );
  }
}

/// Notifier for PIN lock state management
class PinLockNotifier extends StateNotifier<PinLockState> {
  final PinStorageService _pinStorage;

  PinLockNotifier(this._pinStorage) : super(const PinLockState()) {
    _initialize();
  }

  /// Initialize PIN state on app startup
  Future<void> _initialize() async {
    final hasPinSet = await _pinStorage.hasPinSet();
    state = state.copyWith(
      hasPinSet: hasPinSet,
      // If PIN is set, app starts locked
      isUnlocked: !hasPinSet,
    );
  }

  /// Verify PIN and unlock if correct
  Future<bool> verifyAndUnlock(String pin) async {
    try {
      final isValid = await _pinStorage.verifyPin(pin);
      if (isValid) {
        state = state.copyWith(isUnlocked: true, error: null);
        return true;
      } else {
        state = state.copyWith(error: 'Incorrect PIN');
        return false;
      }
    } catch (e) {
      state = state.copyWith(error: 'Error verifying PIN: $e');
      return false;
    }
  }

  /// Set a new PIN
  Future<bool> setPin(String pin, String confirmation) async {
    if (pin != confirmation) {
      state = state.copyWith(error: 'PINs do not match');
      return false;
    }

    if (pin.length != 4) {
      state = state.copyWith(error: 'PIN must be 4 digits');
      return false;
    }

    if (!RegExp(r'^[0-9]+$').hasMatch(pin)) {
      state = state.copyWith(error: 'PIN must contain only numbers');
      return false;
    }

    try {
      await _pinStorage.setPin(pin);
      state = state.copyWith(hasPinSet: true, error: null);
      return true;
    } catch (e) {
      state = state.copyWith(error: 'Failed to set PIN: $e');
      return false;
    }
  }

  /// Change existing PIN
  Future<bool> changePin(
    String oldPin,
    String newPin,
    String confirmation,
  ) async {
    // Verify old PIN
    final isOldPinValid = await _pinStorage.verifyPin(oldPin);
    if (!isOldPinValid) {
      state = state.copyWith(error: 'Current PIN is incorrect');
      return false;
    }

    // Set new PIN
    return await setPin(newPin, confirmation);
  }

  /// Remove PIN
  Future<bool> removePin(String currentPin) async {
    // Verify current PIN
    final isValid = await _pinStorage.verifyPin(currentPin);
    if (!isValid) {
      state = state.copyWith(error: 'Current PIN is incorrect');
      return false;
    }

    try {
      await _pinStorage.removePin();
      state = state.copyWith(hasPinSet: false, isUnlocked: true, error: null);
      return true;
    } catch (e) {
      state = state.copyWith(error: 'Failed to remove PIN: $e');
      return false;
    }
  }

  /// Lock the app (used on app minimize/background)
  void lock() {
    if (state.hasPinSet) {
      state = state.copyWith(isUnlocked: false);
    }
  }

  /// Clear any error messages
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Reset PIN state (used on logout)
  void reset() {
    state = state.copyWith(isUnlocked: true);
  }
}

/// Provider for PIN lock state
final pinLockProvider = StateNotifierProvider<PinLockNotifier, PinLockState>((
  ref,
) {
  final pinStorage = ref.watch(pinStorageServiceProvider);
  return PinLockNotifier(pinStorage);
});
