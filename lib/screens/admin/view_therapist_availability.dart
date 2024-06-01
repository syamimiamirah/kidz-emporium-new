import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kidz_emporium/Screens/admin/view_booking_admin.dart';
import 'package:kidz_emporium/models/therapist_model.dart';
import 'package:snippet_coder_utils/FormHelper.dart';
import '../../config.dart';
import '../../contants.dart';
import '../../models/booking_model.dart';
import '../../models/login_response_model.dart';
import '../../models/reminder_model.dart';
import '../../services/api_service.dart';
import '../../models/user_model.dart';
import '../../utils.dart';

class ViewTherapistAvailabilityPage extends StatefulWidget {
  final LoginResponseModel userData;
  final DateTime fromDate;
  final DateTime toDate;
  final String bookingId;

  const ViewTherapistAvailabilityPage({
    Key? key,
    required this.fromDate,
    required this.toDate,
    required this.bookingId,
    required this.userData
  }) : super(key: key);

  @override
  _ViewTherapistAvailabilityPageState createState() => _ViewTherapistAvailabilityPageState();
}

class _ViewTherapistAvailabilityPageState extends State<ViewTherapistAvailabilityPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late DateTime selectedFromDate;
  late DateTime selectedToDate;
  List<TherapistModel> availableTherapists = [];
  List<UserModel> users = [];
  bool isLoading = false;
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

  @override
  void initState() {
    super.initState();
    selectedFromDate = widget.fromDate;
    selectedToDate = widget.toDate;
    fetchBookingDetails();
    _fetchAvailabilityAndUsers(selectedFromDate, selectedToDate);
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
          userId = booking.userId!;
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

  void _fetchAvailabilityAndUsers(DateTime fromDate, DateTime toDate) async {
    setState(() {
      isLoading = true;
    });

    try {
      // Fetching available therapists and all users in parallel
      final results = await Future.wait([
        APIService.getAvailableTherapists(fromDate, toDate),
        APIService.getAllUsers(),
      ]);

      setState(() {
        availableTherapists = results[0] as List<TherapistModel>;
        users = results[1] as List<UserModel>;
      });
    } catch (error) {
      print('Error fetching data: $error');
      // Handle error
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _selectFromDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedFromDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      // Define a theme for the date picker
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: kPrimaryColor, // Change the primary color
            ),
          ),
          child: child!,
        );
      },
    );
    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(selectedFromDate),
        // Define a theme for the time picker
        builder: (BuildContext context, Widget? child) {
          return Theme(
            data: ThemeData.light().copyWith(
              colorScheme: ColorScheme.light(
                primary: kPrimaryColor, // Change the primary color
              ),
            ),
            child: child!,
          );
        },
      );
      if (pickedTime != null) {
        setState(() {
          selectedFromDate = DateTime(
              pickedDate.year, pickedDate.month, pickedDate.day,
              pickedTime.hour, pickedTime.minute);
        });
        _fetchAvailabilityAndUsers(selectedFromDate, selectedToDate);
      }
    }
  }


  Future<void> _selectToDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedToDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),

      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: kPrimaryColor, // Change the primary color
            ),
          ),
          child: child!,
        );
      },
    );
    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(selectedToDate),

        builder: (BuildContext context, Widget? child) {
          return Theme(
            data: ThemeData.light().copyWith(
              colorScheme: ColorScheme.light(
                primary: kPrimaryColor, // Change the primary color
              ),
            ),
            child: child!,
          );
        },
      );
      if (pickedTime != null) {
        setState(() {
          selectedToDate = DateTime(
              pickedDate.year, pickedDate.month, pickedDate.day,
              pickedTime.hour, pickedTime.minute);
        });
        _fetchAvailabilityAndUsers(selectedFromDate, selectedToDate);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Therapist Availability'),
        backgroundColor: kPrimaryColor,
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: _viewTherapistAvailabilityUI(context),
      ),
    );
  }

  Widget _viewTherapistAvailabilityUI(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildDateSelectionRow(context),
          const SizedBox(height: 20),
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : availableTherapists.isEmpty
                ? Center(child: Text('No therapists available'))
                : ListView.builder(
              itemCount: availableTherapists.length,
              itemBuilder: (context, index) {
                final therapist = availableTherapists[index];
                final user = users.firstWhere(
                      (user) => user.id == therapist.therapistId!,
                  orElse: () =>
                      UserModel(
                        id: '',
                        name: 'Unknown',
                        email: '',
                        password: '',
                        phone: '',
                        role: 'Therapist',
                      ),
                );

                return InkWell(
                  onTap: () {
                    _assignTherapist(user);
                  },
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          backgroundColor: kPrimaryColor,
                          child: Icon(Icons.person, color: Colors.white),
                        ),
                        title: Text(
                          user.name ?? 'Unknown',
                          style: TextStyle(fontSize: 16),
                        ),
                        subtitle: Text(
                          therapist.specialization ?? 'No specialization',
                          style: TextStyle(fontSize: 14),
                        ),
                        trailing: _buildAvailabilityIndicator(true),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _assignTherapist(UserModel user) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(Config.appName),
          content: Text.rich(
            TextSpan(
              text: 'Do you want to assign ',
              children: <TextSpan>[
                TextSpan(
                  text: user.name!,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(text: '?'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.black, // Change to your desired color
              ),
            ),
            TextButton(
              onPressed: () {
                // Handle assignment logic here
                saveBookingDetails(user.id!);
                Navigator.of(context).pop();
              },
              child: Text('Assign'),
              style: TextButton.styleFrom(
                foregroundColor: kPrimaryColor, // Change to your desired color
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> saveBookingDetails(String therapistId) async {
    try {
      BookingModel updatedBooking = BookingModel(
        service: service,
        therapistId: therapistId,
        childId: childId,
        fromDate: Utils.formatDateTimeToString(widget.fromDate),
        toDate: Utils.formatDateTimeToString(widget.toDate),
        statusBooking: "Approved",
      );
      ReminderModel reminderModel = ReminderModel(
        eventName: "Appointment Booking Session",
        details: service!,
        fromDate: Utils.formatDateTimeToString(fromDate),
        toDate: Utils.formatDateTimeToString(toDate),
        userId: userId,
      );


      bool success = await APIService.updateBooking(widget.bookingId, updatedBooking);
      final reminderResponse = await APIService.createReminder(reminderModel);
      setState(() {
        isAPICallProcess = false;
      });

      if (success && reminderResponse != null) {
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
                        builder: (context) => ViewBookingAdminPage(userData: widget.userData)
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
  Widget _buildAvailabilityIndicator(bool isAvailable) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: isAvailable ? Colors.green : Colors.red,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isAvailable ? 'Available' : 'Not Available',
        style: TextStyle(color: Colors.white, fontSize: 14),
      ),
    );
  }

  Widget _buildDateSelectionRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildDateSelector(
          context: context,
          label: 'From Date & Time',
          date: selectedFromDate,
          onTap: () => _selectFromDate(context),
        ),
        _buildDateSelector(
          context: context,
          label: 'To Date & Time',
          date: selectedToDate,
          onTap: () => _selectToDate(context),
        ),
      ],
    );
  }

  Widget _buildDateSelector({
    required BuildContext context,
    required String label,
    required DateTime date,
    required Function() onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 5),
          Row(
            children: [
              Icon(Icons.calendar_today, color: Theme
                  .of(context)
                  .primaryColor),
              SizedBox(width: 10),
              Container(
                width: 150, // Adjust the width as needed
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      vertical: 10, horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    DateFormat('yyyy-MM-dd').format(date),
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.access_time, color: Theme
                  .of(context)
                  .primaryColor),
              SizedBox(width: 10),
              Container(
                width: 150, // Adjust the width as needed
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      vertical: 10, horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    DateFormat('HH:mm').format(date),
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}