import 'package:flutter/material.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';
import 'package:kidz_emporium/Screens/parent/create_payment_parent.dart';
import 'package:kidz_emporium/Screens/parent/view_child_parent.dart';
import 'package:kidz_emporium/Screens/parent/view_reminder_parent.dart';
import 'package:kidz_emporium/contants.dart';
import 'package:kidz_emporium/models/child_model.dart';
import 'package:kidz_emporium/models/login_response_model.dart';
import 'package:kidz_emporium/models/therapist_model.dart';
import 'package:kidz_emporium/services/api_service.dart';

import 'package:snippet_coder_utils/FormHelper.dart';

import '../../config.dart';
import '../../models/booking_model.dart';
import '../../models/reminder_model.dart';
import '../../models/user_model.dart';
import '../../utils.dart';


class CreateBookingParentPage extends StatefulWidget{
  final LoginResponseModel userData;

  const CreateBookingParentPage({Key? key, required this.userData}): super(key: key);
  @override
  _createBookingParentPageState createState() => _createBookingParentPageState();
}

class _createBookingParentPageState extends State<CreateBookingParentPage> {
  String? selectedTherapist;
  String? selectedChild;
  String? service;
  String statusBooking = "Pending";
  late DateTime fromDate;
  late DateTime toDate;
  late String userId;

  List<TherapistModel> therapists = [];
  List<ChildModel> children = [];
  List<UserModel> users = [];

  @override
  void initState() {
    super.initState();
    fetchTherapists();
    fetchChildren();
    if (widget.userData != null && widget.userData.data != null) {
      print("userData: ${widget.userData.data!.id}");
      fromDate = DateTime.now();
      toDate = fromDate.add(Duration(hours: 2));
      userId = widget.userData.data!.id;
    } else {
      // Handle the case where userData or userData.data is null
      print("Error: userData or userData.data is null");
    }
  }

  Future<void> fetchTherapists() async {
    try {
      List<TherapistModel> fetchedTherapists = await APIService.getAllTherapists();
      setState(() {
        therapists = fetchedTherapists;
      });
      // Fetch users (therapists) from API
      List<UserModel> fetchedUsers = await APIService.getAllUsers();
      List<UserModel> therapist = fetchedUsers.where((user) =>
      user.role == 'Therapist').toList();
      print('Filtered therapists: $fetchedTherapists');// Adjust this according to your API method
      setState(() {
        users = therapist;
      });
    } catch (error) {
      print('Error fetching therapists: $error');
    }
  }

