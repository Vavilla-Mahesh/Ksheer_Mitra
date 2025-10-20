import 'package:flutter/foundation.dart';
import '../models/delivery_boy.dart';
import '../services/admin_service.dart';

class DeliveryBoyProvider with ChangeNotifier {
  final AdminService _adminService = AdminService();

  List<DeliveryBoy> _deliveryBoys = [];
  bool _isLoading = false;
  String? _error;
  Map<String, dynamic>? _pagination;

  List<DeliveryBoy> get deliveryBoys => _deliveryBoys;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, dynamic>? get pagination => _pagination;

  Future<void> fetchDeliveryBoys({
    int page = 1,
    int limit = 20,
    String? search,
    bool? isActive,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _adminService.getDeliveryBoys(
        page: page,
        limit: limit,
        search: search,
        isActive: isActive,
      );
      _deliveryBoys = result['deliveryBoys'];
      _pagination = result['pagination'];
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<DeliveryBoy?> getDeliveryBoyById(String deliveryBoyId) async {
    try {
      return await _adminService.getDeliveryBoyDetails(deliveryBoyId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<bool> createDeliveryBoy(Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final deliveryBoy = await _adminService.createDeliveryBoy(data);
      _deliveryBoys.insert(0, deliveryBoy);
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

  Future<bool> updateDeliveryBoy(String deliveryBoyId, Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _adminService.updateDeliveryBoy(deliveryBoyId, data);
      final index = _deliveryBoys.indexWhere((db) => db.id == deliveryBoyId);
      if (index != -1) {
        final updatedDeliveryBoy = await _adminService.getDeliveryBoyDetails(deliveryBoyId);
        _deliveryBoys[index] = updatedDeliveryBoy;
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

  Future<bool> deactivateDeliveryBoy(String deliveryBoyId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _adminService.deactivateDeliveryBoy(deliveryBoyId);
      final index = _deliveryBoys.indexWhere((db) => db.id == deliveryBoyId);
      if (index != -1) {
        final updatedDeliveryBoy = await _adminService.getDeliveryBoyDetails(deliveryBoyId);
        _deliveryBoys[index] = updatedDeliveryBoy;
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

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
