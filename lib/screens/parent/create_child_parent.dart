import 'package:flutter/material.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';
import 'package:kidz_emporium/Screens/parent/view_child_parent.dart';
import 'package:kidz_emporium/Screens/parent/view_reminder_parent.dart';
import 'package:kidz_emporium/contants.dart';
import 'package:kidz_emporium/models/child_model.dart';
import 'package:kidz_emporium/models/login_response_model.dart';
import 'package:kidz_emporium/services/api_service.dart';
import 'package:snippet_coder_utils/FormHelper.dart';

import '../../config.dart';
import '../../utils.dart';


class CreateChildParentPage extends StatefulWidget{
  final LoginResponseModel userData;

  const CreateChildParentPage({Key? key, required this.userData}): super(key: key);
  @override
  _createChildParentPageState createState() => _createChildParentPageState();
}

class _createChildParentPageState extends State<CreateChildParentPage>{
  static final GlobalKey<FormState> globalFormKey = GlobalKey<FormState>();
  bool isAPICallProcess =  false;
  String? childName;
  DateTime? birthDate;
  String? gender;
  String? program;
  late String userId;
  bool isBirthDateSet = false;

  @override
  void initState(){
    super.initState();
    if(widget.userData != null && widget.userData.data != null){
      print("userData: ${widget.userData.data!.id}");
      userId = widget.userData.data!.id;
    }else {
      // Handle the case where userData or userData.data is null
      print("Error: userData or userData.data is null");
    }
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kSecondaryColor,
        title: Text("Create Child Profile"),
        centerTitle: true,
      ),
      body: ProgressHUD(
        child: Form(
          key: _createChildParentPageState.globalFormKey,
          child: _createChildParentUI(context),
        )
      ),
    );
  }


  Widget _createChildParentUI(BuildContext context){
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
              prefixIconColor: kSecondaryColor,
              showPrefixIcon: true,
              prefixIcon: const Icon(Icons.child_care),
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
                            style: TextStyle(fontSize: 16, fontWeight: isBirthDateSet ? FontWeight.normal : FontWeight.bold,),
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
                        value: gender,
                        hint: const Text("Gender", style: TextStyle(fontSize: 16)),
                        items: [
                          DropdownMenuItem<String>(
                            value: null,
                            child: Text("Gender",style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold)),
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
                        onChanged: (String? newValue){
                          //Your code to execute, when a menu item is selected from dropdown
                          //dropDownStringItem = value;
                          setState(() {
                            this.gender = newValue!;
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
                        value: program,
                        hint: const Text("Program", style: TextStyle(fontSize: 16)),
                        items: [
                          DropdownMenuItem<String>(
                            value: null,
                            child: Text("Program",style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold)),
                          ),
                          DropdownMenuItem<String>(
                            value: "No program yet",
                            child: Text("No program yet",style: TextStyle(fontSize: 16)),
                          ),
                          // Other role options
                          // DropdownMenuItem<String>(
                          //   value: "Early Intervention Program (EIP)",
                          //   child: Text("Early Intervention Program (EIP)",style: TextStyle(fontSize: 16)),
                          // ),
                          // DropdownMenuItem<String>(
                          //   value: "Special Education Program (SPED)",
                          //   child: Text("Special Education Program (SPED)",style: TextStyle(fontSize: 16)),
                          // ),
                          // DropdownMenuItem<String>(
                          //   value: "Special Clinic",
                          //   child: Text("Special Clinic",style: TextStyle(fontSize: 16)),
                          // ),
                        ],// The first item is the hint, set its value to null
                        isExpanded: true,
                        icon: Icon(Icons.arrow_drop_down, color: kPrimaryColor),
                        onChanged: (String? newValue){
                          //Your code to execute, when a menu item is selected from dropdown
                          //dropDownStringItem = value;
                          setState(() {
                            this.program = newValue!;
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
                      "Save", (){
                        if(validateAndSave()){
                          setState(() {
                            isAPICallProcess = true;
                          });
                          ChildModel model = ChildModel(
                              childName: childName!,
                              birthDate: Utils.formatDateTimeToString(birthDate!),
                              gender: gender!,
                              program: program!,
                              userId: userId,
                          );

                          APIService.createChild(model).then((response){
                            print(response);
                            setState(() {
                              isAPICallProcess = false;
                            });

                            if(response != null){
                              FormHelper.showSimpleAlertDialog(context, Config.appName, "Child Profile created", "OK", () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ViewChildParentPage(userData: widget.userData),
                                  ),
                                );
                              },
                              );
                            }else{
                              FormHelper.showSimpleAlertDialog(
                                context,
                                Config.appName,
                                "Child profile failed to create",
                                "OK",
                                  () {
                                    Navigator.of(context).pop();
                                  },
                                );
                              }
                            });
                        }
                    },
                      btnColor: kSecondaryColor,
                      txtColor: Colors.white,
                      borderRadius: 10,
                      borderColor: kSecondaryColor,
                      fontSize: 16,
                    ),
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

}

