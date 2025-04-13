import 'package:flutter/material.dart';
import 'package:tasky/services/database.dart';

class LeaderboardScreen extends StatefulWidget {
  final String groupId;

  LeaderboardScreen({required this.groupId});

  @override
  _LeaderboardScreenState createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  List<Map<String, dynamic>> leaderboard = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchLeaderboard();
  }

  Future<void> fetchLeaderboard() async {
    final snapshot = await DatabaseService().getLeaderboardUsers(
      widget.groupId,
    );
    setState(() {
      leaderboard = snapshot;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    print("leadeborad");
    print(leaderboard);
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child:
            isLoading
                ? Center(child: CircularProgressIndicator())
                : Column(
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
    final count = leaderboard.length;

    if (count == 0) return SizedBox();

    final emojis = ["🥇", "🥈", "🥉"];
    final items = leaderboard.take(3).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment:
            count == 1
                ? MainAxisAlignment.center
                : MainAxisAlignment.spaceEvenly,
        children: List.generate(items.length, (index) {
          final user = items[index];
          return Column(
            children: [
              Text(emojis[index], style: TextStyle(fontSize: 32)),
              SizedBox(height: 8),
              Text(
                user["name"],
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: index == 0 ? FontWeight.bold : FontWeight.normal,
                  fontSize: index == 0 ? 18.0 : 16.0,
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
              user["email"] ?? "",
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
