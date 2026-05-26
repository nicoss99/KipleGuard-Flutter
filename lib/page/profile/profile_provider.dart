import 'package:dio/dio.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../core/auth_prefs.dart';
import '../../core/cache/guard_detail_cache.dart';
import '../../core/connectivity/connectivity_refresh.dart';
import '../../core/network/dio_network.dart';
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
    state = state.copyWith(loading: true, clearError: true, clearCacheMeta: true);

    if (!await isDeviceOnline(ref)) {
      await _loadFromCacheOrPrefs();
      state = state.copyWith(loading: false);
      return;
    }

    try {
      final me = await ref.read(guardRepositoryProvider).fetchMe();
      await GuardDetailCache.saveGuardProfile(
        guard: me.guard,
        residences: me.residences,
      );
      _applyGuard(me.guard, me.residences);
      state = state.copyWith(loading: false, clearCacheMeta: true);
    } on DioException catch (e) {
      await _loadFromCacheOrPrefs(networkError: isNetworkError(e));
      state = state.copyWith(
        loading: false,
        error: isNetworkError(e) ? null : profileApiErrorMessage(e),
      );
    } catch (_) {
      await _loadFromCacheOrPrefs();
      state = state.copyWith(loading: false, error: 'Something went wrong');
    }
  }

  Future<void> _loadFromCacheOrPrefs({bool networkError = true}) async {
    final cached = await GuardDetailCache.readGuardProfile();
    if (cached != null) {
      _applyGuard(cached.guard, cached.residences);
      state = state.copyWith(fromCache: true, cacheSavedAt: cached.savedAt);
      return;
    }
    await _loadFromPrefs();
    if (networkError) {
      state = state.copyWith(fromCache: true);
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

  void _applyGuard(GuardProfile guard, List<GuardResidence> residences) {
    state = state.copyWith(
      savedName: guard.name,
      email: guard.email,
      phone: guard.phone,
      initials: profileInitials(guard.name),
      profileImageUrl: guard.profileImageUrl,
      residences: residences,
    );
  }

  void _applyGuardData({
    required String name,
    required String email,
    required String phone,
    String? image,
    required List<GuardResidence> residences,
  }) {
    state = state.copyWith(
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
