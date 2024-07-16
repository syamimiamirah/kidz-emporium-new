import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:kidz_emporium/screens/parent/update_booking_parent.dart';
import 'package:kidz_emporium/screens/parent/view_livestream_parent.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:typed_data';
import 'package:printing/printing.dart';

import '../../contants.dart';
import '../../models/booking_model.dart';
import '../../models/child_model.dart';
import '../../models/login_response_model.dart';
import '../../models/therapist_model.dart';
import '../../models/user_model.dart';

class BookingDetailsPage extends StatefulWidget {
  final LoginResponseModel userData;
  final BookingModel booking;
  final TherapistModel therapist;
  final ChildModel child;
  final UserModel therapistUser;

  const BookingDetailsPage({
    Key? key,
    required this.userData,
    required this.booking,
    required this.therapist,
    required this.child,
    required this.therapistUser,
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

  Future<Uint8List> generateReceipt() async {
    final pdf = pw.Document();

    final String serviceName = widget.booking.service;
    final String? customerName = widget.userData.data?.name;
    final String date = DateFormat('dd-MM-yyyy').format(DateTime.now());
    final double amount = 50.00; // Assuming a fixed amount for this example
    final String receiptNumber = 'KEV/RC/${DateTime.now().millisecondsSinceEpoch}';
    final String paymentMode = 'Debit/Credit Card';
    final String referenceNumber = 'Ref-${DateTime.now().millisecondsSinceEpoch}';

    final logoImage = pw.MemoryImage(
      (await rootBundle.load("assets/images/logo-centre.png")).buffer.asUint8List(),
    );
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Container(
            padding: pw.EdgeInsets.all(16),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Center(child: pw.Image(logoImage, width: 100)), // Center align image
                pw.SizedBox(height: 10),
                pw.Center(child: pw.Text('No.8-17-02, Jalan Medan Pusat Bandar 7A',
                    textAlign: pw.TextAlign.center),), // Center align text
                pw.Center(child: pw.Text('Bangi Sentral, 43650 Bandar Baru Bangi, Selangor',
                    textAlign: pw.TextAlign.center),), // Center align text
                pw.SizedBox(height: 20),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Receipt No:'),
                    pw.Text(receiptNumber),
                  ],
                ),
                pw.SizedBox(height: 10),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Payment Date:'),
                    pw.Text(date),
                  ],
                ),
                pw.SizedBox(height: 10),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Payment Mode:'),
                    pw.Text(paymentMode),
                  ],
                ),
                pw.SizedBox(height: 10),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Reference Number:'),
                    pw.Text(referenceNumber),
                  ],
                ),
                pw.SizedBox(height: 20),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Amount Received:'),
                    pw.Text('RM ${amount.toStringAsFixed(2)}'),
                  ],
                ),
                pw.SizedBox(height: 10),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Received From:'),
                    pw.Text(customerName!),
                  ],
                ),
                pw.SizedBox(height: 20),
                pw.Text('Details', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.Divider(),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Type of service'),
                    pw.Text('Amount'),
                  ],
                ),
                pw.SizedBox(height: 10),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Deposit for ${widget.booking.service}'),
                    pw.Text('RM ${amount.toStringAsFixed(2)}'),
                  ],
                ),
                pw.Divider(),
                pw.SizedBox(height: 30),
                pw.Center(child: pw.Text('Thank you for your business!', style: pw.TextStyle(fontSize: 16))),
              ],
            ),
          );
        },
      ),
    );

    return pdf.save();
  }

  Future<void> printReceipt() async {
    final pdfBytes = await generateReceipt();
    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdfBytes);
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
                    bookingId: widget.booking.id!,
                  ),
                ),
              );
            },
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
              _buildDetailItem(
                label: 'Payment Status:',
                value: widget.booking.paymentId != null ? 'Paid' : 'No Payment Required',
                icon: Icons.payment,
                iconColor: kPrimaryColor,
              ),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    await printReceipt();
                  },
                  style: ElevatedButton.styleFrom(
                    primary: kPrimaryColor,
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'Generate Receipt',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
              SizedBox(height: 20),
              _buildRules(),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: _isRescheduleDisabled
                      ? null
                      : () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UpdateBookingParentPage(
                          userData: widget.userData,
                          bookingId: widget.booking.id ?? '',
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

  Widget _buildDetailItem({
    required String label,
    required String value,
    required IconData icon,
    Color iconColor = Colors.blue,
    Widget? button,
  }) {
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
          if (button != null) ...[
            Spacer(),
            button,
          ],
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
