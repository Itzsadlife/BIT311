import 'services/auth_service.dart';
import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart'; // You should create a home screen

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  Future<void> _checkLoginState(BuildContext context) async {
    var cookie = await AuthService().getCookie();
    if (cookie != null) {
      // Verify if the session cookie is still valid
      // Navigate to the HomeScreen if the session is valid
      // Otherwise, navigate to the LoginScreen
      // This part may require a backend endpoint to validate the session
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Your Project Name',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => LoginScreen(),
        '/home': (context) => HomeScreen(), // You need to create HomeScreen widget
      },
    );
  }
}