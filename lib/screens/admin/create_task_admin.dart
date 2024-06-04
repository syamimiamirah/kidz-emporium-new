import 'package:flutter/material.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';
import 'package:kidz_emporium/Screens/admin/view_task_admin.dart';
import 'package:kidz_emporium/Screens/therapist/view_report_therapist.dart';
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

class CreateTaskAdminPage extends StatefulWidget {
  final LoginResponseModel userData;

  const CreateTaskAdminPage({Key? key, required this.userData}): super(key: key);
  @override
  _createTaskAdminPageState createState() => _createTaskAdminPageState();

}
class _createTaskAdminPageState extends State<CreateTaskAdminPage>{
  static final GlobalKey<FormState> globalFormKey = GlobalKey<FormState>();
  bool isAPICallProcess =  false;
  late DateTime fromDate;
  late DateTime toDate;
  late String userId;
  String? taskTitle;
  String? description;
  List<String> selectedTherapists = [];
  List<UserModel> therapists = [];

  // Future<void> _loadTherapists() async {
  //   try {
  //     List<UserModel> allUsers = await APIService.getAllUsers();
  //     // Filter users by role "Therapist"
  //     therapists = allUsers.where((user) => user.role == "Therapist").toList();
  //
  //     setState(() {});
  //   } catch (error) {
  //     print('Error loading therapists: $error');
  //   }
  // }

  Future<void> _loadTherapists() async {
    try {
      List<UserModel> allUsers = await APIService.getAllUsers();
      List<UserModel> therapistList = allUsers.where((user) => user.role == "Therapist").toList();

      // Separate lists for available and unavailable therapists
      List<UserModel> availableTherapists = [];
      List<UserModel> unavailableTherapists = [];

      for (var therapist in therapistList) {
        bool isAvailable = await APIService.checkTherapistAvailability(therapist.id!, fromDate, toDate);
        if (isAvailable) {
          availableTherapists.add(therapist);
        } else {
          unavailableTherapists.add(therapist);
        }
      }

      // Update therapists based on selection or availability
      therapists = selectedTherapists.isEmpty
          ? availableTherapists
          : therapists.where((therapist) => selectedTherapists.contains(therapist.id) || availableTherapists.contains(therapist)).toList();

      setState(() {});
    } catch (error) {
      print('Error loading therapists: $error');
    }
  }


  // Future<void> _loadTherapists() async {
  //   try {
  //     List<UserModel> allUsers = await APIService.getAllUsers();
  //     List<UserModel> therapistList = allUsers.where((user) => user.role == "Therapist").toList();
  //
  //     therapists = [];
  //     for (var therapist in therapistList) {
  //       bool isAvailable = await APIService.checkTherapistAvailability(therapist.id!, fromDate, toDate);
  //       if (isAvailable) {
  //         therapists.add(therapist);
  //       }
  //     }
  //
  //     setState(() {});
  //   } catch (error) {
  //     print('Error loading therapists: $error');
  //   }
  // }




