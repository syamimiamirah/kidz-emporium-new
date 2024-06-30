import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../contants.dart';
import '../../models/livestream_model.dart';
import '../../models/login_response_model.dart';
import '../../services/api_service.dart';

class ViewLivestreamPage extends StatefulWidget {
  final LoginResponseModel userData;
  final String bookingId;

  const ViewLivestreamPage({
    Key? key,
    required this.userData,
    required this.bookingId,
  }) : super(key: key);

  @override
  _ViewLivestreamPageState createState() => _ViewLivestreamPageState();
}

class _ViewLivestreamPageState extends State<ViewLivestreamPage> {
  String? url;
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    _loadMeetingLink();
  }

  Future<void> _loadMeetingLink() async {
    try {
      LivestreamModel? meeting = await APIService.getLivestreamDetailsByBookingId(widget.bookingId);
      if (meeting != null && meeting.url.isNotEmpty) {
        setState(() {
          url = meeting.url;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
          hasError = true;
        });
      }
    } catch (error) {
      setState(() {
        isLoading = false;
        hasError = true;
      });
      print('Error fetching meeting details: $error');
    }
  }

  void _launchMeetingUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Join Virtual Meeting'),
        centerTitle: true,
        backgroundColor: kPrimaryColor,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 10),
            Text(
              'You are about to join the virtual meeting.',
              style: TextStyle(
                fontSize: 20,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            Text(
              'Meeting Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),
            Text(
              'Meeting ID: ${widget.bookingId}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            Text(
              'Organizer: Kidz Emporium Therapy Center',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            if (hasError)
              Text(
                'The virtual meeting URL is not available.',
                style: TextStyle(color: Colors.red, fontSize: 16),
              ),
            ElevatedButton(
              onPressed: url != null ? () => _launchMeetingUrl(url!) : null,
              child: Text(
                'Join Meeting',
                style: TextStyle(fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                primary: kPrimaryColor,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
