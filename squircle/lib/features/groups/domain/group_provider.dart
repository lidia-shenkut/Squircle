import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/firestore_group_repository.dart';
import 'group_model.dart';
import 'group_repository.dart';

final groupRepositoryProvider = Provider<GroupRepository>((ref) {
  return FirestoreGroupRepository(FirebaseFirestore.instance);
});

final userGroupsProvider =
    StreamProvider.family<List<GroupModel>, String>((ref, uid) {
  return ref.watch(groupRepositoryProvider).watchUserGroups(uid);
});

final groupProvider =
    StreamProvider.family<GroupModel, String>((ref, groupId) {
  return ref.watch(groupRepositoryProvider).watchGroup(groupId);
});
