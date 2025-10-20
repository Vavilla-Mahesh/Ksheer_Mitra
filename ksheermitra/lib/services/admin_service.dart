import '../models/customer.dart';
import '../models/delivery_boy.dart';
import '../models/area.dart';
import '../models/product.dart';
import '../models/invoice.dart';
import '../models/delivery.dart';
import '../models/dashboard_stats.dart';
import '../models/notification.dart';
import 'api_service.dart';

class AdminService {
  final ApiService _apiService = ApiService();

  // Dashboard
  Future<DashboardStats> getDashboardStats() async {
    final response = await _apiService.get('/admin/dashboard/stats', requiresAuth: true);
    return DashboardStats.fromJson(response['data']);
  }

  Future<List<ActivityLog>> getRecentActivities({int limit = 20}) async {
    final response = await _apiService.get(
      '/admin/dashboard/activities',
      queryParams: {'limit': limit},
      requiresAuth: true,
    );
    return (response['data'] as List).map((item) => ActivityLog.fromJson(item)).toList();
  }

  // Customers
  Future<Map<String, dynamic>> getCustomers({
    int page = 1,
    int limit = 20,
    String? search,
    String? areaId,
    bool? isActive,
  }) async {
    final Map<String, dynamic> queryParams = {
      'page': page,
      'limit': limit,
    };
    if (search != null && search.isNotEmpty) queryParams['search'] = search;
    if (areaId != null) queryParams['areaId'] = areaId;
    if (isActive != null) queryParams['isActive'] = isActive;

    final response = await _apiService.get('/admin/customers', queryParams: queryParams, requiresAuth: true);
    
    return {
      'customers': (response['data']['customers'] as List).map((item) => Customer.fromJson(item)).toList(),
      'pagination': response['data']['pagination'],
    };
  }

  Future<Customer> getCustomerDetails(String customerId) async {
    final response = await _apiService.get('/admin/customers/$customerId', requiresAuth: true);
    return Customer.fromJson(response['data']);
  }

  Future<List<Customer>> getCustomersForMap() async {
    final response = await _apiService.get('/admin/customers/map', requiresAuth: true);
    return (response['data'] as List).map((item) => Customer.fromJson(item)).toList();
  }

  Future<void> updateCustomer(String customerId, Map<String, dynamic> data) async {
    await _apiService.put('/admin/customers/$customerId', data, requiresAuth: true);
  }

  Future<void> deactivateCustomer(String customerId) async {
    await _apiService.put('/admin/customers/$customerId', {'isActive': false}, requiresAuth: true);
  }

  Future<void> assignArea(String customerId, String areaId) async {
    await _apiService.post('/admin/assign-area', {'customerId': customerId, 'areaId': areaId}, requiresAuth: true);
  }

  Future<void> bulkAssignArea(List<String> customerIds, String areaId) async {
    await _apiService.post('/admin/bulk-assign-area', {'customerIds': customerIds, 'areaId': areaId}, requiresAuth: true);
  }

  // Delivery Boys
  Future<Map<String, dynamic>> getDeliveryBoys({
    int page = 1,
    int limit = 20,
    String? search,
    bool? isActive,
  }) async {
    final Map<String, dynamic> queryParams = {
      'page': page,
      'limit': limit,
    };
    if (search != null && search.isNotEmpty) queryParams['search'] = search;
    if (isActive != null) queryParams['isActive'] = isActive;

    final response = await _apiService.get('/admin/delivery-boys', queryParams: queryParams, requiresAuth: true);
    
    return {
      'deliveryBoys': (response['data']['deliveryBoys'] as List).map((item) => DeliveryBoy.fromJson(item)).toList(),
      'pagination': response['data']['pagination'],
    };
  }

  Future<DeliveryBoy> getDeliveryBoyDetails(String deliveryBoyId) async {
    final response = await _apiService.get('/admin/delivery-boys/$deliveryBoyId', requiresAuth: true);
    return DeliveryBoy.fromJson(response['data']);
  }

  Future<DeliveryBoy> createDeliveryBoy(Map<String, dynamic> data) async {
    final response = await _apiService.post('/admin/delivery-boys', data, requiresAuth: true);
    return DeliveryBoy.fromJson(response['data']);
  }

  Future<void> updateDeliveryBoy(String deliveryBoyId, Map<String, dynamic> data) async {
    await _apiService.put('/admin/delivery-boys/$deliveryBoyId', data, requiresAuth: true);
  }

