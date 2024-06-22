import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';
import 'package:kidz_emporium/screens/home.dart';
import 'package:kidz_emporium/contants.dart';
import 'package:kidz_emporium/screens/register_page.dart';
import 'package:kidz_emporium/models/login_request_model.dart';
import 'package:kidz_emporium/models/login_response_model.dart';
import 'package:kidz_emporium/models/register_response_model.dart';
import 'package:kidz_emporium/services/api_service.dart';
import 'package:snippet_coder_utils/FormHelper.dart';

import '../config.dart';
import '../services/shared_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);
  //final RegisterResponseModel registerResponse;
  //inal RegisterResponseModel userData;

  @override
  _loginPageState createState() => _loginPageState();
}

class _loginPageState extends State<LoginPage>{
  bool isAPICallProcess =  false;
  bool hidePassword = true;
  static final GlobalKey<FormState> loginFormKey  = GlobalKey<FormState>();
  String? email;
  String? password;

  String? fcmToken;

  @override
  void initState() {
    super.initState();
    _initializeLoginStatus();
    _getFCMToken();
  }

  Future<void> _getFCMToken() async {
    String? token = await SharedService.getFCMToken();
    setState(() {
      fcmToken = token;
    });
  }


  Future<void> _initializeLoginStatus() async {
    if (await SharedService.isLoggedIn()) {
      // User is logged in, retrieve cached login details
      var cachedLoginDetails = await SharedService.loginDetails();

      // Now you can use 'cachedLoginDetails' to initialize the page or update the UI
      // based on the user's login status.
    }
  }



  @override
  Widget build(BuildContext context){
    return Scaffold(
        body: ProgressHUD(
          child: Form(
            key: loginFormKey ,
            child: _loginUI(context),
          ),
        ),
      );
  }
  Widget _loginUI(BuildContext context){
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 10),
            Center(
              child: Image.asset(
                "assets/images/logo-centre.png",
                //width: 150,
                height: 300,
                fit: BoxFit.fitWidth,
              ),
            ),
            SizedBox(height: 10),
            Center(
              child: Text("Welcome Back", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25,),
                ),
            ),
            const SizedBox(height: 10),
            Center(
              child: Text("Login", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20,),
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
                prefixIconColor: kSecondaryColor,
                showPrefixIcon: true,
                prefixIcon: Icon(Icons.email),
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
                prefixIconColor: kSecondaryColor,
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
                  "Sign In", (){
                    if(validateAndSave()){
                      setState(() {
                        isAPICallProcess = true;//API
                      });
                      LoginRequestModel model = LoginRequestModel(
                        email: email!,
                        password: password!,
                      );
                      APIService.login(model).then((response){
                        setState(() {
                          isAPICallProcess = false;//API
                        });

                        if(response){
                          _sendFCMTokenToBackend();
                          _showCustomAlertDialog(
                              context,
                              Config.appName,
                              "User Logged-In Successfully",
                              "OK",
                                  () async {
                                    Navigator.of(context).pop();
                                    var cachedLoginDetails = await SharedService.loginDetails();
                                    if(cachedLoginDetails.data?.role == "Parent"){
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => HomePage(userData: cachedLoginDetails),
                                        ),
                                      );
                                    }else if(cachedLoginDetails.data?.role == "Admin"){
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => AdminHomePage(userData: cachedLoginDetails),
                                        ),
                                      );
                                    }else{
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => TherapistHomePage(userData: cachedLoginDetails),
                                        ),
                                      );
                                    }
                                },kSecondaryColor,

                          );
                        }else{
                          _showCustomAlertDialog(
                            context,
                            Config.appName,
                            "Invalid Email/Password!",
                            "OK",
                                (){
                              Navigator.of(context).pop();
                            }, kSecondaryColor,
                          );
                        }
                      }
                      );
                    }
                  },
              btnColor: Colors.pink,
              txtColor: Colors.white,
              borderRadius: 10,
              borderColor: Colors.pink,
              fontSize: 16,
              ),
            ),
            Center(
              child: RichText(
                text: TextSpan(
                  children: <TextSpan>[
                    TextSpan(
                      text: "Dont have an account?",
                      style: TextStyle(
                        color: Colors.black, fontSize: 16,
                      ),
                    ),
                    TextSpan(
                      text: "Sign Up",
                      style: TextStyle(
                        color: Colors.orange,fontWeight: FontWeight.bold, fontSize: 16,
                      ),
                      recognizer: TapGestureRecognizer()..onTap = (){
                        Navigator.of(context).pushNamedAndRemoveUntil("/register", (route) => false,
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
  Future<void> _sendFCMTokenToBackend() async {
    String? token = await SharedService.getFCMToken();
    if (token != null) {
      try {
        await APIService.sendTokenToBackend(token, email!);
      } catch (error) {
        print('Error sending FCM token to backend: $error');
      }
    }
  }


  bool validateAndSave(){
    final form = loginFormKey.currentState;
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
