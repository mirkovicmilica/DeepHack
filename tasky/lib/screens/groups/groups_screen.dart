import 'package:flutter/material.dart';
import 'package:tasky/models/group.dart';
import 'package:tasky/screens/home/home_screen.dart';
import 'package:tasky/services/auth.dart';
import 'package:tasky/services/database.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';


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

  Future<void> _requestCameraPermission() async {
    var status = await Permission.camera.status;

    if (!status.isGranted) {
      status = await Permission.camera.request();

      if (status.isDenied) {
        // The user denied the permission
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Camera permission is required to scan QR codes')),
        );
        return;
      }

      if (status.isPermanentlyDenied) {
        // The user permanently denied the permission, open app settings
        openAppSettings();
      }
    }
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
       // String? groupId = await _showGroupIdDialog();
        //if (groupId != null && groupId.isNotEmpty) {
          // Add user to existing group
          //await _dbService.addGroupById(groupId, userId!);
          //_loadUserData(); // Reload groups after adding to the group
          await _requestCameraPermission();
          Navigator.pop(context); // close dialog
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => QrScannerScreen(
                onScan: (groupId) async {
                  if (groupId.isNotEmpty) {
                    await _dbService.addGroupById(groupId, userId!);
                    _loadUserData(); // Reload groups after adding to the group
                  }
                },
              ),
            ),
          );
        //}
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

  Future<bool?> _confirmDeleteGroup(String groupName, String groupId) async {
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
              onPressed: () async {
                Navigator.pop(context, true); //  TODO Confirm delete

                // Make sure the userId is not null before calling removeGroupById
                if (userId != null) {
                  await _dbService.removeGroupById(groupId, userId!);
                  // Optionally, you can show a success message or handle UI changes after the delete operation
                  print("Group $groupName deleted successfully");
                } else {
                  print("Error: userId is null.");
                }
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
              child: ListView.builder(
                itemCount: groups.length,
                itemBuilder: (context, index) {
                  return Dismissible(
                    key: Key(groups[index].id),
                    direction: DismissDirection.horizontal, // Allow horizontal swipe (both directions)
                    confirmDismiss: (direction) async {
                      if (direction == DismissDirection.endToStart) {
                        // Left swipe -> delete group
                        return await _confirmDeleteGroup(groups[index].name, groups[index].id);
                      } else if (direction == DismissDirection.startToEnd) {
                        // Right swipe -> show QR code
                        _showQRCode(groups[index].id);
                        return false; // Return false to prevent the item from being dismissed on right swipe
                      }
                      return false;
                    },
                    onDismissed: (direction) {
                      if (direction == DismissDirection.endToStart) {
                        setState(() {
                          groups.removeAt(index); // Remove the group from the list if deleted
                        });
                      }
                    }
                    /*direction: DismissDirection.endToStart,
                    confirmDismiss: (direction) async {
                      return await _confirmDeleteGroup(groups[index].name, groups[index].id);
                    },
                    onDismissed: (direction) {
                      setState(() {
                        groups.removeAt(index);
                      });
                    }*/,
                    secondaryBackground: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: EdgeInsets.only(right: 20),
                      child: Icon(Icons.delete, color: Colors.white),
                    ),
                    background: Container(
                      color: Colors.green,
                      alignment: Alignment.centerRight,
                      padding: EdgeInsets.only(right: 20),
                    ),
                    child: Card(
                      margin: EdgeInsets.all(8),
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        title: Text(
                          groups[index].name,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        trailing: Icon(Icons.arrow_forward_ios),
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
                  );
                },
              ),
            ),
            // Add Group button
            ElevatedButton(onPressed: _createGroup, child: Text('Add Group')),
          ],
        ),
      ),
    );
  }

  // Method to show the QR code in a dialog
  void _showQRCode(String groupId) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('QR Code for Group'),
        content: SizedBox(
          width: 250,  // Set a fixed width for the QR code
          height: 250, // Set a fixed height for the QR code
          child: QrImageView(
            data: groupId, 
            size: 250.0,    
            version: QrVersions.auto, 
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close the dialog
            },
            child: Text('Close'),
          ),
        ],
      );
    },
  );
}


}

class QrScannerScreen extends StatefulWidget {
  final Function(String) onScan;

  QrScannerScreen({required this.onScan});

  @override
  _QrScannerScreenState createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  final GlobalKey qrKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Scan QR Code'),
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () {
            Navigator.pop(context);  // Close the scanner screen
          },
        ),
      ),
      body: QRView(
        key: qrKey,
        onQRViewCreated: (QRViewController controller) {
          controller.scannedDataStream.listen((scanData) {
            widget.onScan(scanData.code ?? "");  // Send the scanned code back to the callback
            Navigator.pop(context);  // Close the scanner screen after scanning
          });
        },
      ),
    );
  }

}

/*class QrScannerScreen extends StatelessWidget {
  final Function(String) onScan;

  QrScannerScreen({required this.onScan});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Scan QR Code'),
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () {
            Navigator.pop(context);  // Close the scanner screen
          },
        ),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            // Start scanning for QR code
            String scannedCode = await scan.Scan().toString();

            // Send the scanned code back to the callback
            if (scannedCode.isNotEmpty) {
              onScan(scannedCode); // Send the scanned code to the parent widget
            }

            // Close the scanner screen after scanning
            Navigator.pop(context);
          },
          child: Text("Scan QR Code"),
        ),
      ),
    );
  }
}*/