  Future<void> deactivateDeliveryBoy(String deliveryBoyId) async {
    await _apiService.put('/admin/delivery-boys/$deliveryBoyId', {'isActive': false}, requiresAuth: true);
  }

  // Areas
  Future<List<Area>> getAreas({bool? isActive}) async {
    final Map<String, dynamic>? queryParams = isActive != null ? {'isActive': isActive} : null;
    final response = await _apiService.get('/admin/areas', queryParams: queryParams, requiresAuth: true);
    return (response['data'] as List).map((item) => Area.fromJson(item)).toList();
  }

  Future<Area> getAreaDetails(String areaId) async {
    final response = await _apiService.get('/admin/areas/$areaId', requiresAuth: true);
    return Area.fromJson(response['data']);
  }

  Future<Area> createArea(Map<String, dynamic> data) async {
    final response = await _apiService.post('/admin/areas', data, requiresAuth: true);
    return Area.fromJson(response['data']);
  }

  Future<void> updateArea(String areaId, Map<String, dynamic> data) async {
    await _apiService.put('/admin/areas/$areaId', data, requiresAuth: true);
  }

  Future<void> deleteArea(String areaId) async {
    await _apiService.delete('/admin/areas/$areaId', requiresAuth: true);
  }

  // Products
  Future<Map<String, dynamic>> getProducts({
    int page = 1,
    int limit = 20,
    String? search,
    bool? isActive,
    String? sortBy,
    String? sortOrder,
  }) async {
    final Map<String, dynamic> queryParams = {
      'page': page,
      'limit': limit,
    };
    if (search != null && search.isNotEmpty) queryParams['search'] = search;
    if (isActive != null) queryParams['isActive'] = isActive;
    if (sortBy != null) queryParams['sortBy'] = sortBy;
    if (sortOrder != null) queryParams['sortOrder'] = sortOrder;

    final response = await _apiService.get('/admin/products', queryParams: queryParams, requiresAuth: true);
    
    return {
      'products': (response['data']['products'] as List).map((item) => Product.fromJson(item)).toList(),
      'pagination': response['data']['pagination'],
    };
  }

  Future<Product> getProductDetails(String productId) async {
    final response = await _apiService.get('/admin/products/$productId', requiresAuth: true);
    return Product.fromJson(response['data']);
  }

  Future<Product> createProduct(Map<String, dynamic> data) async {
    final response = await _apiService.post('/admin/products', data, requiresAuth: true);
    return Product.fromJson(response['data']);
  }

  Future<void> updateProduct(String productId, Map<String, dynamic> data) async {
    await _apiService.put('/admin/products/$productId', data, requiresAuth: true);
  }

  Future<void> deleteProduct(String productId) async {
    await _apiService.delete('/admin/products/$productId', requiresAuth: true);
  }

  // Invoices
  Future<Map<String, dynamic>> getDailyInvoices({
    int page = 1,
    int limit = 20,
    String? startDate,
    String? endDate,
    String? deliveryBoyId,
    String? status,
  }) async {
    final Map<String, dynamic> queryParams = {
      'page': page,
      'limit': limit,
    };
    if (startDate != null) queryParams['startDate'] = startDate;
    if (endDate != null) queryParams['endDate'] = endDate;
    if (deliveryBoyId != null) queryParams['deliveryBoyId'] = deliveryBoyId;
    if (status != null) queryParams['status'] = status;

    final response = await _apiService.get('/admin/invoices/daily', queryParams: queryParams, requiresAuth: true);
    
    return {
      'invoices': (response['data']['invoices'] as List).map((item) => Invoice.fromJson(item)).toList(),
      'pagination': response['data']['pagination'],
    };
  }

  Future<Map<String, dynamic>> getMonthlyInvoices({
    int page = 1,
    int limit = 20,
    String? month,
    String? customerId,
    String? paymentStatus,
  }) async {
    final Map<String, dynamic> queryParams = {
      'page': page,
      'limit': limit,
    };
    if (month != null) queryParams['month'] = month;
    if (customerId != null) queryParams['customerId'] = customerId;
    if (paymentStatus != null) queryParams['paymentStatus'] = paymentStatus;

    final response = await _apiService.get('/admin/invoices/monthly', queryParams: queryParams, requiresAuth: true);
    
    return {
      'invoices': (response['data']['invoices'] as List).map((item) => Invoice.fromJson(item)).toList(),
      'pagination': response['data']['pagination'],
    };
  }

