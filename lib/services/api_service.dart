import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:kidz_emporium/config.dart';
import 'package:kidz_emporium/models/booking_model.dart';
import 'package:kidz_emporium/models/child_model.dart';
import 'package:kidz_emporium/models/livestream_model.dart';
import 'package:kidz_emporium/models/login_response_model.dart';
import 'package:kidz_emporium/models/register_request_model.dart';
import 'package:kidz_emporium/models/register_response_model.dart';
import 'package:kidz_emporium/models/login_request_model.dart';
import 'package:kidz_emporium/models/reminder_model.dart';
import 'package:kidz_emporium/models/task_model.dart';
import 'package:kidz_emporium/services/shared_service.dart';

import '../models/payment_model.dart';
import '../models/report_model.dart';
import '../models/therapist_model.dart';
import '../models/user_model.dart';
import '../models/video_model.dart';
import '../models/youtube_model.dart';
import '../utils.dart';

class APIService{
  static var client = http.Client();

  static Future<bool> login(LoginRequestModel model) async{
    Map<String, String> requestHeaders = {
      'Content-Type': 'application/json',
    };

    var url = Uri.http(Config.apiURL, Config.loginAPI);

    var response = await client.post(
      url,
      headers: requestHeaders,
      body: jsonEncode(model.toJson()),
    );

    if(response.statusCode == 200){
      final Map<String, dynamic> data = json.decode(response.body);

      // Access the _id
      //final String userId = data['data']['_id']; // Update this line
      //shared
    await SharedService.setLoginDetails(loginResponseJson(response.body));
      return true;
    }else{
      return false;
    }

  }
  static Future<bool> register(RegisterRequestModel model) async {
    Map<String, String> requestHeaders = {
      'Content-Type': 'application/json',
    };

    var url = Uri.http(Config.apiURL, Config.registerAPI);

    var response = await client.post(
      url,
      headers: requestHeaders,
      body: jsonEncode(model.toJson()),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      // Print or log relevant information
      print("Response data: $data");
      await SharedService.setLoginDetails(loginResponseJson(response.body));
      return true;
    } else {
      return false;
    }
  }

  static Future<List<UserModel>> getAllUsers() async {
    var url = await Uri.http(
        Config.apiURL, Config.getAllUsersAPI); // Adjust the endpoint

    try {
      var response = await client.get(
        url,
        headers: {'Content-Type': 'application/json'},
      ).timeout(Duration(seconds: 10));


      if (response.statusCode == 200) {
        final dynamic responseData = json.decode(response.body);

        if (responseData['status'] == true &&
            responseData.containsKey('success')) {
          List<UserModel> users = (responseData['success'] as List)
              .map((json) => UserModel.fromJson(json))
              .toList();

          return users;
        } else {
          print(
              "Invalid response format. Expected 'status' true and 'success' key.");
          return [];
        }
      } else {
        print(
            "Failed to fetch all users. Status code: ${response.statusCode}");
        return [];
      }
    } catch (error) {
      print("Error fetching all users: $error");
      return [];
    }
  }
  static Future<void> sendTokenToBackend(String token, String email) async {
    try {
      Map<String, String> requestHeaders = {
        'Content-Type': 'application/json',
      };

      // Construct the URL for the backend API endpoint
      var url = Uri.http(Config.apiURL, Config.sendTokenToBackend);
      print("Token: $token");

      // Convert the body data to JSON format
      String jsonBody = jsonEncode({'email': email, 'fcmToken': token});

      // Make an HTTP POST request to the backend API
      var response = await client.post(
        url,
        headers: requestHeaders,
        body: jsonBody, // Use the JSON-formatted body
      );

      // Check the response status code
      if (response.statusCode == 200) {
        print('FCM token registered successfully');
      } else {
        print('Failed to register FCM token: ${response.statusCode}');
      }
    } catch (error) {
      print('Error sending FCM token to backend: $error');
    }
  }

  static Future<bool> sendNotification(String bookingId, String subject, String message) async {
    try {
      Map<String, String> requestHeaders = {
        'Content-Type': 'application/json',
      };

      // Construct the URL for the backend API endpoint
      var url = Uri.http(Config.apiURL, Config.createNotification);
      //print("Token: $token");

      // Convert the body data to JSON format
      String jsonBody = jsonEncode({'bookingId': bookingId, 'title': subject, 'body': message});

      // Make an HTTP POST request to the backend API
      var response = await client.post(
        url,
        headers: requestHeaders,
        body: jsonBody, // Use the JSON-formatted body
      );

      // Check the response status code
      if (response.statusCode == 200) {
        print('Notification sent successfully');
        return true; // Return true indicating success
      } else {
        print('Failed to send notification: ${response.statusCode}');
        return false; // Return false indicating failure
      }
    } catch (error) {
      print('Error sending notification #: $error');
      return false; // Return false indicating failure
    }
  }



  static Future<ReminderModel?> createReminder(ReminderModel model) async {
    Map<String, String> requestHeaders = {
      'Content-Type': 'application/json',
    };

    var url = Uri.http(Config.apiURL, Config.createReminderAPI);
    print('Request Headers: $requestHeaders');
    print('Request Body: ${jsonEncode(model.toJson())}');
    try {
      var response = await client.post(
        url,
        headers: requestHeaders,
        body: jsonEncode(model.toJson()),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return ReminderModel.fromJson(responseData);
      } else {
        print('Failed to create reminder: ${response.statusCode}');
        throw Exception('Failed to create reminder');
      }
    } catch (error) {
      print('Error creating reminder: $error');
      throw Exception('Failed to create reminder');
    }
  }


