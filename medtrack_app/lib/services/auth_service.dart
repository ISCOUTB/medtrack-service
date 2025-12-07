import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class AuthService with ChangeNotifier {
  final String baseUrl = 'http://10.0.2.2:3000/auth';

  String? _token;

  bool get isAuthenticated => _token != null && !JwtDecoder.isExpired(_token!);

  Future<bool> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _token = data['token'];
        await _saveToken(_token!);
        notifyListeners();
        return true;
      } else {
        return false;
      }
    } catch (e) {
      debugPrint('Error logging in: $e');
      return false;
    }
  }

  Future<bool> register(String nombre, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nombre': nombre,
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 201) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      debugPrint('Error registering: $e');
      return false;
    }
  }

  Future<void> logout() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    notifyListeners();
  }

  Future<void> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('token')) return;

    final extractedToken = prefs.getString('token');
    if (JwtDecoder.isExpired(extractedToken!)) {
      return;
    }

    _token = extractedToken;
    notifyListeners();
  }

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  String? get token => _token;

  int? get userId {
    if (_token != null) {
      Map<String, dynamic> decodedToken = JwtDecoder.decode(_token!);
      return decodedToken['id'];
    }
    return null;
  }
}
