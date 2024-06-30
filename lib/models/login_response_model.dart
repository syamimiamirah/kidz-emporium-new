import 'dart:convert';

LoginResponseModel loginResponseJson(String str) =>
    LoginResponseModel.fromJson(json.decode(str));

class LoginResponseModel {

  LoginResponseModel({
    required this.message,
    required this.data,
  });
  late final String message;
  late final Data? data;

  LoginResponseModel.fromJson(Map<String, dynamic> json){
    message = json['message'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null; // Handle null 'data'
  }


  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['message'] = message;
    _data['data'] = data?.toJson(); // Use the safe navigation operator '?'
    return _data;
  }
}

class Data {
  Data({
    required this.email,
    required this.name,
    required this.id,
    required this.token,
    required this.role,
  });
  late final String email;
  late final String name;
  late final String id;
  late final String? token;
  late final String role;

  Data.fromJson(Map<String, dynamic> json){
    email = json['email'];
    name = json['name'];
    id = json['userId'];
    token = json['token'];
    role = json['role'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['email'] = email;
    data['name'] = name;
    data['userId'] = id;
    data['token'] = token;
    data['role'] = role;

    if (id != null) {
      data['userId'] = id; // Include id in JSON if it's not null
    }

    return data;
  }
}
