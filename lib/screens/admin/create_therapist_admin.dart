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



class CreateTherapistAdminPage extends StatefulWidget{
  final LoginResponseModel userData;
  const CreateTherapistAdminPage({Key? key, required this.userData}) : super(key: key);

  @override
  _createTherapistAdminPageState createState() =>_createTherapistAdminPageState();
}

class _createTherapistAdminPageState extends State<CreateTherapistAdminPage>{
  static final GlobalKey<FormState> globalFormKey = GlobalKey<FormState>();
  bool isAPICallProcess =  false;
  String? selectedTherapist;
  String? selectedTherapistName;
  String? specialization;
  DateTime? hiringDate;
  String? aboutMe;
  late String userId;
  bool isHiringDateSet = false;
  List<UserModel> users = [];

  @override
  void initState(){
    super.initState();
    fetchTherapists();
    if(widget.userData != null && widget.userData.data != null){
      print("userData: ${widget.userData.data!.id}");
      userId = widget.userData.data!.id;
    }else {
      // Handle the case where userData or userData.data is null
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

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kSecondaryColor,
        title: Text("Create Therapist Profile"),
        centerTitle: true,
      ),
      body: ProgressHUD(
          child: Form(
            key: _createTherapistAdminPageState.globalFormKey,
            child: _createTherapistAdminUI(context),
          )
      ),
    );
  }

  Widget _createTherapistAdminUI(BuildContext context){
    return SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 10),
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
                            value: selectedTherapist,
                            isExpanded: true,
                            icon: Icon(Icons.arrow_drop_down, color: kSecondaryColor),
                            onChanged: (newValue) {
                              setState(() {
                                selectedTherapist = newValue!;
                                selectedTherapistName = users.firstWhere((user) => user.id == selectedTherapist).name;
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
                            value: specialization,
                            hint: const Text("Specialization", style: TextStyle(fontSize: 16)),
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
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime(1900),
                                  lastDate: DateTime.now(),
                                  builder: (BuildContext context, Widget? child) {
                                    return Theme(
                                      data: ThemeData(
                                        colorScheme: ColorScheme.light(
                                          primary: kSecondaryColor, // Set your desired color here
                                        ),
                                        buttonTheme: ButtonThemeData(
                                          textTheme: ButtonTextTheme.primary,
                                        ),
                                      ),
                                      child: child!,
                                    );
                                  },
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
                                  style: TextStyle(fontSize: 16, fontWeight: isHiringDateSet ? FontWeight.normal : FontWeight.bold,),
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
                        borderColor: Colors.grey,
                        fontSize: 16,
                      ),
                      SizedBox(width: 20),
                      FormHelper.submitButton(
                        "Save", (){
                        if(validateAndSave()){
                          setState(() {
                            isAPICallProcess = true;
                          });


                          TherapistModel model = TherapistModel(
                            specialization: specialization!,
                            hiringDate: Utils.formatDateTimeToString(hiringDate!),
                            aboutMe: aboutMe!,
                            therapistId: selectedTherapist!,
                            managedBy: widget.userData.data!.id
                          );

                          APIService.createTherapist(model).then((response) {
                            print(response);
                            setState(() {
                              isAPICallProcess = false;
                            });
                            if (response != null) {
                              FormHelper.showSimpleAlertDialog(
                                context, Config.appName,
                                "Therapist Profile created", "OK", () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        ViewTherapistAdminPage(
                                            userData: widget.userData),
                                  ),
                                );
                              },
                              );
                            } else {
                              FormHelper.showSimpleAlertDialog(
                                context,
                                Config.appName,
                                "Therapist profile failed to create",
                                "OK",
                                    () {
                                  Navigator.of(context).pop();
                                },
                              );
                            }
                          });

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

}
