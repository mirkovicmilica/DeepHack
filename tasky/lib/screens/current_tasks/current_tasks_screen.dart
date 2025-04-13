import 'package:flutter/material.dart';
import 'package:tasky/models/task.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tasky/services/database.dart'; // Make sure this is correct
import 'package:tasky/models/group.dart';

class CurrentTasksScreen extends StatefulWidget {
    final String groupId;
  CurrentTasksScreen({required this.groupId});
  @override
  _CurrentTasksScreenState createState() => _CurrentTasksScreenState();
}

class _CurrentTasksScreenState extends State<CurrentTasksScreen> {
  List<Task> assignedTasks = [];
  List<Task> completedTasks = [];
  late DatabaseService databaseService;
  late String groupId = widget.groupId; // Define the groupId to fetch tasks

  @override
  void initState() {
    super.initState();
    databaseService = DatabaseService();
    groupId = widget.groupId;
    // Load the groupId (you need to ensure you have this)
    // groupId = "your_group_id"; // Replace this with the actual group ID

    _loadTasks();
  }

  Future<void> _loadTasks() async {
    try {
      // Fetch the assigned and pending tasks using the database service
      Map<String, List<Task>> taskData =
          await databaseService.getAssignedAndPendingApprovalTasks(groupId);
      setState(() {
        assignedTasks = taskData['assignedTasks']!;
        completedTasks = taskData['pendingApprovalTasks']!;
      });
    } catch (e) {
      print('Error loading tasks: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            "Assigned Tasks",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        ...assignedTasks.map((task) {
          final isAssignedToYou = task.creator == "You"; // Modify as per your logic

          return Card(
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            elevation: 2,
            child: ListTile(
              title: Text(task.title),
              subtitle: Text("Assigned to: ${task.creator}"),
              trailing: isAssignedToYou
                  ? Image.asset(
                      'assets/icons/camera.png',
                      width: 24,
                      height: 24,
                      color: Colors.orange,
                    )
                  : Icon(Icons.lock_outline, color: Colors.grey),
              onTap: isAssignedToYou
                  ? () => _handleTakePhoto(task)
                  : null, // Disable tap if not yours
            ),
          );
        }),
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
                width: 120,
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

  Future<void> _handleTakePhoto(Task task) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      print("User completed '${task.title}' with photo: ${pickedFile.path}");

      // Mark task as completed via the Firebase service
      await databaseService.updateTaskStatus(task.id, 'completed');

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
