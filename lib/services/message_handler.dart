import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:kidz_emporium/Screens/home.dart';
import 'package:kidz_emporium/services/shared_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/parent/view_notification_parent.dart';
import 'local_notification.dart';

class MessageHandler {
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  static int _notificationCount = 0; // Notification counter
  static bool _notificationHandled = false;

  static Future<void> initialize(BuildContext context) async {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("Message received: ${message.notification?.title ?? 'No Title'} - ${message.notification?.body ?? 'No Body'}");
      _notificationCount++;
      LocalNotification.showSimpleNotification(
        title: message.notification?.title ?? 'No Title',
        body: message.notification?.body ?? 'No Body',
        payload: message.data['bookingId'] ?? 'No Payload',
      );
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleMessage(context, message);
    });



    // Request permissions for iOS
    await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Get the token for this device
    String? token = await _firebaseMessaging.getToken();
    print("FCM Token: $token");
  }

  static int getNotificationCount() {
    return _notificationCount;
  }

  static void incrementNotificationCount() {
    _notificationCount++;
  }

  static void resetNotificationCount() {
    _notificationCount = 0;
  }

  static void markNotificationAsHandled() {
    _notificationHandled = true;
  }

  static void resetNotificationHandledFlag() {
    _notificationHandled = false;
  }

  static Future<void> _handleMessage(BuildContext context, RemoteMessage message) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int notificationCount = prefs.getInt('notificationCount') ?? 0;
    notificationCount += 1;
    prefs.setInt('notificationCount', notificationCount);

    // Update last notification payload in shared preferences
    prefs.setString('lastNotificationPayload', json.encode(message.data));

    if (!_notificationHandled) {
      if (await SharedService.isLoggedIn()) {
        var cachedLoginDetails = await SharedService.loginDetails();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NotificationDetailsPage(
              payload: message.data['bookingId'] ?? 'No Payload',
              userData: cachedLoginDetails,
            ),
          ),
        ).then((_) => markNotificationAsHandled());
      } else {
        Navigator.pushNamed(context, '/login').then((_) async {
          var cachedLoginDetails = await SharedService.loginDetails();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NotificationDetailsPage(
                payload: json.encode(message.data),
                userData: cachedLoginDetails,
              ),
            ),
          ).then((_) => markNotificationAsHandled());
        });
      }
    }
  }
}
