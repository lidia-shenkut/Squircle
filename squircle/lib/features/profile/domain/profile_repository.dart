import 'user_profile.dart';

abstract class ProfileRepository {
  Future<void> createProfile(UserProfile profile);
  Future<void> updateProfile(String uid, Map<String, dynamic> fields);
  Future<bool> isUsernameAvailable(String username);
  Future<UserProfile?> getProfile(String uid);
  Stream<UserProfile?> watchProfile(String uid);
  Future<void> deleteAccount(String uid);
  Future<void> addGroupToProfile(String uid, String groupId);
  Future<void> removeGroupFromProfile(String uid, String groupId);
}
