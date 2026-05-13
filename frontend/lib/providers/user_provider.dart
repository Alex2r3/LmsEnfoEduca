import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';

class UserProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<bool> createUser({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String role,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      await ApiService.post('/auth/register', {
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'password': password,
        'role': role,
      });
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<bool> deleteUser(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await ApiService.delete('/users/$userId');
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<List<User>> getUsersByRole(String role) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiService.get('/users?role=$role');
      final List usersData = response['users'];
      _isLoading = false;
      notifyListeners();
      return usersData.map((u) => User.fromJson(u)).toList();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<bool> updateUser(String id, Map<String, dynamic> data) async {
    try {
      final response = await ApiService.put('/users/$id', data);
      return response != null;
    } catch (e) {
      rethrow;
    }
  }
}