  static Future<List<ReminderModel>> getReminder(String userId) async {
    var url = Uri.http(Config.apiURL, Config.getReminderAPI, {'userId': userId});
    print("Request URL: $url");

    try {
      var response = await client.get(
        url,
        headers: {'Content-Type': 'application/json'},
      ).timeout(Duration(seconds: 10));


      if (response.statusCode == 200) {
        final dynamic responseData = json.decode(response.body);

        if (responseData['status'] == true && responseData.containsKey('success')) {
          List<ReminderModel> reminders = (responseData['success'] as List)
              .map((json) => ReminderModel.fromJson(json))
              .toList();

          return reminders;
        } else {
          print("Invalid response format. Expected 'status' true and 'success' key.");
          return [];
        }
      } else {
        print("Failed to fetch reminders. Status code: ${response.statusCode}");
        return [];
      }
    } catch (error) {
      print("Error fetching reminders: $error");
      return [];
    }
  }

  static Future<bool> deleteReminder(String id) async {
    Map<String, String> requestHeaders = {
      'Content-Type': 'application/json',
    };

    var url = Uri.http(Config.apiURL, Config.deleteReminderAPI);  // Change '_id' to 'id'
    print("Request URL: $url");

    try {
      var response = await client.delete(
        url,
        headers: requestHeaders,
        body: jsonEncode({'id': id}),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print("Failed to delete reminder. Status code: ${response.statusCode}");
        return false;
      }
    } catch (error) {
      print("Error deleting reminder: $error");
      return false;
    }
  }

  static Future<ReminderModel?> getReminderDetails(String id) async {
    try {
      var url = Uri.http(Config.apiURL, '${Config.getReminderDetailsAPI}/$id');
      print("Request URL: $url");

      var response = await client.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final dynamic responseData = json.decode(response.body);
        return responseData != null ? ReminderModel.fromJson(responseData['success']) : null;
      } else {
        print('Error response body: ${response.body}');
        throw Exception('Failed to get reminder details. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error getting reminder details: $error');
      throw error;
    }
  }

  static Future<bool> updateReminder(String id, ReminderModel updatedModel) async {
    Map<String, String> requestHeaders = {
      'Content-Type': 'application/json',
    };

    var url = Uri.http(Config.apiURL, '${Config.updateReminderAPI}/$id'); // Adjust the API endpoint
    print("Request URL: $url");
    print("id: $id");
    var response = await client.put(
      url,
      headers: requestHeaders,
      body: jsonEncode({'_id': id, 'updatedData': updatedModel.toJson()}),
    );

    if (response.statusCode == 200) {
      print("success");
      return true;
    } else {
      print("Failed to update reminder. Status code: ${response.statusCode}");
      return false;
    }
  }

  //child
  static Future<ChildModel?> createChild(ChildModel model) async {
    Map<String, String> requestHeaders = {
      'Content-Type': 'application/json',
    };

    var url = Uri.http(Config.apiURL, Config.createChildAPI);

    var response = await client.post(
      url,
      headers: requestHeaders,
      body: jsonEncode(model.toJson()),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      return ChildModel.fromJson(responseData);
    } else {
      throw Exception('Failed to create child');
    }
  }


  static Future<List<ChildModel>> getChild(String userId) async {
    var url = Uri.http(Config.apiURL, Config.getChildAPI, {'userId': userId});
    print("Request URL: $url");

    try {
      var response = await client.get(
        url,
        headers: {'Content-Type': 'application/json'},
      ).timeout(Duration(seconds: 10));


      if (response.statusCode == 200) {
        final dynamic responseData = json.decode(response.body);

        if (responseData['status'] == true && responseData.containsKey('success')) {
          List<ChildModel> children = (responseData['success'] as List)
              .map((json) => ChildModel.fromJson(json))
              .toList();

          return children;
        } else {
          print("Invalid response format. Expected 'status' true and 'success' key.");
          return [];
        }
      } else {
        print("Failed to fetch children. Status code: ${response.statusCode}");
        return [];
      }
    } catch (error) {
      print("Error fetching children: $error");
      return [];
    }
  }

  static Future<List<ChildModel>> getAllChildren() async {
    var url = await Uri.http(
        Config.apiURL, Config.getAllChildrenAPI); // Adjust the endpoint

    try {
      var response = await client.get(
        url,
        headers: {'Content-Type': 'application/json'},
      ).timeout(Duration(seconds: 10));


      if (response.statusCode == 200) {
        final dynamic responseData = json.decode(response.body);

        if (responseData['status'] == true &&
            responseData.containsKey('success')) {
          List<ChildModel> children = (responseData['success'] as List)
              .map((json) => ChildModel.fromJson(json))
              .toList();

          return children;
        } else {
          print(
              "Invalid response format. Expected 'status' true and 'success' key.");
          return [];
        }
      } else {
        print(
            "Failed to fetch all children. Status code: ${response.statusCode}");
        return [];
      }
    } catch (error) {
      print("Error fetching all children: $error");
      return [];
    }
  }

