import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../services/admin_service.dart';

class ProductProvider with ChangeNotifier {
  final AdminService _adminService = AdminService();

  List<Product> _products = [];
  bool _isLoading = false;
  String? _error;
  Map<String, dynamic>? _pagination;

  List<Product> get products => _products;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, dynamic>? get pagination => _pagination;

  Future<void> fetchProducts({
    int page = 1,
    int limit = 20,
    String? search,
    bool? isActive,
    String? sortBy,
    String? sortOrder,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _adminService.getProducts(
        page: page,
        limit: limit,
        search: search,
        isActive: isActive,
        sortBy: sortBy,
        sortOrder: sortOrder,
      );
      _products = result['products'];
      _pagination = result['pagination'];
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Product?> getProductById(String productId) async {
    try {
      return await _adminService.getProductDetails(productId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<bool> createProduct(Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final product = await _adminService.createProduct(data);
      _products.insert(0, product);
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

  Future<bool> updateProduct(String productId, Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _adminService.updateProduct(productId, data);
      final index = _products.indexWhere((p) => p.id == productId);
      if (index != -1) {
        final updatedProduct = await _adminService.getProductDetails(productId);
        _products[index] = updatedProduct;
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

  Future<bool> deleteProduct(String productId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _adminService.deleteProduct(productId);
      _products.removeWhere((p) => p.id == productId);
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
