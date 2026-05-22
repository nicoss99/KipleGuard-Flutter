import 'profile_strings.dart';

class ChangePasswordValidation {
  const ChangePasswordValidation({
    this.currentError = false,
    this.newError = false,
    this.confirmError = false,
    this.currentMessage,
    this.newMessage,
    this.confirmMessage,
  });

  final bool currentError;
  final bool newError;
  final bool confirmError;
  final String? currentMessage;
  final String? newMessage;
  final String? confirmMessage;

  bool get hasError => currentError || newError || confirmError;

  static bool canSubmit({
    required String current,
    required String newPass,
    required String confirm,
  }) {
    return current.isNotEmpty &&
        newPass.isNotEmpty &&
        confirm.isNotEmpty &&
        newPass == confirm;
  }

  /// Mirrors Android `ChangePasswordActivity` save validation order.
  static ChangePasswordValidation validate({
    required String current,
    required String newPass,
    required String confirm,
  }) {
    var currentError = false;
    var newError = false;
    var confirmError = false;
    String? currentMessage;
    String? newMessage;
    String? confirmMessage;

    if (current.isEmpty) {
      currentError = true;
      currentMessage = ProfileStrings.currentPasswordRequired;
    }

    if (newPass.isEmpty) {
      newError = true;
      newMessage = ProfileStrings.passwordEmpty;
    }

    if (confirm.isEmpty) {
      confirmError = true;
      confirmMessage = ProfileStrings.passwordEmpty;
    } else if (newPass != confirm) {
      confirmError = true;
      confirmMessage = ProfileStrings.passwordNotSame;
    }

    return ChangePasswordValidation(
      currentError: currentError,
      newError: newError,
      confirmError: confirmError,
      currentMessage: currentMessage,
      newMessage: newMessage,
      confirmMessage: confirmMessage,
    );
  }
}
