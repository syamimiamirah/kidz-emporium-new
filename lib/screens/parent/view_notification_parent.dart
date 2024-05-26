import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:kidz_emporium/Screens/parent/update_booking_parent.dart';
import 'package:kidz_emporium/models/login_response_model.dart';

import '../../contants.dart';

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

  @override
  void initState() {
    super.initState();
    _parsePayload(widget.payload);

    _firebaseMessaging.getInitialMessage().then((message) {
      if (message != null) {
        _handleMessage(message);
      }
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (mounted) { // Check if the widget is mounted before calling setState
        _handleMessage(message);
      }
    });
  }

  void _parsePayload(String payload) {
    try {
      final data = Map<String, dynamic>.from(json.decode(payload));
      setState(() {
        _title = data['title'] ?? 'No Title';
        _body = data['body'] ?? 'No Body';
        _bookingId = data['bookingId'] ?? 'No Booking ID';
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
    });
  }

  @override
  void dispose() {
    // Dispose any ongoing operations here
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Below is the message from the Center regarding your booking session',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 20),
            _buildInfoItem('Title:', _title),
            SizedBox(height: 20),
            _buildInfoItem('Description:', _body),
            // SizedBox(height: 20),
            // _buildInfoItem('Booking ID:', _bookingId),
            SizedBox(height: 40),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  print('Booking ID: $_bookingId');
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UpdateBookingParentPage(userData: widget.userData, bookingId: _bookingId),
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
          ],
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
                  offset: Offset(0, 3), // changes position of shadow
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
