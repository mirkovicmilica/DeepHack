import 'package:flutter/material.dart';
import 'package:tasky/screens/home/home_screen.dart';
import 'package:tasky/services/auth.dart';

class GroupScreen extends StatefulWidget {
  @override
  _GroupScreenState createState() => _GroupScreenState();
}

class _GroupScreenState extends State<GroupScreen> {
  final AuthService _auth = AuthService();
  List<String> groups = []; // List to store group names

  // Create a new group with an editable name
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
          setState(() {
            groups.add(newGroupName); // Add new group to the list
          });
        }
      } else if (groupName == 'add') {
        // Ask for group ID if 'Add by Group ID' is selected
        String? groupId = await _showGroupIdDialog();
        if (groupId != null && groupId.isNotEmpty) {
          setState(() {
            groups.add(groupId); // Add existing group by ID
          });
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
          TextButton.icon(
            icon: Icon(Icons.person),
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
              child: ListView.builder(
                itemCount: groups.length,
                itemBuilder: (context, index) {
                  return Dismissible(
                    key: Key(groups[index]),
                    direction: DismissDirection.endToStart,
                    confirmDismiss: (direction) async {
                      // Show confirmation dialog before dismissing
                      return await _confirmDeleteGroup(groups[index]);
                    },
                    onDismissed: (direction) {
                      // Remove the group from the list when dismissed
                      setState(() {
                        groups.removeAt(
                          index,
                        ); // Remove the group at the given index
                      });
                    },
                    background: Container(
                      color: Colors.red,
                      child: Icon(Icons.delete, color: Colors.white),
                      alignment: Alignment.centerRight,
                      padding: EdgeInsets.only(right: 20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Container(
                        height: 100,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              offset: Offset(2, 4),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        child: InkWell(
                          onTap: () {
                            // Navigate to home screen for the selected group
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => HomeScreen(
                                      groupName:
                                          groups[index], // Pass the group name
                                    ),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Center(
                            child: Text(
                              groups[index],
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      // Floating action button for creating a new group
      floatingActionButton: FloatingActionButton(
        onPressed: _createGroup, // Trigger the create group function
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        child: Icon(Icons.add), // The plus icon
      ),
    );
  }
}
