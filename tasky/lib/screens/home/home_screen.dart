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
      CurrentTasksScreen(groupId: widget.groupId),
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
        currentScreen = StoreScreen(
          userGems: userGems,
          onGemsChanged: (newGems) {
            setState(() {
              userGems = newGems;
            });
          },
        );
        break;
      default:
        currentScreen = TaskSwipeScreen(groupId: widget.groupId);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.groupName,
          style: TextStyle(color: Colors.black), // Set title text color to white
        ),
        iconTheme: IconThemeData(color: Colors.black), // Set icon color to white
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Row(
              children: [
                Image.asset('assets/icons/gem.png', width: 24, height: 24),
                const SizedBox(width: 6),
                Text(
                  '$userGems',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.black, // Set gem text color to black
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
        backgroundColor: const Color.fromARGB(255,205,205,205),
        elevation: 2,
      ),
      body: SafeArea(child: currentScreen),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color.fromARGB(255,205,205,205),
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.black, // Set selected icon and label color to black
        unselectedItemColor: Colors.black, // Set unselected icon and label color to black
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
