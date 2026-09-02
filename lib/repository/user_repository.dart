

import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hajedi/data/user.dart';
import 'package:hajedi/utils/auth_utils.dart';
import 'package:http/http.dart' as http;

class UserRepository {
  final String _baseUrl = dotenv.env['API_URL']!;
   
  Future<List<User>> getAllUsers() async {
    final url = Uri.parse('$_baseUrl/auth/users');

    final token = await AuthUtils.getToken();

    final response = await http.get(
      url,
      headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      final usersList = data['data'] as List;

      return usersList
          .map((json) => User.fromJson(json))
          .toList();
    }

    throw Exception(data['message'] ?? 'Failed to fetch users');
  } 

  Future<User> registerUser(User user) async {
    final url = Uri.parse('$_baseUrl/auth/register');
    final token = await AuthUtils.getToken();

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'name': user.name,
        'role': user.role,
        'password': user.password,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 201) {
      return User.fromJson(data['user']);
    }

    throw Exception(data['message'] ?? 'Registration failed');
  }

  Future<User> updateUser(
    String id, {
    String? name,
    String? role,
    String? password,
  }) async {
    final url = Uri.parse('$_baseUrl/auth/users/$id');

    final token = await AuthUtils.getToken();

    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'name': ?name,
        'role': ?role,
        if (password != null && password.isNotEmpty) 'password': password,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return User.fromJson(data['user']);
    }

    throw Exception(data['message'] ?? 'Failed to update user');
  }

  Future<void> removeUser(String id) async {
    final url = Uri.parse('$_baseUrl/auth/users/$id');

    final token = await AuthUtils.getToken();

    final response = await http.delete(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return;
    }

    throw Exception(data['message'] ?? 'Failed to remove user');
  }
} 
