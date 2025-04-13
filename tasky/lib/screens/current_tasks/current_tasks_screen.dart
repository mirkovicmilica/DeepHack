import 'package:flutter/material.dart';
import 'package:tasky/models/task.dart'; // Import your Task model
import 'package:image_picker/image_picker.dart';

// Define a stateful widget for the current tasks screen
class CurrentTasksScreen extends StatefulWidget {
  @override
  _CurrentTasksScreenState createState() => _CurrentTasksScreenState();
}

// The mutable state for the CurrentTasksScreen widget
class _CurrentTasksScreenState extends State<CurrentTasksScreen> {
  // Sample list of tasks - normally you might fetch this data from a service
  List<Task> tasks = [
    Task(
      id: "123",
      title: "Clean kitchen",
      creator: "You",
      reward: 5,
      icon: "massage",
      avatarUrl: "https://example.com/your_avatar.jpg",
      description: "Clean the kitchen thoroughly.",
      // Note: No status given, so it defaults to null. In our filtering, it must be 'assigned'
      status: 'assigned',
    ),
    Task(
      id: '1234',
      title: "Mop floor",
      creator: "Charlie",
      reward: 3,
      icon: "massage",
      avatarUrl: "https://example.com/charlie_avatar.jpg",
      description: "Mop the floor of the living room.",
      status: 'assigned',
    ),
    Task(
      id: '12',
      title: "Wash windows",
      creator: "Alice",
      reward: 4,
      icon: "massage",
      avatarUrl: "https://example.com/alice_avatar.jpg",
      description: "Clean the windows in the house.",
      status: 'completed', // This task is marked as completed
      upvotes: 5,
      downvotes: 1,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    // Filter tasks that are assigned based on their 'status' property
    List<Task> assignedTasks =
        tasks.where((task) => task.status == 'assigned').toList();

    // Filter tasks that are completed based on their 'status' property
    List<Task> completedTasks =
        tasks.where((task) => task.status == 'completed').toList();

    // Sort the completed tasks in descending order by number of upvotes
    completedTasks.sort((a, b) => b.upvotes.compareTo(a.upvotes));

    return ListView(
      // ListView holds all our sections as a vertical list
      children: [
        // Header for the Assigned Tasks section with padding
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            "Assigned Tasks",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        // Map over the assignedTasks to create a list of swipeable items
        ...assignedTasks.map((task) {
          final isAssignedToYou = task.creator == "You";

          return Card(
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            elevation: 2,
            child: ListTile(
              title: Text(task.title),
              subtitle: Text("Assigned to: ${task.creator}"),
              trailing:
                  isAssignedToYou
                      ? Icon(Icons.pending_actions, color: Colors.orange)
                      : Icon(Icons.lock_outline, color: Colors.grey),
              onTap:
                  isAssignedToYou
                      ? () => _handleTakePhoto(task)
                      : null, // Disable tap if not yours
            ),
          );
        }),
        // Header for the Completed Tasks section
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            "Completed Tasks",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        // Map over completed tasks to display them in a Card widget
        ...completedTasks.map(
          (task) => Card(
            margin: EdgeInsets.all(8),
            child: ListTile(
              title: Text(task.title), // Display the task title
              subtitle: Text("Completed by: ${task.creator}"),
              // Leading displays an avatar image of the task creator
              leading: CircleAvatar(
                backgroundImage: NetworkImage(task.avatarUrl),
              ),
              // Trailing contains a set of buttons for upvoting and downvoting
              trailing: SizedBox(
                width: 120, // Fixed width ensures consistent layout
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Upvote button
                    IconButton(
                      icon: Icon(Icons.thumb_up, color: Colors.green),
                      onPressed: () {
                        setState(() {
                          task.upvotes++; // Increase upvotes count
                        });
                      },
                    ),
                    Text("${task.upvotes}"), // Display current upvotes count
                    // Downvote button
                    IconButton(
                      icon: Icon(Icons.thumb_down, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          task.downvotes++; // Increase downvotes count
                        });
                      },
                    ),
                    Text(
                      "${task.downvotes}",
                    ), // Display current downvotes count
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _handleTakePhoto(Task task) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      // You now have the image path → you can store, upload, mark as complete, etc.
      print("User completed '${task.title}' with photo: ${pickedFile.path}");

      // Optional: mark task as completed
      setState(() {
        task.status = 'completed';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Photo submitted for '${task.title}'")),
      );
    } else {
      print("User cancelled photo for ${task.title}");
    }
  }
}
