import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kidz_emporium/Screens/parent/update_booking_parent.dart';
import 'package:kidz_emporium/models/booking_model.dart';
import 'package:kidz_emporium/models/child_model.dart';
import 'package:kidz_emporium/models/livestream_model.dart';
import 'package:kidz_emporium/models/therapist_model.dart';
import 'package:kidz_emporium/models/user_model.dart'; // Import UserModel
import 'package:kidz_emporium/screens/parent/view_livestream_parent.dart';

import '../../contants.dart';
import '../../models/login_response_model.dart';
import '../../services/api_service.dart';

class BookingDetailsPage extends StatefulWidget {
  final LoginResponseModel userData;
  final BookingModel booking;
  final TherapistModel therapist;
  final ChildModel child;
  final UserModel therapistUser; // Add UserModel parameter

  const BookingDetailsPage({
    Key? key,
    required this.userData,
    required this.booking,
    required this.therapist,
    required this.child,
    required this.therapistUser, // Add UserModel parameter
  }) : super(key: key);

  @override
  _BookingDetailsPageState createState() => _BookingDetailsPageState();
}

class _BookingDetailsPageState extends State<BookingDetailsPage> {
  bool _isRescheduleDisabled = false;

  @override
  void initState() {
    super.initState();
    _checkRescheduleEligibility();
  }

  void _checkRescheduleEligibility() {
    final DateTime bookingDate = DateTime.parse(widget.booking.fromDate);
    final DateTime currentDate = DateTime.now();
    final Duration difference = bookingDate.difference(currentDate);

    setState(() {
      _isRescheduleDisabled = difference.inDays < 3;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Booking Details'),
        centerTitle: true,
        backgroundColor: kPrimaryColor,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.video_call),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ViewLivestreamPage(
                        userData: widget.userData,
                        bookingId: widget.booking.id!),
                    )
                );
              } ,
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 3,
                blurRadius: 5,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              SizedBox(height: 20),
              _buildDetailItem(
                label: 'Child Name:',
                value: widget.child.childName,
                icon: Icons.child_care,
                iconColor: kPrimaryColor,
              ),
              _buildDetailItem(
                label: 'Type of Services:',
                value: widget.booking.service,
                icon: Icons.school,
                iconColor: kPrimaryColor,
              ),
              _buildDetailItem(
                label: 'Booking Date:',
                value: DateFormat('dd-MM-yyyy').format(DateTime.parse(widget.booking.fromDate)),
                icon: Icons.calendar_today,
                iconColor: kPrimaryColor,
              ),
              _buildDetailItem(
                label: 'Time Slot:',
                value:
                "${DateFormat('hh:mm a').format(DateTime.parse(widget.booking.fromDate))} - ${DateFormat('hh:mm a').format(DateTime.parse(widget.booking.toDate))}",
                icon: Icons.access_time,
                iconColor: kPrimaryColor,
              ),
              _buildDetailItem(
                label: 'Therapist:',
                value: widget.therapistUser.name,
                icon: Icons.person,
                iconColor: kPrimaryColor,
              ),
              SizedBox(height: 20),
              _buildRules(),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: _isRescheduleDisabled ? null : () {
                    print('Booking ID: ${widget.booking.id}');
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UpdateBookingParentPage(userData: widget.userData, bookingId: widget.booking.id ?? ''),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    primary: kPrimaryColor,
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'Reschedule',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
              SizedBox(height: 10),
              Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.info, color: kPrimaryColor),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "*You can reschedule your appointment at least 3 days before the session",
                              style: TextStyle(
                                fontSize: 16,
                                fontStyle: FontStyle.italic,
                                color: Colors.black54,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kPrimaryColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Appointment',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem({required String label, required String value, required IconData icon, Color iconColor = Colors.blue}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 30, color: iconColor),
          SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRules() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[200],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Reminders Before Going to the Center:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          SizedBox(height: 10),
          _buildRuleItem('Wear a mask at all times.'),
          _buildRuleItem('Maintain social distancing.'),
          _buildRuleItem('Arrive 10 minutes prior to your appointment.'),
          _buildRuleItem('Reschedule your appointment if your child is feeling unwell.'),
        ],
      ),
    );
  }

  Widget _buildRuleItem(String rule) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle, size: 20, color: Colors.green),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              rule,
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
