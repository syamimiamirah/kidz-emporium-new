import 'package:flutter/material.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';
import 'package:kidz_emporium/screens/parent/view_child_parent.dart';
import 'package:kidz_emporium/screens/parent/view_reminder_parent.dart';
import 'package:kidz_emporium/contants.dart';
import 'package:kidz_emporium/models/child_model.dart';
import 'package:kidz_emporium/models/login_response_model.dart';
import 'package:kidz_emporium/services/api_service.dart';
import 'package:snippet_coder_utils/FormHelper.dart';

import '../../config.dart';
import '../../utils.dart';


class UpdateChildParentPage extends StatefulWidget{
  final LoginResponseModel userData;
  final String childId;

  const UpdateChildParentPage({Key? key, required this.userData,  required this.childId}): super(key: key);
  @override
  _updateChildParentPageState createState() => _updateChildParentPageState();
}

class _updateChildParentPageState extends State<UpdateChildParentPage>{
  static final GlobalKey<FormState> globalFormKey = GlobalKey<FormState>();
  bool isAPICallProcess =  false;
  String childName = "";
  late DateTime birthDate = DateTime.now();
  late String gender = "";
  late String program= "";
  late String userId;
  bool isBirthDateSet = false;

  //late TextEditingController childNameController;

  @override
  void initState(){
    super.initState();
    if(widget.userData != null && widget.userData.data != null){
      print("userData: ${widget.userData.data!.id}");
      userId = widget.userData.data!.id;
      fetchChildDetails();
    }else {
      // Handle the case where userData or userData.data is null
      print("Error: userData or userData.data is null");
    }
  }
  Future<void> fetchChildDetails() async {
    try {
      ChildModel? child = await APIService.getChildDetails(widget.childId);

      if (child != null) {
        // Update UI with fetched reminder details
        setState(() {
          childName = child.childName;
          birthDate = Utils.parseStringToDateTime(child.birthDate);
          gender = child.gender;
          program = child.program;
          // Update other fields as needed
        });
      } else {
        // Handle case where reminder is null
        print('Child details not found');
      }
    } catch (error) {
      print('Error fetching child details: $error');
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kSecondaryColor,
        title: Text("Update Child Profile"),
        centerTitle: true,
      ),
      body: ProgressHUD(
          child: Form(
            key: _updateChildParentPageState.globalFormKey,
            child: _updateChildParentUI(context),
          )
      ),
    );
  }


  Widget _updateChildParentUI(BuildContext context){
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 10),
          Padding(padding: const EdgeInsets.only(top: 10),
            child: FormHelper.inputFieldWidget(context, "child_name", "Child's Name", (onValidateVal){
              if(onValidateVal.isEmpty){
                return "Child's Name can't be empty";
              }
              return null;
            }, (onSavedVal){
              childName = onSavedVal.toString().trim();
            },
              initialValue: childName,
              prefixIconColor: kSecondaryColor,
              showPrefixIcon: true,
              prefixIcon: const Icon(Icons.event_note),
              borderRadius: 10,
              borderColor: Colors.grey,
              contentPadding: 15,
              fontSize: 16,
              prefixIconPaddingLeft: 10,
              hintFontSize: 16,
            ),
          ),
          const SizedBox(height: 10),
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
                                initialDate: birthDate,
                                firstDate: DateTime(1900),
                                lastDate: DateTime.now(),
                              ).then((selectedDate){
                                if(selectedDate != null && selectedDate != birthDate){
                                  setState(() {
                                    birthDate = selectedDate;
                                    isBirthDateSet = true;
                                  });
                                }
                              });
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 15),
                              child: Text(
                                birthDate != null
                                    ? "${birthDate!.toLocal()}".split(' ')[0]
                                    : 'Birth Date',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: birthDate != null ? FontWeight.normal : FontWeight.bold,
                                ),
                              ),

                            ),
                          ),
                        ),
                      ]
                  ),
                ),
              )
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
                        Icons.transgender, // Your desired icon
                        color: kSecondaryColor, // Icon color
                      ),
                    ),
                    Expanded(
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: gender.isNotEmpty ? gender : null,
                          hint: const Text("Gender", style: TextStyle(fontSize: 16)),
                          items: const [
                            DropdownMenuItem<String>(
                              value: null,
                              child: Text("Gender",style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),),
                            ),
                            // Other role options
                            DropdownMenuItem<String>(
                              value: "Male",
                              child: Text("Male",style: TextStyle(fontSize: 16)),
                            ),
                            DropdownMenuItem<String>(
                              value: "Female",
                              child: Text("Female",style: TextStyle(fontSize: 16)),
                            )
                          ],// The first item is the hint, set its value to null
                          isExpanded: true,
                          icon: Icon(Icons.arrow_drop_down, color: kPrimaryColor),
                          onChanged: (String? newValue) {
                            setState(() {
                              this.gender = newValue!; // Ensure a non-null value
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
                          value: program.isNotEmpty ? program : null,
                          hint: const Text("Program", style: TextStyle(fontSize: 16)),
                          items: const [
                            DropdownMenuItem<String>(
                              value: null,
                              child: Text("Program",style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),),
                            ),
                            DropdownMenuItem<String>(
                              value: "Occupational Therapy (OT)",
                              child: Text("Occupational Therapy (OT)",style: TextStyle(fontSize: 16,),),
                            ),
                            DropdownMenuItem<String>(
                              value: "Special Education (SPED)",
                              child: Text("Special Education (SPED)",style: TextStyle(fontSize: 16,),),
                            ),
                            DropdownMenuItem<String>(
                              value: "Special Therapy (ST)",
                              child: Text("Special Therapy (ST)",style: TextStyle(fontSize: 16,),),
                            ),
                            DropdownMenuItem<String>(
                              value: "Clinical Psychology (PSY)",
                              child: Text("Clinical Psychology (PSY)",style: TextStyle(fontSize: 16,),),
                            ),
                            DropdownMenuItem<String>(
                              value: "Big Ones Playgroup",
                              child: Text("Big Ones Playgroup",style: TextStyle(fontSize: 16,),),
                            ),
                            DropdownMenuItem<String>(
                              value: "Small Ones Playgroup",
                              child: Text("Small Ones Playgroup",style: TextStyle(fontSize: 16,),),
                            ),
                            DropdownMenuItem<String>(
                              value: "No program yet",
                              child: Text("No program yet",style: TextStyle(fontSize: 16,),),
                            ),
                          ],// The first item is the hint, set its value to null
                          isExpanded: true,
                          icon: Icon(Icons.arrow_drop_down, color: kPrimaryColor),
                          onChanged: (String? newValue) {
                            setState(() {
                              this.program = newValue!; // Ensure a non-null value
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
          const SizedBox(height: 10),
          Center(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FormHelper.submitButton("Cancel", (){
                        Navigator.pushReplacement(context, MaterialPageRoute(
                            builder: (context) =>  ViewChildParentPage(userData:widget.userData)),
                        );
                      },
                        btnColor: Colors.grey,
                        txtColor: Colors.black,
                        borderRadius: 10,
                        borderColor: Colors.grey,
                        fontSize: 16,
                      ),
                      SizedBox(width: 20),
                      FormHelper.submitButton(
                        "Save", () async {
                        if(validateAndSave()){
                          setState((){
                            isAPICallProcess = true; //API
                          });
                          ChildModel updatedModel = ChildModel(
                            childName: childName!,
                            birthDate: Utils.formatDateTimeToString(birthDate),
                            gender: gender,
                            program: program,
                            userId: userId,
                          );
                          print(widget.childId);
                          bool success = await APIService.updateChild(widget.childId, updatedModel);
                          setState(() {
                            isAPICallProcess = false;
                          });

                          if (success) {
                            _showCustomAlertDialog(
                              context,
                              Config.appName,
                              "Child profile updated",
                              "OK",
                                  () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ViewChildParentPage(userData: widget.userData),
                                  ),
                                );
                              }, kPrimaryColor,
                            );
                          }
                          else {
                            _showCustomAlertDialog(
                              context,
                              Config.appName,
                              "Failed to update child profile",
                              "OK",
                                  () {
                                Navigator.of(context).pop();
                              }, kPrimaryColor,
                            );
                          }
                        }
                      },
                        fontSize: 16,
                        btnColor: Colors.pink,
                        txtColor: Colors.white,
                        borderRadius: 10,
                        borderColor: Colors.pink,),
                    ],
                  )
                ],
              )
          )
        ],
      ),
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

