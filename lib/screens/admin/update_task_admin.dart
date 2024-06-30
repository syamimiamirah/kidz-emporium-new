import 'package:flutter/material.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';
import 'package:kidz_emporium/screens/admin/view_task_admin.dart';
import 'package:kidz_emporium/screens/therapist/view_report_therapist.dart';
import 'package:kidz_emporium/components/side_menu.dart';
import 'package:kidz_emporium/contants.dart';
import 'package:kidz_emporium/models/therapist_model.dart';
import 'package:snippet_coder_utils/FormHelper.dart';
import '../../config.dart';
import '../../models/booking_model.dart';
import '../../models/child_model.dart';
import '../../models/login_response_model.dart';
import '../../models/report_model.dart';
import '../../models/task_model.dart';
import '../../models/user_model.dart';
import '../../services/api_service.dart';
import '../../utils.dart';

class UpdateTaskAdminPage extends StatefulWidget {
  final LoginResponseModel userData;
  final String taskId;


  const UpdateTaskAdminPage({Key? key, required this.userData, required this.taskId}): super(key: key);
  @override
  _updateTaskAdminPageState createState() => _updateTaskAdminPageState();

}
class _updateTaskAdminPageState extends State<UpdateTaskAdminPage>{
  static final GlobalKey<FormState> globalFormKey = GlobalKey<FormState>();
  bool isAPICallProcess =  false;
  late DateTime fromDate;
  late DateTime toDate;
  late String userId;
  late String taskTitle = "";
  late String description = "";
  List<String> selectedTherapists = [];
  List<UserModel> therapists = [];
  List<UserModel> savedTherapists = [];
  List<UserModel> notAvailableTherapists = [];
  List<UserModel> remainingTherapists = [];

