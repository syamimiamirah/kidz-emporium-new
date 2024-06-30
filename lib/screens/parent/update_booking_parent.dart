import 'package:flutter/material.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';
import 'package:kidz_emporium/screens/parent/create_payment_parent.dart';
import 'package:kidz_emporium/screens/parent/view_booking_parent.dart';
import 'package:kidz_emporium/screens/parent/view_child_parent.dart';
import 'package:kidz_emporium/screens/parent/view_reminder_parent.dart';
import 'package:kidz_emporium/contants.dart';
import 'package:kidz_emporium/models/child_model.dart';
import 'package:kidz_emporium/models/login_response_model.dart';
import 'package:kidz_emporium/models/therapist_model.dart';
import 'package:kidz_emporium/services/api_service.dart';

import 'package:snippet_coder_utils/FormHelper.dart';

import '../../config.dart';
import '../../models/booking_model.dart';
import '../../models/user_model.dart';
import '../../utils.dart';
import 'details_booking_parent.dart';


class UpdateBookingParentPage extends StatefulWidget{
  final LoginResponseModel userData;
  final String bookingId;

  const UpdateBookingParentPage({Key? key, required this.userData, required this.bookingId}): super(key: key);
  @override
  _updateBookingParentPageState createState() => _updateBookingParentPageState();
}

class _updateBookingParentPageState extends State<UpdateBookingParentPage> {
  late DateTime fromDate = DateTime.now();
  late DateTime toDate = DateTime.now();
  late String childId = "";
  late String therapistId = "";
  late String paymentId = "";
  late String service = "";
  String? therapistName;
  String? childName;
  late String userId;
  bool isAPICallProcess =  false;


  List<TherapistModel> therapists = [];
  List<ChildModel> children = [];
  List<UserModel> users = [];

  @override
  void initState() {
    super.initState();
    _loadData();
    /*fetchBookingDetails();
    fetchTherapists();
    fetchChildren();*/
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

  Future<void> _loadData() async {
    try {
      // Use Future.wait to wait for both API calls to complete
      await Future.wait([
      fetchBookingDetails(),
      fetchTherapists(),
      fetchChildren(),
      ]);
    } catch (error) {
      print('Error loading data: $error');
    }
  }
  Future<void> fetchTherapists() async {
    try {
      // Fetch therapists from API
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
      print('Error fetching data: $error');
    }
  }

  Future<void> fetchBookingDetails() async {
    try {
      // Fetch booking details from API
      BookingModel? booking = await APIService.getBookingDetails(widget.bookingId);
      if (booking != null) {
        // Update UI with fetched booking details
        setState(() {
          childId = booking.childId;
          service = booking.service;
          fromDate = Utils.parseStringToDateTime(booking.fromDate);
          toDate = Utils.parseStringToDateTime(booking.toDate);
          therapistId = booking.therapistId!;
          paymentId = booking.paymentId ?? '';
          // Find therapist name from users list
          UserModel? selectedTherapist = users.firstWhere(
                (user) => user.id == therapistId,
            orElse: () => UserModel(id: '', name: 'Unknown', email: '', password: '', phone: '', role: 'Therapist'), // Default if therapist is not found
          );
          therapistName = selectedTherapist.name;
          // Fetch and set child name similarly if needed
        });
      } else {
        // Handle case where booking is null
        print('Booking details not found');
      }
    } catch (error) {
      print('Error fetching booking details: $error');
      // Handle error
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
        title: Text('Update Booking'),
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
                          child: Text(
                            service.isNotEmpty ? service : "Type of Services",
                            style: TextStyle(fontSize: 16),
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
                              hint: const Text("Select Child", style: TextStyle(fontSize: 16)),
                              value: childId,
                              onChanged: (newValue) {
                                setState(() {
                                  childId = newValue!;
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
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Colors.grey,
                      padding: EdgeInsets.symmetric(horizontal: 55, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10), // BorderRadius
                      ),
                    ),
                    child: Text('Cancel',
                      style: TextStyle(fontSize: 16, color: Colors.black),
                    ),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: () async {
                      if (await validateAndSave()) {
                        setState(() {
                          isAPICallProcess = true;
                        });
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      primary: kPrimaryColor,
                      padding: EdgeInsets.symmetric(horizontal: 60, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'Save',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
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
      DateTime initialDate,{
        required bool pickDate,
        DateTime? firstDate,
      }) async{

    while (initialDate.weekday == DateTime.sunday || initialDate.weekday == DateTime.monday) {
      initialDate = initialDate.add(Duration(days: 1));
    }

    if (pickDate){
      final date = await showDatePicker(
        context: context,
        initialDate: initialDate,
        firstDate: DateTime.now(),
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

      if(date == null) return null;

      final time = Duration(hours: initialDate.hour, minutes: initialDate.minute);

      return date.add(time);
    }else{
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

      if(timeOfDay == null) return null;
      final date = DateTime(initialDate.year, initialDate.month, initialDate.day);
      final time = Duration(hours: timeOfDay.hour, minutes: timeOfDay.minute);
      return date.add(time);
    }
  }

  Future<bool> validateAndSave() async {
    print("Validate and Save method is called");
    BookingModel? booking = await APIService.getBookingDetails(widget.bookingId);

    print(Utils.parseStringToDateTime(booking!.fromDate));
    if (fromDate != Utils.parseStringToDateTime(booking!.fromDate) || toDate != Utils.parseStringToDateTime(booking!.toDate)) {
      // Timeslot is being updated, perform the availability check
      saveBookingDetails();
    } else {
      // Timeslot remains the same, update only the task details
      saveBookingDetails();
    }
    return true;
  }

  // Future<void> checkTherapistAvailabilityAndUpdate() async {
  //   try {
  //     bool isAvailable = await APIService.checkTherapistAvailability(
  //       therapistId,
  //       fromDate,
  //       toDate,
  //     );
  //     if (isAvailable) {
  //       // Therapist is available, proceed with task update
  //       saveBookingDetails();
  //     } else {
  //       // Therapist is not available during the specified time range
  //       FormHelper.showSimpleAlertDialog(
  //         context,
  //         "Therapist Not Available",
  //         "The selected therapist is not available during the specified time range.",
  //         "OK",
  //             () => Navigator.of(context).pop(),
  //       );
  //     }
  //   } catch (error) {
  //     print('Error checking therapist availability: $error');
  //     // Handle error
  //   }
  // }

  Future<void> saveBookingDetails() async {
    try {
      BookingModel updatedBooking = BookingModel(
        userId: userId,
        service: service,
        therapistId: null,
        childId: childId,
        fromDate: Utils.formatDateTimeToString(fromDate),
        toDate: Utils.formatDateTimeToString(toDate),
        statusBooking: "Pending",
      );

      bool success = await APIService.updateBooking(widget.bookingId, updatedBooking);
      setState(() {
        isAPICallProcess = false;
      });

      if (success) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(Config.appName),
              content: Text('Booking details have been updated successfully.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ViewBookingParentPage(userData: widget.userData),
                      ),
                    );
                  },
                  child: Text(
                    'OK',
                    style: TextStyle(color: kPrimaryColor),
                  ),
                ),
              ],
            );
          },
        );
      } else {
        // Handle update failure
        // Show error message or retry option
      }
    } catch (error) {
      print('Error updating booking details: $error');
    }
  }
}

