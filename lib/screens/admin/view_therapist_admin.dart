import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kidz_emporium/Screens/admin/update_therapist_admin.dart';
import 'package:kidz_emporium/Screens/parent/create_child_parent.dart';
import 'package:kidz_emporium/Screens/parent/update_child_parent.dart';
import 'package:kidz_emporium/Screens/parent/update_reminder_parent.dart';
import 'package:kidz_emporium/Screens/parent/view_reminder_parent.dart';
import 'package:kidz_emporium/components/side_menu.dart';
import 'package:kidz_emporium/models/child_model.dart';
import 'package:kidz_emporium/models/login_response_model.dart';
import 'package:kidz_emporium/contants.dart';
import 'package:kidz_emporium/models/therapist_model.dart';

import '../../config.dart';
import '../../models/user_model.dart';
import '../../services/api_service.dart';
import 'create_therapist_admin.dart';

class ViewTherapistAdminPage extends StatefulWidget {
  final LoginResponseModel userData;

  const ViewTherapistAdminPage({Key? key, required this.userData}) : super(key: key);

  @override
  _ViewTherapistAdminPageState createState() => _ViewTherapistAdminPageState();
}

class _ViewTherapistAdminPageState extends State<ViewTherapistAdminPage> {
  List<TherapistModel> therapists = [];
  List<UserModel> users = [];// Added the list to store children

  @override
  void initState() {
    super.initState();
    _loadTherapists(widget.userData.data!.id);
  }

  Future<void> _loadTherapists(String managedBy) async {
    try {
      List<TherapistModel> loadedTherapists = await APIService.getAllTherapists();
      List<UserModel> loadedUsers = await APIService.getAllUsers(); // Adjust this according to your API

      setState(() {
        therapists = loadedTherapists;
        users = loadedUsers;
      });
    } catch (error) {
      print('Error loading therapists: $error');
    }
  }

  /*String getImagePathByGender(String gender) {
    return gender == 'Male' ? 'assets/images/male_child.png' : 'assets/images/female_child.png';
  }
  */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AdminNavBar(userData: widget.userData),
      appBar: AppBar(
        backgroundColor: kSecondaryColor,
        title: Text("View Therapist Profile"),
        centerTitle: true,
      ),
      body: Container(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "List of therapists",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: therapists.length,
                itemBuilder: (context, index) {
                  UserModel therapistUser = users.firstWhere((user) => user.id == therapists[index].therapistId);
                  String therapistName = therapistUser.name;
                  return Dismissible(
                    key: Key(therapists[index].id ?? ''),
                    onDismissed: (direction) async {
                      String? therapistId = therapists[index].id;

                      // Ensure the reminderId is not null before attempting deletion
                      if (therapistId != null) {
                        bool deleteConfirmed = await showDeleteConfirmationDialog(context);

                        if (deleteConfirmed) {
                          bool deleteSuccess = await APIService.deleteTherapist(therapistId);

                          if (deleteSuccess) {
                            setState(() {
                              therapists!.removeAt(index);
                            });

                            // Show an AlertDialog for successful deletion
                            showAlertDialog(context, 'Therapist profile deleted successfully');
                          } else {
                            showAlertDialog(context, 'Failed to delete child profile');
                          }
                        }
                      }
                    },
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: EdgeInsets.only(right: 20),
                      child: Icon(
                        Icons.delete,
                        color: Colors.white,
                      ),
                    ),

                    child: Card(
                      //color: Colors.pink[200],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                        side: BorderSide(color: Colors.grey.shade300, width: 1),
                      ),
                      elevation: 4,
                      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                      child:
                      ListTile(
                        contentPadding: EdgeInsets.all(10),
                        minVerticalPadding: 20,
                        leading: CircleAvatar(
                          radius: 30,
                          backgroundImage: AssetImage('assets/images/medical_team.png'),
                        ),
                        title: Row(
                          children: [
                            Icon(Icons.person, size: 18, color: kSecondaryColor),
                            SizedBox(width: 10),
                            Text(
                              therapistName ?? '',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                            ),
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.date_range, size: 18, color: kSecondaryColor),
                                SizedBox(width: 10),
                                Text(
                                  DateFormat('yyyy-MM-dd').format(DateTime.parse(therapists[index].hiringDate as String)),
                                  style: TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Icon(Icons.school, size: 18, color: kSecondaryColor),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    therapists[index].specialization,
                                    style: TextStyle(fontSize: 16),
                                    softWrap: true,
                                    maxLines: null,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.edit, color: Colors.black),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => UpdateTherapistAdminPage(userData: widget.userData, therapistId: therapists[index].therapistId ?? ''),
                              ),
                            );
                          },
                        ),
                      ),

                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CreateTherapistAdminPage(userData: widget.userData),
            ),
          );
        },
        child: Icon(Icons.add, color: Colors.white),
        backgroundColor: Colors.pink,
      ),
    );
  }
  Future<bool> showDeleteConfirmationDialog(BuildContext context) async {
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(Config.appName),
          content: Text('Are you sure you want to delete this therapist?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // Return false when cancel is pressed
              },
              child: Text('Cancel', style: TextStyle(color: Colors.black),),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // Return true when delete is pressed
              },
              child: Text('Delete', style: TextStyle(color: kSecondaryColor),),
            ),
          ],
        );
      },
    );
  }

  void showAlertDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(Config.appName),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK', style: TextStyle(color: kSecondaryColor),),
            ),
          ],
        );
      },
    );
  }
}
