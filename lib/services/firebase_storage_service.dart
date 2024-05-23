import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

class FirebaseStorageHelper {
  static Future<String?> uploadVideo(String filePath) async {
    try {
      Reference ref = FirebaseStorage.instance.ref().child('videos/${DateTime.now().millisecondsSinceEpoch}');
      UploadTask uploadTask = ref.putFile(File(filePath));
      TaskSnapshot taskSnapshot = await uploadTask;
      String downloadURL = await taskSnapshot.ref.getDownloadURL();
      return downloadURL;
    } catch (e) {
      print('Error uploading video: $e');
      return null;
    }
  }

  static Future<void> deleteVideo(String videoUrl) async {
    try {
      // Get a reference to the video in Firebase Storage
      Reference ref = FirebaseStorage.instance.refFromURL(videoUrl);

      // Delete the video
      await ref.delete();

      print('Video deleted successfully.');
    } catch (e) {
      print('Error deleting video: $e');
    }
  }

  static Future<void> updateVideo(String oldVideoUrl, String newFilePath) async {
    try {
      // Delete the old video
      await FirebaseStorage.instance.refFromURL(oldVideoUrl).delete();

      // Upload the new video
      await uploadVideo(newFilePath);
    } catch (e) {
      print('Error updating video: $e');
    }
  }
}
