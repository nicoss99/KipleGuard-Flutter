import 'package:dio/dio.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/auth_prefs.dart';
import '../../core/profile_initials.dart';
import '../../service/api_service.dart';
import 'profile_repository.dart';
import 'profile_state.dart';

final profileRepositoryProvider = Provider<ProfileRepository>(
  (ref) => ProfileRepository(ref.watch(dioProvider)),
);

final profileProvider = NotifierProvider<ProfileNotifier, ProfileState>(ProfileNotifier.new);

class ProfileNotifier extends Notifier<ProfileState> {
  @override
  ProfileState build() => const ProfileState();

  Future<void> load() async {
    final name = (await AuthPrefs.readUserName()) ?? '';
    final email = (await AuthPrefs.readUserEmail()) ?? '';
    final phone = (await AuthPrefs.readUserPhone()) ?? '';
    state = ProfileState(
      savedName: name,
      email: email,
      phone: phone,
      initials: profileInitials(name),
    );
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
      final profileUuid = await AuthPrefs.readProfileUuid();
      if (profileUuid == null || profileUuid.isEmpty) {
        throw ProfileApiException('Missing profile');
      }
      await ref.read(profileRepositoryProvider).updateProfileName(
            profileUuid: profileUuid,
            name: name,
          );
      await AuthPrefs.setUserName(name);
      state = state.copyWith(
        loading: false,
        savedName: name,
        initials: profileInitials(name),
        showSave: false,
      );
      return true;
    } on DioException catch (e) {
      state = state.copyWith(loading: false, error: profileApiErrorMessage(e));
      return false;
    } on ProfileApiException catch (e) {
      state = state.copyWith(loading: false, error: e.message);
      return false;
    } catch (_) {
      state = state.copyWith(loading: false, error: 'Something went wrong');
      return false;
    }
  }

  /// Returns `true` when session cleared (navigate to login).
  Future<bool> signOut({bool force = false}) async {
    state = state.copyWith(loading: true, clearError: true);
    try {
      if (!force) {
        final recordUuid = await AuthPrefs.readUserFirebaseRecordUuid();
        if (recordUuid != null && recordUuid.isNotEmpty) {
          try {
            await ref.read(profileRepositoryProvider).invalidateFirebaseToken(recordUuid);
          } on DioException {
            state = state.copyWith(loading: false);
            return false;
          }
        }
      }
      await AuthPrefs.clearSession();
      state = state.copyWith(loading: false);
      return true;
    } catch (_) {
      state = state.copyWith(loading: false, error: 'Something went wrong');
      return false;
    }
  }
}
