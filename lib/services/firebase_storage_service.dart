import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseStorageHelper {
  // Method to upload a video file
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

  // Method to delete a video file
  static Future<void> deleteVideo(String videoUrl) async {
    try {
      Reference ref = FirebaseStorage.instance.refFromURL(videoUrl);
      await ref.delete();
      print('Video deleted successfully.');
    } catch (e) {
      print('Error deleting video: $e');
    }
  }

  // Method to update a video file
  static Future<void> updateVideo(String oldVideoUrl, String newFilePath) async {
    try {
      await deleteVideo(oldVideoUrl);
      await uploadVideo(newFilePath);
    } catch (e) {
      print('Error updating video: $e');
    }
  }

  static Future<String?> uploadThumbnail(String thumbnailPath) async {

    final storageRef = FirebaseStorage.instance.ref().child('thumbnails/${DateTime.now().millisecondsSinceEpoch}');
    final uploadTask = storageRef.putFile(File(thumbnailPath));
    TaskSnapshot taskSnapshot = await uploadTask;
    String downloadURL = await taskSnapshot.ref.getDownloadURL();
    return downloadURL;
  }

  // Method to upload any file (including PDFs)
  static Future<String?> uploadFile(String filePath) async {
    try {
      Reference ref = FirebaseStorage.instance.ref().child('reports/${DateTime.now().millisecondsSinceEpoch}');
      UploadTask uploadTask = ref.putFile(File(filePath));
      TaskSnapshot taskSnapshot = await uploadTask;
      String downloadURL = await taskSnapshot.ref.getDownloadURL();
      return downloadURL;
    } catch (e) {
      print('Error uploading file: $e');
      return null;
    }
  }

  // Method to delete any file
  static Future<void> deleteFile(String fileUrl) async {
    try {
      Reference ref = FirebaseStorage.instance.refFromURL(fileUrl);
      await ref.delete();
      print('File deleted successfully.');
    } catch (e) {
      print('Error deleting file: $e');
    }
  }

  // Method to update any file (including PDFs)
  static Future<String?> updateFile(String oldFileUrl, String newFilePath) async {
    try {
      await deleteFile(oldFileUrl);
      String? newFileUrl = await uploadFile(newFilePath);
      return newFileUrl;
    } catch (e) {
      print('Error updating file: $e');
      return null;
    }
  }

}
