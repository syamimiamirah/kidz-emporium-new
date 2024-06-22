import 'package:flutter/material.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';
import 'package:kidz_emporium/screens/admin/view_booking_admin.dart';
import 'package:kidz_emporium/services/api_service.dart';
import 'package:snippet_coder_utils/FormHelper.dart';

import '../../config.dart';
import '../../contants.dart';
import '../../models/login_response_model.dart';

class AdminSendMessagePage extends StatefulWidget {
  final LoginResponseModel userData;
  final String bookingId;

  const AdminSendMessagePage({Key? key, required this.userData, required this.bookingId}) : super(key: key);

  @override
  _AdminSendMessagePageState createState() => _AdminSendMessagePageState();
}

class _AdminSendMessagePageState extends State<AdminSendMessagePage> {
  static final GlobalKey<FormState> globalFormKey = GlobalKey<FormState>();

  // Example list of available dates as placeholders
  List<String> availableDates = [
    'dd/mm/yyyy',
    'dd/mm/yyyy',
    'dd/mm/yyyy',
  ];

  // Generate message with bullet points
  String generateMessage() {
    String baseMessage = "We are sorry, the chosen date has no available therapist. Please reschedule your session based on the dates below:\n\n";
    String bulletPoints = availableDates.map((date) => '• $date').join('\n');
    return baseMessage + bulletPoints;
  }

  String subject = "Booking Date is Not Available";
  String message = "";

  @override
  void initState() {
    super.initState();
    message = generateMessage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Compose Message'),
        centerTitle: true,
        backgroundColor: kSecondaryColor,
      ),
      body: ProgressHUD(
        child: Form(
          key: _AdminSendMessagePageState.globalFormKey,
          child: _AdminSendMessageUI(context),
        ),
      ),
    );
  }

  Widget _AdminSendMessageUI(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 10),
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 10),
              child: FormHelper.inputFieldWidget(
                context,
                "subject",
                'Subject',
                    (onValidateVal) {
                  if (onValidateVal.isEmpty) {
                    return "Subject can't be empty";
                  }
                  return null;
                },
                    (onSavedVal) {
                  subject = onSavedVal.toString().trim();
                },
                prefixIconColor: kSecondaryColor,
                showPrefixIcon: true,
                prefixIcon: const Icon(Icons.task),
                borderRadius: 10,
                borderColor: Colors.grey,
                contentPadding: 15,
                fontSize: 16,
                prefixIconPaddingLeft: 10,
                hintFontSize: 16,
                initialValue: subject, // Set initial value
              ),
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 10),
              child: FormHelper.inputFieldWidget(
                context,
                "message",
                "Message",
                    (onValidateVal) {
                  if (onValidateVal.isEmpty) {
                    return "Message can't be empty";
                  }
                  return null;
                },
                    (onSavedVal) {
                  message = onSavedVal.toString().trim();
                },
                prefixIconColor: kSecondaryColor,
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
                initialValue: message, // Set initial value
              ),
            ),
          ),
          SizedBox(height: 20),
          Center(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FormHelper.submitButton(
                      "Cancel",
                          () {
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
                      "Send",
                          () async {
                        if (validateAndSave()) {
                          // Print the subject and message before submission
                          print("Subject: $subject");
                          print("Message: $message");

                          bool sent = await APIService.sendNotification(
                            widget.bookingId,
                            subject,
                            message,
                          );
                          if (sent) {
                            _showCustomAlertDialog(
                              context,
                              Config.appName,
                              "Your message has been sent successfully.",
                              "OK",
                                  () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ViewBookingAdminPage(userData: widget.userData),
                                  ),
                                );
                              },
                              kPrimaryColor,  // Change this color to the desired color
                            );
                          } else {
                            _showCustomAlertDialog(
                              context,
                              Config.appName,
                              "Message failed to send",
                              "OK",
                                  () {
                                Navigator.of(context).pop();
                              },
                              kPrimaryColor,  // Change this color to the desired color
                            );
                          }
                        }
                      },
                      btnColor: Colors.pink,
                      txtColor: Colors.white,
                      borderRadius: 10,
                      fontSize: 16,
                      borderColor: Colors.pink,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool validateAndSave() {
    final form = globalFormKey.currentState;
    if (form != null && form.validate()) {
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
