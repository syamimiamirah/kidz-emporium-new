// user_provider.dart

import 'package:flutter/material.dart';
import 'package:kidz_emporium/models/login_response_model.dart';

class UserProvider extends ChangeNotifier {
  late LoginResponseModel _userData;

  LoginResponseModel get userData => _userData;

  void setUserData(LoginResponseModel userData) {
    _userData = userData;
    notifyListeners();
  }
}