  static Future<bool> deleteChild(String id) async {
    Map<String, String> requestHeaders = {
      'Content-Type': 'application/json',
    };

    var url = Uri.http(Config.apiURL, Config.deleteChildAPI);  // Change '_id' to 'id'
    print("Request URL: $url");

    try {
      var response = await client.delete(
        url,
        headers: requestHeaders,
        body: jsonEncode({'id': id}),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print("Failed to delete child. Status code: ${response.statusCode}");
        return false;
      }
    } catch (error) {
      print("Error deleting child: $error");
      return false;
    }
  }

  static Future<ChildModel?> getChildDetails(String id) async {
    try {
      var url = Uri.http(Config.apiURL, '${Config.getChildDetailsAPI}/$id');
      print("Request URL: $url");

      var response = await client.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final dynamic responseData = json.decode(response.body);
        return responseData != null ? ChildModel.fromJson(responseData['success']) : null;
      } else {
        print('Error response body: ${response.body}');
        throw Exception('Failed to get child details. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error getting child details: $error');
      throw error;
    }
  }

  static Future<bool> updateChild(String id, ChildModel updatedModel) async {
    Map<String, String> requestHeaders = {
      'Content-Type': 'application/json',
    };

    var url = Uri.http(Config.apiURL, '${Config.updateChildAPI}/$id'); // Adjust the API endpoint
    print("Request URL: $url");
    print("id: $id");
    var response = await client.put(
      url,
      headers: requestHeaders,
      body: jsonEncode({'_id': id, 'updatedData': updatedModel.toJson()}),
    );

    if (response.statusCode == 200) {
      print("success");
      return true;
    } else {
      print("Failed to update child. Status code: ${response.statusCode}");
      return false;
    }
  }

  //therapist
  static Future<TherapistModel?> createTherapist(TherapistModel model) async {
    Map<String, String> requestHeaders = {
      'Content-Type': 'application/json',
    };

    var url = Uri.http(Config.apiURL, Config.createTherapistAPI);

    var response = await client.post(
      url,
      headers: requestHeaders,
      body: jsonEncode(model.toJson()),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      return TherapistModel.fromJson(responseData);
    } else {
      throw Exception('Failed to create therapist');
    }
  }

  static Future<List<TherapistModel>> getTherapist(String managedBy) async {
    var url = Uri.http(Config.apiURL, Config.getTherapistAPI, {'managedBy': managedBy});
    print("Request URL: $url");

    try {
      var response = await client.get(
        url,
        headers: {'Content-Type': 'application/json'},
      ).timeout(Duration(seconds: 10));


      if (response.statusCode == 200) {
        final dynamic responseData = json.decode(response.body);

        if (responseData['status'] == true && responseData.containsKey('success')) {
          List<TherapistModel> therapists = (responseData['success'] as List)
              .map((json) => TherapistModel.fromJson(json))
              .toList();

          return therapists;
        } else {
          print("Invalid response format. Expected 'status' true and 'success' key.");
          return [];
        }
      } else {
        print("Failed to fetch therapists. Status code: ${response.statusCode}");
        return [];
      }
    } catch (error) {
      print("Error fetching therapists: $error");
      return [];
    }
  }

  static Future<List<TherapistModel>> getAllTherapists() async {
    var url = await Uri.http(
        Config.apiURL, Config.getAllTherapistsAPI); // Adjust the endpoint

    try {
      var response = await client.get(
        url,
        headers: {'Content-Type': 'application/json'},
      ).timeout(Duration(seconds: 10));


      if (response.statusCode == 200) {
        final dynamic responseData = json.decode(response.body);

        if (responseData['status'] == true &&
            responseData.containsKey('success')) {
          List<TherapistModel> therapists = (responseData['success'] as List)
              .map((json) => TherapistModel.fromJson(json))
              .toList();

          return therapists;
        } else {
          print(
              "Invalid response format. Expected 'status' true and 'success' key.");
          return [];
        }
      } else {
        print(
            "Failed to fetch all therapists. Status code: ${response.statusCode}");
        return [];
      }
    } catch (error) {
      print("Error fetching all therapists: $error");
      return [];
    }
  }


  static Future<bool> deleteTherapist(String id) async {
    Map<String, String> requestHeaders = {
      'Content-Type': 'application/json',
    };

    var url = Uri.http(Config.apiURL, Config.deleteTherapistAPI);  // Change '_id' to 'id'
    print("Request URL: $url");

    try {
      var response = await client.delete(
        url,
        headers: requestHeaders,
        body: jsonEncode({'id': id}),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print("Failed to delete therapist. Status code: ${response.statusCode}");
        return false;
      }
    } catch (error) {
      print("Error deleting therapist: $error");
      return false;
    }
  }

  static Future<TherapistModel?> getTherapistDetails(String therapistId) async {
    try {
      var url = Uri.http(Config.apiURL, '${Config.getTherapistDetailsAPI}/$therapistId');
      print("Request URL: $url");

      var response = await client.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final dynamic responseData = json.decode(response.body);
        return responseData != null ? TherapistModel.fromJson(responseData['success']) : null;
      } else {
        print('Error response body: ${response.body}');
        throw Exception('Failed to get therapist details. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error getting therapist details: $error');
      throw error;
    }
  }



