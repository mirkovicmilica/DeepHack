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
            // seedColor: const Color.fromARGB(255, 241, 239, 236), // Set your desired color
            seedColor: const Color.fromARGB(255, 120, 120, 120), // Set your desired color
          ),
          // scaffoldBackgroundColor: Color.fromARGB(255, 245,245,245), // light gray background for all screens,
          scaffoldBackgroundColor: Color.fromARGB(255, 8, 26, 45), // light gray background for all screens

          useMaterial3: true, // Enable Material 3 theme
          visualDensity: VisualDensity.adaptivePlatformDensity,
          bottomNavigationBarTheme: BottomNavigationBarThemeData(
            backgroundColor: const Color.fromARGB(255, 255, 2, 187), // gray bar background
            selectedItemColor: const Color.fromARGB(255, 255,255,255), // active icon/text color
            unselectedItemColor: const Color.fromARGB(255, 255,255,255), // inactive icon/text color
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
