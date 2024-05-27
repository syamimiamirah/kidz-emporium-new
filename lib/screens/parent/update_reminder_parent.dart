import 'package:flutter/material.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';
import 'package:kidz_emporium/Screens/parent/view_reminder_parent.dart';
/*import 'package:jwt_decoder/jwt_decoder.dart';*/
import 'package:kidz_emporium/models/reminder_model.dart';
import 'package:kidz_emporium/services/api_service.dart';
import 'package:provider/provider.dart';
import 'package:snippet_coder_utils/FormHelper.dart';
import '../../components/side_menu.dart';
import '../../config.dart';
import '../../contants.dart';
import '../../models/login_response_model.dart';
import '../../provider/user_provider.dart';
import '../../utils.dart';
//import 'package:events_calendar_example/utils.dart';

class UpdateReminderParentPage extends StatefulWidget{
  final LoginResponseModel userData;
  final DateTime? selectedDate;
  final String reminderId;

  const UpdateReminderParentPage({Key? key, this.selectedDate, required this.userData, required this.reminderId}) : super(key: key);

  @override
  _updateReminderParentPageState createState() => _updateReminderParentPageState();

}
class _updateReminderParentPageState extends State<UpdateReminderParentPage>{
  static final GlobalKey<FormState> globalFormKey = GlobalKey<FormState>();
  bool isAPICallProcess =  false;
  late String eventName = '';
  late String details = '';
  late DateTime fromDate;
  late DateTime toDate;
  late String userId;

  late TextEditingController eventNameController;
  late TextEditingController detailsController;

  @override
  void initState() {
    super.initState();
    // Check if widget.userData and widget.userData.data are not null
    if (widget.userData != null && widget.userData.data != null) {
      print("userData: ${widget.userData.data!.id}");
      fromDate = widget.selectedDate ?? DateTime.now();
      toDate = widget.selectedDate ?? fromDate.add(Duration(hours: 2));
      userId = widget.userData.data!.id;
      fetchReminderDetails();
    } else {
      // Handle the case where userData or userData.data is null
      print("Error: userData or userData.data is null");
    }
  }
  Future<void> fetchReminderDetails() async {
    try {
      ReminderModel? reminder = await APIService.getReminderDetails(widget.reminderId);

      if (reminder != null) {
        // Update UI with fetched reminder details
        setState(() {
          eventName = reminder.eventName;
          details = reminder.details;
          fromDate = Utils.parseStringToDateTime(reminder.fromDate);
          toDate = Utils.parseStringToDateTime(reminder.toDate);
          // Update other fields as needed
        });
      } else {
        // Handle case where reminder is null
        print('Reminder details not found');
      }
    } catch (error) {
      print('Error fetching reminder details: $error');
      // Handle error
    }
  }
  @override
  Widget build(BuildContext context){
    // Retrieve the selected date from the arguments
    //DateTime? selectedDate = ModalRoute.of(context)?.settings.arguments as DateTime?;
    // Use the selected date in your UI, for example, set it as the initial date
    //fromDate = selectedDate ?? DateTime.now().add(Duration(days: 7));
    return Scaffold(
      //drawer: NavBar(userData: widget.userData),
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        title: Text("Update Reminder"),
        centerTitle: true,
      ),
      body: ProgressHUD(
          child: Form(
            key: _updateReminderParentPageState.globalFormKey,
            child: _updateReminderParentUI(context),
          )
      ),
    );
  }
  Widget _updateReminderParentUI(BuildContext context){
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: FormHelper.inputFieldWidget(
              context,
              "event",
              "Event Name",
                  (onValidateVal) {
                if (onValidateVal.isEmpty) {
                  return "Event name can't be empty";
                }
                return null;
              },
                  (onSavedVal) {
                // Update the state variable with the existing data
                eventName = onSavedVal.toString().trim();
              },
              initialValue: eventName,
              prefixIconColor: kPrimaryColor,
              showPrefixIcon: true,
              prefixIcon: const Icon(Icons.event_note),
              borderRadius: 10,
              borderColor: Colors.grey,
              contentPadding: 15,
              fontSize: 16,
              prefixIconPaddingLeft: 10,
              hintFontSize: 16,
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child:
            FormHelper.inputFieldWidget(
              context,
              "details",
              "Details",
                  (onValidateVal) {
                if (onValidateVal.isEmpty) {
                  return "Details can't be empty";
                }
                return null;
              },
                  (onSavedVal) {
                // Update the state variable with the existing data
                details = onSavedVal.toString().trim();
              },
              initialValue: details,
              prefixIconColor: kPrimaryColor,
              showPrefixIcon: true,
              prefixIcon: const Icon(Icons.description),
              borderRadius: 10,
              borderColor: Colors.grey,
              contentPadding: 15,
              fontSize: 16,
              hintFontSize: 16,
              prefixIconPaddingLeft: 10,
              prefixIconPaddingBottom: 55,
              isMultiline: true,
            ),
          ),

          const SizedBox(height: 20),
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
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey,),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: ListTile(
                            title: Text(Utils.toDate(fromDate),style: TextStyle(fontSize: 16)),
                            trailing: const Icon(Icons.arrow_drop_down),
                            onTap: () => pickFromDateTime(pickDate: true),
                          ),
                        ),
                        Expanded(
                          child: ListTile(
                            title: Text(Utils.toTime(fromDate),style: TextStyle(fontSize: 16)),
                            trailing: const Icon(Icons.arrow_drop_down),
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
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey,),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: ListTile(
                            title: Text(Utils.toDate(toDate),style: TextStyle(fontSize: 16)),
                            trailing: Icon(Icons.arrow_drop_down),
                            onTap: () => pickToDateTime(pickDate: true),
                          ),
                        ),
                        Expanded(
                          child: ListTile(
                            title: Text(Utils.toTime(toDate), style: TextStyle(fontSize: 16)),
                            trailing: Icon(Icons.arrow_drop_down),
                            onTap: ()=> pickToDateTime(pickDate: false),
                          ),
                        ),
                      ],
                    )
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
                            builder: (context) =>  ViewReminderParentPage(userData:widget.userData)),
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
                        "Save", () async {
                        if(validateAndSave()){
                          setState((){
                            isAPICallProcess = true; //API
                          });
                          ReminderModel updatedModel = ReminderModel(
                            eventName: eventName!,
                            details: details!,
                            fromDate: Utils.formatDateTimeToString(fromDate),
                            toDate: Utils.formatDateTimeToString(toDate),
                            userId: userId,
                          );
                          print(widget.reminderId);
                          bool success = await APIService.updateReminder(widget.reminderId, updatedModel);
                          setState(() {
                              isAPICallProcess = false;
                          });

                          if (success) {
                            FormHelper.showSimpleAlertDialog(
                              context,
                              Config.appName,
                              "Reminder updated",
                              "OK",
                                  () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ViewReminderParentPage(userData: widget.userData),
                                  ),
                                );
                              },
                            );
                          }
                          else {
                          FormHelper.showSimpleAlertDialog(
                            context,
                            Config.appName,
                            "Failed to update reminder",
                            "OK",
                          () {
                              Navigator.of(context).pop();
                              },
                            );
                          }
                          }
                          },
                        fontSize: 16,
                        btnColor: kPrimaryColor,
                        txtColor: Colors.white,
                        borderRadius: 10,
                        borderColor: kPrimaryColor,),
                    ],
                  ),
                ],
              )
          ),

        ],

      ),

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
      );

      if(date == null) return null;

      final time = Duration(hours: initialDate.hour, minutes: initialDate.minute);

      return date.add(time);
    }else{
      final timeOfDay = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(initialDate),
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
