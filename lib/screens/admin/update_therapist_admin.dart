import 'package:flutter/material.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';
import 'package:kidz_emporium/Screens/admin/view_therapist_admin.dart';
import 'package:kidz_emporium/components/side_menu.dart';
import 'package:kidz_emporium/contants.dart';
import 'package:kidz_emporium/Screens/login_page.dart';
import 'package:kidz_emporium/models/therapist_model.dart';
import 'package:snippet_coder_utils/FormHelper.dart';

import '../../config.dart';
import '../../models/login_response_model.dart';
import '../../models/user_model.dart';
import '../../services/api_service.dart';
import '../../utils.dart';
import '../parent/view_reminder_parent.dart';



class UpdateTherapistAdminPage extends StatefulWidget{
  final LoginResponseModel userData;
  final String therapistId;

  const UpdateTherapistAdminPage({Key? key, required this.userData, required this.therapistId}) : super(key: key);

  @override
  _updateTherapistAdminPageState createState() =>_updateTherapistAdminPageState();
}

class _updateTherapistAdminPageState extends State<UpdateTherapistAdminPage>{
  static final GlobalKey<FormState> globalFormKey = GlobalKey<FormState>();
  bool isAPICallProcess =  false;
  late String therapistName = "";
  late String specialization = "";
  late String therapistId = "";
  late DateTime hiringDate = DateTime.now();
  late String aboutMe = "";
  late String managedBy = "";
  List<UserModel> users = [];
  bool isHiringDateSet = false;

  @override
  void initState(){
    super.initState();
    if(widget.userData != null && widget.userData.data != null){
      print("userData: ${widget.userData.data!.id}");
      managedBy = widget.userData.data!.id;
      fetchTherapists();
      fetchTherapistDetails(); // Fetch therapist details when the screen initializes
    } else {
      print("Error: userData or userData.data is null");
    }
  }

