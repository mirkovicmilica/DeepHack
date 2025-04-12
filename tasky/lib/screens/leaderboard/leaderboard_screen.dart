import 'package:flutter/material.dart';

class LeaderboardScreen extends StatelessWidget {
  final List<Map<String, dynamic>> leaderboard = [
    {
      "name": "Jackson",
      "points": 1847,
      "avatar": "https://i.pravatar.cc/150?img=12",
    },
    {
      "name": "Eiden",
      "points": 2430,
      "avatar": "https://i.pravatar.cc/150?img=8",
    },
    {
      "name": "Emma",
      "points": 1674,
      "avatar": "https://i.pravatar.cc/150?img=5",
    },
    {
      "name": "Sebastian",
      "points": 1124,
      "avatar": "https://i.pravatar.cc/150?img=4",
    },
    {
      "name": "Jason",
      "points": 875,
      "avatar": "https://i.pravatar.cc/150?img=3",
    },
    {
      "name": "Natalie",
      "points": 774,
      "avatar": "https://i.pravatar.cc/150?img=2",
    },
    {
      "name": "Serenity",
      "points": 723,
      "avatar": "https://i.pravatar.cc/150?img=7",
    },
    {
      "name": "Hannah",
      "points": 559,
      "avatar": "https://i.pravatar.cc/150?img=1",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0F172A), // Dark background
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 16),
            const Text(
              "Leaderboard",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 24),
            _buildTopThree(),
            SizedBox(height: 16),
            Expanded(child: _buildOthers()),
          ],
        ),
      ),
    );
  }

  Widget _buildTopThree() {
    final topThree = leaderboard.take(3).toList(); // First 3

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(3, (index) {
          final person = topThree[index];
          final isFirst = index == 1;

          return Column(
            children: [
              if (isFirst)
                Icon(Icons.emoji_events, color: Colors.amber, size: 32),
              CircleAvatar(
                radius: isFirst ? 40 : 32,
                backgroundImage: NetworkImage(person["avatar"]),
              ),
              SizedBox(height: 8),
              Text(
                person["name"],
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: isFirst ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              Text(
                "${person["points"]} pts",
                style: TextStyle(color: Colors.grey[400], fontSize: 14),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildOthers() {
    final others = leaderboard.skip(3).toList();

    return ListView.builder(
      itemCount: others.length,
      padding: EdgeInsets.only(bottom: 16),
      itemBuilder: (context, index) {
        final user = others[index];
        final rank = index + 4;

        return Container(
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(16),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(user["avatar"]),
            ),
            title: Text(user["name"], style: TextStyle(color: Colors.white)),
            subtitle: Text(
              "@username",
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
            trailing: Text(
              "${user["points"]} pts",
              style: TextStyle(
                color: Colors.tealAccent[100],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      },
    );
  }
}
