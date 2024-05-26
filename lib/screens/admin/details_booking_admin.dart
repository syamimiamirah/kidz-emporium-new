import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kidz_emporium/models/booking_model.dart';
import 'package:kidz_emporium/models/child_model.dart';
import 'package:kidz_emporium/models/login_response_model.dart';
import 'package:kidz_emporium/models/therapist_model.dart';
import 'package:kidz_emporium/screens/admin/view_therapist_availability.dart';

import '../../contants.dart';
import '../../models/user_model.dart';
import 'create_notification_admin.dart';

class BookingDetailsAdminPage extends StatefulWidget {
  final LoginResponseModel userData;
  final BookingModel booking;
  final TherapistModel therapist;
  final UserModel therapistUser;

  final ChildModel child;

  const BookingDetailsAdminPage({
    Key? key,
    required this.userData,
    required this.booking,
    required this.therapist,
    required this.child,
    required this.therapistUser,
  }) : super(key: key);

  @override
  _BookingDetailsTherapistPageState createState() => _BookingDetailsTherapistPageState();
}


class _BookingDetailsTherapistPageState extends State<BookingDetailsAdminPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Booking Details'),
        centerTitle: true,
        backgroundColor: kPrimaryColor,
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
                value: widget.booking.service, // Use therapist's name from UserModel
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
                value: "${DateFormat('hh:mm a').format(DateTime.parse(widget.booking.fromDate))} - ${DateFormat('hh:mm a').format(DateTime.parse(widget.booking.toDate))}",
                icon: Icons.access_time,
                iconColor: kPrimaryColor,
              ),
              _buildDetailItem(
                label: 'Therapist:',
                value: widget.therapistUser.name,
                icon: Icons.person,
                iconColor: kPrimaryColor,
              ),
              _buildDetailItem(
                label: 'Payment Status:',
                value: widget.booking.paymentId != null ? 'Paid' : 'No Payment Required',
                icon: Icons.payment,
                iconColor: kPrimaryColor,
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  SizedBox(width: 10),
                  Column(
                    children: [
                      Center(
                        child: ElevatedButton(
                          onPressed:  () {
                            print('Booking ID: ${widget.booking.id}');
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AdminSendMessagePage(bookingId: widget.booking.id!, userData: widget.userData,

                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            primary: kSecondaryColor,
                            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            'Send Notification',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(width: 10),
                  Column(
                    children: [
                      Center(
                        child: ElevatedButton(
                          onPressed:  () {
                            print('Booking ID: ${widget.booking.id}');
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ViewTherapistAvailabilityPage(
                                  fromDate: DateTime.parse(widget.booking.fromDate),
                                  toDate: DateTime.parse(widget.booking.toDate),
                                  bookingId: widget.booking.id!,
                                  userData: widget.userData,
                                ),
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
                            'Assign Therapist',
                            style: TextStyle(fontSize: 16, color: Colors.black),
                          ),
                        ),
                      ),
                    ],
                  )
                ],
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
            'Booking Details',
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

/*Widget _buildRules() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[200],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Reminders:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          SizedBox(height: 10),
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
  }*/
}
