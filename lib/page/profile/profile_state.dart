/// Edit profile UI state (loaded from [AuthPrefs], no remote fetch on open).
class ProfileState {
  const ProfileState({
    this.loading = false,
    this.savedName = '',
    this.email = '',
    this.phone = '',
    this.initials = '',
    this.showSave = false,
    this.error,
  });

  final bool loading;
  final String savedName;
  final String email;
  final String phone;
  final String initials;
  final bool showSave;
  final String? error;

  ProfileState copyWith({
    bool? loading,
    String? savedName,
    String? email,
    String? phone,
    String? initials,
    bool? showSave,
    String? error,
    bool clearError = false,
  }) {
    return ProfileState(
      loading: loading ?? this.loading,
      savedName: savedName ?? this.savedName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      initials: initials ?? this.initials,
      showSave: showSave ?? this.showSave,
      error: clearError ? null : (error ?? this.error),
    );
  }
}
