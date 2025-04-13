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
  int userGems = 100;

  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      TaskSwipeScreen(groupId: widget.groupId),
      CurrentTasksScreen(),
      LeaderboardScreen(),
      StoreScreen(
        userGems: userGems,
        onGemsChanged: (newGems) {
          setState(() {
            userGems = newGems;
          });
        },
      ),
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
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Row(
              children: [
                Image.asset(
                  'assets/icons/gem.png',
                  width: 24,
                  height: 24,
                ),
                const SizedBox(width: 6),
                Text(
                  '$userGems',
                  style: TextStyle(
                    fontSize: 18,
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
        backgroundColor: Colors.white,
        elevation: 2,
      ),
      body: SafeArea(
        child: IndexedStack(index: _selectedIndex, children: _screens),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/icons/tasks.png',
              width: 30,
              height: 30,
            ),
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
            icon: Image.asset(
              'assets/icons/store.png',
              width: 30,
              height: 30,
            ),
            label: 'Store',
          ),
        ],
      ),
    );
  }
}
