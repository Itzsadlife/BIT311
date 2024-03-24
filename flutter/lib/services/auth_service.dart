// lib/services/auth_service.dart
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final String baseUrl = 'http://192.168.98.55/BIT311_backend/';

  Future<bool> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('${baseUrl}login.php'),
      body: {
        'email': email,
        'password': password,
      },
    );

    if (response.statusCode == 200) {
      // Parse response and check for success
      var jsonResponse = jsonDecode(response.body);
      if (jsonResponse['status'] == 'success') {
        // Save the session cookie
        var cookie = response.headers['set-cookie'];
        if (cookie != null) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('cookie', cookie);
        }
        return true;
      }
    }
    return false;
  }

  Future<void> logout() async {
    // Clear the session cookie
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('cookie');
  }

  // Helper function to get the stored cookie
  Future<String?> getCookie() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('cookie');
  }
}
