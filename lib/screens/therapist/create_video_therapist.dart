import 'package:flutter/material.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kidz_emporium/Screens/therapist/view_video_therapist.dart';
import 'package:kidz_emporium/models/login_response_model.dart';
import 'package:kidz_emporium/contants.dart';
import 'package:kidz_emporium/services/api_service.dart';
import 'package:snippet_coder_utils/FormHelper.dart';

import '../../config.dart';
import '../../models/child_model.dart';
import '../../models/video_model.dart';
import '../../services/firebase_storage_service.dart';

class CreateVideoTherapistPage extends StatefulWidget {
  final LoginResponseModel userData;

  const CreateVideoTherapistPage({Key? key, required this.userData}): super(key: key);
  @override
  _createVideoTherapistPageState createState() => _createVideoTherapistPageState();

}

class _createVideoTherapistPageState extends State<CreateVideoTherapistPage> {
  static final GlobalKey<FormState> globalFormKey = GlobalKey<FormState>();
  bool isAPICallProcess = false;
  late String userId;
  String? videoTitle;
  String? videoDescription;
  List<String> selectedChildren = [];
  List<ChildModel> children= [];
  XFile? selectedVideo;

  Future<void> _loadChildren() async {
    try{
      List<ChildModel> allChildren = await APIService.getAllChildren();
      setState(() {
        children = allChildren;
      });
    }catch(error){
      print('Error loading children: $error');
    }
  }

  Future<void> _pickVideo() async {
    final XFile? video = await ImagePicker().pickVideo(source: ImageSource.gallery);
    setState(() {
      selectedVideo = video!;
    });
  }

  @override
  void initState(){
    _loadChildren();
    super.initState();
    if (widget.userData != null && widget.userData.data != null) {
      print("userData: ${widget.userData.data!.id}");
      userId = widget.userData.data!.id;
    } else {
      print("Error: userData or userData.data is null");
    }
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text('Upload Video'),
        centerTitle: true,
        backgroundColor: kSecondaryColor,
      ),
      body: ProgressHUD(
        child: Form(
          key: _createVideoTherapistPageState.globalFormKey,
          child: _createVideoTherapistUI(context),
        )
      )
    );
  }

  Widget _createVideoTherapistUI(BuildContext context){
    String? fileName = selectedVideo != null ? selectedVideo!.path.split('/').last : null;
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 10),
          Center(
            child: Padding(padding: const EdgeInsets.only(top: 10),
              child: FormHelper.inputFieldWidget(context, "video title", 'Video Title', (onValidateVal){
                if(onValidateVal.isEmpty){
                  return "Video title can't be empty";
                }
                return null;
              }, (onSavedVal){
                videoTitle = onSavedVal.toString().trim();
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
                  videoDescription = onSavedVal.toString().trim();
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
          const SizedBox(height: 10),
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
                            color: kSecondaryColor, // Icon color
                          ),
                        ),
                        Text(
                          'Children',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: children.map((child) {
                        return CheckboxListTile(
                          title: Text(
                            child.childName,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          value: selectedChildren.contains(child.id),
                          onChanged: (bool? value) {
                            setState(() {
                              if (value != null && value) {
                                selectedChildren.add(child.id!);
                              } else {
                                selectedChildren.remove(child.id);
                              }
                            });
                          },
                          controlAffinity: ListTileControlAffinity.leading,
                          activeColor: kSecondaryColor, // Change the color of the checkbox when selected
                          checkColor: Colors.white, // Change the color of the checkmark
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: _pickVideo,
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
                    Icons.video_library,
                    color: kSecondaryColor,
                  ),
                  SizedBox(width: 10), // Add spacing between icon and text
                  Text(
                    'Choose Video',
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
                        Navigator.pushReplacement(context, MaterialPageRoute(
                            builder: (context) =>  ViewVideoTherapistPage(userData:widget.userData)),
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
                        if(validateAndSave() && selectedVideo != null){
                          setState(() {
                            isAPICallProcess = true;
                          });

                          String? videoURL = await FirebaseStorageHelper.uploadVideo(selectedVideo!.path!);
                          print(videoURL);

                          VideoModel model = VideoModel(
                            userId: widget.userData.data!.id,
                            videoTitle: videoTitle!,
                            videoDescription: videoDescription!,
                            childId: selectedChildren,
                            file: videoURL!,
                          );

                          APIService.createVideo(model).then((response) {
                            print(videoURL);
                            print(response);
                            setState(() {
                              isAPICallProcess = false;
                            });
                            if (response != null) {
                              FormHelper.showSimpleAlertDialog(
                                context, Config.appName,
                                "Video uploaded", "OK", () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        ViewVideoTherapistPage(
                                            userData: widget.userData),
                                  ),
                                );
                              },
                              );
                            } else {
                              FormHelper.showSimpleAlertDialog(
                                context,
                                Config.appName,
                                "Video failed to upload",
                                "OK",
                                    () {
                                  Navigator.of(context).pop();
                                },
                              );
                            }
                          });

                        }
                      },
                        btnColor: Colors.pink,
                        txtColor: Colors.white,
                        borderRadius: 10,
                        fontSize: 16,
                        borderColor: Colors.pink,
                      ),
                    ],
                  )
                ],
              )
          )
        ],
      )
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