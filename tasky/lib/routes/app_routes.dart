import 'package:flutter/material.dart';
import 'package:tasky/screens/authentication/authentication_screen.dart';
import 'package:tasky/screens/groups/groups_screen.dart';
import 'package:tasky/screens/wrapper.dart';
import '../screens/authentication/login_screen.dart';
import '../screens/authentication/signup_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/tasks/task_swipe_screen.dart';
import '../screens/current_tasks/current_tasks_screen.dart';
import '../screens/leaderboard/leaderboard_screen.dart';

class AppRoutes {
  static const login = '/login';
  static const signup = '/signup';
  static const group = '/group';
  static const tasks = '/tasks';
  static const currentTasks = '/current-tasks';
  static const leaderboard = '/leaderboard';
  static const authentication = '/authentication';
  static const wrapper = "/";

  static Map<String, WidgetBuilder> routes = {
    login: (_) => LoginScreen(),
    signup: (_) => SignupScreen(),
    // tasks: (_) => TaskSwipeScreen(),
    currentTasks: (_) => CurrentTasksScreen(),
    leaderboard: (_) => LeaderboardScreen(),
    authentication: (_) => AuthenticationScreen(),
    group: (_) => GroupScreen(),
    wrapper: (_) => Wrapper(),
  };
}
