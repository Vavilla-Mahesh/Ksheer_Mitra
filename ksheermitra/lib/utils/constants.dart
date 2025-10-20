class Constants {
  // App Info
  static const String appName = 'Ksheermitra';
  static const String appVersion = '1.0.0';

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // File Upload
  static const int maxImageSizeMB = 5;
  static const int maxImageSizeBytes = maxImageSizeMB * 1024 * 1024;
  static const List<String> allowedImageExtensions = ['jpg', 'jpeg', 'png'];

  // OTP
  static const int otpLength = 6;
  static const int otpResendTimeout = 60;
  static const int maxOTPAttempts = 5;
  static const int maxOTPRequests = 3;
  static const int otpRequestWindow = 15;

  // Session
  static const int sessionTimeoutMinutes = 30;
  static const int tokenRefreshThresholdMinutes = 5;

  // Auto Refresh
  static const int dashboardRefreshInterval = 5;

  // Messaging
  static const int bulkMessageBatchSize = 10;
  static const int bulkMessageBatchDelay = 60;

  // Status
  static const List<String> subscriptionStatuses = ['active', 'paused', 'cancelled', 'expired'];
  static const List<String> deliveryStatuses = ['pending', 'delivered', 'missed', 'cancelled'];
  static const List<String> paymentStatuses = ['pending', 'paid', 'partially_paid', 'overdue'];
  static const List<String> invoiceTypes = ['daily', 'monthly'];

  // Units
  static const List<String> productUnits = ['liter', 'ml', 'kg', 'gm', 'piece'];

  // Frequencies
  static const List<String> subscriptionFrequencies = ['daily', 'weekly', 'monthly', 'custom'];

  // Payment Methods
  static const List<String> paymentMethods = ['cash', 'upi', 'card', 'bank_transfer', 'cheque'];

  // Days of Week
  static const List<String> daysOfWeek = [
    'Sunday',
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday'
  ];

  // Report Types
  static const List<String> reportTypes = [
    'daily_delivery',
    'weekly_sales',
    'monthly_sales',
    'subscriptions',
    'payments',
    'product_wise',
    'delivery_boy_performance',
    'area_wise'
  ];

  // Export Formats
  static const List<String> exportFormats = ['pdf', 'excel', 'csv'];

  // Colors
  static const String primaryColorHex = '#2E7D32';
  static const String secondaryColorHex = '#66BB6A';
  static const String accentColorHex = '#FFA726';
  static const String errorColorHex = '#D32F2F';
  static const String successColorHex = '#388E3C';
  static const String warningColorHex = '#F57C00';

  // Map
  static const double defaultMapZoom = 14.0;
  static const double markerZoom = 16.0;
  static const double routeZoom = 13.0;

  // Notification Types
  static const String notificationTypeDelivery = 'delivery';
  static const String notificationTypePayment = 'payment';
  static const String notificationTypeInvoice = 'invoice';
  static const String notificationTypePromo = 'promo';
  static const String notificationTypeWelcome = 'welcome';

  // Activity Types
  static const String activityCustomerAdded = 'customer_added';
  static const String activityDeliveryBoyAdded = 'delivery_boy_added';
  static const String activityProductAdded = 'product_added';
  static const String activitySubscriptionCreated = 'subscription_created';
  static const String activityDeliveryCompleted = 'delivery_completed';
  static const String activityPaymentReceived = 'payment_received';
  static const String activityInvoiceGenerated = 'invoice_generated';
}
