import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class NotificationDetailsPage extends StatefulWidget {
  final String payload;

  const NotificationDetailsPage({Key? key, required this.payload}): super(key: key);

  @override
  _NotificationDetailsPageState createState() => _NotificationDetailsPageState();
}

class _NotificationDetailsPageState extends State<NotificationDetailsPage> {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  @override
  void initState() {
    super.initState();
    _firebaseMessaging.getInitialMessage().then((message) {
      if (message != null) {
        // Handle initial message
        _handleMessage(message);
      }
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // Handle incoming message when the app is in the foreground
      _handleMessage(message);
    });
  }

  void _handleMessage(RemoteMessage message) {
    final data = message.data;
    if (data.containsKey('bookingId')) {
      // Extract bookingId from message data
      final String bookingId = data['bookingId'];
      // Do something with the bookingId (e.g., navigate to another page)
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => NotificationDetailsPage(payload: bookingId)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notification Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Notification Details:',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(
              widget.payload,
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}