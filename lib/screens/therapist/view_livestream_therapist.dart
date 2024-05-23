// /*
// import 'package:flutter/material.dart';
// import 'package:flutter_webrtc/flutter_webrtc.dart';
//
// class VideoCallScreen extends StatefulWidget {
//   @override
//   _VideoCallScreenState createState() => _VideoCallScreenState();
// }
//
// class _VideoCallScreenState extends State<VideoCallScreen> {
//   RTCVideoRenderer _localRenderer = RTCVideoRenderer();
//   RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
//
//   @override
//   void initState() {
//     super.initState();
//     _initRenderers();
//     // Initialize WebRTC client and establish connection
//     // Set up signaling to negotiate peer connection
//     // Configure media streams and start capturing video/audio
//   }
//
//   void _initRenderers() async {
//     await _localRenderer.initialize();
//     await _remoteRenderer.initialize();
//   }
//
//   @override
//   void dispose() {
//     super.dispose();
//     _localRenderer.dispose();
//     _remoteRenderer.dispose();
//     // Clean up WebRTC resources and close connections
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Video Call'),
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: RTCVideoView(_localRenderer),
//           ),
//           Expanded(
//             child: RTCVideoView(_remoteRenderer),
//           ),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               IconButton(
//                 icon: Icon(Icons.mic),
//                 onPressed: () {
//                   // Toggle mute/unmute audio
//                 },
//               ),
//               IconButton(
//                 icon: Icon(Icons.videocam),
//                 onPressed: () {
//                   // Toggle enable/disable video
//                 },
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }
// */
