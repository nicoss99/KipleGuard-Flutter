import '../auth/guard_models.dart';

/// Edit profile UI state (guard `/api/v1/guard/me` + local draft name).
class ProfileState {
  const ProfileState({
    this.loading = false,
    this.savedName = '',
    this.email = '',
    this.phone = '',
    this.initials = '',
    this.profileImageUrl,
    this.residences = const [],
    this.showSave = false,
    this.error,
    this.fromCache = false,
    this.cacheSavedAt,
  });

  final bool loading;
  final String savedName;
  final String email;
  final String phone;
  final String initials;
  final String? profileImageUrl;
  final List<GuardResidence> residences;
  final bool showSave;
  final String? error;
  final bool fromCache;
  final DateTime? cacheSavedAt;

  ProfileState copyWith({
    bool? loading,
    String? savedName,
    String? email,
    String? phone,
    String? initials,
    String? profileImageUrl,
    List<GuardResidence>? residences,
    bool? showSave,
    String? error,
    bool? fromCache,
    DateTime? cacheSavedAt,
    bool clearError = false,
    bool clearCacheMeta = false,
  }) {
    return ProfileState(
      loading: loading ?? this.loading,
      savedName: savedName ?? this.savedName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      initials: initials ?? this.initials,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      residences: residences ?? this.residences,
      showSave: showSave ?? this.showSave,
      error: clearError ? null : (error ?? this.error),
      fromCache: clearCacheMeta ? false : (fromCache ?? this.fromCache),
      cacheSavedAt: clearCacheMeta ? null : (cacheSavedAt ?? this.cacheSavedAt),
    );
  }
}
