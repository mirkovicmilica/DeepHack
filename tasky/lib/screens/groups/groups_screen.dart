import 'package:firebase_auth/firebase_auth.dart';
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
  List<Group> groups = [];
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
      if (status.isPermanentlyDenied) openAppSettings();
    }
  }

  void _loadUserData() async {
    Map<String, dynamic>? userData = await _dbService.getCurrentUserData();
    if (!mounted) return;
    if (userData != null && userData['uid'] != null) {
      setState(() {
        userName = userData['name'] ?? 'User';
        userId = userData['uid'];
      });
      final userGroups = await _dbService.getUserGroups(userData['uid']);
      if (!mounted) return;
      setState(() {
        groups = userGroups;
      });
    }
  }

  void _createGroup() async {
    String? choice = await showDialog<String>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              'Choose an Option',
              style: TextStyle(color: Theme.of(context).primaryColor),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: Text(
                    'Create New Group',
                    style: TextStyle(color: Theme.of(context).primaryColor),
                  ),
                  onTap: () => Navigator.pop(context, 'create'),
                ),
                ListTile(
                  title: Text(
                    'Add by Group ID',
                    style: TextStyle(color: Theme.of(context).primaryColor),
                  ),
                  onTap: () => Navigator.pop(context, 'add'),
                ),
              ],
            ),
          ),
    );

    if (choice == 'create') {
      String? newGroupName = await _showGroupNameDialog();
      if (newGroupName != null && newGroupName.isNotEmpty && userId != null) {
        await _dbService.createGroup(newGroupName, userId!);
        _loadUserData();
      }
    } else if (choice == 'add') {
      await _requestCameraPermission();
      Navigator.pop(context);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => QrScannerScreen(
                onScan: (groupId) async {
                  if (groupId.isNotEmpty) {
                    await _dbService.addGroupById(groupId, userId!);
                    _loadUserData();
                  }
                },
              ),
        ),
      );
    }
  }

  Future<String?> _showGroupNameDialog() => showDialog<String>(
    context: context,
    builder: (context) {
      TextEditingController controller = TextEditingController();
      return AlertDialog(
        title: Text(
          'Enter Group Name',
          style: TextStyle(color: Theme.of(context).primaryColor),
        ),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(hintText: 'Group Name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: Text('Add'),
          ),
        ],
      );
    },
  );

  Future<bool?> _confirmDeleteGroup(String groupName, String groupId) async {
    return showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              'Confirm Deletion',
              style: TextStyle(color: Theme.of(context).primaryColor),
            ),
            content: Text(
              'Are you sure you want to delete "$groupName"?',
              style: TextStyle(color: Theme.of(context).primaryColor),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(context, true);
                  if (userId != null)
                    await _dbService.removeGroupById(groupId, userId!);
                },
                child: Text('Delete'),
              ),
            ],
          ),
    );
  }

  void _showQRCode(String groupId) => showDialog(
    context: context,
    builder:
        (context) => AlertDialog(
          title: Text('QR Code for Group'),
          content: SizedBox(
            width: 250,
            height: 250,
            child: QrImageView(
              data: groupId,
              size: 250.0,
              version: QrVersions.auto,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Close'),
            ),
          ],
        ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Theme.of(context).primaryColor),
        title: Text(
          'Groups',
          style: TextStyle(
            color: Theme.of(context).primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (userName != null)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Center(
                child: Text(
                  userName!,
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async => await _auth.signOut(),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 24),
            Expanded(
              child:
                  groups.isEmpty
                      ? Center(child: Text("No groups found."))
                      : ListView.builder(
                        padding: EdgeInsets.only(bottom: 16),
                        itemCount: groups.length,
                        itemBuilder: (context, index) {
                          final group = groups[index];
                          return Dismissible(
                            key: Key(group.id),
                            direction: DismissDirection.horizontal,
                            confirmDismiss: (direction) async {
                              if (direction == DismissDirection.endToStart) {
                                return await _confirmDeleteGroup(
                                  group.name,
                                  group.id,
                                );
                              } else if (direction ==
                                  DismissDirection.startToEnd) {
                                _showQRCode(group.id);
                                return false;
                              }
                              return false;
                            },
                            onDismissed:
                                (direction) =>
                                    setState(() => groups.removeAt(index)),
                            background: Container(
                              margin: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              alignment: Alignment.centerLeft,
                              padding: EdgeInsets.only(left: 20),
                              child: Icon(
                                Icons.qr_code,
                                color: Colors.green[700],
                              ),
                            ),
                            secondaryBackground: Container(
                              margin: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              alignment: Alignment.centerRight,
                              padding: EdgeInsets.only(right: 20),
                              child: Icon(Icons.delete, color: Colors.red[700]),
                            ),
                            child: Card(
                              margin: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              elevation: 4,
                              child: ListTile(
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 14,
                                ),
                                leading: CircleAvatar(
                                  backgroundColor: Theme.of(
                                    context,
                                  ).primaryColor.withOpacity(0.1),
                                  child: Icon(
                                    Icons.group,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                                title: Text(
                                  group.name,
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                trailing: Icon(
                                  Icons.arrow_forward_ios,
                                  size: 16,
                                ),
                                onTap:
                                    () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) => HomeScreen(
                                              groupName: group.name,
                                              groupId: group.id,
                                            ),
                                      ),
                                    ),
                              ),
                            ),
                          );
                        },
                      ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 24.0, left: 80, right: 80),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: _createGroup,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[100],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 2,
                  ),
                  icon: Icon(Icons.add, color: Theme.of(context).primaryColor),
                  label: Text(
                    "Add Group",
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
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
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: QRView(
        key: qrKey,
        onQRViewCreated: (QRViewController controller) {
          controller.scannedDataStream.listen((scanData) {
            widget.onScan(scanData.code ?? "");
            Navigator.pushReplacementNamed(context, '/group');
          });
        },
      ),
    );
  }
}
