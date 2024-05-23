import 'package:flutter/material.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';
import 'package:kidz_emporium/Screens/therapist/view_report_therapist.dart';
import 'package:kidz_emporium/contants.dart';
import 'package:kidz_emporium/models/therapist_model.dart';
import 'package:snippet_coder_utils/FormHelper.dart';
import '../../components/side_menu.dart';
import '../../config.dart';
import '../../models/booking_model.dart';
import '../../models/child_model.dart';
import '../../models/login_response_model.dart';
import '../../models/report_model.dart';
import '../../models/user_model.dart';
import '../../services/api_service.dart';

class CreateReportTherapistPage extends StatefulWidget {
  final LoginResponseModel userData;
  final BookingModel booking;

  const CreateReportTherapistPage({Key? key, required this.userData, required this.booking}): super(key: key);
  @override
  _createReportPageState createState() => _createReportPageState();
}

class _createReportPageState extends State<CreateReportTherapistPage> {
  static final GlobalKey<FormState> globalFormKey = GlobalKey<FormState>();
  bool isAPICallProcess =  false;
  List<BookingModel> bookings = [];
  List<ChildModel> children = [];
  List<TherapistModel> therapists = [];
  List<UserModel> users = [];
  String? reportTitle;
  String? description;
  late String childId = '';
  late String childName = '';

  @override
  void initState() {
    super.initState();
    fetchBookingDetails();
  }

  Future<void> fetchBookingDetails() async {
    try {
      BookingModel? booking = await APIService.getBookingDetails(widget.booking.id!);

      if (booking != null) {
        // Update UI with fetched reminder details
        setState(() {
          childId = widget.booking.childId;
        });

        // Fetch child details
        await fetchChildDetails(childId);
      } else {
        // Handle case where reminder is null
        print('Booking details not found');
      }
    } catch (error) {
      print('Error fetching booking details: $error');
      // Handle error
    }
  }

  Future<void> fetchChildDetails(String childId) async {
    try {
      ChildModel? child = await APIService.getChildDetails(childId);

      if (child != null) {
        // Update UI with fetched child details
        setState(() {
          childName = child.childName;
        });
      } else {
        print('Child details not found');
      }
    } catch (error) {
      print('Error fetching child details: $error');
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Report'),
        centerTitle: true,
        backgroundColor: kPrimaryColor, // Change the color to match your theme
      ),
      body: ProgressHUD(
          child: Form(
            key: _createReportPageState.globalFormKey,
            child: _createReportUI(context),
          )
      ),
    );
  }
  Widget _createReportUI(BuildContext context){
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: FormHelper.inputFieldWidget(context, "child name", "Child Name", (onValidateVal){
              if(onValidateVal.isEmpty){
                return "Child name can't be empty";
              }
              return null;

            }, (onSavedVal){

            },
              initialValue: childName,
              prefixIconColor: kPrimaryColor,
              showPrefixIcon: true,
              prefixIcon: const Icon(Icons.child_care),
              borderRadius: 10,
              borderColor: Colors.grey,
              contentPadding: 15,
              fontSize: 16,
              prefixIconPaddingLeft: 10,
              hintFontSize: 16,
              isReadonly: true,
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: FormHelper.inputFieldWidget(context, "title", "Report Title", (onValidateVal){
              if(onValidateVal.isEmpty){
                return "Report title can't be empty";
              }
              return null;

            }, (onSavedVal){
              reportTitle = onSavedVal.toString().trim();
            },
              prefixIconColor: kPrimaryColor,
              showPrefixIcon: true,
              prefixIcon: const Icon(Icons.feedback),
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
              prefixIconPaddingTop: 0,
              isMultiline: true,
              hintFontSize: 16,
              maxLength: TextField.noMaxLength,
              multilineRows: 20,

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
                        Navigator.pop(context);
                      },
                        btnColor: Colors.grey,
                        txtColor: Colors.black,
                        borderRadius: 10,
                        borderColor: Colors.grey,
                        fontSize: 16,
                      ),
                      SizedBox(width: 20),
                      FormHelper.submitButton(
                        "Save", (){
                        if(validateAndSave()){
                          setState((){
                            isAPICallProcess = true; //API
                          });
                          ReportModel model = ReportModel(
                            userId: widget.userData.data!.id,
                            reportTitle: reportTitle!,
                            reportDescription: description!,
                            childId: widget.booking.childId,
                            bookingId: widget.booking.id!

                          );
                          APIService.createReport(model).then((response) {
                            print(response);
                            setState(() {
                              isAPICallProcess = false;
                            });

                            if (response != null) {
                              FormHelper.showSimpleAlertDialog(
                                context,
                                Config.appName,
                                "Report created",
                                "OK",
                                    () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ViewReportTherapistPage(userData: widget.userData),
                                    ),
                                  );
                                },
                              );
                            } else {
                              FormHelper.showSimpleAlertDialog(
                                context,
                                Config.appName,
                                "Reminder failed to create",
                                "OK",
                                    () {
                                  Navigator.of(context).pop();
                                },
                              );
                            }
                          });
                        }},
                        fontSize: 16,
                        btnColor: Colors.orange,
                        txtColor: Colors.black,
                        borderRadius: 10,
                        borderColor: Colors.orange,),
                    ],
                  ),
                ],
              )
          ),

        ],

      ),

    );
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
