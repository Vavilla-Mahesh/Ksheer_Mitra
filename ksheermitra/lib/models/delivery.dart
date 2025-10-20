import 'product.dart';

class Delivery {
  final String id;
  final String subscriptionId;
  final String customerId;
  final String productId;
  final String deliveryBoyId;
  final String deliveryDate;
  final double quantity;
  final double amount;
  final String status;
  final String? notes;
  final String? deliveredAt;
  final String? customerName;
  final String? productName;
  final Product? product;

  Delivery({
    required this.id,
    required this.subscriptionId,
    required this.customerId,
    required this.productId,
    required this.deliveryBoyId,
    required this.deliveryDate,
    required this.quantity,
    required this.amount,
    required this.status,
    this.notes,
    this.deliveredAt,
    this.customerName,
    this.productName,
    this.product,
  });

  factory Delivery.fromJson(Map<String, dynamic> json) {
    return Delivery(
      id: json['id'],
      subscriptionId: json['subscriptionId'],
      customerId: json['customerId'],
      productId: json['productId'],
      deliveryBoyId: json['deliveryBoyId'],
      deliveryDate: json['deliveryDate'],
      quantity: double.parse(json['quantity'].toString()),
      amount: double.parse(json['amount'].toString()),
      status: json['status'],
      notes: json['notes'],
      deliveredAt: json['deliveredAt'],
      customerName: json['customer']?['name'],
      productName: json['product']?['name'],
      product: json['product'] != null ? Product.fromJson(json['product']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'subscriptionId': subscriptionId,
      'customerId': customerId,
      'productId': productId,
      'deliveryBoyId': deliveryBoyId,
      'deliveryDate': deliveryDate,
      'quantity': quantity,
      'amount': amount,
      'status': status,
      'notes': notes,
      'deliveredAt': deliveredAt,
    };
  }

  bool get isPending => status == 'pending';
  bool get isDelivered => status == 'delivered';
  bool get isMissed => status == 'missed';
  bool get isCancelled => status == 'cancelled';
}
