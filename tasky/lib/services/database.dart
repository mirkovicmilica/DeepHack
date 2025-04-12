import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // --- USERS ---
  Future<void> createUser(String uid, String name, String email) async {
    return await _db.collection('users').doc(uid).set({
      'name': name,
      'email': email,
      'createdAt': FieldValue.serverTimestamp(),
      'groups': [], // Add an empty list for groups
    });
  }

  Future<Map<String, dynamic>?> getCurrentUserData() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) return null;

    // Add UID to the data
    final data = doc.data()!;
    data['uid'] = uid;
    return data;
  }

  // Fetch the user's groups
  Future<List<String>> getUserGroups(String userId) async {
    final userDoc = await _db.collection('users').doc(userId).get();
    if (!userDoc.exists) return [];
    List<dynamic> groupIds = userDoc['groups'] ?? [];
    return groupIds.map((groupId) => groupId.toString()).toList();
  }

  // GROUPS

  Future<void> createGroup(String groupName, String userId) async {
    // Create a new group in Firestore
    DocumentReference groupRef = await _db.collection('groups').add({
      'name': groupName,
      'members': [
        userId,
      ], // Initially, the group will have only the creator as a member
    });

    // Add the group to the user's groups list
    await _db.collection('users').doc(userId).update({
      'groups': FieldValue.arrayUnion([groupRef.id]),
    });
  }

  Future<void> addGroupById(String groupId, String userId) async {
    // Check if the group exists
    DocumentSnapshot groupSnapshot =
        await _db.collection('groups').doc(groupId).get();
    if (!groupSnapshot.exists) {
      print("Group not found!");
      return;
    }

    // Add the user to the group's members list
    await _db.collection('groups').doc(groupId).update({
      'members': FieldValue.arrayUnion([userId]),
    });

    // Add the group to the user's groups list
    await _db.collection('users').doc(userId).update({
      'groups': FieldValue.arrayUnion([groupId]),
    });
  }

  // Fetch group data
  Future<Map<String, dynamic>?> getGroupData(String groupId) async {
    final groupDoc = await _db.collection('groups').doc(groupId).get();
    return groupDoc.exists ? groupDoc.data() : null;
  }
}
