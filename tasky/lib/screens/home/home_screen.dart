import 'package:flutter/material.dart';
import '../tasks/task_swipe_screen.dart';
import '../current_tasks/current_tasks_screen.dart';
import '../leaderboard/leaderboard_screen.dart';

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
      CurrentTasksScreen(),
      LeaderboardScreen(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.groupName}',
          style: TextStyle(color: Theme.of(context).primaryColor),
        ),
        iconTheme: IconThemeData(color: Theme.of(context).primaryColor),
      ),
      body: SafeArea(
        child: IndexedStack(index: _selectedIndex, children: _screens),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.assignment), label: 'Tasks'),
          BottomNavigationBarItem(icon: Icon(Icons.check), label: 'Current'),
          BottomNavigationBarItem(
            icon: Icon(Icons.leaderboard),
            label: 'Leaderboard',
          ),
        ],
      ),
    );
  }
}
