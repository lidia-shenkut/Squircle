import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/firestore_profile_repository.dart';
import 'profile_repository.dart';
import 'user_profile.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return FirestoreProfileRepository(FirebaseFirestore.instance);
});

final currentProfileProvider =
    StreamProvider.family<UserProfile?, String>((ref, uid) {
  return ref.watch(profileRepositoryProvider).watchProfile(uid);
});
