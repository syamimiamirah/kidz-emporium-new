// import 'package:flutter/material.dart';
// import '../../models/livestream_model.dart';
// import '../../models/login_response_model.dart';
// import '../../contants.dart';
// import '../../services/api_service.dart';
//
// class BroadcastLivestreamTherapistPage extends StatefulWidget {
//   final LoginResponseModel userData;
//   final String bookingId;
//
//   const BroadcastLivestreamTherapistPage({
//     Key? key,
//     required this.userData, required this.bookingId,
//   }) : super(key: key);
//
//   @override
//   _BroadcastLivestreamTherapistPageState createState() => _BroadcastLivestreamTherapistPageState();
//
// }
//
//
// class _BroadcastLivestreamTherapistPageState extends State<BroadcastLivestreamTherapistPage> {
//   late RTCPeerConnection _peerConnection;
//
//   @override
//   void initState() {
//     super.initState();
//     _initWebRTC();
//   }
//
//   void _initWebRTC() async {
//     // Initialize WebRTC peer connection
//     _peerConnection = await createPeerConnection(configuration, constraints);
//
//     // Add event listeners (optional)
//     _peerConnection.onIceCandidate = (candidate) {
//       // Handle ICE candidate events
//     };
//     _peerConnection.onTrack = (event) {
//       // Handle track events
//     };
//     // Add more event listeners as needed
//
//     // Add local stream (optional)
//     final stream = await navigator.mediaDevices.getUserMedia(mediaConstraints);
//     stream.getTracks().forEach((track) {
//       _peerConnection.addTrack(track, stream);
//     });
//   }
//
//   @override
//   void dispose() {
//     _peerConnection.dispose(); // Dispose of WebRTC resources
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         appBar: AppBar(
//           title: Text('Broadcast Livestream'),
//           centerTitle: true,
//           backgroundColor: kPrimaryColor,
//         ),
//         body: Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 SizedBox(height: 10),
//                 Text(
//                   'To start the livestream, please insert the meeting URL.',
//                   style: TextStyle(
//                     fontSize: 17,
//                     color: Colors.black,
//                   ),
//                 ),
//                 SizedBox(height: 20),
//                 TextField(
//                   controller: _urlController,
//                   decoration: InputDecoration(
//                     labelText: 'Meeting Room URL',
//                     labelStyle: TextStyle(
//                       color: Colors.grey, // Change the color of the label text here
//                     ),
//                     fillColor: Colors.grey[200],
//                     filled: true,
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(10.0),
//                       borderSide: BorderSide.none,
//                     ),
//                   ),
//                 ),
//                 SizedBox(height: 20),
//                 ElevatedButton(
//                   onPressed: () {
//                     LivestreamModel model = LivestreamModel(
//                         userId: widget.userData.data!.id,
//                         url: _urlController.text,
//                         bookingId: widget.bookingId
//                     );
//
//                     APIService.createLivestream(model)
//                         .then((response) {
//                       // Handle successful response (if needed)
//                       print('Livestream created successfully');
//                     })
//                         .catchError((error) {
//                       // Handle error response (if needed)
//                       print('Error creating livestream: $error');
//                     });
//                   },
//                   child: Text('Start Livestream',
//                     style: TextStyle(fontSize: 16),
//                   ),
//                   style: ElevatedButton.styleFrom(
//                     primary: kPrimaryColor,
//                     padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                   ),
//                 ),
//
//                 SizedBox(height: 20),
//               ],
//             )
//         )
//     );
//   }
//
// }