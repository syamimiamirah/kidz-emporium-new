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

class UpdateReportTherapistPage extends StatefulWidget {
  final LoginResponseModel userData;
  final String reportId;

  const UpdateReportTherapistPage({Key? key, required this.userData, required this.reportId}): super(key: key);
  @override
  _updateReportPageState createState() => _updateReportPageState();
}

class _updateReportPageState extends State<UpdateReportTherapistPage> {
  static final GlobalKey<FormState> globalFormKey = GlobalKey<FormState>();
  bool isAPICallProcess =  false;
  List<UserModel> users = [];
  late String reportTitle = "";
  late String description = "";
  late String childId = '';
  late String childName = '';
  late String bookingId = '';

  @override
  void initState() {
    super.initState();
    fetchReportDetails();
  }

  Future<void> fetchReportDetails() async {
    try {
      ReportModel? report = (await APIService.getReportDetails(widget.reportId)) as ReportModel?;

      if (report != null) {
        // Update UI with fetched reminder details
        setState(() async {
          reportTitle = report.reportTitle;
          description = report.reportDescription;
          childId = report.childId;
          ChildModel? child = await APIService.getChildDetails(childId);
          if(child != null) {
            setState(() {
              childName = child.childName;
            });
          }else{
            print('Child details not found');
          }
        });
      } else {
        // Handle case where reminder is null
        print('Report details not found');
      }
    } catch (error) {
      print('Error fetching report details: $error');
      // Handle error
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Update Report'),
        centerTitle: true,
        backgroundColor: kPrimaryColor, // Change the color to match your theme
      ),
      body: ProgressHUD(
          child: Form(
            key: _updateReportPageState.globalFormKey,
            child: _updateReportUI(context),
          )
      ),
    );
  }
  Widget _updateReportUI(BuildContext context){
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
              initialValue: reportTitle,
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
              initialValue: description,
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
                        "Save", () async {
                        if(validateAndSave()){
                          setState((){
                            isAPICallProcess = true; //API
                          });
                          ReportModel updatedModel = ReportModel(
                              userId: widget.userData.data!.id,
                              reportTitle: reportTitle,
                              reportDescription: description,
                              childId: childId,
                              bookingId: bookingId,
                          );
                          print(widget.reportId);
                          bool success = await APIService.updateReport(widget.reportId, updatedModel);
                          setState(() {
                            isAPICallProcess = false;
                          });

                          if (success) {
                            FormHelper.showSimpleAlertDialog(
                              context,
                              Config.appName,
                              "Report updated",
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
                          }
                          else {
                            FormHelper.showSimpleAlertDialog(
                              context,
                              Config.appName,
                              "Failed to update report",
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
