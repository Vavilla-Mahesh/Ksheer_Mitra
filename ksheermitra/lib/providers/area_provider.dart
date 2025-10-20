import 'package:flutter/foundation.dart';
import '../models/area.dart';
import '../services/admin_service.dart';

class AreaProvider with ChangeNotifier {
  final AdminService _adminService = AdminService();

  List<Area> _areas = [];
  bool _isLoading = false;
  String? _error;

  List<Area> get areas => _areas;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchAreas({bool? isActive}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _areas = await _adminService.getAreas(isActive: isActive);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Area?> getAreaById(String areaId) async {
    try {
      return await _adminService.getAreaDetails(areaId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<bool> createArea(Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final area = await _adminService.createArea(data);
      _areas.insert(0, area);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateArea(String areaId, Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _adminService.updateArea(areaId, data);
      final index = _areas.indexWhere((a) => a.id == areaId);
      if (index != -1) {
        final updatedArea = await _adminService.getAreaDetails(areaId);
        _areas[index] = updatedArea;
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteArea(String areaId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _adminService.deleteArea(areaId);
      _areas.removeWhere((a) => a.id == areaId);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
