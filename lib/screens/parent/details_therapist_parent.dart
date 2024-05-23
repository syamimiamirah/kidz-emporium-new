import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kidz_emporium/models/therapist_model.dart';

import '../../contants.dart';
import '../../models/login_response_model.dart';
import '../../models/user_model.dart';
import '../../services/api_service.dart';
import '../../utils.dart';

class TherapistDetailParentPage extends StatefulWidget {
  final LoginResponseModel userData;
  final String therapistId;

  const TherapistDetailParentPage(
      {Key? key, required this.userData, required this.therapistId})
      : super(key: key);

  @override
  _TherapistDetailParentPageState createState() => _TherapistDetailParentPageState();
}

class _TherapistDetailParentPageState extends State<TherapistDetailParentPage> {
  late String therapistName = "";
  late String specialization = "";
  late DateTime hiringDate = DateTime.now();
  late String aboutMe = "";
  late String userId;
  List<UserModel> users = [];

  @override
  void initState() {
    super.initState();
    if (widget.userData != null && widget.userData.data != null) {
      print("userData: ${widget.userData.data!.id}");
      userId = widget.userData.data!.id;
      fetchUserData(); // Fetch user data before fetching therapist details
    } else {
      // Handle the case where userData or userData.data is null
      print("Error: userData or userData.data is null");
    }
  }

  Future<void> fetchUserData() async {
    try {
      List<UserModel> userList = await APIService.getAllUsers(); // Fetch user data
      setState(() {
        users = userList;
      });
      fetchTherapistDetails(); // Once user data is fetched, fetch therapist details
    } catch (error) {
      print('Error fetching user data: $error');
      // Handle error
    }
  }

  Future<void> fetchTherapistDetails() async {
    try {
      TherapistModel? therapist = await APIService.getTherapistDetails(widget.therapistId);
      UserModel therapistUser = users.firstWhere((user) => user.id == therapist?.therapistId);
      if (therapist != null) {
        // Update UI with fetched reminder details
        setState(() {
          therapistName = therapistUser.name;
          hiringDate = Utils.parseStringToDateTime(therapist.hiringDate);
          specialization = therapist.specialization;
          aboutMe = therapist.aboutMe;
          // Update other fields as needed
        });
      } else {
        // Handle case where reminder is null
        print('Therapist details not found');
      }
    } catch (error) {
      print('Error fetching therapist details: $error');
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Therapist Details'),
        backgroundColor: kSecondaryColor,
        centerTitle: true,
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
                label: 'Therapist Name:',
                value: therapistName,
                icon: Icons.person,
                iconColor: kSecondaryColor,
              ),
              _buildDetailItem(
                label: 'Hiring Date: ',
                value: DateFormat('yyyy-MM-dd').format(hiringDate), // Use therapist's name from UserModel
                icon: Icons.calendar_today,
                iconColor: kSecondaryColor,
              ),
              _buildDetailItem(
                label: 'Specialization',
                value: specialization,
                icon: Icons.school,
                iconColor: kSecondaryColor,
              ),
              _buildDetailItem(
                label: 'About Me:',
                value: aboutMe, // Use therapist's name from UserModel
                icon: Icons.person,
                iconColor: kSecondaryColor,
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
        color: kSecondaryColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Therapist Profile',
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
          Expanded(
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
}