import 'package:flutter/material.dart';
import 'package:tasky/models/user_model.dart';
import 'package:tasky/screens/authentication/authentication_screen.dart';
import 'package:provider/provider.dart';
import 'package:tasky/screens/groups/groups_screen.dart';

class Wrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserModel?>(context);
    print("test");
    return user == null ? AuthenticationScreen() : GroupScreen();
  }
}
