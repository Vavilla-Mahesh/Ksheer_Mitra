import 'package:flutter/foundation.dart';
import '../models/customer.dart';
import '../services/admin_service.dart';

class CustomerProvider with ChangeNotifier {
  final AdminService _adminService = AdminService();

  List<Customer> _customers = [];
  List<Customer> _mapCustomers = [];
  bool _isLoading = false;
  String? _error;
  Map<String, dynamic>? _pagination;

  List<Customer> get customers => _customers;
  List<Customer> get mapCustomers => _mapCustomers;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, dynamic>? get pagination => _pagination;

  Future<void> fetchCustomers({
    int page = 1,
    int limit = 20,
    String? search,
    String? areaId,
    bool? isActive,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _adminService.getCustomers(
        page: page,
        limit: limit,
        search: search,
        areaId: areaId,
        isActive: isActive,
      );
      _customers = result['customers'];
      _pagination = result['pagination'];
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchCustomersForMap() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _mapCustomers = await _adminService.getCustomersForMap();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Customer?> getCustomerById(String customerId) async {
    try {
      return await _adminService.getCustomerDetails(customerId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<bool> updateCustomer(String customerId, Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _adminService.updateCustomer(customerId, data);
      final index = _customers.indexWhere((c) => c.id == customerId);
      if (index != -1) {
        final updatedCustomer = await _adminService.getCustomerDetails(customerId);
        _customers[index] = updatedCustomer;
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

  Future<bool> deactivateCustomer(String customerId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _adminService.deactivateCustomer(customerId);
      final index = _customers.indexWhere((c) => c.id == customerId);
      if (index != -1) {
        final updatedCustomer = await _adminService.getCustomerDetails(customerId);
        _customers[index] = updatedCustomer;
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

  Future<bool> assignArea(String customerId, String areaId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _adminService.assignArea(customerId, areaId);
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

  Future<bool> bulkAssignArea(List<String> customerIds, String areaId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _adminService.bulkAssignArea(customerIds, areaId);
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
