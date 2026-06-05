/// Result of `POST /api/v1/guard/auth/verify-pin`.
class GuardPinVerifyResult {
  const GuardPinVerifyResult._({required this.verified, this.message});

  const GuardPinVerifyResult.verified() : this._(verified: true);

  const GuardPinVerifyResult.failed(String message)
      : this._(verified: false, message: message);

  final bool verified;
  final String? message;
}