  @override
  void initState() {
    super.initState();
    if (widget.userData != null && widget.userData.data != null) {
      print("userData: ${widget.userData.data!.id}");
      fromDate = DateTime.now();
      toDate = fromDate.add(Duration(hours: 2));
      userId = widget.userData.data!.id;
    } else {
      // Handle the case where userData or userData.data is null
      print("Error: userData or userData.data is null");
    }
    _loadTherapists();
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Task'),
        centerTitle: true,
        backgroundColor: kPrimaryColor,
      ),
      body: ProgressHUD(
          child: Form(
            key: _createTaskAdminPageState.globalFormKey,
            child: _createTaskAdminUI(context),
        )
      )
    );
  }

  Widget _createTaskAdminUI(BuildContext context){
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
                  children:[
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: Icon(
                            Icons.people, // Your desired icon
                            color: kPrimaryColor, // Icon color
                          ),
                        ),
                        Text(
                          'Therapists',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: therapists.map((therapist) {
                        bool isSelected = selectedTherapists.contains(therapist.id);
                        return ListTile(
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                therapist.name,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                decoration: BoxDecoration(
                                  color:Colors.green,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text('Available',
                                  style: TextStyle(color: Colors.white, fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                          trailing: isSelected ? Icon(Icons.check, color: kPrimaryColor) : null,
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

                  ],
                ),
              ),
            ),
          ),
          // Center(
          //   child: Padding(
          //     padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          //     child: Container(
          //       decoration: BoxDecoration(
          //         borderRadius: BorderRadius.circular(10),
          //         border: Border.all(color: Colors.grey),
          //       ),
          //       child: Column(
          //         crossAxisAlignment: CrossAxisAlignment.start,
          //         children:[
          //           Row(
          //             children: [
          //               Padding(
          //                 padding: const EdgeInsets.all(10),
          //                 child: Icon(
          //                   Icons.people, // Your desired icon
          //                   color: kPrimaryColor, // Icon color
          //                 ),
          //               ),
          //               Text(
          //                 'Therapists',
          //                 style: TextStyle(
          //                   fontSize: 16,
          //                   fontWeight: FontWeight.bold,
          //                 ),
          //               ),
          //             ],
          //           ),
          //           Column(
          //             children: therapists.map((therapist) {
          //               return CheckboxListTile(
          //                 title: Text(
          //                   therapist.name,
          //                   style: TextStyle(
          //                     fontSize: 16,
          //                     fontWeight: FontWeight.w500,
          //                   ),
          //                 ),
          //                 value: selectedTherapists.contains(therapist.id),
          //                 onChanged: (bool? value) {
          //                   setState(() {
          //                     if (value != null && value) {
          //                       selectedTherapists.add(therapist.id!);
          //                     } else {
          //                       selectedTherapists.remove(therapist.id);
          //                     }
          //                   });
          //                 },
          //                 controlAffinity: ListTileControlAffinity.leading,
          //                 activeColor: kPrimaryColor, // Change the color of the checkbox when selected
          //                 checkColor: Colors.white, // Change the color of the checkmark
          //               );
          //             }).toList(),
          //           ),
          //         ],
          //       ),
          //     ),
          //   ),
          // ),
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
                      "Save", () {
                      if (validateAndSave()) {
                        setState(() {
                          isAPICallProcess = true;
                        });
                        // Check therapist availability before creating the task
                        APIService.checkTherapistAvailability(
                            selectedTherapists.first, fromDate, toDate).then((
                            isAvailable) {
                          if (isAvailable) {
                            // Therapist is available, proceed with task creation
                            TaskModel model = TaskModel(
                              userId: userId,
                              taskTitle: taskTitle!,
                              taskDescription: description!,
                              fromDate: Utils.formatDateTimeToString(fromDate!),
                              toDate: Utils.formatDateTimeToString(toDate!),
                              therapistId: selectedTherapists,
                            );

                            APIService.createTask(model).then((response) {
                              print(response);
                              setState(() {
                                isAPICallProcess = false;
                              });
                              if (response != null) {
                                FormHelper.showSimpleAlertDialog(
                                    context, Config.appName,
                                    "Task for therapist created", "OK", () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(builder: (context) =>
                                        ViewTaskAdminPage(
                                            userData: widget.userData)),
                                  );
                                });
                              } else {
                                FormHelper.showSimpleAlertDialog(
                                    context, Config.appName,
                                    "Task failed to create", "OK", () {
                                  Navigator.of(context).pop();
                                });
                              }
                            });
                          } else {
                            // Therapist is not available during the specified time range
                            FormHelper.showSimpleAlertDialog(
                                context, Config.appName,
                                "Therapist is not available during the specified time range",
                                "OK", () {
                              Navigator.of(context).pop();
                            });
                          }
                        });
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
    _loadTherapists();
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
    _loadTherapists();
  }

  Future<DateTime?> pickDateTime(
      DateTime initialDate,{
        required bool pickDate,
        DateTime? firstDate,
      }) async{
    if (pickDate){
      final date = await showDatePicker(
        context: context,
        initialDate: initialDate,
        firstDate: firstDate ?? DateTime(2015, 8),
        lastDate: DateTime(2101),
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