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
          scaffoldBackgroundColor: Color(
            0xFFF4F4F4,
          ), // light gray background for all screens

          useMaterial3: true, // Enable Material 3 theme
          visualDensity: VisualDensity.adaptivePlatformDensity,
          bottomNavigationBarTheme: BottomNavigationBarThemeData(
            backgroundColor: Colors.grey[400], // gray bar background
            selectedItemColor: Colors.white, // active icon/text color
            unselectedItemColor: Colors.grey[300], // inactive icon/text color
            showUnselectedLabels: true,
            type: BottomNavigationBarType.fixed, // keeps all items visible
          ),
        ),
        initialRoute: AppRoutes.wrapper,
        routes: AppRoutes.routes,
      ),
    );
  }
}
