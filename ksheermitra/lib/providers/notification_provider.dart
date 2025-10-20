import 'package:flutter/foundation.dart';
import '../models/notification.dart';
import '../services/admin_service.dart';

class NotificationProvider with ChangeNotifier {
  final AdminService _adminService = AdminService();

  List<NotificationMessage> _notifications = [];
  List<NotificationTemplate> _templates = [];
  bool _isLoading = false;
  String? _error;
  Map<String, dynamic>? _pagination;

  List<NotificationMessage> get notifications => _notifications;
  List<NotificationTemplate> get templates => _templates;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, dynamic>? get pagination => _pagination;

  Future<void> fetchNotifications({
    int page = 1,
    int limit = 20,
    String? status,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _adminService.getNotifications(
        page: page,
        limit: limit,
        status: status,
      );
      _notifications = result['notifications'];
      _pagination = result['pagination'];
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchTemplates() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _templates = await _adminService.getNotificationTemplates();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> sendIndividualMessage({
    required String recipientId,
    required String message,
    String? templateId,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _adminService.sendIndividualMessage(
        recipientId: recipientId,
        message: message,
        templateId: templateId,
      );
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

  Future<String?> sendBulkMessage({
    required List<String> recipientIds,
    required String message,
    String? templateId,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final batchId = await _adminService.sendBulkMessage(
        recipientIds: recipientIds,
        message: message,
        templateId: templateId,
      );
      _isLoading = false;
      notifyListeners();
      return batchId;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