  static Future<bool> updateTherapist(String therapistId, TherapistModel updatedModel) async {
    Map<String, String> requestHeaders = {
      'Content-Type': 'application/json',
    };

    var url = Uri.http(Config.apiURL, '${Config.updateTherapistAPI}/$therapistId'); // Adjust the API endpoint
    print("Request URL: $url");
    print("id: $therapistId");
    var response = await client.put(
      url,
      headers: requestHeaders,
      body: jsonEncode({'therapistId': therapistId, 'updatedData': updatedModel.toJson()}),
    );

    if (response.statusCode == 200) {
      print("success");
      return true;
    } else {
      print("Failed to update therapist. Status code: ${response.statusCode}");
      return false;
    }
  }

  static Future<bool> checkTherapistAvailability(String id, DateTime startTime, DateTime endTime) async {
    // Print for debugging
    print('Formatted startTime: ${startTime.toIso8601String()}');
    print('Formatted endTime: ${endTime.toIso8601String()}');
    try {
      /*var url = Uri.http(Config.apiURL, Config.checkTherapistAvailability, {
        'id': id,
        'startTime': startTime.toIso8601String(), // Format DateTime to ISO string
        'endTime': endTime.toIso8601String(),     // Format DateTime to ISO string
      });*/
      var url = Uri.http(Config.apiURL, '${Config.checkTherapistAvailability}/$id', {
        'fromDate': startTime.toIso8601String(),
        'toDate': endTime.toIso8601String(),
      });


      var response = await client.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print("success");
        return responseData['isTherapistAvailable'];
      } else {
        // Handle the error response here
        print('Failed to check therapist availability. Status code: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      // Handle exceptions
      print('Error checking therapist availability: $e');
      return false;
    }
  }

  static Future<List<TherapistModel>> getAvailableTherapists(DateTime fromDate, DateTime toDate) async {
    try {
      var url = Uri.http(Config.apiURL, Config.getAvailableTherapist, {
        'fromDate': fromDate.toIso8601String(),
        'toDate': toDate.toIso8601String(),
      });

      var response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        List<dynamic> therapistData = responseData['availableTherapists'];
        List<TherapistModel> therapists = therapistData.map((data) => TherapistModel.fromJson(data)).toList();
        return therapists;
      } else {
        // Handle the error response here
        print('Failed to get available therapists. Status code: ${response.statusCode}');
        throw Exception('Failed to get available therapists');
      }
    } catch (e) {
      // Handle exceptions
      print('Error getting available therapists: $e');
      throw Exception('Error getting available therapists');
    }
  }



  //youtube videos
  final String apiKey = 'AIzaSyAkNvZJvVD7_Hd5BmviEPb9ai6tQIgJS08';
  final String username = 'kidzemporiumtherapycenter'; // Replace with the desired channel ID

  /*Future<List<YoutubeModel>> searchVideosByUsername(String username) async {
    final response = await http.get(
      Uri.parse('https://www.googleapis.com/youtube/v3/search'
          '?part=snippet&q=$username&type=channel&key=$apiKey'),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);

      print('Response Body: $data'); // Print the response body for analysis

      if (data.containsKey('items') && data['items'] != null) {
        final List<dynamic> channels = data['items'];

        if (channels.isNotEmpty) {
          final String channelId = channels[0]['id']['channelId'];
          return await fetchVideosByChannelId(channelId);
        } else {
          throw Exception('No channel found for the given username');
        }
      } else {
        throw Exception('Invalid response format. Expected key "items" not found or is null.');
      }
    } else {
      throw Exception('Failed to load videos. Status code: ${response.statusCode}');
    }
  }*/

