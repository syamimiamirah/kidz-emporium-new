class UserModel {
  late String name;
  late String email;
  late String password;
  late String phone;
  late String role;
  final String? id; // Change to non-nullable type

  UserModel({
    required this.name,
    required this.email,
    required this.password,
    required this.phone,
    required this.role,
    this.id, // Update constructor
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      password: json['password'] ?? '',
      phone: json['phone'] ?? '',
      role: json['role'] ?? '',
      id: json['userId'], // Use '_id' instead of 'id'
    );
  }


  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'name': name,
      'email': email,
      'password': password,
      'phone': phone,
      'role': role,
      '_id': id,
    };

    return data;
  }
}
