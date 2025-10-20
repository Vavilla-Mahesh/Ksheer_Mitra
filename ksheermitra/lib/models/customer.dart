class Customer {
  final String id;
  final String name;
  final String phone;
  final String? email;
  final String? address;
  final double? latitude;
  final double? longitude;
  final String? areaId;
  final String? areaName;
  final String? deliveryBoyId;
  final String? deliveryBoyName;
  final bool isActive;
  final int? activeSubscriptions;
  final String? paymentStatus;

  Customer({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    this.address,
    this.latitude,
    this.longitude,
    this.areaId,
    this.areaName,
    this.deliveryBoyId,
    this.deliveryBoyName,
    required this.isActive,
    this.activeSubscriptions,
    this.paymentStatus,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'],
      name: json['name'],
      phone: json['phone'],
      email: json['email'],
      address: json['address'],
      latitude: json['latitude'] != null ? double.tryParse(json['latitude'].toString()) : null,
      longitude: json['longitude'] != null ? double.tryParse(json['longitude'].toString()) : null,
      areaId: json['areaId'],
      areaName: json['area']?['name'],
      deliveryBoyId: json['area']?['deliveryBoyId'],
      deliveryBoyName: json['area']?['deliveryBoy']?['name'],
      isActive: json['isActive'] ?? true,
      activeSubscriptions: json['activeSubscriptions'],
      paymentStatus: json['paymentStatus'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'address': address,
      'latitude': latitude?.toString(),
      'longitude': longitude?.toString(),
      'areaId': areaId,
      'isActive': isActive,
    };
  }
}
