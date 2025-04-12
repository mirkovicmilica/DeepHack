import 'package:flutter/material.dart';
import 'package:tasky/models/task.dart';

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
          // Calculate the actual index by taking the modulus of index and tasks length
          int taskIndex = index % tasks.length;
          final task = tasks[taskIndex];

          return Card(
            margin: EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(task.title, style: TextStyle(fontSize: 24)),
                SizedBox(height: 10),
                Text("Created by: ${task.creator}"),
                Text("Reward: ${task.reward} pts"),
                SizedBox(height: 20),
                task.status == 'completed'
                    ? Row(
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
                    )
                    : SizedBox.shrink(),
              ],
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
