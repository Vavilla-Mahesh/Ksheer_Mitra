class DeliveryBoy {
  final String id;
  final String name;
  final String phone;
  final String? email;
  final String? address;
  final double? latitude;
  final double? longitude;
  final bool isActive;
  final List<String>? areaIds;
  final int? totalDeliveries;
  final int? todayDeliveries;
  final double? performanceRating;

  DeliveryBoy({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    this.address,
    this.latitude,
    this.longitude,
    required this.isActive,
    this.areaIds,
    this.totalDeliveries,
    this.todayDeliveries,
    this.performanceRating,
  });

  factory DeliveryBoy.fromJson(Map<String, dynamic> json) {
    return DeliveryBoy(
      id: json['id'],
      name: json['name'],
      phone: json['phone'],
      email: json['email'],
      address: json['address'],
      latitude: json['latitude'] != null ? double.tryParse(json['latitude'].toString()) : null,
      longitude: json['longitude'] != null ? double.tryParse(json['longitude'].toString()) : null,
      isActive: json['isActive'] ?? true,
      areaIds: json['areaIds'] != null ? List<String>.from(json['areaIds']) : null,
      totalDeliveries: json['totalDeliveries'],
      todayDeliveries: json['todayDeliveries'],
      performanceRating: json['performanceRating'] != null ? double.tryParse(json['performanceRating'].toString()) : null,
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
      'isActive': isActive,
    };
  }
}
