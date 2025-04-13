import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:tasky/models/task_model.dart';
import 'package:tasky/models/group.dart';
import 'package:flutter/material.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

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
  Future<List<Group>> getUserGroups(String userId) async {
    final userDoc = await _db.collection('users').doc(userId).get();
    if (!userDoc.exists) return [];

    List<dynamic> groupIds = userDoc['groups'] ?? [];

    // Fetch the group data for each group ID and return a list of Group objects
    List<Group> groups = [];
    for (String groupId in groupIds) {
      final groupData = await getGroupData(groupId); // Fetch group data
      if (groupData != null) {
        groups.add(groupData); // Add the Group object to the list
      }
    }

    return groups;
  }

  // GROUPS

  Future<void> createGroup(String groupName, String userId) async {
    // Create a new group in Firestore
    DocumentReference groupRef = await _db.collection('groups').add({
      'name': groupName,
      'members': [
        userId,
      ], // Initially, the group will have only the creator as a member
      'tasks': [], // Initialize with an empty task list (optional)
      'createdAt': FieldValue.serverTimestamp(),
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

  Future<Group?> getGroupData(String groupId) async {
    final groupDoc = await _db.collection('groups').doc(groupId).get();

    if (groupDoc.exists) {
      // Create and return the Group instance
      return Group.fromMap(groupDoc.data()!, groupDoc.id);
    }

    return null; // If the document doesn't exist, return null
  }

  Future<void> createTask({
    required String title,
    required String groupId,
    String? assignedTo,
    String? description,
    int reward = 0,
    String status = 'incomplete',
    String avatarUrl = 'https://example.com/default_avatar.jpg',
    String? icon,
    DateTime? dueDate,
  }) async {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) {
      throw Exception("User is not logged in");
    }

    final newTaskRef = await _db.collection('tasks').add({
      'title': title,
      'description': description ?? '',
      'groupId': groupId,
      'createdBy': currentUserId,
      'assignedTo': assignedTo,
      'status': status,
      'reward': reward,
      'avatarUrl': avatarUrl,
      'icon': icon, // Store icon code point (icon as integer)
      'dueDate': dueDate != null ? Timestamp.fromDate(dueDate) : null,
      'createdAt': FieldValue.serverTimestamp(),
      'upvotes': 0, // Initial value
      'downvotes': 0, // Initial value
    });

    // Optional: Add task ID to group's task list
    await _db.collection('groups').doc(groupId).update({
      'tasks': FieldValue.arrayUnion([newTaskRef.id]),
    });
  }

  Future<List<TaskModel>> getIncompleteTasksForGroup(String groupId) async {
    final querySnapshot =
        await _db
            .collection('tasks')
            .where('groupId', isEqualTo: groupId)
            .where('status', isEqualTo: 'incomplete')
            .get();

    return querySnapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return TaskModel.fromFirestore(data);
    }).toList();
  }

  Future<void> acceptTask(TaskModel task, String currentUserId) async {
    // Update the task in Firestore
    await _db.collection('tasks').doc(task.id).update({
      'status': 'accepted',
      'assignedTo': currentUserId,
    });
  }

  Future<void> completeTask(TaskModel task) async {
    final taskRef = FirebaseFirestore.instance.collection('tasks').doc(task.id);
    print('COMPLETE SERVICE');
    print(task);

    await taskRef.update({'status': 'completed', 'imageUrl': task.imageUrl});
  }

  Future<List<TaskModel>> getAssignedTasks(String groupId) async {
    final snapshot =
        await FirebaseFirestore.instance
            .collection('tasks')
            .where('groupId', isEqualTo: groupId)
            .where(
              'status',
              isEqualTo: 'accepted',
            ) // or other status you prefer
            .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      print(data);
      return TaskModel.fromFirestore(data);
    }).toList();
  }

  Future<List<TaskModel>> getCompletedTasks(String groupId) async {
    final snapshot =
        await FirebaseFirestore.instance
            .collection('tasks')
            .where('groupId', isEqualTo: groupId)
            .where(
              'status',
              isEqualTo: 'completed',
            ) // or other status you prefer
            .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return TaskModel.fromFirestore(data);
    }).toList();
  }
}
