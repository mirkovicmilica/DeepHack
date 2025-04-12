import 'package:flutter/material.dart';
import 'package:tasky/models/task.dart';

class CurrentTasksScreen extends StatefulWidget {
  @override
  _CurrentTasksScreenState createState() => _CurrentTasksScreenState();
}

class _CurrentTasksScreenState extends State<CurrentTasksScreen> {
  // Sample data for tasks
  List<Task> tasks = [
    Task(
      title: "Clean kitchen",
      creator: "You",
      reward: 5,
      icon: Icons.kitchen,
      avatarUrl: "https://example.com/your_avatar.jpg",
      description: "Clean the kitchen thoroughly.",
    ),
    Task(
      title: "Mop floor",
      creator: "Charlie",
      reward: 3,
      icon: Icons.cleaning_services,
      avatarUrl: "https://example.com/charlie_avatar.jpg",
      description: "Mop the floor of the living room.",
    ),
    Task(
      title: "Wash windows",
      creator: "Alice",
      reward: 4,
      icon: Icons.window,
      avatarUrl: "https://example.com/alice_avatar.jpg",
      description: "Clean the windows in the house.",
      status: 'completed',
      upvotes: 5,
      downvotes: 1,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    // Separate tasks into assigned and completed based on status
    List<Task> assignedTasks =
        tasks.where((task) => task.status == 'assigned').toList();
    List<Task> completedTasks =
        tasks.where((task) => task.status == 'completed').toList();

    // Sort completed tasks by upvotes in descending order
    completedTasks.sort((a, b) => b.upvotes.compareTo(a.upvotes));

    return ListView(
      children: [
        // Assigned Tasks Section
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            "Assigned Tasks",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        ...assignedTasks.map(
          (task) => ListTile(
            title: Text(task.title),
            subtitle: Text("Assigned to: ${task.creator}"),
            trailing: Icon(Icons.check_box_outline_blank),
          ),
        ),

        // Completed Tasks Section
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            "Completed Tasks",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        ...completedTasks.map(
          (task) => Card(
            margin: EdgeInsets.all(8),
            child: ListTile(
              title: Text(task.title),
              subtitle: Text("Completed by: ${task.creator}"),
              leading: CircleAvatar(
                backgroundImage: NetworkImage(task.avatarUrl),
              ),
              trailing: SizedBox(
                width: 120, // Set a fixed width for trailing
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      icon: Icon(Icons.thumb_up, color: Colors.green),
                      onPressed: () {
                        setState(() {
                          task.upvotes++;
                        });
                      },
                    ),
                    Text("${task.upvotes}"),
                    IconButton(
                      icon: Icon(Icons.thumb_down, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          task.downvotes++;
                        });
                      },
                    ),
                    Text("${task.downvotes}"),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
