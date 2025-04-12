import 'package:flutter/material.dart';
import 'package:tasky/models/task.dart';
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
                                  icon: Icon(
                                    Icons.thumb_up,
                                    color: Colors.green,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      task.upvotes++;
                                    });
                                  },
                                ),
                                Text("${task.upvotes}"),
                                IconButton(
                                  icon: Icon(
                                    Icons.thumb_down,
                                    color: Colors.red,
                                  ),
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
