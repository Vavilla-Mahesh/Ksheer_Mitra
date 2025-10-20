class NotificationMessage {
  final String id;
  final String recipientId;
  final String recipientPhone;
  final String? recipientName;
  final String message;
  final String status;
  final String? templateId;
  final String? scheduledAt;
  final String? sentAt;
  final String createdAt;
  final String? errorMessage;

  NotificationMessage({
    required this.id,
    required this.recipientId,
    required this.recipientPhone,
    this.recipientName,
    required this.message,
    required this.status,
    this.templateId,
    this.scheduledAt,
    this.sentAt,
    required this.createdAt,
    this.errorMessage,
  });

  factory NotificationMessage.fromJson(Map<String, dynamic> json) {
    return NotificationMessage(
      id: json['id'],
      recipientId: json['recipientId'],
      recipientPhone: json['recipientPhone'],
      recipientName: json['recipientName'],
      message: json['message'],
      status: json['status'],
      templateId: json['templateId'],
      scheduledAt: json['scheduledAt'],
      sentAt: json['sentAt'],
      createdAt: json['createdAt'],
      errorMessage: json['errorMessage'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'recipientId': recipientId,
      'recipientPhone': recipientPhone,
      'recipientName': recipientName,
      'message': message,
      'status': status,
      'templateId': templateId,
      'scheduledAt': scheduledAt,
      'sentAt': sentAt,
      'createdAt': createdAt,
      'errorMessage': errorMessage,
    };
  }

  bool get isPending => status == 'pending';
  bool get isSent => status == 'sent';
  bool get isFailed => status == 'failed';
  bool get isScheduled => scheduledAt != null && status == 'pending';
}

class NotificationTemplate {
  final String id;
  final String name;
  final String message;
  final List<String> variables;
  final bool isActive;

  NotificationTemplate({
    required this.id,
    required this.name,
    required this.message,
    required this.variables,
    required this.isActive,
  });

  factory NotificationTemplate.fromJson(Map<String, dynamic> json) {
    return NotificationTemplate(
      id: json['id'],
      name: json['name'],
      message: json['message'],
      variables: json['variables'] != null ? List<String>.from(json['variables']) : [],
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'message': message,
      'variables': variables,
      'isActive': isActive,
    };
  }
}
