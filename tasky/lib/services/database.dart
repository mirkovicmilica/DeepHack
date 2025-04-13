import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tasky/models/task_model.dart';
import 'package:tasky/models/group.dart';
import 'package:flutter/material.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // --- USERS ---
  Future<void> createUser(String uid, String name, String email) async {
    return await _db.collection('users').doc(uid).set({
      'name': name,
      'email': email,
      'createdAt': FieldValue.serverTimestamp(),
      'groups': [],
      'points': 0,
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

  Future<String?> getUserNameById(String userId) async {
    try {
      final doc = await _db.collection('users').doc(userId).get();
      if (doc.exists) {
        return doc.data()?['name'] ?? 'Unnamed';
      }
    } catch (e) {
      print("Error fetching user name: $e");
    }
    return null;
  }

  Future<void> updateUserPoints(String userId, int points) async {
    await FirebaseFirestore.instance.collection('users').doc(userId).update({
      'points': points,
    });
  }

  Future<List<Map<String, dynamic>>> getLeaderboardUsers(String groupId) async {
    // Step 1: Get member IDs from the group
    final groupDoc = await _db.collection('groups').doc(groupId).get();

    if (!groupDoc.exists) {
      throw Exception("Group not found");
    }

    final memberIds = List<String>.from(groupDoc.data()?['members'] ?? []);

    if (memberIds.isEmpty) {
      return []; // no members in group
    }

    // Step 2: Get user docs filtered by memberIds
    final userDocs =
        await _db
            .collection('users')
            .where(FieldPath.documentId, whereIn: memberIds.take(10).toList())
            .get();

    // Step 3: Map and sort users by points
    final users =
        userDocs.docs.map((doc) {
          final data = doc.data();
          return {
            'name': data['name'] ?? 'Unnamed',
            'points': data['points'] ?? 0,
            'email': data['email'] ?? '',
            'uid': doc.id,
          };
        }).toList();

    // Sort manually because `whereIn` doesn't support ordering
    users.sort((a, b) => (b['points'] as int).compareTo(a['points'] as int));

    return users;
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

  Future<void> removeGroupById(String groupId, String userId) async {
    // Check if the group exists
    DocumentSnapshot groupSnapshot =
        await _db.collection('groups').doc(groupId).get();
    if (!groupSnapshot.exists) {
      print("Group not found!");
      return;
    }

    // Remove the user from the group's members list
    await _db.collection('groups').doc(groupId).update({
      'members': FieldValue.arrayRemove([userId]),
    });

    // Remove the group from the user's groups list
    await _db.collection('users').doc(userId).update({
      'groups': FieldValue.arrayRemove([groupId]),
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
    String? assignedToName,
    String? description,
    int reward = 0,
    String status = 'incomplete',
    String avatarUrl = 'https://example.com/default_avatar.jpg',
    String? icon,
    DateTime? dueDate,
  }) async {
    final userData = await getCurrentUserData();
    if (userData == null) {
      // handle error
      return;
    }

    print('ASSIGNED TO');
    print(assignedTo);
    final newTaskRef = await _db.collection('tasks').add({
      'title': title,
      'description': description ?? '',
      'groupId': groupId,
      'createdBy': userData['uid'],
      'assignedTo': assignedTo,
      'status': status,
      'reward': reward,
      'avatarUrl': avatarUrl,
      'icon': icon, // Store icon code point (icon as integer)
      'dueDate': dueDate != null ? Timestamp.fromDate(dueDate) : null,
      'createdAt': FieldValue.serverTimestamp(),
      'votes': {},
      'assignedToName': userData['name'],
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

  Future<void> acceptTask(TaskModel task) async {
    final userData = await getCurrentUserData();
    if (userData == null) {
      // handle error
      return;
    }

    // Update the task in Firestore
    await _db.collection('tasks').doc(task.id).update({
      'status': 'accepted',
      'assignedTo': userData['uid'],
      'assignedToName': userData['name'],
    });
  }

  Future<void> completeTask(TaskModel task, String userId) async {
    final taskRef = FirebaseFirestore.instance.collection('tasks').doc(task.id);
    final userRef = FirebaseFirestore.instance.collection('users').doc(userId);

    // Mark the task as completed
    await taskRef.update({'status': 'completed'});

    // Atomically increment user's points
    await userRef.update({'points': FieldValue.increment(task.reward)});
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
      print('DATA');
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

  Future<void> voteOnTask(String taskId, int voteValue) async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final taskRef = FirebaseFirestore.instance.collection('tasks').doc(taskId);

    final snapshot = await taskRef.get();
    if (!snapshot.exists) return;

    final currentVotes = Map<String, dynamic>.from(
      snapshot.data()?['votes'] ?? {},
    );
    // Prevent multiple votes from the same user
    if (currentVotes.containsKey(userId) && currentVotes[userId] == voteValue)
      return;

    // Update the vote
    currentVotes[userId] = voteValue;
    await taskRef.update({'votes': currentVotes});
  }
}
