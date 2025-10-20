import 'package:flutter/foundation.dart';
import '../models/invoice.dart';
import '../services/admin_service.dart';

class InvoiceProvider with ChangeNotifier {
  final AdminService _adminService = AdminService();

  List<Invoice> _dailyInvoices = [];
  List<Invoice> _monthlyInvoices = [];
  bool _isLoading = false;
  String? _error;
  Map<String, dynamic>? _dailyPagination;
  Map<String, dynamic>? _monthlyPagination;

  List<Invoice> get dailyInvoices => _dailyInvoices;
  List<Invoice> get monthlyInvoices => _monthlyInvoices;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, dynamic>? get dailyPagination => _dailyPagination;
  Map<String, dynamic>? get monthlyPagination => _monthlyPagination;

  Future<void> fetchDailyInvoices({
    int page = 1,
    int limit = 20,
    String? startDate,
    String? endDate,
    String? deliveryBoyId,
    String? status,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _adminService.getDailyInvoices(
        page: page,
        limit: limit,
        startDate: startDate,
        endDate: endDate,
        deliveryBoyId: deliveryBoyId,
        status: status,
      );
      _dailyInvoices = result['invoices'];
      _dailyPagination = result['pagination'];
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchMonthlyInvoices({
    int page = 1,
    int limit = 20,
    String? month,
    String? customerId,
    String? paymentStatus,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _adminService.getMonthlyInvoices(
        page: page,
        limit: limit,
        month: month,
        customerId: customerId,
        paymentStatus: paymentStatus,
      );
      _monthlyInvoices = result['invoices'];
      _monthlyPagination = result['pagination'];
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Invoice?> getInvoiceById(String invoiceId) async {
    try {
      return await _adminService.getInvoiceDetails(invoiceId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<bool> verifyInvoice(String invoiceId, {String? notes}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _adminService.verifyInvoice(invoiceId, notes: notes);
      final index = _dailyInvoices.indexWhere((inv) => inv.id == invoiceId);
      if (index != -1) {
        final updated = await _adminService.getInvoiceDetails(invoiceId);
        _dailyInvoices[index] = updated;
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

  Future<bool> recordPayment(String invoiceId, Map<String, dynamic> paymentData) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _adminService.recordPayment(invoiceId, paymentData);
      
      final dailyIndex = _dailyInvoices.indexWhere((inv) => inv.id == invoiceId);
      if (dailyIndex != -1) {
        final updated = await _adminService.getInvoiceDetails(invoiceId);
        _dailyInvoices[dailyIndex] = updated;
      }
      
      final monthlyIndex = _monthlyInvoices.indexWhere((inv) => inv.id == invoiceId);
      if (monthlyIndex != -1) {
        final updated = await _adminService.getInvoiceDetails(invoiceId);
        _monthlyInvoices[monthlyIndex] = updated;
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

  Future<String?> getInvoicePdfUrl(String invoiceId) async {
    try {
      return await _adminService.getInvoicePdfUrl(invoiceId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<bool> resendInvoice(String invoiceId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _adminService.resendInvoice(invoiceId);
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