  Future<void> fetchTherapists() async {
    try {
      List<UserModel> fetchedUsers = await APIService.getAllUsers();

      print('Fetched users JSON response: $fetchedUsers');

      // Filter the fetched users to get only therapists
      List<UserModel> fetchedTherapists = fetchedUsers.where((user) =>
      user.role == 'Therapist').toList();
      print('Filtered therapists: $fetchedTherapists');

      // Print the id field of each user to debug
      fetchedTherapists.forEach((user) {
        print('User ID: ${user.id}');
      });

      setState(() {
        users = fetchedTherapists;
      });
    }catch (error) {
      print('Error fetching therapists: $error');
    }
  }
  Future<void> fetchTherapistDetails() async {
    try {
      TherapistModel? therapist = await APIService.getTherapistDetails(widget.therapistId);
      print(therapist);
      //UserModel therapistUser = users.firstWhere((user) => user.id == therapist?.therapistId);
      if (therapist != null) {
        // Update UI with fetched therapist details
        setState(() {
          therapistId = therapist.therapistId;
          hiringDate = Utils.parseStringToDateTime(therapist.hiringDate);
          print('Hiring date string: $hiringDate');
          specialization = therapist.specialization;
          aboutMe = therapist.aboutMe;
          // Update other fields as needed
        });
      } else {
        // Handle case where therapist is null
        print('Therapist details not found');
      }
    } catch (error) {
      print('Error fetching therapist details: $error');
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kSecondaryColor,
        title: Text("Update Therapist Profile"),
        centerTitle: true,
      ),
      body: ProgressHUD(
          child: Form(
            key: _updateTherapistAdminPageState.globalFormKey,
            child: _updateTherapistAdminUI(context),
          )
      ),
    );
  }

  Widget _updateTherapistAdminUI(BuildContext context){
    return SingleChildScrollView(
        child: Column(
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey,),

                  ),
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Icon(
                          Icons.person, // Your desired icon
                          color: kSecondaryColor, // Icon color
                        ),
                      ),
                      Expanded(
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            hint: const Text("Select Therapist", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
                            value: therapistId,
                            isExpanded: true,
                            icon: Icon(Icons.arrow_drop_down, color: kSecondaryColor),
                            onChanged: (newValue) {
                              setState(() {
                                therapistId = newValue!;
                                //therapistName = users.firstWhere((user) => user.id == therapistName).name;
                              });
                            },
                            items: users.map((UserModel user) {
                              return DropdownMenuItem<String>(
                                value: user.id,
                                child: Text(user.name, style: TextStyle(fontSize: 16)
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 10),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey,),

                  ),
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Icon(
                          Icons.school, // Your desired icon
                          color: kSecondaryColor, // Icon color
                        ),
                      ),
                      Expanded(
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: specialization.isNotEmpty ? specialization : null,
                            hint: const Text("Specialization",style: TextStyle(fontSize: 16,)),
                            items: [
                              DropdownMenuItem<String>(
                                value: null,
                                child: Text("Specialization",style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),),
                              ),
                              // Other role options
                              DropdownMenuItem<String>(
                                value: "Occupational Therapy",
                                child: Text("Occupational Therapy",style: TextStyle(fontSize: 16,),),
                              ),
                              DropdownMenuItem<String>(
                                value: "Speech-Language Pathology",
                                child: Text("Speech-Language Pathology",style: TextStyle(fontSize: 16,),),
                              ),
                              DropdownMenuItem<String>(
                                value: "Psychology, Counselling",
                                child: Text("Psychology, Counselling",style: TextStyle(fontSize: 16,),),
                              ),
                              DropdownMenuItem<String>(
                                value: "Special Education",
                                child: Text("Special Education",style: TextStyle(fontSize: 16,),),
                              ),
                              DropdownMenuItem<String>(
                                value: "Early Childhood Education",
                                child: Text("Early Childhood Education",style: TextStyle(fontSize: 16,),),
                              ),
                            ],// The first item is the hint, set its value to null
                            isExpanded: true,
                            icon: Icon(Icons.arrow_drop_down, color: kSecondaryColor),
                            onChanged: (String? newValue){
                              //Your code to execute, when a menu item is selected from dropdown
                              //dropDownStringItem = value;
                              setState(() {
                                this.specialization = newValue!;
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              ),
            ),
            Center(
                child: Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 10),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey,),
                    ),
                    child: Row(
                        children:[
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: Icon(
                              Icons.calendar_today, // Your desired icon for date picker
                              color: kSecondaryColor, // Icon color
                            ),
                          ),
                          Expanded(
                            child: InkWell(
                              onTap: (){
                                showDatePicker(
                                  context: context,
                                  initialDate: hiringDate,
                                  firstDate: DateTime(1900),
                                  lastDate: DateTime.now(),
                                ).then((selectedDate){
                                  if(selectedDate != null && selectedDate != hiringDate){
                                    setState(() {
                                      hiringDate = selectedDate;
                                      isHiringDateSet = true;
                                    });
                                  }
                                });
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: 15),
                                child: Text(
                                  hiringDate != null
                                      ? "${hiringDate!.toLocal()}".split(' ')[0]
                                      : 'Hiring Date',
                                  style: TextStyle(fontSize: 16, fontWeight: hiringDate != null ? FontWeight.normal : FontWeight.bold,),
                                ),
                              ),
                            ),
                          ),
                        ]
                    ),
                  ),
                )
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child:
              FormHelper.inputFieldWidget(
                context,
                "about me", "About Me",
                    (onValidateVal){
                  if(onValidateVal.isEmpty){
                    return "About Me can't be empty";
                  }
                  return null;
                },
                    (onSavedVal){
                  aboutMe = onSavedVal.toString().trim();
                },
                initialValue: aboutMe,
                prefixIconColor: kSecondaryColor,
                showPrefixIcon: true,
                prefixIcon: const Icon(Icons.description),
                borderRadius: 10,
                borderColor: Colors.grey,
                contentPadding: 15,
                fontSize: 16,
                prefixIconPaddingLeft: 10,
                prefixIconPaddingBottom: 55,
                isMultiline: true,
                hintFontSize: 16,
              ),
            ),
            const SizedBox(height: 10),
            Center(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FormHelper.submitButton("Cancel", (){
                          Navigator.pushReplacement(context, MaterialPageRoute(
                              builder: (context) =>  ViewTherapistAdminPage(userData:widget.userData)),
                          );
                        },
                          btnColor: Colors.grey,
                          txtColor: Colors.black,
                          borderRadius: 10,
                          fontSize: 16,
                          borderColor: Colors.grey,
                        ),
                        SizedBox(width: 20),
                        FormHelper.submitButton(
                          "Save", () async {
                          if(validateAndSave()){
                            setState(() {
                              isAPICallProcess = true;
                            });


                            TherapistModel updatedModel = TherapistModel(
                              specialization: specialization!,
                              hiringDate: Utils.formatDateTimeToString(hiringDate!),
                              aboutMe: aboutMe!,
                              managedBy: widget.userData.data!.id,
                              therapistId: therapistId,
                            );

                            bool success = await APIService.updateTherapist(widget.therapistId, updatedModel);
                            setState(() {
                              isAPICallProcess = false;
                            });

                            if (success) {
                              _showCustomAlertDialog(
                                context,
                                Config.appName,
                                "Therapist profile updated",
                                "OK",
                                    () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ViewTherapistAdminPage(userData: widget.userData),
                                    ),
                                  );
                                }, kPrimaryColor,
                              );
                            }
                            else {
                              _showCustomAlertDialog(
                                context,
                                Config.appName,
                                "Failed to update therapist profile",
                                "OK",
                                    () {
                                  Navigator.of(context).pop();
                                }, kPrimaryColor,
                              );
                            }
                          }
                        },
                          btnColor: Colors.pink,
                          txtColor: Colors.white,
                          borderRadius: 10,
                          fontSize: 16,
                          borderColor: Colors.pink,
                        ),
                      ],
                    )
                  ],
                )
            )
          ],
        )
    );
  }
  bool validateAndSave() {
    print("Validate and Save method is called");
    final form = globalFormKey.currentState;
    if (form != null && form.validate()) {
      print("Save method is called");
      form.save();
      return true;
    } else {
      return false;
    }
  }
  void _showCustomAlertDialog(BuildContext context, String title, String message, String buttonText, VoidCallback onPressed, Color buttonTextColor) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: onPressed,
              child: Text(
                buttonText,
                style: TextStyle(color: buttonTextColor),
              ),
            ),
          ],
        );
      },
    );
  }
}