  @override
  void initState() {
    super.initState();
    _loadData();
    print(widget.taskId);
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
        fetchTaskDetails(),
        _loadTherapists(),
      ]);
    } catch (error) {
      print('Error loading data: $error');
    }
  }
  Future<void> _loadTherapists() async {
    try {
      List<UserModel> allUsers = await APIService.getAllUsers();
      List<UserModel> therapistList = allUsers.where((user) => user.role == "Therapist").toList();

      // Separate therapists into saved and remaining
      List<UserModel> availableTherapists = [];
      List<UserModel> unselectedTherapists = [];
      List<UserModel> unavailableTherapists = [];
      for (var therapist in therapistList) {

        if (selectedTherapists.contains(therapist.id)) {
          savedTherapists.add(therapist);
        } else {
          unselectedTherapists.add(therapist);
        }
      }
      for (var therapist in unselectedTherapists) {
        bool isAvailable = await APIService.checkTherapistAvailability(therapist.id!, fromDate, toDate);
        if (isAvailable) {
          remainingTherapists.add(therapist);
        } else {
          notAvailableTherapists.add(therapist);
        }
      }
      setState(() {
        savedTherapists = savedTherapists;
        remainingTherapists = remainingTherapists;
        notAvailableTherapists = notAvailableTherapists;
        print(unavailableTherapists);
      });

      // Check availability of therapists only when the date is changed
      // if (fromDate != null && toDate != null) {
      //   await _checkTherapistsAvailability();
      // }
    } catch (error) {
      print('Error loading therapists: $error');
    }
  }

  Future<void> _checkTherapistsAvailability() async {
    try {
      List<UserModel> allUsers = await APIService.getAllUsers();
      List<UserModel> therapistList = allUsers.where((user) => user.role == "Therapist").toList();

      List<UserModel> availableTherapists = [];
      List<UserModel> unavailableTherapists = [];

      for (var therapist in therapistList) {
        bool isAvailable = await APIService.checkTherapistAvailability(
          therapist.id!,
          fromDate,
          toDate,
        );
        if (isAvailable) {
          availableTherapists.add(therapist);
        } else {
          unavailableTherapists.add(therapist);
        }
      }

      setState(() {
        savedTherapists = availableTherapists;
        remainingTherapists = unavailableTherapists;
      });
    } catch (error) {
      print('Error loading therapists availability: $error');
    }
  }


  Future<void> fetchTaskDetails() async {
    try{
      TaskModel? task = await APIService.getTaskDetails(widget.taskId);
      if(task != null) {
        setState(() {
          taskTitle = task.taskTitle;
          description = task.taskDescription;
          fromDate = Utils.parseStringToDateTime(task.fromDate);
          toDate = Utils.parseStringToDateTime(task.toDate);
          selectedTherapists = task.therapistId;
        });
      }else {
        print('Task details not found');
      }
    } catch(error) {
      print('Error fetching task details: $error');
    }
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
        appBar: AppBar(
          title: Text('Update Task'),
          centerTitle: true,
          backgroundColor: kPrimaryColor,
        ),
        body: ProgressHUD(
            child: Form(
              key: _updateTaskAdminPageState.globalFormKey,
              child: _updateTaskAdminUI(context),
            )
        )
    );
  }

  Widget _updateTaskAdminUI(BuildContext context){
    return SingleChildScrollView(
        child: Column(
          children: [
            Center(
              child: Padding(padding: const EdgeInsets.only(top: 10),
                child: FormHelper.inputFieldWidget(context, "task title", 'Task Title', (onValidateVal){
                  if(onValidateVal.isEmpty){
                    return "Task title can't be empty";
                  }
                  return null;
                }, (onSavedVal){
                  taskTitle = onSavedVal.toString().trim();
                },
                  initialValue: taskTitle,
                  prefixIconColor: kPrimaryColor,
                  showPrefixIcon: true,
                  prefixIcon: const Icon(Icons.task),
                  borderRadius: 10,
                  borderColor: Colors.grey,
                  contentPadding: 15,
                  fontSize: 16,
                  prefixIconPaddingLeft: 10,
                  hintFontSize: 16,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 10),
                child:
                FormHelper.inputFieldWidget(
                  context,
                  "description", "Description",
                      (onValidateVal){
                    if(onValidateVal.isEmpty){
                      return "Description can't be empty";
                    }
                    return null;
                  },
                      (onSavedVal){
                    description = onSavedVal.toString().trim();
                  },
                  initialValue: description,
                  prefixIconColor: kPrimaryColor,
                  showPrefixIcon: true,
                  prefixIcon: const Icon(Icons.description),
                  borderRadius: 10,
                  borderColor: Colors.grey,
                  contentPadding: 15,
                  fontSize: 16,
                  prefixIconPaddingLeft: 10,
                  prefixIconPaddingBottom: 170,
                  isMultiline: true,
                  hintFontSize: 16,
                  maxLength: TextField.noMaxLength,
                  multilineRows: 10,
                ),
              ),
            ),
            SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 25),
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
                padding: const EdgeInsets.only(left: 20, right: 20, top: 5, bottom: 10),
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
                  padding: EdgeInsets.only(left: 25),
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
                padding: const EdgeInsets.only(left: 20, right: 20, top: 5, bottom: 10),
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
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header for available therapists
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Row(
                          children: [
                            Icon(
                              Icons.people, // Your desired icon
                              color: kPrimaryColor, // Icon color
                            ),
                            SizedBox(width: 10),
                            Text(
                              'Selected Therapists',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // List of available therapists
                      Column(
                        children: savedTherapists.map((therapist) {
                          bool isSelected = selectedTherapists.contains(therapist.id);
                          return ListTile(
                            title: Text(therapist.name ?? ''),
                            trailing: isSelected ? Icon(Icons.check_circle, color: kPrimaryColor) : null,
                            onTap: () {
                              setState(() {
                                if (isSelected) {
                                  selectedTherapists.remove(therapist.id);
                                } else {
                                  selectedTherapists.add(therapist.id!);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                      // Divider between available and unavailable therapists
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Divider(color: Colors.grey),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Row(
                          children: [
                            Icon(
                              Icons.people, // Your desired icon
                              color: kPrimaryColor, // Icon color
                            ),
                            SizedBox(width: 10),
                            Text(
                              'Available Therapists',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // List of available therapists
                      Column(
                        children: remainingTherapists.map((therapist){
                          bool isSelected = selectedTherapists.contains(therapist.id);
                          return ListTile(
                            title: Text(therapist.name ?? ''),
                            trailing: isSelected ? Icon(Icons.check_circle, color: kPrimaryColor) : null,
                            onTap: () {
                              setState(() {
                                if (isSelected) {
                                  selectedTherapists.remove(therapist.id);
                                } else {
                                  selectedTherapists.add(therapist.id!);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                      // Divider between available and unavailable therapists
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Divider(color: Colors.grey),
                      ),
                      // Header for unavailable therapists
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Row(
                          children: [
                            Icon(
                              Icons.people_outline, // Your desired icon
                              color: Colors.grey, // Icon color
                            ),
                            SizedBox(width: 10),
                            Text(
                              'Unavailable Therapists',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // List of unavailable therapists
                      Column(
                        children: notAvailableTherapists.map((therapist) {
                          return ListTile(
                            title: Text(therapist.name ?? '',
                              style: TextStyle(color: Colors.grey),
                            ),
                            trailing: Icon(Icons.block, color: Colors.red),
                            onTap: null, // Non-clickable
                          );
                        }).toList(),
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
                            builder: (context) => ViewTaskAdminPage(userData: widget.userData)),
                        );
                      },
                        btnColor: Colors.grey,
                        txtColor: Colors.black,
                        borderRadius: 10,
                        borderColor: Colors.grey,
                        fontSize: 16,
                      ),
                      SizedBox(width: 20,),
                      FormHelper.submitButton(
                        "Save", () async {
                        if (await validateAndSave()) {
                          setState(() {
                            isAPICallProcess = true;
                          });
                          // Check therapist availability before creating the task
                        }
                      },
                        btnColor: kPrimaryColor,
                        txtColor: Colors.black,
                        borderRadius: 10,
                        borderColor: kSecondaryColor,
                        fontSize: 16,
                      ),
                    ],
                  )
                ],
              ),
            ),
            SizedBox(height: 20),

          ],
        )
    );
  }
  Future pickFromDateTime({required bool pickDate}) async{
    final date = await pickDateTime(fromDate, pickDate: pickDate);
    if(date == null) return;

    if(date.isAfter(toDate)){
      toDate = date.add(Duration(hours: 2));
    }
    setState(()
    => fromDate = date
    );
    await _checkTherapistsAvailability();
  }

  Future pickToDateTime({required bool pickDate}) async{
    final date = await pickDateTime(
      toDate,
      pickDate: pickDate,
      firstDate: pickDate ? fromDate : null,
    );
    if(date == null) return;

    setState(()
    => toDate = date);
    await _checkTherapistsAvailability();
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
        firstDate: firstDate ?? DateTime(2015, 8),
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
    final form = globalFormKey.currentState;
    if (form != null && form.validate()) {
      print("Save method is called");
      form.save();
      if (selectedTherapists.isEmpty) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(Config.appName),
              content: Text("Please select at least one therapist."),
              actions: [
                TextButton(
                  child: Text("OK"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
        return false;
      }
      TaskModel? task = await APIService.getTaskDetails(widget.taskId);

      print(Utils.parseStringToDateTime(task!.fromDate));
      updateTaskDetails();
      // if (fromDate != Utils.parseStringToDateTime(task!.fromDate) || toDate != Utils.parseStringToDateTime(task!.toDate)) {
      //   // Timeslot is being updated, perform the availability check
      //   checkTherapistAvailabilityAndUpdate();
      // } else {
      //   // Timeslot remains the same, update only the task details
      //   updateTaskDetails();
      // }
      return true;
    } else {
      return false;
    }
  }
  Future<void> checkTherapistAvailabilityAndUpdate() async {
    try {
      bool isAvailable = await APIService.checkTherapistAvailability(
        selectedTherapists.first,
        fromDate,
        toDate,
      );
      if (isAvailable) {
        // Therapist is available, proceed with task update
        updateTaskDetails();
      } else {
        // Therapist is not available during the specified time range
        _showCustomAlertDialog(
          context,
          "Therapist Not Available",
          "The selected therapist is not available during the specified time range.",
          "OK",
              () => Navigator.of(context).pop(), kPrimaryColor,
        );
      }
    } catch (error) {
      print('Error checking therapist availability: $error');
      // Handle error
    }
  }
    // Call API to update task
  void updateTaskDetails() async {
      TaskModel updatedTask = TaskModel(
        id: widget.taskId,
        userId: userId,
        taskTitle: taskTitle,
        taskDescription: description,
        fromDate: Utils.formatDateTimeToString(fromDate),
        toDate: Utils.formatDateTimeToString(toDate),
        therapistId: selectedTherapists,
      );

      try {
        bool response = await APIService.updateTask(widget.taskId, updatedTask);
        if (response) {
          _showCustomAlertDialog(
            context,
            "Task Updated",
            "The task details have been successfully updated.",
            "OK",
                () =>
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ViewTaskAdminPage(
                          userData: widget.userData,
                        ),
                  ),
                ), kPrimaryColor,
          );
        } else {
          _showCustomAlertDialog(
            context,
            "Error",
            "Failed to update task details. Please try again.",
            "OK",
                () => Navigator.of(context).pop(), kPrimaryColor,
          );
        }
      } catch (error) {
        print('Error updating task: $error');
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
