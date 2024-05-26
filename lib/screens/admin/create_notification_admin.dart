import 'package:flutter/material.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';
import 'package:kidz_emporium/Screens/admin/view_booking_admin.dart';
import 'package:kidz_emporium/contants.dart';
import 'package:kidz_emporium/services/api_service.dart';
import 'package:kidz_emporium/services/local_notification.dart';
import 'package:snippet_coder_utils/FormHelper.dart';

import '../../config.dart';
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
  TextEditingController _recipientController = TextEditingController();
  TextEditingController _subjectController = TextEditingController();
  TextEditingController _messageController = TextEditingController();
  String subject = "";
  String message = "";

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
                            FormHelper.showSimpleAlertDialog(
                              context,
                              Config.appName,
                              "Your message has been sent successfully.",
                              "OK",
                                  () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        ViewBookingAdminPage(userData: widget.userData),
                                  ),
                                );
                              },
                            );
                          } else {
                            FormHelper.showSimpleAlertDialog(
                              context,
                              Config.appName,
                              "Message failed to send",
                              "OK",
                                  () {
                                Navigator.of(context).pop();
                              },
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
}
