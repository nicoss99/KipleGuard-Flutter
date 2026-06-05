import 'guard_pin_verify_identity.dart';

/// Result of `POST /api/v1/guard/auth/verify-pin`.
class GuardPinVerifyResult {
  const GuardPinVerifyResult._({
    required this.verified,
    this.message,
    this.identity,
  });

  const GuardPinVerifyResult.verified({GuardPinVerifyIdentity? identity})
      : this._(verified: true, identity: identity);

  const GuardPinVerifyResult.failed(String message)
      : this._(verified: false, message: message);

  final bool verified;
  final String? message;
  final GuardPinVerifyIdentity? identity;
}
