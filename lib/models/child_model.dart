class ChildModel {
  String childName;
  String birthDate;
  String gender;
  String program;
  late String userId;
  final String? id;

  ChildModel({
    required this.childName,
    required this.birthDate,
    required this.gender,
    required this.program,
    required this.userId,
    this.id,
  });

  factory ChildModel.fromJson(Map<String, dynamic> json) {
    return ChildModel(
      id: json['_id'],
      childName: json['childName'] ?? '', // Provide a default value or handle null
      birthDate: json['birthDate'] ?? '', // Provide a default value or handle null
      gender: json['gender'] ?? '', // Provide a default value or handle null
      program: json['program'] ?? '', // Provide a default value or handle null
      userId: json['userId'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'childName': childName,
      'birthDate': birthDate,
      'gender': gender,
      'program': program,
      'userId': userId,
      '_id': id,
    };

    if (id != null) {
      data['_id'] = id; // Include id in JSON if it's not null
    }

    return data;
  }
}