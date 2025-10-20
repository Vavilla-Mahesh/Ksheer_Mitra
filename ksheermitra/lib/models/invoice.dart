class Invoice {
  final String id;
  final String invoiceNumber;
  final String type;
  final String? customerId;
  final String? deliveryBoyId;
  final String invoiceDate;
  final String periodStart;
  final String periodEnd;
  final double totalAmount;
  final double paidAmount;
  final String paymentStatus;
  final String? paymentDate;
  final String? paymentMethod;
  final String? transactionId;
  final String? pdfPath;
  final String? notes;
  final String? customerName;
  final String? deliveryBoyName;
  final bool isVerified;

  Invoice({
    required this.id,
    required this.invoiceNumber,
    required this.type,
    this.customerId,
    this.deliveryBoyId,
    required this.invoiceDate,
    required this.periodStart,
    required this.periodEnd,
    required this.totalAmount,
    required this.paidAmount,
    required this.paymentStatus,
    this.paymentDate,
    this.paymentMethod,
    this.transactionId,
    this.pdfPath,
    this.notes,
    this.customerName,
    this.deliveryBoyName,
    required this.isVerified,
  });

  factory Invoice.fromJson(Map<String, dynamic> json) {
    return Invoice(
      id: json['id'],
      invoiceNumber: json['invoiceNumber'],
      type: json['type'],
      customerId: json['customerId'],
      deliveryBoyId: json['deliveryBoyId'],
      invoiceDate: json['invoiceDate'],
      periodStart: json['periodStart'],
      periodEnd: json['periodEnd'],
      totalAmount: double.parse(json['totalAmount'].toString()),
      paidAmount: json['paidAmount'] != null ? double.parse(json['paidAmount'].toString()) : 0.0,
      paymentStatus: json['paymentStatus'],
      paymentDate: json['paymentDate'],
      paymentMethod: json['paymentMethod'],
      transactionId: json['transactionId'],
      pdfPath: json['pdfPath'],
      notes: json['notes'],
      customerName: json['customer']?['name'],
      deliveryBoyName: json['deliveryBoy']?['name'],
      isVerified: json['isVerified'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'invoiceNumber': invoiceNumber,
      'type': type,
      'customerId': customerId,
      'deliveryBoyId': deliveryBoyId,
      'invoiceDate': invoiceDate,
      'periodStart': periodStart,
      'periodEnd': periodEnd,
      'totalAmount': totalAmount,
      'paidAmount': paidAmount,
      'paymentStatus': paymentStatus,
      'paymentDate': paymentDate,
      'paymentMethod': paymentMethod,
      'transactionId': transactionId,
      'notes': notes,
      'isVerified': isVerified,
    };
  }

  bool get isPending => paymentStatus == 'pending';
  bool get isPaid => paymentStatus == 'paid';
  bool get isPartiallyPaid => paymentStatus == 'partially_paid';
  bool get isOverdue => paymentStatus == 'overdue';
  bool get isDaily => type == 'daily';
  bool get isMonthly => type == 'monthly';
  
  double get balanceAmount => totalAmount - paidAmount;
}
