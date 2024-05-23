class ReminderModel {
  late String eventName;
  late String details;
  late String fromDate;
  late String toDate;
  late String userId;
  final String? id;

  ReminderModel({
    required this.eventName,
    required this.details,
    required this.fromDate,
    required this.toDate,
    required this.userId,
    this.id, // Nullable id field
  });

  factory ReminderModel.fromJson(Map<String, dynamic> json) {
    return ReminderModel(
      id: json['_id'],
      eventName: json['eventName'] ?? '', // Provide a default value or handle null
      details: json['details'] ?? '', // Provide a default value or handle null
      fromDate: json['fromDate'] ?? '', // Provide a default value or handle null
      toDate: json['toDate'] ?? '', // Provide a default value or handle null
      userId: json['userId'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'eventName': eventName,
      'details': details,
      'fromDate': fromDate,
      'toDate': toDate,
      'userId': userId,
      '_id': id,
    };

    if (id != null) {
      data['_id'] = id; // Include id in JSON if it's not null
    }

    return data;
  }
}
