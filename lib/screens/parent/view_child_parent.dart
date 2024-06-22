import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kidz_emporium/screens/parent/create_child_parent.dart';
import 'package:kidz_emporium/screens/parent/update_child_parent.dart';
import 'package:kidz_emporium/screens/parent/update_reminder_parent.dart';
import 'package:kidz_emporium/screens/parent/view_reminder_parent.dart';
import 'package:kidz_emporium/components/side_menu.dart';
import 'package:kidz_emporium/models/child_model.dart';
import 'package:kidz_emporium/models/login_response_model.dart';
import 'package:kidz_emporium/contants.dart';

import '../../config.dart';
import '../../services/api_service.dart';

class ViewChildParentPage extends StatefulWidget {
  final LoginResponseModel userData;

  const ViewChildParentPage({Key? key, required this.userData}) : super(key: key);

  @override
  _ViewChildParentPageState createState() => _ViewChildParentPageState();
}

class _ViewChildParentPageState extends State<ViewChildParentPage> {
  List<ChildModel> children = []; // Added the list to store children

  @override
  void initState() {
    super.initState();
    _loadChildren(widget.userData.data!.id);
  }

  Future<void> _loadChildren(String userId) async {
    try {
      List<ChildModel> loadedChildren = await APIService.getChild(widget.userData.data!.id);

      setState(() {
        children = loadedChildren;
      });
    } catch (error) {
      print('Error loading children: $error');
    }
  }

  String getImagePathByGender(String gender) {
    return gender == 'Male' ? 'assets/images/male_child.png' : 'assets/images/female_child.png';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavBar(userData: widget.userData),
      appBar: AppBar(
        backgroundColor: kSecondaryColor,
        title: Text("View Child Profile"),
        centerTitle: true,
      ),
      body: Container(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Your children",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: children.length,
                itemBuilder: (context, index) {
                  return Dismissible(
                    key: Key(children[index].id ?? ''),
                    onDismissed: (direction) async {
                      String? childId = children[index].id;

                      // Ensure the reminderId is not null before attempting deletion
                      if (childId != null) {
                        bool deleteConfirmed = await showDeleteConfirmationDialog(context);

                        if (deleteConfirmed) {
                          bool deleteSuccess = await APIService.deleteChild(childId);

                          if (deleteSuccess) {
                            setState(() {
                              children!.removeAt(index);
                            });

                            // Show an AlertDialog for successful deletion
                            showAlertDialog(context, 'Child profile deleted successfully');
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
                      color: Colors.white,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                        side: BorderSide(color: Colors.grey.shade300, width: 1),
                      ),
                      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                      child: ListTile(
                        contentPadding: EdgeInsets.all(10),
                        minVerticalPadding: 20,
                        leading: CircleAvatar(
                          radius: 30,
                          backgroundImage: AssetImage(getImagePathByGender(children[index].gender ?? '')),
                        ),
                        title: Text(
                          children[index].childName ?? '',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Birth Date: ${DateFormat('yyyy-MM-dd').format(DateTime.parse(children[index].birthDate as String))}",
                              style: TextStyle(fontSize: 16, color: Colors.black),
                            ),
                            Text(
                              "Program: ${children[index].program ?? 'N/A'}",
                              style: TextStyle(fontSize: 16, color: Colors.black),
                            ),
                            // Add any other details as needed
                          ],
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.edit, color: Colors.black),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => UpdateChildParentPage(userData: widget.userData, childId: children[index].id ?? ''),
                              ),
                            );
                          },
                        ),
                        // Add any other child details as needed
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
              builder: (context) => CreateChildParentPage(userData: widget.userData),
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
          content: Text('Are you sure you want to delete this child?'),
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
