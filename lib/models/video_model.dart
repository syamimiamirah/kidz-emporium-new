import 'package:image_picker/image_picker.dart';
class VideoModel {
  late String userId;
  final String? id;
  String videoTitle;
  String videoDescription;
  List <String> childId;
  String file;
  final String? thumbnailPath;

  VideoModel({
    required this.userId,
    this.id,
    required this.videoTitle,
    required this.videoDescription,
    required this.childId,
    required this.file,
    this.thumbnailPath,
});

  factory VideoModel.fromJson(Map<String, dynamic> json) {
    return VideoModel(
        id: json['_id'],
        userId: json['userId'] ?? '',
        videoTitle: json['videoTitle'] ?? '',
        videoDescription: json['videoDescription'] ?? '',
        childId: List<String>.from(json['childId'] ?? []),
        file: json['filePath'] ?? '',
        thumbnailPath: json['thumbnail'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'userId': userId,
      'videoTitle': videoTitle,
      'videoDescription': videoDescription,
      'childId': childId,
      'filePath': file,
      'thumbnail': thumbnailPath,
      '_id': id,
    };
    if(id != null){
      data['_id'] = id;
    }
    return data;
  }
}