import 'package:flutter/material.dart';

// Task model class with upvotes, downvotes, and status
class TaskModel {
  final String id;
  final String title;
  final String creator;
  final int reward;
  final String icon;
  final String avatarUrl;
  final String description;
  String imageUrl;
  String assignedTo;
  String assignedToName;
  String status; // Can be "assigned", "completed", etc.
  Map<String, int> votes;

  // Constructor
  TaskModel({
    required this.id,
    required this.title,
    required this.creator,
    required this.reward,
    required this.icon,
    required this.avatarUrl,
    required this.description,
    this.assignedTo = '',
    this.assignedToName = '',
    this.status = 'assigned', // Default status is 'assigned'
    this.imageUrl = '',
    this.votes = const {},
  });

  // Method to convert Task object to a map (for saving or JSON parsing)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'creator': creator,
      'reward': reward,
      'icon': icon,
      'avatarUrl': avatarUrl,
      'description': description,
      'status': status,
      'assignedTo': assignedTo,
      'imageUrl': imageUrl,
      'votes': votes,
      'assignedToName': assignedToName,
    };
  }

  // Method to create Task object from a map (for parsing from JSON)
  factory TaskModel.fromMap(Map<String, dynamic> map) {
    return TaskModel(
      id: map['id'],
      title: map['title'],
      creator: map['creator'],
      reward: map['reward'],
      icon: map['icon'], // Convert code point back to IconData
      avatarUrl: map['avatarUrl'],
      description: map['description'],
      status: map['status'] ?? 'assigned',
      assignedTo: map['assignedTo'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      votes: Map<String, int>.from(map['votes'] ?? {}),
      assignedToName: map['assignedToName'] ?? '',
    );
  }

  factory TaskModel.fromFirestore(Map<String, dynamic> data) {
    return TaskModel(
      id: data['id'],
      title: data['title'] ?? '',
      creator: data['createdBy'] ?? '',
      reward: data['reward'] ?? 0,
      icon: data['icon'], // Default icon
      avatarUrl: data['avatarUrl'] ?? "https://example.com/default_avatar.jpg",
      description: data['description'] ?? '',
      status: data['status'] ?? 'incomplete',
      assignedTo: data['assignedTo'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      votes: Map<String, int>.from(data['votes'] ?? {}),
      assignedToName: data['assignedToName'] ?? '',
    );
  }

  int get upvotes => votes.values.where((v) => v == 1).length;
  int get downvotes => votes.values.where((v) => v == -1).length;

  // Optionally, you can add a toString method for easy debugging
  @override
  String toString() {
    return 'Task(title: $title, creator: $creator, reward: $reward, status: $status)';
  }
}
