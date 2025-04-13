import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tasky/models/task_model.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tasky/services/database.dart'; // Make sure this is correct
import 'package:tasky/services/auth.dart';

class TaskSwipeScreen extends StatefulWidget {
  final String groupId;

  TaskSwipeScreen({required this.groupId});

  @override
  _TaskSwipeScreenState createState() => _TaskSwipeScreenState();
}

class _TaskSwipeScreenState extends State<TaskSwipeScreen> {
  List<TaskModel> tasks = [];
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
              ? Center(
                child: Text(
                  "No tasks found",
                  style: TextStyle(
                    color: Colors.black, // Set the text color to white
                    fontSize: 24, // Increase the font size
                    fontWeight: FontWeight.bold, // Optional: make it bold
                  ),
                ),
              )
              : PageView.builder(
                controller: _pageController,
                scrollDirection: Axis.vertical,
                itemCount: itemCount,
                itemBuilder: (context, index) {
                  int taskIndex = index % tasks.length;
                  final task = tasks[taskIndex];
                  print(
                    "Currently logged-in user: ${FirebaseAuth.instance.currentUser?.uid}",
                  );

                  return Dismissible(
                    key: Key('${task.title}-$index'),
                    direction: DismissDirection.horizontal,
                    background: Container(
                      margin: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      alignment: Alignment.centerLeft,
                      padding: EdgeInsets.only(left: 32),
                      child: Text(
                        'Accept',
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    secondaryBackground: Container(
                      margin: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      alignment: Alignment.centerRight,
                      padding: EdgeInsets.only(right: 32),
                      child: Text(
                        'Decline',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    onDismissed: (direction) async {
                      setState(() {
                        tasks.removeAt(taskIndex);
                      });
                      final currentUserId = AuthService().getCurrentUserId();

                      if (currentUserId == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("User not logged in")),
                        );
                        return;
                      }
                      if (direction == DismissDirection.endToStart) {
                        // Swiped right = declined
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("${task.title} declined")),
                        );
                      } else {
                        print(currentUserId);
                        // Swiped left = accepted
                        await _dbService.acceptTask(task, currentUserId);
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
                        color: const Color.fromARGB(255,215,215,215),
                        width: double.infinity,
                        height: double.infinity,
                        padding: EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 32,
                        ),
                        child: Column(
                          mainAxisAlignment:
                              MainAxisAlignment
                                  .spaceBetween, // Push content down
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Image at the top with top margin
                            Padding(
                              padding: EdgeInsets.only(
                                top: 40,
                              ), // Top margin for image
                              child: Image.asset(
                                'assets/icons/${task.icon}.png',
                                width: 250,
                                height: 250,
                              ),
                            ),
                            // Expanded space for text elements, pushing them to the bottom
                            Expanded(
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment
                                        .end, // Align text to the bottom
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // Title text
                                  Text(
                                    task.title,
                                    style: TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(height: 16),
                                  // Row for Nick and Points on the same line
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Nick",
                                        style: TextStyle(fontSize: 20),
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                            "${task.reward}",
                                            style: TextStyle(fontSize: 20),
                                          ),
                                          SizedBox(width: 8),
                                          Image.asset(
                                            'assets/icons/gem.png',
                                            width: 30,
                                            height: 30,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 24),
                                  // Description with gray color
                                  Text(
                                    task.description,
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.grey,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
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
          content: SingleChildScrollView(
            child: Column(
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

                DropdownButtonFormField<String>(
                  value:
                      _iconController.text.isNotEmpty
                          ? _iconController.text
                          : null,
                  decoration: InputDecoration(labelText: 'Icon'),
                  items:
                      [
                            'clean-dishes',
                            'clean-toilet',
                            'garbage',
                            'homework',
                            'iron-clothes',
                            'laundry',
                            'lunch',
                            'pet-food',
                            'toilet-paper',
                            'vacum',
                            'walk-pet',
                          ]
                          .map(
                            (code) => DropdownMenuItem(
                              value: code,
                              child: Row(
                                children: [
                                  Image.asset(
                                    'assets/icons/$code.png',
                                    width: 30,
                                    height: 30,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(code, style: TextStyle(fontSize: 16)),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                  onChanged: (value) {
                    setState(() {
                      _iconController.text = value!;
                    });
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
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
                  icon: _iconController.text,
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
