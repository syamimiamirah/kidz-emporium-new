import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:kidz_emporium/Screens/admin/view_therapist_admin.dart';
import 'package:kidz_emporium/Screens/admin/view_youtube_admin.dart';
import 'package:kidz_emporium/Screens/login_page.dart';
import 'package:kidz_emporium/Screens/parent/create_booking_parent.dart';
import 'package:kidz_emporium/Screens/parent/create_child_parent.dart';
import 'package:kidz_emporium/Screens/parent/details_booking_parent.dart';
import 'package:kidz_emporium/Screens/parent/view_booking_parent.dart';
import 'package:kidz_emporium/Screens/parent/view_child_parent.dart';
import 'package:kidz_emporium/Screens/parent/view_reminder_parent.dart';
import 'package:kidz_emporium/Screens/parent/view_report_parent.dart';
import 'package:kidz_emporium/Screens/parent/view_therapist_parent.dart';
import 'package:kidz_emporium/Screens/therapist/create_video_therapist.dart';
import 'package:kidz_emporium/Screens/therapist/details_booking_therapist.dart';
import 'package:kidz_emporium/Screens/therapist/view_booking_therapist.dart';
import 'package:kidz_emporium/Screens/therapist/view_child_therapist.dart';
import 'package:kidz_emporium/Screens/therapist/view_report_therapist.dart';
import 'package:kidz_emporium/Screens/therapist/view_task_therapist.dart';
import 'package:kidz_emporium/Screens/therapist/view_therapist.dart';
import 'package:kidz_emporium/Screens/therapist/view_video_therapist.dart';
import 'package:kidz_emporium/contants.dart';
import 'package:kidz_emporium/Screens/login_page.dart';
import 'package:kidz_emporium/components/side_menu.dart';
import 'package:kidz_emporium/models/login_response_model.dart';
import 'package:kidz_emporium/models/user_model.dart';
import 'package:kidz_emporium/screens/parent/view_chat_parent.dart';
import 'package:kidz_emporium/screens/parent/view_notification_parent.dart';
import 'package:kidz_emporium/screens/parent/view_video_parent.dart';
import 'package:kidz_emporium/services/local_notification.dart';
import '../config.dart';
import '../main.dart';
import '../models/booking_model.dart';
import '../models/child_model.dart';
import '../models/therapist_model.dart';
import '../services/api_service.dart';
import '../services/shared_service.dart';
import 'admin/create_task_admin.dart';
import 'admin/create_therapist_admin.dart';
import 'admin/details_booking_admin.dart';
import 'admin/view_booking_admin.dart';
import 'admin/view_task_admin.dart';

class HomePage extends StatefulWidget {
  final LoginResponseModel userData;
  const HomePage({Key? key, required this.userData}) : super(key: key);

  @override
  _homePageState createState() =>_homePageState();
}

class _homePageState extends State<HomePage>{
  //Creating static data in lists
  List catNames = [
    "Booking",
    "Therapist",
    "Report",
    "Video",
    "Calendar",
    "Child"
  ];

  List<Color> catColors= [
    kPrimaryColor,
    kSecondaryColor,
    kPrimaryColor,
    kSecondaryColor,
    kPrimaryColor,
    kSecondaryColor,
  ];

  List<Icon> catIcons = [
    Icon(Icons.library_books, color: Colors.white, size: 30),
    Icon(Icons.people, color: Colors.white, size: 30),
    Icon(Icons.event_note, color: Colors.white, size: 30),
    Icon(Icons.video_library, color: Colors.white, size: 30),
    Icon(Icons.calendar_month, color: Colors.white, size: 30),
    Icon(Icons.child_care, color: Colors.white, size: 30),
  ];
  List bookingList = [
    'Booking 1', 'Booking 2', 'Booking 3', 'Booking 4'
  ];

  List<BookingModel> bookings = [];
  List<ChildModel> children = [];
  List<TherapistModel> therapists = [];
  List<UserModel> users = []; // Add a list to store user details

