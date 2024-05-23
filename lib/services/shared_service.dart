import 'dart:convert';
import 'package:api_cache_manager/api_cache_manager.dart';
import 'package:api_cache_manager/models/cache_db_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:kidz_emporium/models/login_response_model.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class SharedService{
  static Future<bool> isLoggedIn() async{
    var isKeyExist = await APICacheManager().isAPICacheKeyExist("login_details");

    return isKeyExist;
  }

  static Future<LoginResponseModel> loginDetails() async {
    var isKeyExist = await APICacheManager().isAPICacheKeyExist("login_details");

    if (isKeyExist) {
      var cacheData = await APICacheManager().getCacheData("login_details");
      return loginResponseJson(cacheData.syncData);
    } else {
      // Return a default LoginResponseModel if the cache key doesn't exist
      return LoginResponseModel(message: "", data: Data(email: "", name: "", id: "", token: "secretkey", role: ""));
    }
  }
  static Future<void> setLoginDetails(
      LoginResponseModel model,
      ) async {
    APICacheDBModel cacheDBModel = APICacheDBModel(
      key: "login_details",
      syncData: jsonEncode(model.toJson()),
    );
    await APICacheManager().addCacheData(cacheDBModel);
  }

  static Future<void> logout(BuildContext context) async{
    await APICacheManager().deleteCache("login_details");
    Navigator.pushNamedAndRemoveUntil(
        context,
        '/login',
            (route) => false,
    );
  }

  static FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  static Future<String?> getFCMToken() async {
    try {
      // Get the FCM token from the device
      return await _firebaseMessaging.getToken();
    } catch (error) {
      print('Error getting FCM token: $error');
      return null;
    }
  }
}