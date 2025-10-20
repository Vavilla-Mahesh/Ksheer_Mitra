import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/dashboard_stats.dart';
import '../services/admin_service.dart';

class DashboardProvider with ChangeNotifier {
  final AdminService _adminService = AdminService();

  DashboardStats? _stats;
  List<ActivityLog> _activities = [];
  bool _isLoading = false;
  String? _error;
  Timer? _refreshTimer;

  DashboardStats? get stats => _stats;
  List<ActivityLog> get activities => _activities;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void startAutoRefresh({int intervalMinutes = 5}) {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(
      Duration(minutes: intervalMinutes),
      (_) => fetchDashboardData(),
    );
  }

  void stopAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }

  Future<void> fetchDashboardData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _adminService.getDashboardStats(),
        _adminService.getRecentActivities(limit: 20),
      ]);

      _stats = results[0] as DashboardStats;
      _activities = results[1] as List<ActivityLog>;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshStats() async {
    try {
      _stats = await _adminService.getDashboardStats();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> refreshActivities() async {
    try {
      _activities = await _adminService.getRecentActivities(limit: 20);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }
}
