import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../domain/group_model.dart';
import '../domain/group_repository.dart';

class FirestoreGroupRepository implements GroupRepository {
  FirestoreGroupRepository(this._firestore);

  final FirebaseFirestore _firestore;
  final _uuid = const Uuid();

  CollectionReference get _groups => _firestore.collection('groups');

  String _generateCode() {
    // 6-character alphanumeric code
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final uuid = _uuid.v4().replaceAll('-', '').toUpperCase();
    return uuid.substring(0, 6);
  }

  @override
  Future<String> createGroup(GroupModel group) async {
    final docRef = _groups.doc();
    final inviteCode = _generateCode();
    final now = DateTime.now();
    final newGroup = GroupModel(
      groupId: docRef.id,
      name: group.name,
      iconUrl: group.iconUrl,
      adminUid: group.adminUid,
      memberUids: [group.adminUid],
      inviteCode: inviteCode,
      inviteLinkActive: true,
      createdAt: now,
      updatedAt: now,
    );
    await docRef.set(newGroup.toFirestore());
    return docRef.id;
  }

  @override
  Future<void> updateGroup(String groupId, Map<String, dynamic> fields) async {
    await _groups.doc(groupId).update({
      ...fields,
      'updated_at': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> joinGroupByCode(String inviteCode, String uid) async {
    final query = await _groups
        .where('invite_code', isEqualTo: inviteCode)
        .where('invite_link_active', isEqualTo: true)
        .limit(1)
        .get();

    if (query.docs.isEmpty) {
      throw Exception('Invalid or expired invite code.');
    }

    final groupDoc = query.docs.first;
    await groupDoc.reference.update({
      'member_uids': FieldValue.arrayUnion([uid]),
      'updated_at': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> joinGroupByLink(String groupId, String uid) async {
    final doc = await _groups.doc(groupId).get();
    if (!doc.exists) throw Exception('Group not found.');
    final data = doc.data() as Map<String, dynamic>;
    if (data['invite_link_active'] != true) {
      throw Exception('Invite link is no longer active.');
    }
    await _groups.doc(groupId).update({
      'member_uids': FieldValue.arrayUnion([uid]),
      'updated_at': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<String> generateInviteCode(String groupId) async {
    final code = _generateCode();
    await _groups.doc(groupId).update({
      'invite_code': code,
      'invite_link_active': true,
      'updated_at': FieldValue.serverTimestamp(),
    });
    return code;
  }

  @override
  Future<void> revokeInviteCode(String groupId) async {
    await _groups.doc(groupId).update({
      'invite_link_active': false,
      'updated_at': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> inviteByEmail(String groupId, String email) async {
    // This triggers a Cloud Function via a subcollection write
    await _groups.doc(groupId).collection('pending_invites').add({
      'email': email,
      'invited_at': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> removeMember(String groupId, String uid) async {
    await _groups.doc(groupId).update({
      'member_uids': FieldValue.arrayRemove([uid]),
      'updated_at': FieldValue.serverTimestamp(),
    });
  }

  @override
  Stream<List<GroupModel>> watchUserGroups(String uid) {
    return _groups
        .where('member_uids', arrayContains: uid)
        .orderBy('updated_at', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((doc) => GroupModel.fromFirestore(doc)).toList());
  }

  @override
  Stream<GroupModel> watchGroup(String groupId) {
    return _groups.doc(groupId).snapshots().map((doc) {
      if (!doc.exists) throw Exception('Group not found.');
      return GroupModel.fromFirestore(doc);
    });
  }

  @override
  Future<GroupModel?> getGroup(String groupId) async {
    final doc = await _groups.doc(groupId).get();
    if (!doc.exists) return null;
    return GroupModel.fromFirestore(doc);
  }
}
