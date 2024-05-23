class RegisterRequestModel {
  RegisterRequestModel({
    required this.name,
    required this.email,
    required this.password,
    required this.phone,
    required this.role,
  });
  late final String name;
  late final String email;
  late final String password;
  late final String phone;
  late final String role;

  RegisterRequestModel.fromJson(Map<String, dynamic> json){
    name = json['name'];
    email = json['email'];
    password = json['password'];
    phone = json['phone'];
    role = json['role'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['name'] = name;
    _data['email'] = email;
    _data['password'] = password;
    _data['phone'] = phone;
    _data['role'] = role;
    return _data;
  }
}