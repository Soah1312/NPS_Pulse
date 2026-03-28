import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_profile.dart';

/// Global user profile state provider.
/// Holds the current authenticated user's profile data.
final userProfileProvider =
    StateNotifierProvider<UserProfileNotifier, AsyncValue<UserProfile?>>(
      (ref) => UserProfileNotifier(),
    );

class UserProfileNotifier extends StateNotifier<AsyncValue<UserProfile?>> {
  UserProfileNotifier() : super(const AsyncValue.data(null));

  /// Set the user profile after login/fetch
  void setProfile(UserProfile profile) {
    state = AsyncValue.data(profile);
  }

  /// Clear profile on logout
  void clearProfile() {
    state = const AsyncValue.data(null);
  }

  /// Set loading state
  void setLoading() {
    state = const AsyncValue.loading();
  }

  /// Set error state
  void setError(Object error, StackTrace stackTrace) {
    state = AsyncValue.error(error, stackTrace);
  }
}
