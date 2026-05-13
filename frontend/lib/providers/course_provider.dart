import 'package:flutter/material.dart';
import '../models/course_model.dart';
import '../services/api_service.dart';

class CourseProvider extends ChangeNotifier {
  List<Course> _courses = [];
  Map<String, dynamic> _dashboardData = {};
  bool _isLoading = false;

  List<Course> get courses => _courses;
  Map<String, dynamic> get dashboardData => _dashboardData;
  bool get isLoading => _isLoading;

  Future<void> fetchDashboardData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiService.get('/dashboard');
      _dashboardData = response['dashboard'];
      
      if (_dashboardData.containsKey('courses')) {
        _courses = (_dashboardData['courses'] as List)
            .map((c) => Course.fromJson(c))
            .toList();
      }
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> fetchCourses() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiService.get('/courses');
      _courses = (response['courses'] as List)
          .map((c) => Course.fromJson(c))
          .toList();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<bool> createCourse(Map<String, dynamic> data) async {
    try {
      final response = await ApiService.post('/courses', data);
      if (response != null) {
        await fetchCourses();
        await fetchDashboardData();
        return true;
      }
      return false;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> createTask(Map<String, dynamic> data) async {
    try {
      final response = await ApiService.post('/tasks', data);
      if (response != null) {
        await fetchDashboardData();
        return true;
      }
      return false;
    } catch (e) {
      rethrow;
    }
  }
}
