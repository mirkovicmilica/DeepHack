import 'package:flutter/material.dart';

// Task model class with upvotes, downvotes, and status
class Task {
  final String id;
  final String title;
  final String creator;
  final int reward;
  final String icon;
  final String avatarUrl;
  final String description;
  String assignedTo;
  int upvotes;
  int downvotes;
  String status; // Can be "assigned", "completed", etc.

  // Constructor
  Task({
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
  });

  // Method to convert Task object to a map (for saving or JSON parsing)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'creator': creator,
      'reward': reward,
      'icon': icon, // Store icon code point (icon as integer)
      'avatarUrl': avatarUrl,
      'description': description,
      'upvotes': upvotes,
      'downvotes': downvotes,
      'status': status,
      'assignedTo': assignedTo,
    };
  }

  // Method to create Task object from a map (for parsing from JSON)
  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      title: map['title'],
      creator: map['creator'],
      reward: map['reward'],
      icon: map['icon'], // Convert code point back to IconData
      avatarUrl: map['avatarUrl'],
      description: map['description'],
      upvotes: map['upvotes'] ?? 0,
      downvotes: map['downvotes'] ?? 0,
      status: map['status'] ?? 'assigned',
      assignedTo: map['assignedTo'] ?? '',
    );
  }

  factory Task.fromFirestore(Map<String, dynamic> data) {
    return Task(
      id: data['id'],
      title: data['title'] ?? '',
      creator: data['createdBy'] ?? '',
      reward: data['reward'] ?? 0,
      icon: data['icon'], // Default icon
      avatarUrl: data['avatarUrl'] ?? "https://example.com/default_avatar.jpg",
      description: data['description'] ?? '',
      status: data['status'] ?? 'incomplete',
      upvotes: data['upvotes'] ?? 0,
      downvotes: data['downvotes'] ?? 0,
      assignedTo: data['assignedTo'] ?? '',
    );
  }

  // Optionally, you can add a toString method for easy debugging
  @override
  String toString() {
    return 'Task(title: $title, creator: $creator, reward: $reward, status: $status)';
  }
}