  @override
  void initState() {
    listenToNotification();
    super.initState();
    _loadData(widget.userData.data!.id);
  }
listenToNotification(){
    print("listening to notification");
    LocalNotification.onClickNotification.stream.listen((event){
       Navigator.push(context, MaterialPageRoute(builder: (context)=> NotificationDetailsPage(payload: event,)));
    });
}

  Future<void> _loadData(String userId) async {
    try {
      // Use Future.wait to wait for all API calls to complete
      await Future.wait([
        _loadBooking(userId),
        _loadChildren(userId),
        _loadTherapists(userId),
        _loadUsers(), // Fetch user details
      ]);
    } catch (error) {
      print('Error loading data: $error');
    }
  }

  // Fetch user details
  Future<void> _loadUsers() async {
    try {
      List<UserModel> loadedUsers = await APIService.getAllUsers();
      setState(() {
        users = loadedUsers;
      });
    } catch (error) {
      print('Error loading users: $error');
    }
  }

  Future<void> _loadBooking(String userId) async {
    try {
      List<BookingModel> loadedBooking = await APIService.getBooking(widget.userData.data!.id);
      setState(() {
        bookings = loadedBooking;
      });
    } catch (error) {
      print('Error loading bookings: $error');
    }
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

  Future<void> _loadTherapists(String userId) async {
    try {
      List<TherapistModel> loadedTherapists = await APIService.getAllTherapists();
      setState(() {
        therapists = loadedTherapists;
      });
    } catch (error) {
      print('Error loading therapists: $error');
    }
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      drawer: NavBar(userData: widget.userData),
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        title: Text("Parent Home Page"),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil("/login", (route) => false,
            )
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
          context, MaterialPageRoute(builder: (context) => FAQPage())
        );
        },
        child: Icon(Icons.chat, color: Colors.white),
        backgroundColor: kPrimaryColor,
      ),
      body: ListView(
        children: [
          Container(
            padding: EdgeInsets.only(top: 15, left: 15, right: 15, bottom: 10),
            decoration: BoxDecoration(
              color: kPrimaryColor,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                SizedBox(height: 10),
                Padding(
                  padding: EdgeInsets.only(left: 3, bottom: 15),
                  child: Row(
                    children: <Widget>[
                      Text("Hi, ${widget.userData.data?.name ?? 'User'}!", style: TextStyle(fontSize: 25,color: Colors.white, decoration: TextDecoration.none)),
                    ],
                  ),
                )
              ],
            )
          ),
          Padding(padding: EdgeInsets.only(top: 20, left: 15, right: 15),
          child: Column(
            children: [
              GridView.builder(
                itemCount: catNames.length,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                childAspectRatio: 1.1,
                ),
                itemBuilder: (context, index){
                  return InkWell( // Wrap the container with InkWell for clickability
                      onTap: () async {
                    // Handle the click event for the calendar
                   List<TherapistModel> therapists = await APIService.getAllTherapists();
                   List<UserModel> users = await APIService.getAllUsers();
                    if (catNames[index] == "Booking") {
                      // Add your code here to navigate or perform an action
                      // when the calendar is clicked
                      print("Booking clicked!");
                      Navigator.push(context, MaterialPageRoute(
                          builder: (context) =>  ViewBookingParentPage(userData:widget.userData)),
                      );
                    }

                    if (catNames[index] == "Therapist") {
                      // Add your code here to navigate or perform an action
                      // when the calendar is clicked
                      print("Therapist clicked!");
                      Navigator.push(context, MaterialPageRoute(
                          builder: (context) => ViewTherapistParentPage(userData:widget.userData, therapists: therapists, users: users,)),//CreateTherapist()),
                      );
                    }
                    if (catNames[index] == "Report") {
                      // Add your code here to navigate or perform an action
                      // when the calendar is clicked
                      print("Report clicked!");
                      Navigator.push(context, MaterialPageRoute(
                          builder: (context) =>  ViewReportParentPage(userData:widget.userData)),
                      );
                    }
                    if (catNames[index] == "Video") {
                      // Add your code here to navigate or perform an action
                      // when the calendar is clicked
                      print("Video clicked!");
                      Navigator.push(context, MaterialPageRoute(
                          builder: (context) =>  ViewVideoParentPage(userData:widget.userData)),
                      );
                    }
                    if (catNames[index] == "Calendar") {
                      // Add your code here to navigate or perform an action
                      // when the calendar is clicked
                      print("Calendar clicked!");
                      Navigator.push(context, MaterialPageRoute(
                          builder: (context) =>  ViewReminderParentPage(userData:widget.userData)),
                      );
                    }
                    if (catNames[index] == "Child") {
                      // Add your code here to navigate or perform an action
                      // when the calendar is clicked
                      print("Child clicked!");
                      Navigator.push(context, MaterialPageRoute(
                          builder: (context) => ViewChildParentPage(userData:widget.userData)),
                      );
                    }
                  },
                  child: Column(
                    children: [
                      Container(
                        height: 60,
                        width: 60,
                        decoration: BoxDecoration(
                          color: catColors[index],
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: catIcons[index],),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        catNames[index], style: TextStyle(fontSize: 16,color: Colors.black.withOpacity(0.6),
                      ),
                      ),
                    ],
                  ),
                  );
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "My Booking",
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(
                          builder: (context) => ViewBookingParentPage(userData:widget.userData)),
                      );
                    },
                    child: Text(
                      "See All",
                      style: TextStyle(
                        fontSize: 18,
                        color: kSecondaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                ],
              ),
              SizedBox(
                height: 10,
              ),
              GridView.builder(
                itemCount: bookings.length,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                ),
                itemBuilder: (context, index){
                  return InkWell(
                    onTap: () async {
                      try {
                        // Retrieve the booking
                        BookingModel booking = bookings[index];

                        // Retrieve the therapist corresponding to the booking
                        TherapistModel therapist = therapists.firstWhere(
                              (therapist) => therapist.id == booking.therapistId,
                          orElse: () => TherapistModel(
                            specialization: 'Unknown',
                            hiringDate: '',
                            aboutMe: '',
                            therapistId: '',
                            managedBy: '',
                          ),
                        );

                        // Retrieve the child corresponding to the booking
                        ChildModel child = children.firstWhere(
                              (child) => child.id == booking.childId,
                          orElse: () => ChildModel(
                            childName: 'Unknown',
                            birthDate: '',
                            gender: '',
                            program: '',
                            userId: '',
                          ),
                        );

                        // Retrieve the user details of the therapist
                        UserModel therapistUser = users.firstWhere(
                              (user) => user.id == booking.therapistId,
                          orElse: () => UserModel(
                            id: '',
                            name: 'Unknown',
                            email: '',
                            password: '',
                            phone: '',
                            role: 'Therapist',
                          ),
                        );

                        // Navigate to BookingDetailsPage with retrieved data
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BookingDetailsAdminPage(
                              userData: widget.userData,
                              booking: booking,
                              therapist: therapist,
                              child: child,
                              therapistUser: therapistUser,
                            ),
                          ),
                        );
                      } catch (error) {
                        print('Error navigating to BookingDetailsPage: $error');
                        // Handle error gracefully, e.g., show a snackbar or display an error message
                      }
                    },

                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: kSecondaryColor.withOpacity(0.2),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Padding(padding: EdgeInsets.all(10),
                            child: Icon(Icons.person, size: 50),
                            ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            bookings[index].service,
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            "On ${DateFormat('dd-MM-yyyy').format(
                          DateTime.parse(bookings[index].fromDate))}" ,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          )
        ],
      ),
    );
  }
}

