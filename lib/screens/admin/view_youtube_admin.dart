import 'package:flutter/material.dart';
import 'package:kidz_emporium/Screens/admin/watch_youtube_admin.dart';
import '../../components/side_menu.dart';
import '../../contants.dart';
import '../../models/login_response_model.dart';
import '../../models/youtube_model.dart';
import '../../services/api_service.dart';

class ViewYoutubeAdmin extends StatefulWidget {
  final LoginResponseModel userData;

  const ViewYoutubeAdmin({Key? key, required this.userData}) : super(key: key);

  @override
  _ViewYoutubeAdminPageState createState() => _ViewYoutubeAdminPageState();
}

class _ViewYoutubeAdminPageState extends State<ViewYoutubeAdmin> {
  late Future<List<YoutubeModel>> videos;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Replace 'UCzWxpAV6ospqUqZqOdna44A' with your actual channel ID
    videos = APIService.fetchVideosByChannelId('UCzWxpAV6ospqUqZqOdna44A');
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
      drawer: AdminNavBar(userData: widget.userData),
      appBar: AppBar(
        title: Text('YouTube Video List'),
        centerTitle: true,
        backgroundColor: kSecondaryColor,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _resetSearch,
          ),
        ],
      ),
      body: FutureBuilder<List<YoutubeModel>>(
        future: videos,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            // Print the error message for debugging
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
                    'All Videos',
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
                            // Navigate to the VideoPlayerPage when a video is tapped
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => VideoPlayerPage(
                                  videoId: video.videoId ?? '',
                                  title: video.title,
                                  description: video.description
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
      ),
    );
  }
}
