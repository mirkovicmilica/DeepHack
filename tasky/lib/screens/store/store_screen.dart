import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tasky/services/database.dart';

class StoreScreen extends StatefulWidget {
  final int userGems;
  final Function(int) onGemsChanged;
  StoreScreen({required this.userGems, required this.onGemsChanged});
  @override
  _StoreScreenState createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {
  late int userGems;
  String? currentUserId;
  final DatabaseService _dbService = DatabaseService();

  final List<StoreItem> items = [
    StoreItem(name: 'massage', imagePath: 'assets/icons/massage.png', gems: 50),
    StoreItem(name: 'movie', imagePath: 'assets/icons/movie.png', gems: 80),
    StoreItem(name: 'dinner', imagePath: 'assets/icons/dinner.png', gems: 75),
    StoreItem(name: '1', imagePath: 'assets/icons/coin.png', gems: 20),
    StoreItem(name: '10', imagePath: 'assets/icons/coins.png', gems: 100),
    StoreItem(name: '100', imagePath: 'assets/icons/euros.png', gems: 500),
  ];

  @override
  void initState() {
    super.initState();
    userGems = widget.userGems;
    currentUserId = FirebaseAuth.instance.currentUser?.uid;
  }

  void _updateGems(int newAmount) async {
    setState(() {
      userGems = newAmount;
    });

    // Update in the parent widget
    widget.onGemsChanged(userGems);

    // Update in Firestore
    await _dbService.updateUserPoints(currentUserId!, newAmount);
  }

  void _showSnackBar(BuildContext context, StoreItem item) {
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    if (userGems >= item.gems) {
      _updateGems(userGems - item.gems);

      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('You purchased ${item.name}.'),
          duration: Duration(seconds: 4),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () {
              _updateGems(userGems + item.gems);

              scaffoldMessenger.showSnackBar(
                SnackBar(
                  content: Text('Purchase of ${item.name} was removed.'),
                  duration: Duration(seconds: 2),
                  behavior: SnackBarBehavior.floating,
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              );
            },
          ),
        ),
      );
    } else {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('Not enough gems to purchase ${item.name}.'),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Main content
          Padding(
            padding: const EdgeInsets.only(top: 80), // Give space for top bar
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                final isAffordable = userGems >= item.gems;
                return GestureDetector(
                  onTap: () => _showSnackBar(context, item),
                  child: Card(
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    color: isAffordable ? Colors.white : Colors.grey[300],
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      leading: Image.asset(
                        item.imagePath,
                        width: 40,
                        height: 40,
                      ),
                      title: Text(item.name, style: TextStyle(fontSize: 18)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('${item.gems}', style: TextStyle(fontSize: 16)),
                          const SizedBox(width: 6),
                          Image.asset(
                            'assets/icons/gem.png',
                            width: 24,
                            height: 24,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class StoreItem {
  final String name;
  final String imagePath;
  final int gems;

  StoreItem({required this.name, required this.imagePath, required this.gems});
}
