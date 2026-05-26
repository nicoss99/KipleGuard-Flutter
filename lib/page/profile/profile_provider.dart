import 'package:dio/dio.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../core/auth_prefs.dart';
import '../../core/profile_initials.dart';
import '../auth/guard_models.dart';
import '../auth/guard_repository.dart';
import 'profile_repository.dart';
import 'profile_state.dart';

final profileProvider = NotifierProvider<ProfileNotifier, ProfileState>(ProfileNotifier.new);

/// Android `EditProfileActivity`: `app_name` + `v` + `VERSION_NAME`.
final appVersionLabelProvider = FutureProvider<String>((ref) async {
  final info = await PackageInfo.fromPlatform();
  return '${info.appName} v${info.version}';
});

class ProfileNotifier extends Notifier<ProfileState> {
  @override
  ProfileState build() => const ProfileState();

  Future<void> load() async {
    state = state.copyWith(loading: true, clearError: true);
    try {
      final me = await ref.read(guardRepositoryProvider).fetchMe();
      _applyGuard(me.guard, me.residences);
      state = state.copyWith(loading: false);
    } on DioException catch (e) {
      await _loadFromPrefs();
      state = state.copyWith(loading: false, error: profileApiErrorMessage(e));
    } catch (_) {
      await _loadFromPrefs();
      state = state.copyWith(loading: false, error: 'Something went wrong');
    }
  }

  Future<void> _loadFromPrefs() async {
    final name = (await AuthPrefs.readUserName()) ?? '';
    final email = (await AuthPrefs.readUserEmail()) ?? '';
    final phone = (await AuthPrefs.readUserPhone()) ?? '';
    final image = await AuthPrefs.readProfileImageUrl();
    final residences = await AuthPrefs.readGuardResidences();
    _applyGuardData(name: name, email: email, phone: phone, image: image, residences: residences);
  }

  void _applyGuard(GuardProfile guard, List<GuardResidence> residences) =>
      _applyGuardData(
        name: guard.name,
        email: guard.email,
        phone: guard.phone,
        image: guard.profileImageUrl,
        residences: residences,
      );

  void _applyGuardData({
    required String name,
    required String email,
    required String phone,
    String? image,
    required List<GuardResidence> residences,
  }) {
    state = ProfileState(
      savedName: name,
      email: email,
      phone: phone,
      initials: profileInitials(name),
      profileImageUrl: image,
      residences: residences,
    );
  }

  void clearError() {
    if (state.error != null) state = state.copyWith(clearError: true);
  }

  void onNameChanged(String text) {
    final trimmed = text.trim();
    final same = trimmed.toLowerCase() == state.savedName.toLowerCase();
    state = state.copyWith(showSave: trimmed.isNotEmpty && !same, clearError: true);
  }

  Future<bool> saveName(String draft) async {
    final name = draft.trim();
    if (name.isEmpty) return false;
    if (name.toLowerCase() == state.savedName.toLowerCase()) return false;

    state = state.copyWith(loading: true, clearError: true);
    try {
      await AuthPrefs.setUserName(name);
      state = state.copyWith(
        loading: false,
        savedName: name,
        initials: profileInitials(name),
        showSave: false,
      );
      return true;
    } catch (_) {
      state = state.copyWith(loading: false, error: 'Something went wrong');
      return false;
    }
  }

  Future<bool> signOut() async {
    state = state.copyWith(loading: true, clearError: true);
    try {
      await ref.read(profileRepositoryProvider).logout();
      await AuthPrefs.clearSession();
      state = state.copyWith(loading: false);
      return true;
    } on DioException {
      state = state.copyWith(loading: false);
      return false;
    } catch (_) {
      state = state.copyWith(loading: false, error: 'Something went wrong');
      return false;
    }
  }
}
