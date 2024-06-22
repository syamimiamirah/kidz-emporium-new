import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kidz_emporium/screens/therapist/view_report_therapist.dart';
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
import '../../services/firebase_storage_service.dart';

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
  late String file = '';
  PlatformFile? selectedFile;

  @override
  void initState() {
    super.initState();
    fetchReportDetails();
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null && result.files.isNotEmpty) {
      setState(() {
        selectedFile = result.files.first;
      });
    }
  }


  Future<void> fetchReportDetails() async {
    try {
      ReportModel? report = await APIService.getReportDetails(widget.reportId);

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
          file = report.file;
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
    String? fileName = selectedFile != null ? selectedFile!.path?.split('/').last : null;
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
              prefixIconPaddingBottom: 80,
              isMultiline: true,
              hintFontSize: 16,
              maxLength: TextField.noMaxLength,
              multilineRows: 5,
            ),
          ),

          const SizedBox(height: 10),
          GestureDetector(
            onTap: _pickFile,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey), // Change border color
              ),
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.file_upload,
                    color: kPrimaryColor,
                  ),
                  SizedBox(width: 10), // Add spacing between icon and text
                  Text(
                    'Upload Report',
                    style: TextStyle(
                      color: Colors.black, // Change text color
                      fontSize: 16,
                      fontWeight: FontWeight.bold, // Make text bold
                      fontFamily: 'Roboto', // Change font family
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 10), // Add some space between button and file name
          // Display file name if a file is selected
          fileName != null
              ? Text(
            'File Selected: $fileName',
            style: TextStyle(
              fontSize: 16,
              color: Colors.black,
            ),
          )
              : Container(),
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
                        if(validateAndSave() && selectedFile != null){
                          setState((){
                            isAPICallProcess = true; //API
                          });
                          String? fileURL = await FirebaseStorageHelper.updateFile(file, selectedFile!.path!);
                          print(fileURL);

                          ReportModel updatedModel = ReportModel(
                              userId: widget.userData.data!.id,
                              reportTitle: reportTitle,
                              reportDescription: description,
                              childId: childId,
                              bookingId: bookingId,
                              file: fileURL!,
                          );
                          print(widget.reportId);
                          bool success = await APIService.updateReport(widget.reportId, updatedModel);
                          setState(() {
                            isAPICallProcess = false;
                          });

                          if (success) {
                            _showCustomAlertDialog(
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
                              }, kPrimaryColor,
                            );
                          }
                          else {
                            _showCustomAlertDialog(
                              context,
                              Config.appName,
                              "Failed to update report",
                              "OK",
                                  () {
                                Navigator.of(context).pop();
                              }, kPrimaryColor,
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
