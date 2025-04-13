import 'package:flutter/material.dart';

class LeaderboardScreen extends StatelessWidget {
  final List<Map<String, dynamic>> leaderboard = [
    {"name": "Eiden", "points": 2430},
    {"name": "Jackson", "points": 1847},
    {"name": "Emma", "points": 1674},
    {"name": "Sebastian", "points": 1124},
    {"name": "Jason", "points": 875},
    {"name": "Natalie", "points": 774},
    {"name": "Serenity", "points": 723},
    {"name": "Hannah", "points": 559},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 16),
            Text(
              "Leaderboard",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            SizedBox(height: 24),
            _buildTopThree(context),
            SizedBox(height: 16),
            Expanded(child: _buildOthers(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildTopThree(BuildContext context) {
    final topThree = leaderboard.take(3).toList();
    final reordered = [topThree[1], topThree[0], topThree[2]];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(3, (index) {
          final user = reordered[index];
          final originalRank = leaderboard.indexOf(user) + 1;

          final emoji =
              originalRank == 1
                  ? "🥇"
                  : originalRank == 2
                  ? "🥈"
                  : "🥉";

          final fontWeight =
              originalRank == 1 ? FontWeight.bold : FontWeight.normal;

          final fontSize = originalRank == 1 ? 18.0 : 16.0;

          return Column(
            children: [
              Text(emoji, style: TextStyle(fontSize: 32)),
              SizedBox(height: 8),
              Text(
                user["name"],
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: fontWeight,
                  fontSize: fontSize,
                ),
              ),
              Text(
                "${user["points"]} pts",
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildOthers(BuildContext context) {
    final others = leaderboard.skip(3).toList();

    return ListView.builder(
      itemCount: others.length,
      padding: EdgeInsets.only(bottom: 16, top: 8),
      itemBuilder: (context, index) {
        final user = others[index];
        final rank = index + 4;

        return Container(
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(16),
          ),
          child: ListTile(
            leading: CircleAvatar(
              radius: 20,
              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.15),
              child: Text(
                "$rank",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
            title: Text(
              user["name"] ?? "Unnamed",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: Colors.black,
              ),
            ),
            subtitle: Text(
              "@username", // replace with actual usernames if you have them
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
            trailing: Text(
              "${user["points"]} pts",
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      },
    );
  }
}
