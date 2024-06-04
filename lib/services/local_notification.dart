import 'dart:convert';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rxdart/rxdart.dart';

class LocalNotification {
  static final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  static final onClickNotification = BehaviorSubject<String>();

  static void onNotificationTap(NotificationResponse notificationResponse){
    onClickNotification.add(notificationResponse.payload!);
  }

  static Future init() async {
    // initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    final DarwinInitializationSettings initializationSettingsDarwin =
    DarwinInitializationSettings(
        onDidReceiveLocalNotification: (id, title, body, payload) => null);
    final LinuxInitializationSettings initializationSettingsLinux =
    LinuxInitializationSettings(
        defaultActionName: 'Open notification');
    final InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsDarwin,
        linux: initializationSettingsLinux);
    _flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: onNotificationTap,
        onDidReceiveBackgroundNotificationResponse: onNotificationTap
    );
  }
  //show a simple notification
  static Future showSimpleNotification({
        required String title, required String body, required String payload
      })async {
    const AndroidNotificationDetails androidNotificationDetails =
    AndroidNotificationDetails('kidz-emporium', 'Kidz-Emporium',
        channelDescription: 'Reschedule Booking Appointment',
        importance: Importance.max,
        priority: Priority.high,
        ticker: 'ticker');
    const NotificationDetails notificationDetails =
    NotificationDetails(android: androidNotificationDetails);
    await _flutterLocalNotificationsPlugin.show(
        0, title, body, notificationDetails,
        payload: json.encode({'title': title, 'body': body, 'data': {'bookingId': payload}}),
    );
  }

  // static Future scheduleNotification({
  //   required String title,
  //   required String body,
  //   required String payload,
  // }) async {
  //   // Create the Android notification details
  //   const AndroidNotificationDetails androidNotificationDetails =
  //   AndroidNotificationDetails(
  //     'your_channel_id',
  //     'your_channel_name',
  //     channelDescription: 'Reminder',
  //     importance: Importance.max,
  //     priority: Priority.high,
  //   );
  //   const NotificationDetails notificationDetails =
  //   NotificationDetails(android: androidNotificationDetails);
  //
  //   // Schedule the notification to be displayed
  //   await _flutterLocalNotificationsPlugin.zonedSchedule(
  //     0, // Notification ID
  //     title, // Notification title
  //     body, // Notification body
  //     tz.TZDateTime.now(tz.local).add(const Duration(seconds: 5)), // Schedule time
  //     notificationDetails,
  //     androidAllowWhileIdle: true,
  //     uiLocalNotificationDateInterpretation:
  //     UILocalNotificationDateInterpretation.absoluteTime,
  //   );
  // }

  static Future showPeriodicNotification({
    required String title, required String body, required String payload
  })async {
    const AndroidNotificationDetails androidNotificationDetails =
    AndroidNotificationDetails('your channel id', 'your channel name',
        channelDescription: 'your channel description',
        importance: Importance.max,
        priority: Priority.high,
        ticker: 'ticker');
    const NotificationDetails notificationDetails =
    NotificationDetails(android: androidNotificationDetails);
    await _flutterLocalNotificationsPlugin.periodicallyShow(1, title, body, RepeatInterval.daily, notificationDetails);
  }

  //close a specific channel notification
  //must add a button to close notification and it will be text button, when the parent update the booking
  static Future cancel(int id)async{
      await _flutterLocalNotificationsPlugin.cancel(id);
  }
}