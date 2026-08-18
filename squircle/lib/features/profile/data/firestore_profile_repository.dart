import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/profile_repository.dart';
import '../domain/user_profile.dart';

class FirestoreProfileRepository implements ProfileRepository {
  FirestoreProfileRepository(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference get _users => _firestore.collection('users');
  CollectionReference get _usernames => _firestore.collection('usernames');

  @override
  Future<void> createProfile(UserProfile profile) async {
    final batch = _firestore.batch();
    // Write user document
    batch.set(_users.doc(profile.uid), profile.toFirestore());
    // Write username lookup document (for uniqueness checks)
    batch.set(_usernames.doc(profile.username), {'uid': profile.uid});
    await batch.commit();
  }

  @override
  Future<void> updateProfile(String uid, Map<String, dynamic> fields) async {
    // If username is being updated, handle lookup collection atomically
    if (fields.containsKey('username')) {
      final oldProfile = await getProfile(uid);
      final newUsername = fields['username'] as String;
      final batch = _firestore.batch();
      // Remove old username lookup
      if (oldProfile != null && oldProfile.username.isNotEmpty) {
        batch.delete(_usernames.doc(oldProfile.username));
      }
      // Add new username lookup
      batch.set(_usernames.doc(newUsername), {'uid': uid});
      // Update user document
      batch.update(
        _users.doc(uid),
        {...fields, 'updated_at': FieldValue.serverTimestamp()},
      );
      await batch.commit();
    } else {
      await _users.doc(uid).update({
        ...fields,
        'updated_at': FieldValue.serverTimestamp(),
      });
    }
  }

  @override
  Future<bool> isUsernameAvailable(String username) async {
    final doc = await _usernames.doc(username).get();
    return !doc.exists;
  }

  @override
  Future<UserProfile?> getProfile(String uid) async {
    final doc = await _users.doc(uid).get();
    if (!doc.exists) return null;
    return UserProfile.fromFirestore(doc);
  }

  @override
  Stream<UserProfile?> watchProfile(String uid) {
    return _users.doc(uid).snapshots().map((doc) {
      if (!doc.exists) return null;
      return UserProfile.fromFirestore(doc);
    });
  }

  @override
  Future<void> deleteAccount(String uid) async {
    final profile = await getProfile(uid);
    final batch = _firestore.batch();
    if (profile != null && profile.username.isNotEmpty) {
      batch.delete(_usernames.doc(profile.username));
    }
    batch.delete(_users.doc(uid));
    await batch.commit();
  }

  @override
  Future<void> addGroupToProfile(String uid, String groupId) async {
    await _users.doc(uid).update({
      'group_ids': FieldValue.arrayUnion([groupId]),
      'updated_at': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> removeGroupFromProfile(String uid, String groupId) async {
    await _users.doc(uid).update({
      'group_ids': FieldValue.arrayRemove([groupId]),
      'updated_at': FieldValue.serverTimestamp(),
    });
  }
}
