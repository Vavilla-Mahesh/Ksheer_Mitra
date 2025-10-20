class Area {
  final String id;
  final String name;
  final String? description;
  final String? deliveryBoyId;
  final bool isActive;
  final String? deliveryBoyName;
  final int? customerCount;

  Area({
    required this.id,
    required this.name,
    this.description,
    this.deliveryBoyId,
    required this.isActive,
    this.deliveryBoyName,
    this.customerCount,
  });

  factory Area.fromJson(Map<String, dynamic> json) {
    return Area(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      deliveryBoyId: json['deliveryBoyId'],
      isActive: json['isActive'] ?? true,
      deliveryBoyName: json['deliveryBoy']?['name'],
      customerCount: json['customerCount'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'deliveryBoyId': deliveryBoyId,
      'isActive': isActive,
    };
  }
}
