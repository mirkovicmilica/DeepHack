import 'package:flutter/material.dart';
import '../tasks/task_swipe_screen.dart';
import '../current_tasks/current_tasks_screen.dart';
import '../leaderboard/leaderboard_screen.dart';
import '../store/store_screen.dart';

class HomeScreen extends StatefulWidget {
  final String groupName;
  final String groupId;

  HomeScreen({required this.groupName, required this.groupId});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // Declare the screens list, but do not initialize it with the groupId yet.
  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    // Initialize the screens list in the initState method.
    _screens = [
      TaskSwipeScreen(groupId: widget.groupId),
      CurrentTasksScreen(groupId: widget.groupId),
      LeaderboardScreen(),
      StoreScreen(), // Add StoreScreen here
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget currentScreen;

    switch (_selectedIndex) {
      case 0:
        currentScreen = TaskSwipeScreen(groupId: widget.groupId);
        break;
      case 1:
        currentScreen = CurrentTasksScreen(
          key: ValueKey(DateTime.now()), // Force rebuild
          groupId: widget.groupId,
        );
        break;
      case 2:
        currentScreen = LeaderboardScreen();
        break;
      case 3:
        currentScreen = StoreScreen();
        break;
      default:
        currentScreen = TaskSwipeScreen(groupId: widget.groupId);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.groupName,
          style: TextStyle(color: Theme.of(context).primaryColor),
        ),
        iconTheme: IconThemeData(color: Theme.of(context).primaryColor),
      ),
      body: SafeArea(child: currentScreen),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(
            icon: Image.asset('assets/icons/tasks.png', width: 30, height: 30),
            label: 'Tasks',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/icons/current.png',
              width: 30,
              height: 30,
            ),
            label: 'Current',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/icons/leaderboard.png',
              width: 30,
              height: 30,
            ),
            label: 'Leaderboard',
          ),
          BottomNavigationBarItem(
            icon: Image.asset('assets/icons/store.png', width: 30, height: 30),
            label: 'Store',
          ),
        ],
      ),
    );
  }
}
