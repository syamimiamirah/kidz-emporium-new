import 'dart:async';
import 'package:flutter/material.dart';
import 'package:kidz_emporium/screens/parent/watch_video_parent.dart';
import 'package:kidz_emporium/screens/parent/watch_youtube_parent.dart';
import 'package:kidz_emporium/screens/therapist/watch_video_therapist.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:kidz_emporium/components/side_menu.dart';
import 'package:kidz_emporium/models/login_response_model.dart';
import 'package:kidz_emporium/models/video_model.dart';
import 'package:kidz_emporium/services/api_service.dart';
import 'package:kidz_emporium/services/firebase_storage_service.dart';
import 'package:kidz_emporium/models/youtube_model.dart';
import '../../config.dart';
import '../../contants.dart';
import '../../models/child_model.dart';

class ViewVideoParentPage extends StatefulWidget {
  final LoginResponseModel userData;

  const ViewVideoParentPage({Key? key, required this.userData}) : super(key: key);

  @override
  _ViewVideoParentPageState createState() => _ViewVideoParentPageState();
}

class _ViewVideoParentPageState extends State<ViewVideoParentPage> with SingleTickerProviderStateMixin {
  List<VideoModel> videos = [];
  late Future<List<YoutubeModel>> youtubeVideos;
  TextEditingController searchController = TextEditingController();
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadVideos(widget.userData.data!.id);
    youtubeVideos = APIService.fetchVideosByChannelId('UCzWxpAV6ospqUqZqOdna44A'); // Replace with your channel ID
  }

  Future<void> _loadVideos(String userId) async {
    try {
      List<VideoModel> videoList = await APIService.getAllVideos();
      List<ChildModel> childList = await APIService.getChild(userId);

      // Extract child IDs from the child list
      // List<String?> childIds = childList.map((child) => child.id).toList();
      //
      // // Filter videos that belong to the user's children
      // videoList = videoList.where((video) => childIds.contains(video.childId)).toList();
      setState(() {
        videos = videoList;
      });
    } catch (error) {
      print('Error loading videos: $error');
      showAlertDialog(context, "Error loading videos");
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

  List<YoutubeModel> filterVideos(String query, List<YoutubeModel> videos) {
    return videos.where((video) {
      final titleLower = video.title?.toLowerCase() ?? '';
      final queryLower = query.toLowerCase();
      return titleLower.contains(queryLower);
    }).toList();
  }

  void _resetSearch() {
    setState(() {
      searchController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavBar(userData: widget.userData),
      appBar: AppBar(
        title: Text('Videos'),
        centerTitle: true,
        backgroundColor: kSecondaryColor,
        bottom: TabBar(
          controller: _tabController,
          indicator: UnderlineTabIndicator(
            borderSide: BorderSide(width: 4.0, color: Colors.white),
          ),
          labelStyle: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
          unselectedLabelStyle: TextStyle(fontSize: 14.0),
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: [
            Tab(text: 'Private Videos'),
            Tab(text: 'Public Videos'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildLocalVideosTab(),
          _buildYouTubeVideosTab(),
        ],
      ),
    );
  }

  Widget _buildLocalVideosTab() {
    return Padding(
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
                return Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                    side: BorderSide(color: Colors.grey.shade300, width: 1),
                  ),
                  child: ListTile(
                    title: Text(videos[index].videoTitle, style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)),
                    subtitle: Text(
                      videos[index].videoDescription,
                      maxLines: 4, // Limit to 3 lines
                      overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 14.0,)),  // Display ellipsis if overflow
                    leading: videos[index].thumbnailPath != null ? Image.network(videos[index].thumbnailPath!) : SizedBox.shrink(),
                    onTap: () {
                      Navigator.push(
                        context, MaterialPageRoute(
                        builder: (context) =>
                            WatchVideoParentPage(
                                userData: widget.userData,
                                video: videos[index]),
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
    );
  }


  Widget _buildYouTubeVideosTab() {
    return FutureBuilder<List<YoutubeModel>>(
      future: youtubeVideos,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          print('Error fetching videos: ${snapshot.error}');
          return Center(
            child: Text(
              'Error fetching videos. Please try again.',
              style: TextStyle(color: Colors.red),
            ),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Text(
              'No videos found.',
              style: TextStyle(fontSize: 18),
            ),
          );
        } else {
          List<YoutubeModel> youtubeVideos = snapshot.data!;

          // Filter videos based on the search query
          List<YoutubeModel> filteredVideos =
          filterVideos(searchController.text, youtubeVideos);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    labelText: 'Search Videos',
                    prefixIcon: Icon(Icons.search),
                    fillColor: Colors.grey[200],
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (query) {
                    setState(() {
                      // Update the filteredVideos when the user types in the search field
                      filteredVideos = filterVideos(query, youtubeVideos);
                    });
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'YouTube Videos',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: filteredVideos.length,
                  itemBuilder: (context, index) {
                    final video = filteredVideos[index];

                    return Card(
                      elevation: 2,
                      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                      child: ListTile(
                        contentPadding: EdgeInsets.all(8.0),
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            video.thumbnailUrl ?? '',
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                        ),
                        title: Text(
                          video.title ?? '',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 4),
                            Text(
                              'Description: ${video.description ?? ''}',
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => VideoPlayerParentPage(
                                videoId: video.videoId ?? '',
                                title: video.title,
                                description: video.description,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        }
      },
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
