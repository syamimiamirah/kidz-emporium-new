import 'dart:convert';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';
import 'package:kidz_emporium/Screens/home.dart';
import 'package:kidz_emporium/contants.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:kidz_emporium/screens/login_page.dart';
import 'package:http/http.dart' as http;
import 'package:kidz_emporium/models/register_request_model.dart';
import 'package:kidz_emporium/services/api_service.dart';
import 'package:snippet_coder_utils/FormHelper.dart';

import '../config.dart';

class RegisterPage extends StatefulWidget{
  const RegisterPage({Key? key}) : super(key: key);

  @override
  _registerPageState createState() => _registerPageState();
}

class _registerPageState extends State<RegisterPage> {

  bool isAPICallProcess = false;
  bool hidePassword = true;
  static final GlobalKey<FormState> globalFormKey = GlobalKey<FormState>();
  String? name;
  String? email;
  String? password;
  String? phone;
  String? currentRole;
  //var typeOfRole = ["Admin", "Parent", "Therapist"];
  //var currentRole = "Admin";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: ProgressHUD(
          child: Form(
            key: globalFormKey,
            child: _registerUI(context),
          ),
          //inAsyncCall: isAPICallProcess, // Use this property to control the progress indicator
        ),
      );
  }

  Widget _registerUI(BuildContext context){
    return SingleChildScrollView(
      child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          SizedBox(height: 10),
      Center(
        child: Image.asset(
          "assets/images/logo-centre.png", height: 200,
          fit: BoxFit.fitWidth,
        ),
      ),
      SizedBox(height: 10),
      Center(
        child: Text("Create a New Account", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25,),
        ),
      ),
      const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child:
              FormHelper.inputFieldWidget(
                context,
                "name", "Name",
                    (onValidateVal){
                  if(onValidateVal.isEmpty){
                    return "Name can't be empty";
                  }
                  return null;
                },
                    (onSavedVal){
                  name = onSavedVal.toString().trim();
                },
                prefixIconColor: kPrimaryColor,
                showPrefixIcon: true,
                prefixIcon: const Icon(Icons.person),
                borderRadius: 10,
                borderColor: Colors.grey,
                contentPadding: 15,
                fontSize: 16,
                prefixIconPaddingLeft: 10,
                hintFontSize: 16,
              ),
            ),

            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: FormHelper.inputFieldWidget(
                context,
                "email", "Email",
                    (onValidateVal){
                  if(onValidateVal.isEmpty){
                    return "Email can't be empty";
                  }
                  bool emailValid = RegExp(
                      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9+\.[a-zA-Z]+")
                      .hasMatch(onValidateVal);
                  if(!emailValid){
                    return "Invalid Email";
                  }
                  return null;
                },
                    (onSavedVal){
                  email = onSavedVal.toString().trim();
                },
                prefixIconColor: kPrimaryColor,
                showPrefixIcon: true,
                prefixIcon: const Icon(Icons.email),
                borderRadius: 10,
                borderColor: Colors.grey,
                contentPadding: 15,
                fontSize: 16,
                prefixIconPaddingLeft: 10,
                hintFontSize: 16,
              ),
            ),

            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child:
              FormHelper.inputFieldWidget(
                context,
                "phone", "Phone",
                    (onValidateVal){
                  if(onValidateVal.isEmpty){
                    return "Phone can't be empty";
                  }
                  return null;
                },
                    (onSavedVal){
                  phone = onSavedVal.toString().trim();
                },
                prefixIconColor: kPrimaryColor,
                showPrefixIcon: true,
                prefixIcon: const Icon(Icons.phone),
                borderRadius: 10,
                borderColor: Colors.grey,
                contentPadding: 15,
                fontSize: 16,
                prefixIconPaddingLeft: 10,
                hintFontSize: 16,
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
                        Icons.people, // Your desired icon
                        color: kPrimaryColor, // Icon color
                      ),
                    ),
                Expanded(
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: currentRole,
                      hint: const Text("Role",style: TextStyle(fontSize: 16,)),
                      items: [
                        DropdownMenuItem<String>(
                          value: null,
                          child: Text("Role",style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),),
                        ),
                        // Other role options
                        DropdownMenuItem<String>(
                          value: "Admin",
                          child: Text("Admin",style: TextStyle(fontSize: 16,),),
                        ),
                        DropdownMenuItem<String>(
                          value: "Parent",
                          child: Text("Parent",style: TextStyle(fontSize: 16,),),
                        ),
                        DropdownMenuItem<String>(
                          value: "Therapist",
                          child: Text("Therapist",style: TextStyle(fontSize: 16,),),
                        ),
                      ],// The first item is the hint, set its value to null
                      isExpanded: true,
                      icon: Icon(Icons.arrow_drop_down, color: kPrimaryColor),
                      onChanged: (String? newValue){
                        //Your code to execute, when a menu item is selected from dropdown
                        //dropDownStringItem = value;
                        setState(() {
                          this.currentRole = newValue!;
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
    //Role

            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(top: 0),
              child: FormHelper.inputFieldWidget(
                context,
                "password", "Password",
                    (onValidateVal){
                  if(onValidateVal.isEmpty){
                    return "Password can't be empty";
                  }
                  return null;
                },
                    (onSavedVal){
                  password = onSavedVal;
                },
                prefixIconColor: kPrimaryColor,
                showPrefixIcon: true,
                prefixIcon: Icon(Icons.lock),
                borderRadius: 10,
                borderColor: Colors.grey,
                contentPadding: 15,
                fontSize: 16,
                prefixIconPaddingLeft: 10,
                obscureText: hidePassword,
                hintFontSize: 16,
                suffixIcon: IconButton(
                    onPressed: (){
                      hidePassword = !hidePassword;
                    },
                    color: Colors.white,
                    icon: Icon(hidePassword ? Icons.visibility_off : Icons.visibility)
                ),
              ),
            ),
            const SizedBox(height: 10),
            Center(
              child: FormHelper.submitButton(
                "Sign Up", (){
                if(validateAndSave()){
                  if (currentRole == null) {
                    // Show an error message that the user must choose a role
                    Fluttertoast.showToast(
                      msg: 'Please choose a role',
                      backgroundColor: Colors.red,
                      textColor: Colors.white,
                      toastLength: Toast.LENGTH_SHORT,
                    );
                  } else {
                    setState(() {
                      isAPICallProcess = true;//API
                    });
                    //ProgressHUD.of(context)?.showWithText('Loading...');
                    //APIService.register(RegisterRequestModel(name: name, email: email, password: password, phone: phone, role: role))
                    RegisterRequestModel model = RegisterRequestModel(
                      name: name!,
                      email: email!,
                      password: password!,
                      phone: phone!,
                      role: currentRole!,
                    );

                    APIService.register(model).then((response){
                      setState(() {
                        isAPICallProcess = false;//API
                      });

                      if(response != null){
                        _showCustomAlertDialog(
                          context,
                          Config.appName,
                          "Registration Successful. Please login to the account.",
                          "OK", (){
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LoginPage(),
                            ),
                          );
                          }, kPrimaryColor,
                        );
                      }else{
                        _showCustomAlertDialog(
                          context,
                          Config.appName,
                          "This Email already registered",
                          "OK",(){
                          Navigator.of(context).pop();
                          }, kPrimaryColor,
                        );
                      }
                    },
                    );// Proceed with your API call
                  }
                }
              },
                btnColor: Colors.orange,
                txtColor: Colors.black,
                fontSize: 16,
                borderRadius: 10,
                borderColor: Colors.orange,
              ),
            ),
            Center(
              child: RichText(
                text: TextSpan(
                  children: <TextSpan>[
                    TextSpan(
                      text: "Already have an account?",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                      ),
                    ),
                    TextSpan(
                      text: "Sign In",
                      style: TextStyle(
                        color: Colors.pink,
                        fontWeight: FontWeight.bold,fontSize: 16,
                      ),
                      recognizer: TapGestureRecognizer()..onTap = (){
                        Navigator.of(context).pushNamedAndRemoveUntil("/login", (route) => false,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
      ]
      ),
    );
  }
  bool validateAndSave(){
    final form = globalFormKey.currentState;
    if(form!.validate()){
      form.save();
      return true;
    }else{
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
