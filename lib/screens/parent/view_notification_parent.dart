import 'dart:async';
import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:kidz_emporium/screens/parent/update_booking_parent.dart';
import 'package:kidz_emporium/screens/parent/view_booking_parent.dart';
import 'package:kidz_emporium/models/login_response_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../contants.dart';
import '../../services/message_handler.dart';

class NotificationDetailsPage extends StatefulWidget {
  final String payload;
  final LoginResponseModel userData;

  const NotificationDetailsPage({Key? key, required this.payload, required this.userData}) : super(key: key);

  @override
  _NotificationDetailsPageState createState() => _NotificationDetailsPageState();
}

class _NotificationDetailsPageState extends State<NotificationDetailsPage> {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  String _title = '';
  String _body = '';
  String _bookingId = '';
  String _notificationType = '';
  bool _notificationHandled = false;
  late final StreamSubscription<RemoteMessage> _onMessageSubscription;
  late final StreamSubscription<RemoteMessage> _onMessageOpenedAppSubscription;

  @override
  void initState() {
    super.initState();
    _parsePayload(widget.payload);

    _firebaseMessaging.getInitialMessage().then((message) {
      if (message != null && mounted) {
        _handleMessage(message);
      }
    });

    _onMessageSubscription = FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (mounted) {
        _handleMessage(message);
      }
    });

    _onMessageOpenedAppSubscription = FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (mounted) {
        _handleMessage(message);
      }
    });
  }

  Future<void> _resetNotificationFlag() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notificationHandled', false);
    MessageHandler.resetNotificationHandledFlag();
  }

  void _parsePayload(String payload) {
    try {
      final data = Map<String, dynamic>.from(json.decode(payload));
      setState(() {
        _title = data['title'] ?? 'No Title';
        _body = data['body'] ?? 'No Body';
        _bookingId = data['bookingId'] ?? 'No Booking ID';
        _notificationType = data['type'] ?? 'general';
        _notificationHandled = true;
      });
    } catch (e) {
      print('Error parsing payload: $e');
    }
  }

  void _handleMessage(RemoteMessage message) {
    final notification = message.notification;
    final data = message.data;

    setState(() {
      _title = notification?.title ?? 'No Title';
      _body = notification?.body ?? 'No Body';
      _bookingId = data['bookingId'] ?? 'No Booking ID';
      _notificationType = data['type'] ?? 'general';
      _notificationHandled = true;
    });
  }

  @override
  void dispose() {
    _resetNotificationFlag();
    MessageHandler.resetNotificationCount();
    _onMessageSubscription.cancel();
    _onMessageOpenedAppSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Reset notification count and flag when the user navigates back
        await _resetNotificationFlag();
        MessageHandler.resetNotificationCount();
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: kPrimaryColor,
          elevation: 0,
          title: Text(
            'Notification Details',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: MessageHandler.getNotificationCount() > 0 ? _buildNotificationDetails() : _buildNoNotificationMessage(),
        ),
      ),
    );
  }

  Widget _buildNotificationDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _notificationType == 'booking'
              ? 'Below is the message from the Center regarding your booking session'
              : 'You have received a notification',
          style: TextStyle(
            fontSize: 16,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 20),
        _buildInfoItem('Title:', _title),
        SizedBox(height: 20),
        _buildInfoItem('Description:', _body),
        if (_notificationType == 'booking') ...[
          SizedBox(height: 40),
          Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UpdateBookingParentPage(
                      userData: widget.userData,
                      bookingId: _bookingId,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                primary: kPrimaryColor,
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'Reschedule',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ] else if (_notificationType == 'general') ...[
          SizedBox(height: 40),
          Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ViewBookingParentPage(userData: widget.userData),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                primary: kPrimaryColor,
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'Acknowledge',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildNoNotificationMessage() {
    return Center(
      child: Text(
        'No new notifications',
        style: TextStyle(
          fontSize: 18,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildInfoItem(String title, String text) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: Container(
            padding: EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Text(
              text,
              style: TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
