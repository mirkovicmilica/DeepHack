import 'package:flutter/material.dart';
import 'package:tasky/models/group.dart';
import 'package:tasky/screens/home/home_screen.dart';
import 'package:tasky/services/auth.dart';
import 'package:tasky/services/database.dart';

class GroupScreen extends StatefulWidget {
  @override
  _GroupScreenState createState() => _GroupScreenState();
}

class _GroupScreenState extends State<GroupScreen> {
  final AuthService _auth = AuthService();
  final DatabaseService _dbService = DatabaseService();
  String? userName;
  List<Group> groups = []; // List to store group IDs
  String? userId;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() async {
    Map<String, dynamic>? userData = await _dbService.getCurrentUserData();
    if (!mounted) return; // Make sure the widget is still in the tree

    if (userData != null && userData['uid'] != null) {
      setState(() {
        userName = userData['name'] ?? 'User';
        userId =
            userData['uid']; // Add this line if userId is a member variable
      });

      final userGroups = await _dbService.getUserGroups(userData['uid']);
      if (!mounted) return;
      setState(() {
        groups = userGroups;
      });
    } else {
      print('User data or UID is missing.');
    }
  }

  // Create a new group
  void _createGroup() async {
    String? groupName = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Choose an Option',
            style: TextStyle(
              color:
                  Theme.of(context).primaryColor, // Use theme color for title
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text(
                  'Create New Group',
                  style: TextStyle(
                    color:
                        Theme.of(context).primaryColor, // Theme color for text
                  ),
                ),
                onTap: () {
                  Navigator.pop(
                    context,
                    'create',
                  ); // Close the dialog and return 'create'
                },
              ),
              ListTile(
                title: Text(
                  'Add by Group ID',
                  style: TextStyle(
                    color:
                        Theme.of(context).primaryColor, // Theme color for text
                  ),
                ),
                onTap: () {
                  Navigator.pop(
                    context,
                    'add',
                  ); // Close the dialog and return 'add'
                },
              ),
            ],
          ),
        );
      },
    );

    if (groupName != null) {
      if (groupName == 'create') {
        // Ask for new group name if 'Create New Group' is selected
        String? newGroupName = await _showGroupNameDialog();
        if (newGroupName != null && newGroupName.isNotEmpty) {
          // Ensure that userName is not null before using it
          if (userId != null) {
            // Create group and add user to it
            await _dbService.createGroup(newGroupName, userId!);
            _loadUserData(); // Reload groups after creating the group
          } else {
            // Handle the case where userName is null
            print('Error: userName is null.');
          }
        }
      } else if (groupName == 'add') {
        // Ask for group ID if 'Add by Group ID' is selected
        String? groupId = await _showGroupIdDialog();
        if (groupId != null && groupId.isNotEmpty) {
          // Add user to existing group
          await _dbService.addGroupById(groupId, userId!);
          _loadUserData(); // Reload groups after adding to the group
        }
      }
    }
  }

  // Show dialog to input a new group name
  Future<String?> _showGroupNameDialog() {
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        TextEditingController controller = TextEditingController();
        return AlertDialog(
          title: Text(
            'Enter Group Name',
            style: TextStyle(
              color:
                  Theme.of(context).primaryColor, // Use theme color for title
            ),
          ),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: InputDecoration(hintText: 'Group Name'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog if cancel
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  controller.text,
                ); // Pass the entered group name
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  // Show dialog to input a group ID
  Future<String?> _showGroupIdDialog() {
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        TextEditingController controller = TextEditingController();
        return AlertDialog(
          title: Text(
            'Enter Group ID',
            style: TextStyle(
              color:
                  Theme.of(context).primaryColor, // Use theme color for title
            ),
          ),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: InputDecoration(hintText: 'Group ID'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog if cancel
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  controller.text,
                ); // Pass the entered group ID
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  Future<bool?> _confirmDeleteGroup(String groupName) async {
    bool? delete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Confirm Deletion',
            style: TextStyle(
              color: Theme.of(context).primaryColor, // Theme color for title
            ),
          ),
          content: Text(
            'Are you sure you want to delete "$groupName"?',
            style: TextStyle(
              color: Theme.of(context).primaryColor, // Theme color for content
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false); // Don't delete
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, true); // Confirm delete
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );

    return delete; // Return the result of the confirmation
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          if (userName != null)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Text(
                userName!,
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          TextButton.icon(
            icon: Icon(Icons.logout),
            label: Text('Log out'),
            onPressed: () async {
              await _auth.signOut();
            },
          ),
        ],
        iconTheme: IconThemeData(
          color:
              Theme.of(
                context,
              ).primaryColor, // Set the color of the back button
        ),
        title: Text(
          'Groups',
          style: TextStyle(
            color: Theme.of(context).primaryColor, // Title uses primary color
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Displaying groups as big containers in the center of the screen
            Expanded(
              child: ListView.separated(
                padding: EdgeInsets.symmetric(vertical: 8),
                itemCount: groups.length,
                separatorBuilder: (_, __) => SizedBox(height: 12),
                itemBuilder: (context, index) {
                  return Center(
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.85,
                      child: Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: ListTile(
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 14,
                            horizontal: 16,
                          ),
                          title: Center(
                            child: Text(
                              groups[index].name,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          trailing: Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 18,
                            color: Colors.grey[600],
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => HomeScreen(
                                      groupName: groups[index].name,
                                      groupId: groups[index].id,
                                    ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Add Group button
            SizedBox(height: 20),

            // Add Group Button (Small, with emoji)
            Center(
              child: ElevatedButton.icon(
                onPressed: _createGroup,
                icon: Text("➕", style: TextStyle(fontSize: 18)),
                label: Text(
                  "Add Group",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Theme.of(context).primaryColor,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  minimumSize: Size(0, 40), // Smaller height
                  elevation: 3,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
