import 'package:flutter/material.dart';

// Task model class with upvotes, downvotes, and status
class TaskModel {
  final String id;
  final String title;
  final String creator;
  final int reward;
  final IconData icon;
  final String avatarUrl;
  final String description;
  String imageUrl;
  String assignedTo;
  int upvotes;
  int downvotes;
  String status; // Can be "assigned", "completed", etc.

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
    this.upvotes = 0,
    this.downvotes = 0,
    this.status = 'assigned', // Default status is 'assigned'
    this.imageUrl = '',
  });

  // Method to convert Task object to a map (for saving or JSON parsing)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'creator': creator,
      'reward': reward,
      'icon': icon.codePoint, // Store icon code point (icon as integer)
      'avatarUrl': avatarUrl,
      'description': description,
      'upvotes': upvotes,
      'downvotes': downvotes,
      'status': status,
      'assignedTo': assignedTo,
      'imageUrl': imageUrl,
    };
  }

  // Method to create Task object from a map (for parsing from JSON)
  factory TaskModel.fromMap(Map<String, dynamic> map) {
    return TaskModel(
      id: map['id'],
      title: map['title'],
      creator: map['creator'],
      reward: map['reward'],
      icon: IconData(
        map['icon'],
        fontFamily: 'MaterialIcons',
      ), // Convert code point back to IconData
      avatarUrl: map['avatarUrl'],
      description: map['description'],
      upvotes: map['upvotes'] ?? 0,
      downvotes: map['downvotes'] ?? 0,
      status: map['status'] ?? 'assigned',
      assignedTo: map['assignedTo'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
    );
  }

  factory TaskModel.fromFirestore(Map<String, dynamic> data) {
    return TaskModel(
      id: data['id'],
      title: data['title'] ?? '',
      creator: data['createdBy'] ?? '',
      reward: data['reward'] ?? 0,
      icon: Icons.assignment, // Default icon
      avatarUrl: data['avatarUrl'] ?? "https://example.com/default_avatar.jpg",
      description: data['description'] ?? '',
      status: data['status'] ?? 'incomplete',
      upvotes: data['upvotes'] ?? 0,
      downvotes: data['downvotes'] ?? 0,
      assignedTo: data['assignedTo'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
    );
  }

  // Optionally, you can add a toString method for easy debugging
  @override
  String toString() {
    return 'Task(title: $title, creator: $creator, reward: $reward, status: $status)';
  }
}
