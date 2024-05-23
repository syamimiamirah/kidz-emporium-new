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

  @override
  void initState() {
    super.initState();
    _loadVideos(widget.userData.data!.id);
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

  Future<String?> generateThumbnail(String videoUrl) async {
    final thumbnailUrl = await VideoThumbnail.thumbnailFile(
      video: videoUrl,
      thumbnailPath: (await getTemporaryDirectory()).path,
      imageFormat: ImageFormat.WEBP,
    );
    return thumbnailUrl;
  }

  void _deleteVideo(int index) {
    setState(() {
      videos.removeAt(index);
    });
  }

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
                  return Dismissible(
                    key: Key(videos[index].id ?? ''), // Provide a unique key for each item
                    onDismissed: (direction) async {
                      String? videoId = videos[index].id;
                      String? videoPath = videos[index].file;

                      // Ensure the reminderId is not null before attempting deletion
                      if (videoId != null) {
                        bool deleteConfirmed = await showDeleteConfirmationDialog(context);

                        if (deleteConfirmed) {
                          await FirebaseStorageHelper.deleteVideo(videoPath);
                          bool deleteSuccess = await APIService.deleteVideo(videoId);

                          if (deleteSuccess) {
                            setState(() {
                              videos!.removeAt(index);
                            });

                            showAlertDialog(context, 'Video deleted successfully');
                          } else {
                            showAlertDialog(context, 'Failed to delete video');
                          }
                        }
                      }
                    },
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerLeft,
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Icon(
                        Icons.delete,
                        color: Colors.white,
                      ),
                    ),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context, MaterialPageRoute(
                          builder: (context) =>
                              WatchVideoTherapistPage(
                                  userData: widget.userData,
                                  video: videos[index]),
                        ),
                        );
                        print('Video tapped: ${videos[index].videoTitle}');
                      },
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                          side: BorderSide(color: Colors.grey.shade300, width: 1),
                        ),
                        child: ListTile(
                          title: Text(videos[index].videoTitle),
                          subtitle: Text(videos[index].videoDescription),
                          leading: FutureBuilder<String?>(
                            future: generateThumbnail(videos[index].file),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.done && snapshot.hasData && snapshot.data!.isNotEmpty) {
                                return Image.file(File(snapshot.data!));
                              } else {
                                return SizedBox.shrink();
                              }
                            },
                          ),
                        ),
                      ),
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
        backgroundColor: kSecondaryColor,
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
