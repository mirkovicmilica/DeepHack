import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tasky/models/user_model.dart';
import 'package:tasky/services/auth.dart';
import 'routes/app_routes.dart';

class TaskyApp extends StatelessWidget {
  const TaskyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamProvider<UserModel?>.value(
      value: AuthService().user,
      initialData: null,
      child: MaterialApp(
        title: 'Tasky',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.pink, // Set your desired color
          ),
          useMaterial3: true, // Enable Material 3 theme
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        initialRoute: AppRoutes.wrapper,
        routes: AppRoutes.routes,
      ),
    );
  }
}
