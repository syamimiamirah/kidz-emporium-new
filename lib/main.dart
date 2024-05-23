import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:kidz_emporium/Screens/home.dart';
import 'package:kidz_emporium/contants.dart';
import 'package:kidz_emporium/Screens/login_page.dart';
import 'package:kidz_emporium/Screens/register_page.dart';
import 'package:kidz_emporium/provider/user_provider.dart';
import 'package:provider/provider.dart';
import 'Screens/parent/create_reminder_parent.dart';
import 'Screens/parent/view_reminder_parent.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure that Flutter bindings are initialized
  await Firebase.initializeApp(); // Initialize Firebase
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
//This widget is the root of your application
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Kidz Emporium Therapy Management System',
      theme: ThemeData(
        primaryColor: kPrimaryColor,
        scaffoldBackgroundColor: kBackgroundColor,

      ),
      routes: {
        '/login': (context) => LoginPage(),
        '/register': (context) => RegisterPage(),
        //'/home': (context) => HomePage(userData: ,),
        //'/view_reminder_parent': (context) => ViewReminderParentPage(userData:widget.userData)),
        /*'/create_reminder_parent': (context) {
          final userProvider = Provider.of<UserProvider>(context, listen: false);
          final selectedDate = ModalRoute.of(context)?.settings.arguments as DateTime?;
          return CreateReminderParentPage(
            selectedDate: selectedDate, // Pass your selected date here
            userData: userProvider.userData,
          );
        },*/
      },
      home: WelcomeScreen(),
    );
  }
}
class WelcomeScreen extends StatelessWidget{
  @override
  Widget build(BuildContext context){
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 2,
            child: Container(decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/logo-centre.png"),
                fit: BoxFit.fitWidth,
              ),
            ),
            ),
          ),
          Expanded(
            child: Column(
                children: <Widget>[
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                        children: [
                          TextSpan(
                            text: "Welcome!\n",
                            style: TextStyle(color: Colors.black, fontSize: 25, fontWeight: FontWeight.bold,),
                          ),
                          TextSpan(
                            text: "Sign in or create a new account\n",
                            style: TextStyle(color: Colors.black, fontSize: 18),
                          ),
                        ],
                    ),
                  ),
          FittedBox(
            child: GestureDetector(
              onTap:() {Navigator.push(context, MaterialPageRoute(
              builder: (context) {
                return LoginPage();
              },
              ));
                },
              child: Container(
                margin: EdgeInsets.only(bottom: 5),
                padding: EdgeInsets.symmetric(horizontal: 26, vertical: 16),
                width: 350,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Colors.pink,
                ),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text("Go to", style: TextStyle(fontSize: 16, color: Colors.white), textAlign: TextAlign.right),
                      Text(" Sign In", style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold,), textAlign: TextAlign.right),
                    ]
                ),
              ),
            )
          ),

          FittedBox(
              child: GestureDetector(
                onTap:() {Navigator.push(context, MaterialPageRoute(
              builder: (context){
              return RegisterPage();
              },
                ));
                  },
                child: Container(
                  margin: EdgeInsets.only(bottom: 25),
                  padding: EdgeInsets.symmetric(horizontal: 26, vertical: 16),
                  width: 350,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Colors.orange,
                  ),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text("No account yet?", style: TextStyle(fontSize: 16)),
                        Text(" Sign Up", style: TextStyle(fontSize:16, fontWeight: FontWeight.bold,),
                        ),
                      ]
                  )
              ),
              ),
          ),
                ],
            ),

          ),
        ],
      )
    );
  }
}
