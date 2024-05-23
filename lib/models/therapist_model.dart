class TherapistModel {
  late String specialization;
  late String hiringDate;
  late String aboutMe;
  late String therapistId;
  late String managedBy;
  final String? id;

  TherapistModel({
    required this.specialization,
    required this.hiringDate,
    required this.aboutMe,
    required this.therapistId,
    required this.managedBy,
    this.id, // Nullable id field
  });

  factory TherapistModel.fromJson(Map<String, dynamic> json) {
    return TherapistModel(
      id: json['_id'], // Provide a default value or handle null
      specialization: json['specialization'] ?? '', // Provide a default value or handle null
      hiringDate: json['hiringDate'] ?? '', // Provide a default value or handle null
      aboutMe: json['aboutMe'] ?? '',
      therapistId: json['therapistId'] ?? '',// Provide a default value or handle null
      managedBy: json['managedBy'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'specialization': specialization,
      'hiringDate': hiringDate,
      'aboutMe': aboutMe,
      'therapistId': therapistId,
      'managedBy': managedBy,
      '_id': id,
    };

    if (id != null) {
      data['_id'] = id; // Include id in JSON if it's not null
    }

    return data;
  }
}