  Future<Invoice> getInvoiceDetails(String invoiceId) async {
    final response = await _apiService.get('/admin/invoices/$invoiceId', requiresAuth: true);
    return Invoice.fromJson(response['data']);
  }

  Future<void> verifyInvoice(String invoiceId, {String? notes}) async {
    await _apiService.post(
      '/admin/invoices/$invoiceId/verify',
      {'notes': notes},
      requiresAuth: true,
    );
  }

  Future<void> recordPayment(String invoiceId, Map<String, dynamic> paymentData) async {
    await _apiService.post(
      '/admin/invoices/$invoiceId/payment',
      paymentData,
      requiresAuth: true,
    );
  }

  Future<String> getInvoicePdfUrl(String invoiceId) async {
    final response = await _apiService.get('/admin/invoices/$invoiceId/pdf', requiresAuth: true);
    return response['data']['pdfUrl'];
  }

  Future<void> resendInvoice(String invoiceId) async {
    await _apiService.post('/admin/invoices/$invoiceId/resend', {}, requiresAuth: true);
  }

  // Deliveries
  Future<Map<String, dynamic>> getDeliveries({
    int page = 1,
    int limit = 20,
    String? startDate,
    String? endDate,
    String? deliveryBoyId,
    String? customerId,
    String? status,
  }) async {
    final Map<String, dynamic> queryParams = {
      'page': page,
      'limit': limit,
    };
    if (startDate != null) queryParams['startDate'] = startDate;
    if (endDate != null) queryParams['endDate'] = endDate;
    if (deliveryBoyId != null) queryParams['deliveryBoyId'] = deliveryBoyId;
    if (customerId != null) queryParams['customerId'] = customerId;
    if (status != null) queryParams['status'] = status;

    final response = await _apiService.get('/admin/deliveries', queryParams: queryParams, requiresAuth: true);
    
    return {
      'deliveries': (response['data']['deliveries'] as List).map((item) => Delivery.fromJson(item)).toList(),
      'pagination': response['data']['pagination'],
    };
  }

  // Notifications
  Future<void> sendIndividualMessage({
    required String recipientId,
    required String message,
    String? templateId,
  }) async {
    await _apiService.post(
      '/admin/notifications/send',
      {
        'recipientId': recipientId,
        'message': message,
        if (templateId != null) 'templateId': templateId,
      },
      requiresAuth: true,
    );
  }

  Future<String> sendBulkMessage({
    required List<String> recipientIds,
    required String message,
    String? templateId,
  }) async {
    final response = await _apiService.post(
      '/admin/notifications/bulk',
      {
        'recipientIds': recipientIds,
        'message': message,
        if (templateId != null) 'templateId': templateId,
      },
      requiresAuth: true,
    );
    return response['data']['batchId'];
  }

  Future<Map<String, dynamic>> getNotifications({
    int page = 1,
    int limit = 20,
    String? status,
  }) async {
    final Map<String, dynamic> queryParams = {
      'page': page,
      'limit': limit,
    };
    if (status != null) queryParams['status'] = status;

    final response = await _apiService.get('/admin/notifications', queryParams: queryParams, requiresAuth: true);
    
    return {
      'notifications': (response['data']['notifications'] as List)
          .map((item) => NotificationMessage.fromJson(item))
          .toList(),
      'pagination': response['data']['pagination'],
    };
  }

  Future<List<NotificationTemplate>> getNotificationTemplates() async {
    final response = await _apiService.get('/admin/notifications/templates', requiresAuth: true);
    return (response['data'] as List).map((item) => NotificationTemplate.fromJson(item)).toList();
  }

  // Reports
  Future<Map<String, dynamic>> generateReport({
    required String reportType,
    required String startDate,
    required String endDate,
    Map<String, dynamic>? filters,
  }) async {
    final response = await _apiService.post(
      '/admin/reports/generate',
      {
        'reportType': reportType,
        'startDate': startDate,
        'endDate': endDate,
        if (filters != null) 'filters': filters,
      },
      requiresAuth: true,
    );
    return response['data'];
  }

  Future<String> exportReport({
    required String reportType,
    required String format,
    required String startDate,
    required String endDate,
    Map<String, dynamic>? filters,
  }) async {
    final response = await _apiService.post(
      '/admin/reports/export',
      {
        'reportType': reportType,
        'format': format,
        'startDate': startDate,
        'endDate': endDate,
        if (filters != null) 'filters': filters,
      },
      requiresAuth: true,
    );
    return response['data']['downloadUrl'];
  }
}
