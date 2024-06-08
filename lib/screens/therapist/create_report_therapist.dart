import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';
import 'package:image_picker/image_picker.dart';
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
import '../../services/firebase_storage_service.dart';

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
  PlatformFile? selectedFile;

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
                        if(validateAndSave()){
                          setState((){
                            isAPICallProcess = true; //API
                          });
                          String? fileURL = await FirebaseStorageHelper.uploadFile(selectedFile!.path!);
                          print(fileURL);
                          ReportModel model = ReportModel(
                            userId: widget.userData.data!.id,
                            reportTitle: reportTitle!,
                            reportDescription: description!,
                            childId: widget.booking.childId,
                            bookingId: widget.booking.id!,
                            file: fileURL!,
                          );
                          APIService.createReport(model).then((response) {
                            print(response);
                            setState(() {
                              isAPICallProcess = false;
                            });

                            if (response != null) {
                              _showCustomAlertDialog(
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
                                }, kPrimaryColor,
                              );
                            } else {
                              _showCustomAlertDialog(
                                context,
                                Config.appName,
                                "Reminder failed to create",
                                "OK",
                                    () {
                                  Navigator.of(context).pop();
                                }, kPrimaryColor,
                              );
                            }
                          });
                        }},
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
