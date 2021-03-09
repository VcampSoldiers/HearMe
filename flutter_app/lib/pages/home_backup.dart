// import 'package:flutter/material.dart';
// import 'package:flutter_app/azure_util.dart';
// import 'package:flutter_app/pages/login_screen.dart';
// import 'dart:async';
// import 'dart:typed_data';
// import 'package:sound_stream/sound_stream.dart';
// import '../authenticate.dart';

// class HomePage extends StatefulWidget {
//   static const routeName = '/home-page';

//   @override
//   _HomePageState createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> {
//   RecorderStream _recorder = RecorderStream();

//   List<Uint8List> _micChunks = [];
//   bool _isRecording = false;

//   StreamSubscription _recorderStatus;
//   StreamSubscription _audioStream;

//   Uint8List audioFile;
//   String detectedWord = "";

//   @override
//   void initState() {
//     super.initState();
//     initPlugin();

//     // _textController.addListener(() {
//     //   setState(() {
//     //     detectedWord = _textController.text;
//     //   });
//     // });
//   }

//   @override
//   void dispose() {
//     _recorderStatus?.cancel();
//     _audioStream?.cancel();
//     super.dispose();
//   }

//   // Platform messages are asynchronous, so we initialize in an async method.
//   Future<void> initPlugin() async {
//     _recorderStatus = _recorder.status.listen((status) {
//       // _micChunks.clear();
//       if (mounted)
//         setState(() {
//           _isRecording = status == SoundStreamStatus.Playing;
//         });
//     });

//     _audioStream = _recorder.audioStream.listen((data) {
//       _micChunks.add(data);
//     });

//     await Future.wait([
//       _recorder.initialize(),
//     ]);
//   }

//   Uint8List toWav(List<Uint8List> file) {
//     final bytes = file.expand((x) => x).toList();
//     var channels = 1;
//     var sampleRate = 16000;

//     int byteRate = ((16 * sampleRate * channels) / 8).round();

//     var size = bytes.length;

//     var fileSize = size + 36;

//     Uint8List header = Uint8List.fromList([
//       // "RIFF"
//       82, 73, 70, 70,
//       fileSize & 0xff,
//       (fileSize >> 8) & 0xff,
//       (fileSize >> 16) & 0xff,
//       (fileSize >> 24) & 0xff,
//       // WAVE
//       87, 65, 86, 69,
//       // fmt
//       102, 109, 116, 32,
//       // fmt chunk size 16
//       16, 0, 0, 0,
//       // Type of format
//       1, 0,
//       // One channel
//       channels, 0,
//       // Sample rate
//       sampleRate & 0xff,
//       (sampleRate >> 8) & 0xff,
//       (sampleRate >> 16) & 0xff,
//       (sampleRate >> 24) & 0xff,
//       // Byte rate
//       byteRate & 0xff,
//       (byteRate >> 8) & 0xff,
//       (byteRate >> 16) & 0xff,
//       (byteRate >> 24) & 0xff,
//       // Uhm
//       ((16 * channels) / 8).round(), 0,
//       // bitsize
//       16, 0,
//       // "data"
//       100, 97, 116, 97,
//       size & 0xff,
//       (size >> 8) & 0xff,
//       (size >> 16) & 0xff,
//       (size >> 24) & 0xff,
//       ...bytes
//     ]);

//     return header;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         backgroundColor: _isRecording ? Colors.black : Colors.white,
//         appBar: AppBar(
//           title: const Text('HearMe'),
//           backgroundColor: Colors.black,
//         ),
//         body: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Expanded(
//               child: IconButton(
//                 iconSize: 96.0,
//                 color: _isRecording ? Colors.white : Colors.black,
//                 icon: Icon(_isRecording ? Icons.mic_off : Icons.mic),
//                 onPressed: () async {
//                   if (_isRecording) {
//                     _recorder.stop();
//                     print("Sending");
//                     audioFile = toWav(_micChunks);
//                     if (_micChunks != null) {
//                       audioFile = toWav(_micChunks);
//                       _micChunks.clear();
//                     }
//                     detectedWord = await AzureManager.speechToText(audioFile);
//                   } else {
//                     _recorder.start();
//                   }
//                 },
//               ),
//             ),
//             Padding(
//               padding: EdgeInsets.all(10),
//               child: Container(
//                 child: Center(
//                   child: Text(
//                     detectedWord,
//                     style: TextStyle(color: Colors.black, fontSize: 35.0),
//                   ),
//                 ),
//               ),
//             ),
//             // IconButton(
//             //     icon: Icon(Icons.plus_one),
//             //     color: _isRecording ? Colors.white : Colors.black,
//             //     onPressed: () async {
//             //       user_id = await AzureManager.addProfile();
//             //     }),
//             // IconButton(
//             //     icon: Icon(Icons.plus_one),
//             //     color: _isRecording ? Colors.white : Colors.black,
//             //     onPressed: () async {
//             //       await AzureManager.enrollProfile(
//             //           // audioFile, "5fdfa3a1-ea1f-43fa-85c8-b73a5327d364");
//             //           audioFile,
//             //           "564b4977-17d6-4564-871b-aa872b147cfb");
//             //     }),
//             // IconButton(
//             //     icon: Icon(Icons.equalizer),
//             //     onPressed: () async {
//             //       // await addPerson("Dongkyuk@andrew.cmu.edu","id1", "DK");
//             //       // await addPerson("Seunghoon0821@gmail.com", "id2", "Simon");
//             //       // await addFriendsRelation("Dongkyuk@andrew.cmu.edu", "Seunghoon0821@gmail.com");
//             //       // var id_list = await getIDList();
//             //       // print(id_list);
//             //       // var id_list = await getIDList();
//             //       // var name = await getPersonName(id_list[0]);
//             //       // print(name);
//             //       // await identifyProfile(audioFile);
//             //     }),
//             // IconButton(
//             //     icon: Icon(Icons.equalizer),
//             //     color: _isRecording ? Colors.white : Colors.black,
//             //     onPressed: () async {
//             //       await AzureManager.identifyProfile(audioFile);
//             //     }),
//             // TextField(
//             //   decoration: InputDecoration(
//             //       border: InputBorder.none, hintText: 'Enter your name'),
//             //   onChanged: (text) {
//             //     print("First text field: $text");
//             //   },
//             // ),
//             Padding(
//               padding: EdgeInsets.all(20),
//               child: TextButton(
//                 child: Text("Log out"),
//                 onPressed: () {
//                   logOut();

//                   Navigator.pushNamedAndRemoveUntil(
//                     context,
//                     LoginPage.routeName,
//                     (Route<dynamic> route) => false,
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
