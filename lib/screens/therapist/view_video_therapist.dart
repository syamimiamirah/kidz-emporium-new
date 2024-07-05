import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:kidz_emporium/screens/therapist/watch_video_therapist.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import 'package:kidz_emporium/components/side_menu.dart';
import 'package:kidz_emporium/models/login_response_model.dart';
import 'package:kidz_emporium/models/video_model.dart';
import 'package:kidz_emporium/services/api_service.dart';

import '../../config.dart';
import '../../contants.dart';
import '../../models/child_model.dart';
import '../../services/firebase_storage_service.dart';
import 'create_video_therapist.dart';

class ViewVideoTherapistPage extends StatefulWidget {
  final LoginResponseModel userData;

  const ViewVideoTherapistPage({Key? key, required this.userData}) : super(key: key);

  @override
  _ViewVideoTherapistPageState createState() => _ViewVideoTherapistPageState();
}

class _ViewVideoTherapistPageState extends State<ViewVideoTherapistPage> {
  List<VideoModel> videos = [];
  List<ChildModel> childList = [];

  @override
  void initState() {
    super.initState();
    _loadVideos(widget.userData.data!.id);
    _loadChildren();
  }

  Future<void> _loadVideos(String userId) async {
    try {
      List<VideoModel> videoList = await APIService.getVideo(userId);
      setState(() {
        videos = videoList;
      });
    } catch (error) {
      print('Error loading videos: $error');
    }
  }
  Future<void> _loadChildren () async {
    try {
      List<ChildModel> children = await APIService.getAllChildren();

      setState(() {
        childList = children;
      });
    } catch (error) {
      print('Error loading child data: $error');
    }
  }

  String? getChildNameById(String? childId) {
    print('Fetching name for Child ID: $childId');
    final child = childList.firstWhere((child) => child.id == childId, orElse: () => ChildModel(childName: 'Not Defined', birthDate: '', gender: '', program: '', userId: ''));
    print('Child Name: ${child.childName}');
    return child.childName;
  }


  // Future<String?> generateThumbnail(String videoUrl) async {
  //   final thumbnailUrl = await VideoThumbnail.thumbnailFile(
  //     video: videoUrl,
  //     thumbnailPath: (await getTemporaryDirectory()).path,
  //     imageFormat: ImageFormat.WEBP,
  //   );
  //   return thumbnailUrl;
  // }

  void _deleteVideo(int index) {
    setState(() {
      videos.removeAt(index);
    });
  }

  // Update the build method to use the thumbnailUrl field
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: TherapistNavBar(userData: widget.userData),
      appBar: AppBar(
        title: Text('Video List'),
        centerTitle: true,
        backgroundColor: kSecondaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'List of Videos',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: videos.length,
                itemBuilder: (context, index) {
                  final childNames = videos[index].childId?.map(getChildNameById).whereType<String>().join(', ') ?? '';
                  return Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                      side: BorderSide(color: Colors.grey.shade300, width: 1),
                    ),
                    child: ListTile(
                      contentPadding: EdgeInsets.all(12.0),
                      title: Text(
                        videos[index].videoTitle,
                        style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 4),
                          Text(
                            videos[index].videoDescription ?? '',
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 14.0),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Child: $childNames',
                            style: TextStyle(fontSize: 14.0, fontStyle: FontStyle.italic),
                          ),
                        ],
                      ),
                      leading: videos[index].thumbnailPath != null
                          ? Image.network(
                        videos[index].thumbnailPath!,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      )
                          : SizedBox.shrink(),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => WatchVideoTherapistPage(
                              userData: widget.userData,
                              video: videos[index],
                            ),
                          ),
                        );
                        print('Video tapped: ${videos[index].videoTitle}');
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CreateVideoTherapistPage(userData: widget.userData),
            ),
          );
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.pink,
      ),
    );
  }

  Future<bool> showDeleteConfirmationDialog(BuildContext context) async {
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(Config.appName),
          content: Text('Are you sure you want to delete this video?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // Return false when cancel is pressed
              },
              child: Text('Cancel', style: TextStyle(color: Colors.black),),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // Return true when delete is pressed
              },
              child: Text('Delete', style: TextStyle(color: kSecondaryColor),),
            ),
          ],
        );
      },
    );
  }

  void showAlertDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(Config.appName),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK', style: TextStyle(color: kSecondaryColor),),
            ),
          ],
        );
      },
    );
  }
}