  Future<void> fetchChildren() async {
    try {
      List<ChildModel> fetchedChildren = await APIService.getChild(widget.userData.data!.id);
      setState(() {
        children = fetchedChildren;
      });
    } catch (error) {
      print('Error fetching children: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Booking'),
        centerTitle: true,
        backgroundColor: kPrimaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ProgressHUD(
          child: Column(
            children: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 20, bottom: 10),
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
                            color: kPrimaryColor, // Icon color
                          ),
                        ),
                        Expanded(
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: service,
                              hint: const Text("Type of services", style: TextStyle(fontSize: 16)),
                              items: [
                                DropdownMenuItem<String>(
                                  value: null,
                                  child: Text("Type of Services",style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold)),
                                ),
                                DropdownMenuItem<String>(
                                  value: "Screening Session",
                                  child: Text("Screening Session",style: TextStyle(fontSize: 16)),
                                ),
                                DropdownMenuItem<String>(
                                  value: "Speech Therapy (ST)",
                                  child: Text("Speech Therapy (ST)",style: TextStyle(fontSize: 16)),
                                ),
                                DropdownMenuItem<String>(
                                  value: "Occupational Therapy (OT)",
                                  child: Text("Occupational Therapy (OT)",style: TextStyle(fontSize: 16)),
                                ),
                                DropdownMenuItem<String>(
                                  value: "Special Education (SPED)",
                                  child: Text("Special Education (SPED)",style: TextStyle(fontSize: 16)),
                                ),
                                DropdownMenuItem<String>(
                                  value: "Clinical Psychology (PSY)",
                                  child: Text("Clinical Psychology (PSY)",style: TextStyle(fontSize: 16)),
                                ),
                                DropdownMenuItem<String>(
                                  value: "Big Ones Playgroup",
                                  child: Text("Big Ones Playgroup",style: TextStyle(fontSize: 16)),
                                ),
                                DropdownMenuItem<String>(
                                  value: "Small Ones Playgroup",
                                  child: Text("Small Ones Playgroup",style: TextStyle(fontSize: 16)),
                                ),
                              ],// The first item is the hint, set its value to null
                              isExpanded: true,
                              icon: Icon(Icons.arrow_drop_down, color: Colors.grey),
                              onChanged: (String? newValue){
                                //Your code to execute, when a menu item is selected from dropdown
                                //dropDownStringItem = value;
                                setState(() {
                                  this.service = newValue!;
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
                  padding: const EdgeInsets.only(top: 10),
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
                            Icons.child_care, // Your desired icon
                            color: kPrimaryColor, // Icon color
                          ),
                        ),
                        Expanded(
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              hint: const Text("Select Child", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
                              value: selectedChild,
                              onChanged: (newValue) {
                                setState(() {
                                  selectedChild = newValue!;
                                });
                              },
                              items: children
                                  .map<DropdownMenuItem<String>>((ChildModel child) {
                                return DropdownMenuItem<String>(
                                  value: child.id, // Ensure child.id is unique
                                  child: Text(child.childName,style: TextStyle(fontSize: 16)
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
              SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 0),
                    child: Text('FROM', style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                    ),
                  ),
                ],
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 5, bottom: 10),
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey),
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: ListTile(
                                  title: Text(
                                      Utils.toDate(fromDate),
                                      style: TextStyle(fontSize: 16)
                                  ),
                                  trailing: Icon(Icons.arrow_drop_down),
                                  onTap: () => pickFromDateTime(pickDate: true),
                                ),
                              ),
                              Expanded(
                                child: ListTile(
                                  title: Text(
                                      Utils.toTime(fromDate),
                                      style: TextStyle(fontSize: 16)
                                  ),
                                  trailing: Icon(Icons.arrow_drop_down),
                                  onTap: () => pickFromDateTime(pickDate: false),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 0),
                    child: Text('TO', style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                    ),
                  ),
                ],
              ),

              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 5, bottom: 10),
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey),
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: ListTile(
                                  title: Text(
                                      Utils.toDate(toDate),
                                      style: TextStyle(fontSize: 16)
                                  ),
                                  trailing: Icon(Icons.arrow_drop_down),
                                  onTap: () => pickToDateTime(pickDate: true),
                                ),
                              ),
                              Expanded(
                                child: ListTile(
                                  title: Text(
                                      Utils.toTime(toDate),
                                      style: TextStyle(fontSize: 16)
                                  ),
                                  trailing: Icon(Icons.arrow_drop_down),
                                  onTap: () => pickToDateTime(pickDate: false),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(10),
                child: SizedBox(
                  child: ElevatedButton(
                    onPressed: () async {
                      if (selectedChild != null && service != null) {
                        if (service == "Screening Session") {
                          // If Screening Session, directly create the booking
                          BookingModel model = BookingModel(
                            userId: widget.userData.data!.id,
                            service: service!,
                            therapistId: null,
                            childId: selectedChild!,
                            fromDate: Utils.formatDateTimeToString(fromDate!),
                            toDate: Utils.formatDateTimeToString(toDate!),
                            paymentId: null,
                            statusBooking: statusBooking,
                          );


                          try {
                            final bookingResponse = await APIService.createBooking(model);
                            // Handle the booking response here
                            if (bookingResponse != null) {
                              // Booking created successfully
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text('Booking Successful'),
                                    content: Text('Your booking has been created successfully.'),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop(); // Close the dialog
                                          Navigator.of(context).pop(); // Go back to the previous screen
                                        },
                                        child: Text('OK'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            } else {
                              // Booking creation failed
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text('Booking Failed'),
                                    content: Text('Failed to create the booking. Please try again.'),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: Text('OK'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            }
                          } catch (error) {
                            print('Error creating booking: $error');
                            // Handle the error
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text('Error'),
                                  content: Text('An error occurred while creating the booking. Please try again.'),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Text('OK'),
                                    ),
                                  ],
                                );
                              },
                            );
                          }
                        } else {
                          // Navigate to the payment screen for other service types
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PaymentPage(
                                userData: widget.userData,
                                service: service,
                                selectedTherapist: selectedTherapist,
                                selectedChild: selectedChild,
                                fromDate: fromDate!,
                                toDate: toDate!,

                              ),
                            ),
                          );
                        }
                      } else {
                        // Show a message if required fields are not selected
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Incomplete Information'),
                              content: Text('Please select a service and a child to proceed.'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text('OK'),
                                ),
                              ],
                            );
                          },
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      primary: kPrimaryColor,
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10), // BorderRadius
                      ),
                    ),
                    child: Text('Book',
                      style: TextStyle(fontSize: 16,
                      color: Colors.white),
                    ),
                  ),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
  Future pickFromDateTime({required bool pickDate}) async{
    final date = await pickDateTime(fromDate!, pickDate: pickDate);
    if(date == null) return;

    if(date.isAfter(toDate!)){
      toDate = date.add(Duration(hours: 2));
    }
    setState(()
    => fromDate = date
    );
  }

  Future pickToDateTime({required bool pickDate}) async{
    final date = await pickDateTime(
      toDate!,
      pickDate: pickDate,
      firstDate: pickDate ? fromDate : null,
    );
    if(date == null) return;

    setState(()
    => toDate = date);
  }

  Future<DateTime?> pickDateTime(
      DateTime initialDate, {
        required bool pickDate,
        DateTime? firstDate,
      }) async {

    // Adjust initial date if it's Sunday or Monday
    while (initialDate.weekday == DateTime.sunday || initialDate.weekday == DateTime.monday) {
      initialDate = initialDate.add(Duration(days: 1));
    }

    if (pickDate) {
      final date = await showDatePicker(
        context: context,
        initialDate: initialDate,
        firstDate: firstDate ?? DateTime.now(),
        lastDate: DateTime(2101),
        selectableDayPredicate: (DateTime day) {
          // Disable Sunday and Monday
          if (day.weekday == DateTime.sunday || day.weekday == DateTime.monday) {
            return false;
          }
          return true;
        },
        builder: (BuildContext context, Widget? child) {
          return Theme(
            data: ThemeData.light().copyWith(
              primaryColor: kPrimaryColor, // Set your desired primary color
              hintColor: kPrimaryColor, // Set your desired accent color
              colorScheme: ColorScheme.light(primary: kPrimaryColor),
              buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
            ),
            child: child!,
          );
        },
      );

      if (date == null) return null;

      final time = Duration(hours: initialDate.hour, minutes: initialDate.minute);
      return date.add(time);
    } else {
      final timeOfDay = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(initialDate),
        builder: (BuildContext context, Widget? child) {
          return Theme(
            data: ThemeData.light().copyWith(
              primaryColor: kPrimaryColor, // Set your desired primary color
              hintColor: kPrimaryColor, // Set your desired accent color
              colorScheme: ColorScheme.light(primary: kPrimaryColor),
              buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
            ),
            child: child!,
          );
        },
      );

      if (timeOfDay == null) return null;
      final date = DateTime(initialDate.year, initialDate.month, initialDate.day);
      final time = Duration(hours: timeOfDay.hour, minutes: timeOfDay.minute);
      return date.add(time);
    }
  }


}

