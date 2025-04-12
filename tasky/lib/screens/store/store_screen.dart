import 'package:flutter/material.dart';

class StoreScreen extends StatelessWidget {
  final List<StoreItem> items = [
    StoreItem(name: 'massage', imagePath: 'assets/icons/massage.png', gems: 50),
    StoreItem(name: 'movie', imagePath: 'assets/icons/movie.png', gems: 100),
    StoreItem(name: 'dinner', imagePath: 'assets/icons/dinner.png', gems: 75),
  ];

  void _showSnackBar(BuildContext context, StoreItem item) {
    final scaffoldMessenger = ScaffoldMessenger.of(context);

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
            scaffoldMessenger.showSnackBar(
              SnackBar(
                content: Text('Purchase of ${item.name} was removed.'),
                duration: Duration(seconds: 2),
                behavior: SnackBarBehavior.floating,
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            );
          },
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return GestureDetector(
          onTap: () => _showSnackBar(context, item),
          child: Card(
            elevation: 4,
            margin: const EdgeInsets.symmetric(vertical: 10),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              leading: Image.asset(item.imagePath, width: 40, height: 40),
              title: Text(item.name, style: TextStyle(fontSize: 18)),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('${item.gems}', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 6),
                  Image.asset('assets/icons/gem.png', width: 24, height: 24),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class StoreItem {
  final String name;
  final String imagePath;
  final int gems;

  StoreItem({required this.name, required this.imagePath, required this.gems});
}