//Admin Home Page
class AdminHomePage extends StatefulWidget {
  final LoginResponseModel userData;
  const AdminHomePage({Key? key, required this.userData}) : super(key: key);

  @override
  _adminHomePageState createState() =>_adminHomePageState();
}

class _adminHomePageState extends State<AdminHomePage>{
  List catNames = [
    "Booking",
    "Therapist",
    "Report",
    "Video",
    "Task",
    "Child"
  ];

  List<Color> catColors= [
    kPrimaryColor,
    kSecondaryColor,
    kPrimaryColor,
    kSecondaryColor,
    kPrimaryColor,
    kSecondaryColor,
  ];

  List<Icon> catIcons = [
    Icon(Icons.library_books, color: Colors.white, size: 30),
    Icon(Icons.people, color: Colors.white, size: 30),
    Icon(Icons.event_note, color: Colors.white, size: 30),
    Icon(Icons.video_library, color: Colors.white, size: 30),
    Icon(Icons.calendar_month, color: Colors.white, size: 30),
    Icon(Icons.child_care, color: Colors.white, size: 30),
  ];
  List bookingList = [
    'Booking 1', 'Booking 2', 'Booking 3', 'Booking 4'
  ];
  List<BookingModel> bookings = [];
  List<ChildModel> children = [];
  List<TherapistModel> therapists = [];
  List<UserModel> users = []; // Add a list to store user details

