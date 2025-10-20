class DashboardStats {
  final int totalCustomers;
  final int activeCustomers;
  final int totalDeliveryBoys;
  final int activeDeliveryBoys;
  final int totalProducts;
  final int activeProducts;
  final int totalAreas;
  final int todayDeliveries;
  final int todayDelivered;
  final int todayMissed;
  final int activeSubscriptions;
  final double todayRevenue;
  final double monthlyRevenue;
  final int pendingPayments;
  final double pendingAmount;
  final int overdueInvoices;
  final double overdueAmount;

  DashboardStats({
    required this.totalCustomers,
    required this.activeCustomers,
    required this.totalDeliveryBoys,
    required this.activeDeliveryBoys,
    required this.totalProducts,
    required this.activeProducts,
    required this.totalAreas,
    required this.todayDeliveries,
    required this.todayDelivered,
    required this.todayMissed,
    required this.activeSubscriptions,
    required this.todayRevenue,
    required this.monthlyRevenue,
    required this.pendingPayments,
    required this.pendingAmount,
    required this.overdueInvoices,
    required this.overdueAmount,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      totalCustomers: json['totalCustomers'] ?? 0,
      activeCustomers: json['activeCustomers'] ?? 0,
      totalDeliveryBoys: json['totalDeliveryBoys'] ?? 0,
      activeDeliveryBoys: json['activeDeliveryBoys'] ?? 0,
      totalProducts: json['totalProducts'] ?? 0,
      activeProducts: json['activeProducts'] ?? 0,
      totalAreas: json['totalAreas'] ?? 0,
      todayDeliveries: json['todayDeliveries'] ?? 0,
      todayDelivered: json['todayDelivered'] ?? 0,
      todayMissed: json['todayMissed'] ?? 0,
      activeSubscriptions: json['activeSubscriptions'] ?? 0,
      todayRevenue: json['todayRevenue'] != null ? double.parse(json['todayRevenue'].toString()) : 0.0,
      monthlyRevenue: json['monthlyRevenue'] != null ? double.parse(json['monthlyRevenue'].toString()) : 0.0,
      pendingPayments: json['pendingPayments'] ?? 0,
      pendingAmount: json['pendingAmount'] != null ? double.parse(json['pendingAmount'].toString()) : 0.0,
      overdueInvoices: json['overdueInvoices'] ?? 0,
      overdueAmount: json['overdueAmount'] != null ? double.parse(json['overdueAmount'].toString()) : 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalCustomers': totalCustomers,
      'activeCustomers': activeCustomers,
      'totalDeliveryBoys': totalDeliveryBoys,
      'activeDeliveryBoys': activeDeliveryBoys,
      'totalProducts': totalProducts,
      'activeProducts': activeProducts,
      'totalAreas': totalAreas,
      'todayDeliveries': todayDeliveries,
      'todayDelivered': todayDelivered,
      'todayMissed': todayMissed,
      'activeSubscriptions': activeSubscriptions,
      'todayRevenue': todayRevenue,
      'monthlyRevenue': monthlyRevenue,
      'pendingPayments': pendingPayments,
      'pendingAmount': pendingAmount,
      'overdueInvoices': overdueInvoices,
      'overdueAmount': overdueAmount,
    };
  }
}

class ActivityLog {
  final String id;
  final String type;
  final String description;
  final String? userId;
  final String? userName;
  final String timestamp;

  ActivityLog({
    required this.id,
    required this.type,
    required this.description,
    this.userId,
    this.userName,
    required this.timestamp,
  });

  factory ActivityLog.fromJson(Map<String, dynamic> json) {
    return ActivityLog(
      id: json['id'],
      type: json['type'],
      description: json['description'],
      userId: json['userId'],
      userName: json['userName'],
      timestamp: json['timestamp'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'description': description,
      'userId': userId,
      'userName': userName,
      'timestamp': timestamp,
    };
  }
}
