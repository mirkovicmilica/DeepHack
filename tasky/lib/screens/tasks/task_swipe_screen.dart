import 'package:flutter/material.dart';
import 'package:tasky/models/task.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tasky/services/database.dart'; // Make sure this is correct

class TaskSwipeScreen extends StatefulWidget {
  final String groupId;

  TaskSwipeScreen({required this.groupId});

  @override
  _TaskSwipeScreenState createState() => _TaskSwipeScreenState();
}

class _TaskSwipeScreenState extends State<TaskSwipeScreen> {
  List<Task> tasks = [];
  bool isLoading = true;
  final DatabaseService _dbService = DatabaseService();

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final fetchedTasks = await _dbService.getIncompleteTasksForGroup(
      widget.groupId,
    );
    setState(() {
      tasks = fetchedTasks;
      isLoading = false;
    });
  }

  PageController _pageController = PageController(
    initialPage: 0,
    viewportFraction: 1,
  );

  int get itemCount => tasks.length * 1000;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
          isLoading
              ? Center(child: CircularProgressIndicator())
              : tasks.isEmpty
              ? Center(child: Text("No tasks found"))
              : PageView.builder(
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
                              Colors
                                  .red, // use green text instead of full white block
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
                        padding: EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 32,
                        ),
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
    final _titleController = TextEditingController();
    final _rewardController = TextEditingController();
    final _descriptionController = TextEditingController();
    final _avatarUrlController = TextEditingController();
    final _iconController = TextEditingController();

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
                controller: _rewardController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Reward'),
              ),
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
              ),

              TextField(
                controller: _avatarUrlController,
                decoration: InputDecoration(labelText: 'Avatar URL'),
              ),
              TextField(
                controller: _iconController,
                decoration: InputDecoration(labelText: 'Icon Code (numeric)'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                // Convert icon code to IconData
                IconData iconData = IconData(
                  int.tryParse(_iconController.text) ??
                      Icons.assignment.codePoint,
                  fontFamily: 'MaterialIcons',
                );

                // Create the task with the provided values
                await _dbService.createTask(
                  title: _titleController.text,
                  groupId: widget.groupId,
                  description: _descriptionController.text,
                  reward: int.tryParse(_rewardController.text) ?? 0,
                  status: "incomplete",

                  avatarUrl:
                      _avatarUrlController.text.isEmpty
                          ? "https://example.com/default_avatar.jpg"
                          : _avatarUrlController.text,
                  icon: iconData,
                );

                Navigator.of(context).pop();
                _loadTasks(); // Refresh task list
              },
              child: Text("Add Task"),
            ),
          ],
        );
      },
    );
  }
}
