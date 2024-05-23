import 'package:flutter/material.dart';
import 'package:kidz_emporium/models/video_model.dart';
import 'package:video_player/video_player.dart';
import '../../contants.dart';
import '../../models/login_response_model.dart';

class WatchVideoTherapistPage extends StatefulWidget {
  final LoginResponseModel userData;
  final VideoModel video;

  const WatchVideoTherapistPage({ Key? key, required this.userData, required this.video}) :super(key: key);
  @override
  _WatchVideoTherapistPageState createState() => _WatchVideoTherapistPageState();

}
class _WatchVideoTherapistPageState extends State<WatchVideoTherapistPage> {

  late VideoPlayerController _videoPlayerController;
  late Future<void> _initializeVideoPlayerFuture;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _videoPlayerController = VideoPlayerController.network(widget.video.file);
    _initializeVideoPlayerFuture = _videoPlayerController.initialize();
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Watch Video'),
        centerTitle: true,
        backgroundColor: kSecondaryColor,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FutureBuilder(
            future: _initializeVideoPlayerFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return AspectRatio(
                  aspectRatio: _videoPlayerController.value.aspectRatio,
                  child: Stack(
                    children: [
                      VideoPlayer(_videoPlayerController),
                      Center(
                        child: IconButton(
                          icon: Icon(
                            _isPlaying ? Icons.pause : Icons.play_arrow,
                            size: 50,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            setState(() {
                              _isPlaying ? _videoPlayerController.pause() : _videoPlayerController.play();
                              _isPlaying = !_isPlaying;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                );
              } else {
                return Center(child: CircularProgressIndicator());
              }
            },
          ),
          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.only(left: 10.0),
            child: Text(
              widget.video.videoTitle,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.only(left: 10.0),
            child: Text(
              widget.video.videoDescription,
              style: TextStyle(
                fontSize: 16,
              ),
            ),
          ),
          SizedBox(height: 10),
          Center(
            child:
              ElevatedButton(
                onPressed: () {
                  // Add your update logic here
                },
                style: ElevatedButton.styleFrom(
                  primary: kSecondaryColor,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Update',
                  style: TextStyle(fontSize: 16),
                ),
              )
          )
        ],
      ),
    );
  }
}