  @override
  void initState() {
    super.initState();
    _loadData(widget.userData.data!.id);
  }


  Future<void> _loadData(String userId) async {
    try {
      // Use Future.wait to wait for all API calls to complete
      await Future.wait([
        _loadBooking(userId),
        _loadChildren(userId),
        _loadTherapists(userId),
        _loadUsers(), // Fetch user details
      ]);
    } catch (error) {
      print('Error loading data: $error');
    }
  }

  // Fetch user details
  Future<void> _loadUsers() async {
    try {
      List<UserModel> loadedUsers = await APIService.getAllUsers();
      setState(() {
        users = loadedUsers;
      });
    } catch (error) {
      print('Error loading users: $error');
    }
  }

  Future<void> _loadBooking(String userId) async {
    try {
      List<BookingModel> loadedBooking = await APIService.getAllBookings();
      setState(() {
        bookings = loadedBooking;
      });
    } catch (error) {
      print('Error loading bookings: $error');
    }
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

  Future<void> _loadTherapists(String userId) async {
    try {
      List<TherapistModel> loadedTherapists = await APIService.getAllTherapists();
      setState(() {
        therapists = loadedTherapists;
      });
    } catch (error) {
      print('Error loading therapists: $error');
    }
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      drawer: AdminNavBar(userData: widget.userData),
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        title: Text("Admin Home Page"),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.logout),
              onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil("/login", (route) => false,
              )
          ),
        ],
      ),
      body: ListView(
        children: [
          Container(
              padding: EdgeInsets.only(top: 15, left: 15, right: 15, bottom: 10),
              decoration: BoxDecoration(
                color: kPrimaryColor,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  SizedBox(height: 10),
                  Padding(
                    padding: EdgeInsets.only(left: 3, bottom: 15),
                    child: Row(
                      children: <Widget>[
                        Text("Hi, ${widget.userData.data?.name ?? 'User'}!", style: TextStyle(fontSize: 25,color: Colors.white, decoration: TextDecoration.none)),
                      ],
                    ),
                  )
                ],
              )
          ),
          Padding(padding: EdgeInsets.only(top: 20, left: 15, right: 15),
            child: Column(
              children: [
                GridView.builder(
                  itemCount: catNames.length,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 1.1,
                  ),
                  itemBuilder: (context, index){
                    return InkWell( // Wrap the container with InkWell for clickability
                      onTap: () {
                        // Handle the click event for the calendar
                        if (catNames[index] == "Booking") {
                          // Add your code here to navigate or perform an action
                          // when the calendar is clicked
                          print("Booking clicked!");
                          Navigator.push(context, MaterialPageRoute(
                              builder: (context) =>  ViewBookingAdminPage(userData:widget.userData)),
                          );
                        }
                        if (catNames[index] == "Therapist") {
                          // Add your code here to navigate or perform an action
                          // when the calendar is clicked
                          print("Therapist clicked!");
                          Navigator.push(context, MaterialPageRoute(
                              builder: (context) => ViewTherapistAdminPage(userData:widget.userData)),//CreateTherapist()),
                          );
                        }
                        if (catNames[index] == "Report") {
                          // Add your code here to navigate or perform an action
                          // when the calendar is clicked
                          print("Report clicked!");
                          /*Navigator.push(context, MaterialPageRoute(
                              builder: (context) =>  ViewReminderParentPage(userData:widget.userData)),
                          );*/
                        }
                        if (catNames[index] == "Video") {
                          // Add your code here to navigate or perform an action
                          // when the calendar is clicked
                          print("Video clicked!");
                          Navigator.push(context, MaterialPageRoute(
                              builder: (context) =>  ViewYoutubeAdmin(userData:widget.userData)),
                          );
                        }
                        if (catNames[index] == "Task") {
                          // Add your code here to navigate or perform an action
                          // when the calendar is clicked
                          print("Task clicked!");
                          Navigator.push(context, MaterialPageRoute(
                              builder: (context) =>  ViewTaskAdminPage(userData:widget.userData)),
                          );
                        }
                        if (catNames[index] == "Child") {
                          // Add your code here to navigate or perform an action
                          // when the calendar is clicked
                          print("Child clicked!");
                          /*Navigator.push(context, MaterialPageRoute(
                              builder: (context) => ViewChildParentPage(userData:widget.userData)),
                          );*/
                        }
                      },
                      child: Column(
                        children: [
                          Container(
                            height: 60,
                            width: 60,
                            decoration: BoxDecoration(
                              color: catColors[index],
                              shape: BoxShape.rectangle,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: catIcons[index],),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            catNames[index], style: TextStyle(fontSize: 16,color: Colors.black.withOpacity(0.6),
                          ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "My Booking",
                      style: TextStyle(
                        fontSize: 23,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(
                            builder: (context) => ViewBookingAdminPage(userData:widget.userData)),
                        );
                      },
                      child: Text(
                        "See All",
                        style: TextStyle(
                          fontSize: 18,
                          color: kSecondaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                GridView.builder(
                  itemCount: bookings.length,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                  ),
                  itemBuilder: (context, index){
                    return InkWell(
                      onTap: () async {
                        try {
                          // Retrieve the booking
                          BookingModel booking = bookings[index];

                          // Retrieve the therapist corresponding to the booking
                          TherapistModel therapist = therapists.firstWhere(
                                (therapist) => therapist.id == booking.therapistId,
                            orElse: () => TherapistModel(
                              specialization: 'Unknown',
                              hiringDate: '',
                              aboutMe: '',
                              therapistId: '',
                              managedBy: '',
                            ),
                          );

                          // Retrieve the child corresponding to the booking
                          ChildModel child = children.firstWhere(
                                (child) => child.id == booking.childId,
                            orElse: () => ChildModel(
                              childName: 'Unknown',
                              birthDate: '',
                              gender: '',
                              program: '',
                              userId: '',
                            ),
                          );

                          // Retrieve the user details of the therapist
                          UserModel therapistUser = users.firstWhere(
                                (user) => user.id == booking.therapistId,
                            orElse: () => UserModel(
                              id: '',
                              name: 'Unknown',
                              email: '',
                              password: '',
                              phone: '',
                              role: 'Therapist',
                            ),
                          );

                          // Navigate to BookingDetailsPage with retrieved data
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BookingDetailsPage(
                                userData: widget.userData,
                                booking: booking,
                                therapist: therapist,
                                child: child,
                                therapistUser: therapistUser,
                              ),
                            ),
                          );
                        } catch (error) {
                          print('Error navigating to BookingDetailsPage: $error');
                          // Handle error gracefully, e.g., show a snackbar or display an error message
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: kSecondaryColor.withOpacity(0.2),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Padding(padding: EdgeInsets.all(10),
                              child: Icon(Icons.person, size: 50),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              bookings[index].service,
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              "On ${DateFormat('dd-MM-yyyy').format(
                                  DateTime.parse(bookings[index].fromDate))}",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

//Therapist HomePage
class TherapistHomePage extends StatefulWidget {
  final LoginResponseModel userData;
  const TherapistHomePage({Key? key, required this.userData}) : super(key: key);

  @override
  _therapistHomePageState createState() =>_therapistHomePageState();
}

class _therapistHomePageState extends State<TherapistHomePage>{
  List catNames = [
    "Booking",
    "Therapist",
    "Report",
    "Video",
    "Task",
    "Child"
  ];

  List<Color> catColors= [
    kPrimaryColor,
    kSecondaryColor,
    kPrimaryColor,
    kSecondaryColor,
    kPrimaryColor,
    kSecondaryColor,
  ];

  List<Icon> catIcons = [
    Icon(Icons.library_books, color: Colors.white, size: 30),
    Icon(Icons.people, color: Colors.white, size: 30),
    Icon(Icons.event_note, color: Colors.white, size: 30),
    Icon(Icons.video_library, color: Colors.white, size: 30),
    Icon(Icons.calendar_month, color: Colors.white, size: 30),
    Icon(Icons.child_care, color: Colors.white, size: 30),
  ];
  List bookingList = [
    'Booking 1', 'Booking 2', 'Booking 3', 'Booking 4'
  ];

  List<BookingModel> bookings = [];
  List<ChildModel> children = [];
  List<TherapistModel> therapists = [];
  List<UserModel> users = []; // Add a list to store user details

  @override
  void initState() {
    super.initState();
    _loadData(widget.userData.data!.id);
  }


  Future<void> _loadData(String userId) async {
    try {
      // Use Future.wait to wait for all API calls to complete
      await Future.wait([
        _loadBooking(userId),
        _loadChildren(userId),
        _loadTherapists(userId),
        _loadUsers(), // Fetch user details
      ]);
    } catch (error) {
      print('Error loading data: $error');
    }
  }

  // Fetch user details
  Future<void> _loadUsers() async {
    try {
      List<UserModel> loadedUsers = await APIService.getAllUsers();
      setState(() {
        users = loadedUsers;
      });
    } catch (error) {
      print('Error loading users: $error');
    }
  }

  Future<void> _loadBooking(String userId) async {
    try {
      List<BookingModel> loadedBookings = await APIService.getAllBookings();
      List<BookingModel> therapistBookings = loadedBookings.where((booking) => booking.therapistId == widget.userData.data?.id).toList();
      setState(() {
        bookings = therapistBookings;
      });
    } catch (error) {
      print('Error loading bookings: $error');
    }
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

  Future<void> _loadTherapists(String userId) async {
    try {
      List<TherapistModel> loadedTherapists = await APIService.getAllTherapists();
      setState(() {
        therapists = loadedTherapists;
      });
    } catch (error) {
      print('Error loading therapists: $error');
    }
  }
  @override
  Widget build(BuildContext context){
    return Scaffold(
      drawer: TherapistNavBar(userData: widget.userData),
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        title: Text("Therapist Home Page"),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.logout),
              onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil("/login", (route) => false,
              )
          ),
        ],
      ),
      body: ListView(
        children: [
          Container(
              padding: EdgeInsets.only(top: 15, left: 15, right: 15, bottom: 10),
              decoration: BoxDecoration(
                color: kPrimaryColor,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  SizedBox(height: 10),
                  Padding(
                    padding: EdgeInsets.only(left: 3, bottom: 15),
                    child: Row(
                      children: <Widget>[
                        Text("Hi, ${widget.userData.data?.name ?? 'User'}!", style: TextStyle(fontSize: 25,color: Colors.white, decoration: TextDecoration.none)),
                      ],
                    ),
                  )
                ],
              )
          ),
          Padding(padding: EdgeInsets.only(top: 20, left: 15, right: 15),
            child: Column(
              children: [
                GridView.builder(
                  itemCount: catNames.length,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 1.1,
                  ),
                  itemBuilder: (context, index){
                    return InkWell( // Wrap the container with InkWell for clickability
                      onTap: () async {
                        // Handle the click event for the calendar
                        if (catNames[index] == "Booking") {
                          // Add your code here to navigate or perform an action
                          // when the calendar is clicked
                          print("Booking clicked!");
                          Navigator.push(context, MaterialPageRoute(
                              builder: (context) => ViewBookingTherapistPage(userData:widget.userData)),
                          );
                        }
                        List<TherapistModel> therapists = await APIService.getAllTherapists();
                        List<UserModel> users = await APIService.getAllUsers();
                        if (catNames[index] == "Therapist") {
                          // Add your code here to navigate or perform an action
                          // when the calendar is clicked
                          print("Therapist clicked!");
                          Navigator.push(context, MaterialPageRoute(
                              builder: (context) => TherapistDetailPage(userData:widget.userData, therapists: therapists, users: users)),//CreateTherapist()),
                          );
                        }
                        if (catNames[index] == "Report") {
                          // Add your code here to navigate or perform an action
                          // when the calendar is clicked
                          print("Report clicked!");
                          Navigator.push(context, MaterialPageRoute(
                              builder: (context) =>  ViewReportTherapistPage(userData:widget.userData)),
                          );
                        }
                        if (catNames[index] == "Video") {
                          // Add your code here to navigate or perform an action
                          // when the calendar is clicked
                          print("Video clicked!");
                          Navigator.push(context, MaterialPageRoute(
                              builder: (context) =>  ViewVideoTherapistPage(userData:widget.userData)),
                          );
                        }
                        if (catNames[index] == "Task") {
                          // Add your code here to navigate or perform an action
                          // when the calendar is clicked
                          print("Task clicked!");
                          Navigator.push(context, MaterialPageRoute(
                              builder: (context) =>  ViewTaskTherapistPage(userData:widget.userData)),
                          );
                        }

                        List<ChildModel> children = await APIService.getAllChildren();
                        if (catNames[index] == "Child") {
                          // Add your code here to navigate or perform an action
                          // when the calendar is clicked
                          print("Child clicked!");
                          Navigator.push(context, MaterialPageRoute(
                              builder: (context) => ViewChildTherapistPage(userData:widget.userData, children: children)),
                          );
                        }
                      },
                      child: Column(
                        children: [
                          Container(
                            height: 60,
                            width: 60,
                            decoration: BoxDecoration(
                              color: catColors[index],
                              shape: BoxShape.rectangle,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: catIcons[index],),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            catNames[index], style: TextStyle(fontSize: 16,color: Colors.black.withOpacity(0.6),
                          ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "My Booking",
                      style: TextStyle(
                        fontSize: 23,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(
                            builder: (context) => ViewBookingTherapistPage(userData:widget.userData)),
                        );
                      },
                      child: Text(
                        "See All",
                        style: TextStyle(
                          fontSize: 18,
                          color: kSecondaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                GridView.builder(
                  itemCount: bookings.length,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                  ),
                  itemBuilder: (context, index){
                    return InkWell(
                      onTap: () async {
                        try {
                          // Retrieve the booking
                          BookingModel booking = bookings[index];

                          // Retrieve the therapist corresponding to the booking
                          TherapistModel therapist = therapists.firstWhere(
                                (therapist) => therapist.id == booking.therapistId,
                            orElse: () => TherapistModel(
                              specialization: 'Unknown',
                              hiringDate: '',
                              aboutMe: '',
                              therapistId: '',
                              managedBy: '',
                            ),
                          );

                          // Retrieve the child corresponding to the booking
                          ChildModel child = children.firstWhere(
                                (child) => child.id == booking.childId,
                            orElse: () => ChildModel(
                              childName: 'Unknown',
                              birthDate: '',
                              gender: '',
                              program: '',
                              userId: '',
                            ),
                          );

                          // Retrieve the user details of the therapist
                          UserModel therapistUser = users.firstWhere(
                                (user) => user.id == booking.therapistId,
                            orElse: () => UserModel(
                              id: '',
                              name: 'Unknown',
                              email: '',
                              password: '',
                              phone: '',
                              role: 'Therapist',
                            ),
                          );

                          // Navigate to BookingDetailsPage with retrieved data
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BookingDetailsTherapistPage(
                                userData: widget.userData,
                                booking: booking,
                                therapist: therapist,
                                child: child,
                                therapistUser: therapistUser,
                              ),
                            ),
                          );
                        } catch (error) {
                          print('Error navigating to BookingDetailsPage: $error');
                          // Handle error gracefully, e.g., show a snackbar or display an error message
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: kSecondaryColor.withOpacity(0.2),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Padding(padding: EdgeInsets.all(10),
                              child: Icon(Icons.person, size: 50),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              bookings[index].service,
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              "On ${DateFormat('dd-MM-yyyy').format(
                                  DateTime.parse(bookings[index].fromDate))}",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
