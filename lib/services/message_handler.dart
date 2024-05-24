import 'package:firebase_messaging/firebase_messaging.dart';
import 'local_notification.dart';

class MessageHandler {
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  static Future<void> initialize() async {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // Handle foreground messages
      print("Message received: ${message.notification?.title ?? 'No Title'} - ${message.notification?.body ?? 'No Body'}");
      LocalNotification.showSimpleNotification(
        title: message.notification?.title ?? 'No Title',
        body: message.notification?.body ?? 'No Body',
        payload: message.data['bookingId'] ?? 'No Payload',
      );
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      // Handle background messages
      print("Message clicked!");
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
}
