import 'package:flutter/material.dart';
import 'package:kidz_emporium/Screens/therapist/update_report_therapist.dart';
import 'package:kidz_emporium/Screens/therapist/view_report_therapist.dart';
import 'package:kidz_emporium/config.dart';
import 'package:kidz_emporium/contants.dart';
import 'package:kidz_emporium/models/therapist_model.dart';
import '../../components/side_menu.dart';
import '../../models/booking_model.dart';
import '../../models/child_model.dart';
import '../../models/login_response_model.dart';
import '../../models/report_model.dart';
import '../../models/user_model.dart';
import '../../services/api_service.dart';
import 'create_report_therapist.dart';

class ReportDetailsTherapistPage extends StatefulWidget {
  final LoginResponseModel userData;
  final BookingModel booking;
  final TherapistModel therapist;
  final UserModel therapistUser;
  final ChildModel child;

  const ReportDetailsTherapistPage({
    Key? key,
    required this.userData,
    required this.booking,
    required this.therapist,
    required this.child,
    required this.therapistUser,
  }) : super(key: key);

  @override
  _ReportDetailsPageState createState() => _ReportDetailsPageState();
}

class _ReportDetailsPageState extends State<ReportDetailsTherapistPage> {
  bool hasReport = false;
  bool _isLoading = true;
  late String reportTitle = '';
  late String description = '';
  String? id;

  @override
  void initState() {
    super.initState();
    _loadData(widget.userData.data!.id);
  }

Future<void> _loadData(String userId) async {
  try {
    // Use Future.wait to wait for all API calls to complete
    await Future.wait([
    checkReportAvailability(),
    fetchReportDetails(),// Fetch user details
    ]);
  } catch (error) {
    print('Error loading data: $error');
  }
}

  Future<void> checkReportAvailability() async {
    try {
      bool exists = await APIService.checkReport(widget.booking.id!);
      setState(() {
        hasReport = exists;
      });
    } catch (error) {
      print('Error checking report: $error');
    }
  }
  Future<void> fetchReportDetails() async {
    try {
      List<ReportModel> reports = await APIService.getReportDetailsByBookingId(widget.booking.id!);

      if (reports.isNotEmpty) {
        // Assuming you only want to display the details of the first report in the list
        ReportModel report = reports[0];
        setState(() {
          reportTitle = report.reportTitle;
          description = report.reportDescription;
          id = report.id;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false; // Set loading state to false even if no report is found
        });
        print('No report details found');
      }
    } catch (error) {
      print('Error fetching report details: $error');
      setState(() {
        _isLoading = false; // Set loading state to false even if no report is found
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Report Details'),
        centerTitle: true,
        backgroundColor: kPrimaryColor,
      ),
      body: SingleChildScrollView( // Wrap the body with SingleChildScrollView
        child: Center(
        child: _isLoading ? CircularProgressIndicator() : (hasReport ? _buildReportWidget() : _buildNoReportWidget()),
        ),
      ),
    );
  }

  Widget _buildReportWidget() {
    return Padding(
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
            Container(
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
                    'Child`s Report',
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
            ),
            SizedBox(height: 20),
            _buildDetailItem(
              label: 'Report Title:',
              value: reportTitle,
              icon: Icons.feedback,
              iconColor: kPrimaryColor,
            ),
            _buildDetailItem(
              label: 'Description:',
              value: description,
              icon: Icons.description,
              iconColor: kPrimaryColor,
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [ElevatedButton(
                onPressed: () async {
                  bool deleteSuccess = await APIService.deleteReport(id!);
                  if (deleteSuccess) {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text(Config.appName),
                          content: Text('Report deleted successfully'),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () {
                                Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                    builder: (context) => ViewReportTherapistPage(userData: widget.userData),
                                ),
                                );
                              },
                              child: Text('OK'),
                            ),
                          ],
                        );
                      },
                    );
                  } else {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text(Config.appName),
                          content: Text('Failed to delete report'),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text('OK'),
                            ),
                          ],
                        );
                      },
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.red, // Change color to red for delete button
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Delete',
                  style: TextStyle(fontSize: 16),
                ),
              ),
                SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UpdateReportTherapistPage(
                          userData: widget.userData,
                          reportId: id ?? '',
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
                    'Update',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
          ],
        ),
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
          Expanded( // Wrap with Expanded widget
            child: Column(
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
                  // Set maxLines to null for multiline text
                  softWrap: true,
                  maxLines: null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }



  Widget _buildNoReportWidget() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'No Report Found',
            style: TextStyle(
              fontSize: 16,
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              // Navigate to the page where the therapist can create a report
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CreateReportTherapistPage(
                    userData: widget.userData,
                    booking: widget.booking,
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
              'Create Report',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