  static Future<List<YoutubeModel>> fetchVideosByChannelId(String channelId) async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://www.googleapis.com/youtube/v3/search'
              '?part=snippet&channelId=$channelId&maxResults=50&key=AIzaSyAkNvZJvVD7_Hd5BmviEPb9ai6tQIgJS08&type=video&videoEmbeddable=true',
        ),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic>? data = json.decode(response.body);

        if (data != null && data.containsKey('items') && data['items'] != null) {
          final List<dynamic> videos = data['items'];

          List<YoutubeModel> videoList = videos.map((json) {
            try {
              final video = YoutubeModel.fromJson(json);
              print('Video: $video');
              return video;
            } catch (e) {
              print('Error creating VideoModel: $e');
              rethrow; // Rethrow the exception to propagate it further
            }
          }).toList();

          // Filter out videos that are not officially uploaded (liveBroadcastContent != 'none')
          videoList = videoList.where((video) => video.liveBroadcastContent == 'none').toList();

          return videoList;
        } else {
          throw Exception('Invalid response format. Expected key "items" not found or is null.');
        }
      } else {
        throw Exception('Failed to load videos. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching videos: $error');
      throw Exception('Error fetching videos: $error');
    }
  }

  //booking
  static Future<BookingModel?> createBooking(BookingModel model) async {
    Map<String, String> requestHeaders = {
      'Content-Type': 'application/json',
    };

    var url = Uri.http(Config.apiURL, Config.createBookingAPI);

    var response = await client.post(
      url,
      headers: requestHeaders,
      body: jsonEncode(model.toJson()),
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      return BookingModel.fromJson(jsonResponse);
    } else {
      print('Error creating payment: ${response.statusCode}');
      return null;
    }
  }

  static Future<List<BookingModel>> getBooking(String userId) async {
    var url = Uri.http(Config.apiURL, Config.getBookingAPI, {'userId': userId});
    print("Request URL: $url");

    try {
      var response = await client.get(
        url,
        headers: {'Content-Type': 'application/json'},
      ).timeout(Duration(seconds: 10));


      if (response.statusCode == 200) {
        final dynamic responseData = json.decode(response.body);

        if (responseData['status'] == true && responseData.containsKey('success')) {
          List<BookingModel> bookings = (responseData['success'] as List)
              .map((json) => BookingModel.fromJson(json))
              .toList();

          return bookings;
        } else {
          print("Invalid response format. Expected 'status' true and 'success' key.");
          return [];
        }
      } else {
        print("Failed to fetch bookings. Status code: ${response.statusCode}");
        return [];
      }
    } catch (error) {
      print("Error fetching bookings: $error");
      return [];
    }
  }

  static Future<List<BookingModel>> getAllBookings() async {
    var url = await Uri.http(
        Config.apiURL, Config.getAllBookingsAPI); // Adjust the endpoint

    try {
      var response = await client.get(
        url,
        headers: {'Content-Type': 'application/json'},
      ).timeout(Duration(seconds: 10));


      if (response.statusCode == 200) {
        final dynamic responseData = json.decode(response.body);

        if (responseData['status'] == true &&
            responseData.containsKey('success')) {
          List<BookingModel> bookings = (responseData['success'] as List)
              .map((json) => BookingModel.fromJson(json))
              .toList();

          return bookings;
        } else {
          print(
              "Invalid response format. Expected 'status' true and 'success' key.");
          return [];
        }
      } else {
        print(
            "Failed to fetch all bookings. Status code: ${response.statusCode}");
        return [];
      }
    } catch (error) {
      print("Error fetching all bookings: $error");
      return [];
    }
  }


  static Future<bool> deleteBooking(String id) async {
    Map<String, String> requestHeaders = {
      'Content-Type': 'application/json',
    };

    var url = Uri.http(Config.apiURL, Config.deleteBookingAPI);  // Change '_id' to 'id'
    print("Request URL: $url");

    try {
      var response = await client.delete(
        url,
        headers: requestHeaders,
        body: jsonEncode({'id': id}),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print("Failed to delete booking. Status code: ${response.statusCode}");
        return false;
      }
    } catch (error) {
      print("Error deleting booking: $error");
      return false;
    }
  }

  static Future<BookingModel?> getBookingDetails(String id) async {
    try {
      var url = Uri.http(Config.apiURL, '${Config.getBookingDetailsAPI}/$id');
      print("Request URL: $url");

      var response = await client.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final dynamic responseData = json.decode(response.body);
        return responseData != null ? BookingModel.fromJson(responseData['success']) : null;
      } else {
        print('Error response body: ${response.body}');
        throw Exception('Failed to get booking details. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error getting booking details: $error');
      throw error;
    }
  }

  static Future<bool> updateBooking(String id, BookingModel updatedModel) async {
    Map<String, String> requestHeaders = {
      'Content-Type': 'application/json',
    };

    var url = Uri.http(Config.apiURL, '${Config.updateBookingAPI}/$id'); // Adjust the API endpoint
    print("Request URL: $url");
    print("id: $id");
    var response = await client.put(
      url,
      headers: requestHeaders,
      body: jsonEncode({'_id': id, 'updatedData': updatedModel.toJson()}),
    );

    if (response.statusCode == 200) {
      print("success");
      return true;
    } else {
      print("Failed to update booking. Status code: ${response.statusCode}");
      return false;
    }
  }

  //Payment
  static Future<PaymentModel?> createPayment(PaymentModel model) async {
    Map<String, String> requestHeaders = {
      'Content-Type': 'application/json',
    };

    var url = Uri.http(Config.apiURL, Config.createPaymentAPI);

    var response = await client.post(
      url,
      headers: requestHeaders,
      body: jsonEncode(model.toJson()),
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      return PaymentModel.fromJson(jsonResponse);
    } else {
      print('Error creating payment: ${response.statusCode}');
      return null;
    }
  }

  static Future<PaymentModel?> getPaymentDetails(String id) async {
    try {
      var url = Uri.http(Config.apiURL, '${Config.getPaymentDetailsAPI}/$id');
      print("Request URL: $url");

      var response = await client.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final dynamic responseData = json.decode(response.body);
        return responseData != null ? PaymentModel.fromJson(responseData['success']) : null;
      } else {
        print('Error response body: ${response.body}');
        throw Exception('Failed to get payment details. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error getting payment details: $error');
      throw error;
    }
  }
  static Future<List<PaymentModel>> getPayment(String userId) async {
    var url = Uri.http(Config.apiURL, Config.getPaymentAPI, {'userId': userId});
    print("Request URL: $url");

    try {
      var response = await client.get(
        url,
        headers: {'Content-Type': 'application/json'},
      ).timeout(Duration(seconds: 10));


      if (response.statusCode == 200) {
        final dynamic responseData = json.decode(response.body);

        if (responseData['status'] == true && responseData.containsKey('success')) {
          List<PaymentModel> payments = (responseData['success'] as List)
              .map((json) => PaymentModel.fromJson(json))
              .toList();

          return payments;
        } else {
          print("Invalid response format. Expected 'status' true and 'success' key.");
          return [];
        }
      } else {
        print("Failed to fetch payments. Status code: ${response.statusCode}");
        return [];
      }
    } catch (error) {
      print("Error fetching payments: $error");
      return [];
    }
  }

  static Future<List<PaymentModel>> getAllPayments() async {
    var url = await Uri.http(
        Config.apiURL, Config.getAllPaymentsAPI); // Adjust the endpoint

    try {
      var response = await client.get(
        url,
        headers: {'Content-Type': 'application/json'},
      ).timeout(Duration(seconds: 10));


      if (response.statusCode == 200) {
        final dynamic responseData = json.decode(response.body);

        if (responseData['status'] == true &&
            responseData.containsKey('success')) {
          List<PaymentModel> payments = (responseData['success'] as List)
              .map((json) => PaymentModel.fromJson(json))
              .toList();

          return payments;
        } else {
          print(
              "Invalid response format. Expected 'status' true and 'success' key.");
          return [];
        }
      } else {
        print(
            "Failed to fetch all payments. Status code: ${response.statusCode}");
        return [];
      }
    } catch (error) {
      print("Error fetching all payments: $error");
      return [];
    }
  }

  //report
  static Future<ReportModel?> createReport(ReportModel model) async {
    Map<String, String> requestHeaders = {
      'Content-Type': 'application/json',
    };

    var url = Uri.http(Config.apiURL, Config.createReportAPI);

    var response = await client.post(
      url,
      headers: requestHeaders,
      body: jsonEncode(model.toJson()),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      return ReportModel.fromJson(responseData);
    } else {
      throw Exception('Failed to create report');
    }
  }

  static Future<List<ReportModel>> getReport(String userId) async {
    var url = Uri.http(Config.apiURL, Config.getReportAPI, {'userId': userId});
    print("Request URL: $url");

    try {
      var response = await client.get(
        url,
        headers: {'Content-Type': 'application/json'},
      ).timeout(Duration(seconds: 10));


      if (response.statusCode == 200) {
        final dynamic responseData = json.decode(response.body);

        if (responseData['status'] == true && responseData.containsKey('success')) {
          List<ReportModel> therapists = (responseData['success'] as List)
              .map((json) => ReportModel.fromJson(json))
              .toList();

          return therapists;
        } else {
          print("Invalid response format. Expected 'status' true and 'success' key.");
          return [];
        }
      } else {
        print("Failed to fetch report. Status code: ${response.statusCode}");
        return [];
      }
    } catch (error) {
      print("Error fetching report: $error");
      return [];
    }
  }

  static Future<List<ReportModel>> getAllReports() async {
    var url = await Uri.http(
        Config.apiURL, Config.getAllReportsAPI); // Adjust the endpoint

    try {
      var response = await client.get(
        url,
        headers: {'Content-Type': 'application/json'},
      ).timeout(Duration(seconds: 10));


      if (response.statusCode == 200) {
        final dynamic responseData = json.decode(response.body);

        if (responseData['status'] == true &&
            responseData.containsKey('success')) {
          List<ReportModel> therapists = (responseData['success'] as List)
              .map((json) => ReportModel.fromJson(json))
              .toList();

          return therapists;
        } else {
          print(
              "Invalid response format. Expected 'status' true and 'success' key.");
          return [];
        }
      } else {
        print(
            "Failed to fetch all reports. Status code: ${response.statusCode}");
        return [];
      }
    } catch (error) {
      print("Error fetching all reports: $error");
      return [];
    }
  }


  static Future<bool> deleteReport(String id) async {
    Map<String, String> requestHeaders = {
      'Content-Type': 'application/json',
    };

    var url = Uri.http(Config.apiURL, Config.deleteReportAPI);  // Change '_id' to 'id'
    print("Request URL: $url");

    try {
      var response = await client.delete(
        url,
        headers: requestHeaders,
        body: jsonEncode({'id': id}),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print("Failed to delete report. Status code: ${response.statusCode}");
        return false;
      }
    } catch (error) {
      print("Error deleting report: $error");
      return false;
    }
  }

  static Future<List<ReportModel>> getReportDetailsByBookingId(String bookingId) async {
    try {
      var url = Uri.http(Config.apiURL, '${Config.getReportDetailsByBookingIdAPI}/$bookingId');
      print("Request URL: $url");

      var response = await client.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final dynamic responseData = json.decode(response.body);
        if (responseData['status'] == true) {
          List<dynamic> reportsData = responseData['success'];
          List<ReportModel> reports = reportsData
              .map((reportJson) => ReportModel.fromJson(reportJson))
              .toList();
          return reports;
        } else {
          throw Exception('Failed to get report details. Status: ${responseData['status']}');
        }
      } else {
        print('Error response body: ${response.body}');
        throw Exception('Failed to get report details. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error getting report details: $error');
      throw error;
    }
  }

  static Future<ReportModel?> getReportDetails(String id) async {
    try {
      var url = Uri.http(Config.apiURL, '${Config.getReportDetailsAPI}/$id');
      print("Request URL: $url");

      var response = await client.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final dynamic responseData = json.decode(response.body);
        return responseData != null ? ReportModel.fromJson(responseData['success']) : null;
      } else {
        print('Error response body: ${response.body}');
        throw Exception('Failed to get report details. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error getting report details: $error');
      throw error;
    }
  }


  static Future<bool> updateReport(String id, ReportModel updatedModel) async {
    Map<String, String> requestHeaders = {
      'Content-Type': 'application/json',
    };

    var url = Uri.http(Config.apiURL, '${Config.updateReportAPI}/$id'); // Adjust the API endpoint
    print("Request URL: $url");
    print("id: $id");
    var response = await client.put(
      url,
      headers: requestHeaders,
      body: jsonEncode({'_id': id, 'updatedData': updatedModel.toJson()}),
    );

    if (response.statusCode == 200) {
      print("success");
      return true;
    } else {
      print("Failed to update report. Status code: ${response.statusCode}");
      return false;
    }
  }

  static Future<bool> checkReport(String bookingId) async {
    var url = Uri.http(Config.apiURL, '${Config.checkReportAPI}/$bookingId');
    print("Request URL: $url");

    try {
      var response = await client.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print("success");
        return responseData['isReportExist'];
      } else {
        // Handle the error response here
        print('Failed to check report. Status code: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      // Handle exceptions
      print('Error checking report: $e');
      return false;
    }
  }

  //task
  static Future<TaskModel?> createTask(TaskModel model) async {
    Map<String, String> requestHeaders = {
      'Content-Type': 'application/json',
    };

    var url = Uri.http(Config.apiURL, Config.createTaskAPI);

    var response = await client.post(
      url,
      headers: requestHeaders,
      body: jsonEncode(model.toJson()),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      return TaskModel.fromJson(responseData);
    } else {
      throw Exception('Failed to create task');
    }
  }


  static Future<List<TaskModel>> getTask(String userId) async {
    var url = Uri.http(Config.apiURL, Config.getTaskAPI, {'userId': userId});
    print("Request URL: $url");

    try {
      var response = await client.get(
        url,
        headers: {'Content-Type': 'application/json'},
      ).timeout(Duration(seconds: 10));


      if (response.statusCode == 200) {
        final dynamic responseData = json.decode(response.body);

        if (responseData['status'] == true && responseData.containsKey('success')) {
          List<TaskModel> tasks = (responseData['success'] as List)
              .map((json) => TaskModel.fromJson(json))
              .toList();

          return tasks;
        } else {
          print("Invalid response format. Expected 'status' true and 'success' key.");
          return [];
        }
      } else {
        print("Failed to fetch tasks. Status code: ${response.statusCode}");
        return [];
      }
    } catch (error) {
      print("Error fetching tasks: $error");
      return [];
    }
  }

  static Future<List<TaskModel>> getAllTasks() async {
    var url = await Uri.http(
        Config.apiURL, Config.getAllTasksAPI); // Adjust the endpoint

    try {
      var response = await client.get(
        url,
        headers: {'Content-Type': 'application/json'},
      ).timeout(Duration(seconds: 10));


      if (response.statusCode == 200) {
        final dynamic responseData = json.decode(response.body);

        if (responseData['status'] == true &&
            responseData.containsKey('success')) {
          List<TaskModel> tasks = (responseData['success'] as List)
              .map((json) => TaskModel.fromJson(json))
              .toList();

          return tasks;
        } else {
          print(
              "Invalid response format. Expected 'status' true and 'success' key.");
          return [];
        }
      } else {
        print(
            "Failed to fetch all tasks. Status code: ${response.statusCode}");
        return [];
      }
    } catch (error) {
      print("Error fetching all tasks: $error");
      return [];
    }
  }

  static Future<bool> deleteTask(String id) async {
    Map<String, String> requestHeaders = {
      'Content-Type': 'application/json',
    };

    var url = Uri.http(Config.apiURL, Config.deleteTaskAPI);  // Change '_id' to 'id'
    print("Request URL: $url");

    try {
      var response = await client.delete(
        url,
        headers: requestHeaders,
        body: jsonEncode({'id': id}),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print("Failed to delete task. Status code: ${response.statusCode}");
        return false;
      }
    } catch (error) {
      print("Error deleting task: $error");
      return false;
    }
  }

  static Future<TaskModel?> getTaskDetails(String id) async {
    try {
      var url = Uri.http(Config.apiURL, '${Config.getTaskDetailsAPI}/$id');
      print("Request URL: $url");

      var response = await client.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final dynamic responseData = json.decode(response.body);
        return responseData != null ? TaskModel.fromJson(responseData['success']) : null;
      } else {
        print('Error response body: ${response.body}');
        throw Exception('Failed to get task details. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error getting task details: $error');
      throw error;
    }
  }

  static Future<bool> updateTask(String id, TaskModel updatedModel) async {
    Map<String, String> requestHeaders = {
      'Content-Type': 'application/json',
    };

    var url = Uri.http(Config.apiURL, '${Config.updateTaskAPI}/$id'); // Adjust the API endpoint
    print("Request URL: $url");
    print("id: $id");
    var response = await client.put(
      url,
      headers: requestHeaders,
      body: jsonEncode({'_id': id, 'updatedData': updatedModel.toJson()}),
    );

    if (response.statusCode == 200) {
      print("success");
      return true;
    } else {
      print("Failed to update task. Status code: ${response.statusCode}");
      return false;
    }
  }

  //livestream
  static Future<LivestreamModel?> createLivestream(LivestreamModel model) async {
    Map<String, String> requestHeaders = {
      'Content-Type': 'application/json',
    };

    var url = Uri.http(Config.apiURL, Config.createLivestreamAPI);

    var response = await client.post(
      url,
      headers: requestHeaders,
      body: jsonEncode(model.toJson()),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      return LivestreamModel.fromJson(responseData);
    } else {
      throw Exception('Failed to create meeting');
    }
  }

  static Future<LivestreamModel?> getLivestreamDetailsByBookingId(String bookingId) async {
    try {
      var url = Uri.http(Config.apiURL, '${Config.getLivestreamDetailsByBookingIdAPI}/$bookingId');
      print("Request URL: $url");

      var response = await client.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final dynamic responseData = json.decode(response.body);
        // Check the type of responseData['success'] and handle accordingly
        if (responseData != null && responseData['success'] != null) {
          if (responseData['success'] is List) {
            if (responseData['success'].isNotEmpty) {
              return LivestreamModel.fromJson(responseData['success'][0]);
            } else {
              return null;
            }
          } else if (responseData['success'] is Map<String, dynamic>) {
            return LivestreamModel.fromJson(responseData['success']);
          } else {
            throw Exception('Unexpected response format');
          }
        } else {
          return null;
        }
      } else {
        print('Error response body: ${response.body}');
        throw Exception('Failed to get meeting details. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error getting meeting details: $error');
      throw error;
    }
  }

  static Future<VideoModel?> createVideo(VideoModel model) async {
    Map<String, String> requestHeaders = {
      'Content-Type': 'application/json',
    };

    var url = Uri.http(Config.apiURL, Config.createVideoAPI);

    var response = await client.post(
      url,
      headers: requestHeaders,
      body: jsonEncode(model.toJson()),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      return VideoModel.fromJson(responseData);
    } else {
      throw Exception('Failed to create video');
    }
  }


  static Future<List<VideoModel>> getVideo(String userId) async {
    var url = Uri.http(Config.apiURL, Config.getVideoAPI, {'userId': userId});
    print("Request URL: $url");

    try {
      var response = await client.get(
        url,
        headers: {'Content-Type': 'application/json'},
      ).timeout(Duration(seconds: 10));


      if (response.statusCode == 200) {
        final dynamic responseData = json.decode(response.body);

        if (responseData['status'] == true && responseData.containsKey('success')) {
          List<VideoModel> tasks = (responseData['success'] as List)
              .map((json) => VideoModel.fromJson(json))
              .toList();

          return tasks;
        } else {
          print("Invalid response format. Expected 'status' true and 'success' key.");
          return [];
        }
      } else {
        print("Failed to fetch videos. Status code: ${response.statusCode}");
        return [];
      }
    } catch (error) {
      print("Error fetching videos: $error");
      return [];
    }
  }

  static Future<List<VideoModel>> getAllVideos() async {
    var url = await Uri.http(
        Config.apiURL, Config.getAllVideosAPI); // Adjust the endpoint

    try {
      var response = await client.get(
        url,
        headers: {'Content-Type': 'application/json'},
      ).timeout(Duration(seconds: 10));


      if (response.statusCode == 200) {
        final dynamic responseData = json.decode(response.body);

        if (responseData['status'] == true &&
            responseData.containsKey('success')) {
          List<VideoModel> videos = (responseData['success'] as List)
              .map((json) => VideoModel.fromJson(json))
              .toList();

          return videos;
        } else {
          print(
              "Invalid response format. Expected 'status' true and 'success' key.");
          return [];
        }
      } else {
        print(
            "Failed to fetch all videos. Status code: ${response.statusCode}");
        return [];
      }
    } catch (error) {
      print("Error fetching all videos: $error");
      return [];
    }
  }

  static Future<bool> deleteVideo(String id) async {
    Map<String, String> requestHeaders = {
      'Content-Type': 'application/json',
    };

    var url = Uri.http(Config.apiURL, Config.deleteVideoAPI);  // Change '_id' to 'id'
    print("Request URL: $url");

    try {
      var response = await client.delete(
        url,
        headers: requestHeaders,
        body: jsonEncode({'id': id}),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print("Failed to delete video. Status code: ${response.statusCode}");
        return false;
      }
    } catch (error) {
      print("Error deleting video: $error");
      return false;
    }
  }

  static Future<VideoModel?> getVideoDetails(String videoId) async {
    try {
      var url = Uri.http(Config.apiURL, '${Config.getVideoDetailsAPI}/$videoId');
      print("Request URL: $url");

      var response = await client.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final dynamic responseData = json.decode(response.body);
        return responseData != null ? VideoModel.fromJson(responseData['success']) : null;
      } else {
        print('Error response body: ${response.body}');
        throw Exception('Failed to get video details. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error getting video details: $error');
      throw error;
    }
  }

  static Future<bool> updateVideo(String videoId, VideoModel updatedModel) async {
    Map<String, String> requestHeaders = {
      'Content-Type': 'application/json',
    };

    var url = Uri.http(Config.apiURL, '${Config.updateVideoAPI}/$videoId'); // Adjust the API endpoint
    print("Request URL: $url");
    print("id: $videoId");
    var response = await client.put(
      url,
      headers: requestHeaders,
      body: jsonEncode({'videoId': videoId, 'updatedData': updatedModel.toJson()}),
    );

    if (response.statusCode == 200) {
      print("success");
      return true;
    } else {
      print("Failed to update video. Status code: ${response.statusCode}");
      return false;
    }
  }


}