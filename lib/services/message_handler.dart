import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:kidz_emporium/Screens/home.dart';
import 'package:kidz_emporium/services/shared_service.dart';

import '../screens/parent/view_notification_parent.dart';
import 'local_notification.dart';

class MessageHandler {
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  static int _notificationCount = 0; // Notification counter

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

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      // Handle background messages when the notification is clicked
      print("Message clicked!");
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
        );
      } else {
        Navigator.pushNamed(context, '/login'); // Navigate to login page
      }
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
}
