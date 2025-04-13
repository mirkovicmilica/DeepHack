import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:tasky/models/task_model.dart'; // Import your Task model
import 'package:image_picker/image_picker.dart';
import 'package:tasky/services/database.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Define a stateful widget for the current tasks screen
class CurrentTasksScreen extends StatefulWidget {
  final String groupId;

  const CurrentTasksScreen({Key? key, required this.groupId}) : super(key: key);

  @override
  _CurrentTasksScreenState createState() => _CurrentTasksScreenState();
}

// The mutable state for the CurrentTasksScreen widget
class _CurrentTasksScreenState extends State<CurrentTasksScreen> {
  // Sample list of tasks - normally you might fetch this data from a service
  List<TaskModel> acceptedTasks = [];
  List<TaskModel> completedTasks = [];
  final DatabaseService _dbService = DatabaseService();
  bool isLoading = true;
  String? currentUserId;

  @override
  void initState() {
    super.initState();
    currentUserId = FirebaseAuth.instance.currentUser?.uid;

    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final fetchedAcceptedTasks = await _dbService.getAssignedTasks(
      widget.groupId,
    );
    final fetchedCompletedTasks = await _dbService.getCompletedTasks(
      widget.groupId,
    );
    setState(() {
      acceptedTasks = fetchedAcceptedTasks;
      completedTasks = fetchedCompletedTasks;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }
    print("tasks");
    print(acceptedTasks);

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
        ...acceptedTasks.map((task) {
          final isAssignedToYou = task.creator == currentUserId;

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
              onTap: () => _showCompletedImagePopup(task),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _handleTakePhoto(TaskModel task) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      print("User completed '${task.title}' with photo: ${pickedFile.path}");

      // Upload image to Firebase Storage
      final fileName =
          "${task.id}_${DateTime.now().millisecondsSinceEpoch}.jpg";
      final storageRef = FirebaseStorage.instance.ref().child(
        "task_images/$fileName",
      );
      print("PHOTO TEST");
      try {
        print("PHOTO TEST 5");

        await storageRef.putData(await pickedFile.readAsBytes());
        print("PHOTO TEST 4");

        final imageUrl = await storageRef.getDownloadURL();

        // Update the task model with the image URL and set status to completed
        task.imageUrl = imageUrl;
        task.status = 'completed';
        print("PHOTO TEST 3");

        // Update task in Firestore
        await _dbService.completeTask(
          task,
        ); // make sure this updates the full task including imageUrl
        print("PHOTO TEST 2");

        // Update UI
        setState(() {
          acceptedTasks.remove(task);
          completedTasks.add(task);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Task '${task.title}' marked as completed!")),
        );
      } catch (e) {
        print("Error uploading image: $e");
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Failed to upload image.")));
      }
    } else {
      print("User cancelled photo for ${task.title}");
    }
  }

  void _showCompletedImagePopup(TaskModel task) {
    print("SHOW COMPLETE");
    print(task);
    if (task.imageUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("No image available for this task.")),
      );
      return;
    }

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text("Completed Task Image"),
            content: Image.network(task.imageUrl, fit: BoxFit.contain),
            actions: [
              TextButton(
                child: Text("Close"),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
    );
  }
}
