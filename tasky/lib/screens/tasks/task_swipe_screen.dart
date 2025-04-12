import 'package:flutter/material.dart';
import 'package:tasky/models/task.dart';
import 'package:image_picker/image_picker.dart';

class TaskSwipeScreen extends StatefulWidget {
  @override
  _TaskSwipeScreenState createState() => _TaskSwipeScreenState();
}

class _TaskSwipeScreenState extends State<TaskSwipeScreen> {
  List<Task> tasks = [
    Task(
      title: "Do the dishes",
      creator: "Alice",
      reward: 10,
      icon: Icons.kitchen,
      avatarUrl: "https://example.com/alice_avatar.jpg",
      description: "Clean the dishes after dinner.",
      status: 'assigned',
    ),
    Task(
      title: "Take out trash",
      creator: "Bob",
      reward: 5,
      icon: Icons.delete,
      avatarUrl: "https://example.com/bob_avatar.jpg",
      description: "Take out the trash and sort the recycling.",
      status: 'assigned',
    ),
    // Add more tasks if needed
  ];

  final _titleController = TextEditingController();
  final _creatorController = TextEditingController();
  final _rewardController = TextEditingController();
  final _descriptionController = TextEditingController();

  PageController _pageController = PageController(
    initialPage: 0,
    viewportFraction: 1,
  );

  // Initialize the task list size with a large number of tasks for infinite scrolling
  int get itemCount =>
      tasks.length * 1000; // Large multiplier for infinite scroll

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.vertical,
        itemCount: itemCount,
        itemBuilder: (context, index) {
          int taskIndex = index % tasks.length;
          final task = tasks[taskIndex];

          return Dismissible(
            key: Key('${task.title}-$index'),
            direction: DismissDirection.horizontal,
            background: Container(
              color: Colors.red.withOpacity(0.2), // subtle green tint
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.only(left: 32),
              child: Text(
                'Decline',
                style: TextStyle(
                  color:
                      Colors.red, // use green text instead of full white block
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            secondaryBackground: Container(
              color: Colors.green.withOpacity(0.2), // subtle red tint
              alignment: Alignment.centerRight,
              padding: EdgeInsets.only(right: 32),
              child: Text(
                'Accept',
                style: TextStyle(
                  color: Colors.green,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            onDismissed: (direction) {
              setState(() {
                tasks.removeAt(taskIndex);
              });
              if (direction == DismissDirection.endToStart) {
                // Swiped right = accepted
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("${task.title} accepted")),
                );
              } else {
                // Swiped left = declined
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("${task.title} declined")),
                );
              }
            },
            child: Card(
              elevation: 8,
              margin: EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                // Expand to fill available space
                width: double.infinity,
                height: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      task.title,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16),
                    Text(
                      "Created by: ${task.creator}",
                      style: TextStyle(fontSize: 20),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Reward: ${task.reward} pts",
                      style: TextStyle(fontSize: 20),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 24),
                    Text(
                      task.description,
                      style: TextStyle(fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewTask,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        child: Icon(Icons.add),
      ),
    );
  }

  void _addNewTask() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Add New Task"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Task Title'),
              ),
              TextField(
                controller: _creatorController,
                decoration: InputDecoration(labelText: 'Creator'),
              ),
              TextField(
                controller: _rewardController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Reward'),
              ),
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  tasks.add(
                    Task(
                      title: _titleController.text,
                      creator: _creatorController.text,
                      reward: int.parse(_rewardController.text),
                      icon: Icons.assignment,
                      avatarUrl: "https://example.com/default_avatar.jpg",
                      description: _descriptionController.text,
                      status: 'assigned', // New task is assigned by default
                    ),
                  );
                });
                Navigator.of(context).pop();
              },
              child: Text("Add Task"),
            ),
          ],
        );
      },
    );
  }
}
