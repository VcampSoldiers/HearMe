// Packages
import 'package:flutter/material.dart';
import 'package:flutter_app/azure_util.dart';
import 'dart:async';
import 'dart:typed_data';
import 'package:sound_stream/sound_stream.dart';
import '../firebase_util.dart';
import './home_screen.dart';

import '../authenticate.dart';

class EnrollPage extends StatefulWidget {
  static const routeName = '/enroll-page';

  @override
  _EnrollPageState createState() => _EnrollPageState();
}

class _EnrollPageState extends State<EnrollPage> {
  int secondsRecorded = 0;
  Stopwatch timer;
  Timer _timer;

  RecorderStream _recorder = RecorderStream();

  List<Uint8List> _micChunks = [];
  bool _isRecording = false;

  StreamSubscription _recorderStatus;
  StreamSubscription _audioStream;

  Uint8List audioFile;
  bool enrollmentStatus = false;

  @override
  void initState() {
    super.initState();
    initPlugin();
    timer = Stopwatch();
    _timer = new Timer.periodic(new Duration(milliseconds: 100), (timer) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _recorderStatus?.cancel();
    _audioStream?.cancel();
    _timer.cancel();
    super.dispose();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlugin() async {
    _recorderStatus = _recorder.status.listen((status) {
      if (mounted)
        setState(() {
          _isRecording = status == SoundStreamStatus.Playing;
        });
    });

    _audioStream = _recorder.audioStream.listen((data) {
      _micChunks.add(data);
    });

    await Future.wait([
      _recorder.initialize(),
    ]);
  }

  Uint8List toWav(List<Uint8List> file) {
    final bytes = file.expand((x) => x).toList();
    var channels = 1;
    var sampleRate = 16000;

    int byteRate = ((16 * sampleRate * channels) / 8).round();

    var size = bytes.length;

    var fileSize = size + 36;

    Uint8List header = Uint8List.fromList([
      // "RIFF"
      82, 73, 70, 70,
      fileSize & 0xff,
      (fileSize >> 8) & 0xff,
      (fileSize >> 16) & 0xff,
      (fileSize >> 24) & 0xff,
      // WAVE
      87, 65, 86, 69,
      // fmt
      102, 109, 116, 32,
      // fmt chunk size 16
      16, 0, 0, 0,
      // Type of format
      1, 0,
      // One channel
      channels, 0,
      // Sample rate
      sampleRate & 0xff,
      (sampleRate >> 8) & 0xff,
      (sampleRate >> 16) & 0xff,
      (sampleRate >> 24) & 0xff,
      // Byte rate
      byteRate & 0xff,
      (byteRate >> 8) & 0xff,
      (byteRate >> 16) & 0xff,
      (byteRate >> 24) & 0xff,
      // Uhm
      ((16 * channels) / 8).round(), 0,
      // bitsize
      16, 0,
      // "data"
      100, 97, 116, 97,
      size & 0xff,
      (size >> 8) & 0xff,
      (size >> 16) & 0xff,
      (size >> 24) & 0xff,
      ...bytes
    ]);

    return header;
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    double screenHeight = size.height;
    double screenWidth = size.width;

    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.black45,
        appBar: AppBar(
          title:
              const Text("Enroll User", style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.black,
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.fromLTRB(10, 0, 10, 30),
              child: Center(
                child: Text(
                  "In a quiet environment, please read the prompt below. Press the microphone button to begin recording.",
                  style: TextStyle(
                      fontSize: (screenHeight * 0.024), color: Colors.white),
                ),
              ),
            ),
            Spacer(),
            Container(
              height: screenHeight * 0.25,
              width: screenHeight * 0.25,
              child: Stack(
                children: <Widget>[
                  Center(
                    child: Container(
                      height: screenWidth * 0.5,
                      width: screenWidth * 0.5,
                      child: CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.pink[300]),
                        backgroundColor: Colors.white60,
                        strokeWidth: 10,
                        value: timer.elapsed.inSeconds / 20.0,
                      ),
                    ),
                  ),
                  Center(
                    child: IconButton(
                      iconSize: screenHeight * 0.17,
                      color: (timer.elapsed.inSeconds > 0)
                          ? (timer.elapsed.inSeconds <= 20)
                              ? Colors.white60
                              : Colors.white
                          : Colors.white,
                      icon: Icon(_isRecording
                          ? (timer.elapsed.inSeconds <= 20)
                              ? Icons.mic
                              : Icons.arrow_forward
                          : (timer.elapsed.inSeconds <= 20)
                              ? Icons.mic
                              : Icons.arrow_forward),
                      onPressed: () async {
                        if (timer.elapsed.inSeconds > 0 &&
                            timer.elapsed.inSeconds < 20) {
                          null;
                        } else {
                          if (_isRecording) {
                            _recorder.stop();
                            timer.stop();

                            if (timer.elapsed.inSeconds >= 20) {
                              print("Sending");
                              audioFile = toWav(_micChunks);
                              if (_micChunks != null) {
                                audioFile = toWav(_micChunks);
                                _micChunks.clear();
                              }
                              String user_email =
                                  await FireBaseAuthenticationService
                                          .getCurrentUser()
                                      .then((value) => value.email);
                              var user_id = await FirestoreManager.getPersonID(
                                  user_email);

                              enrollmentStatus =
                                  await AzureManager.enrollProfile(
                                      audioFile, user_id);
                              if (enrollmentStatus) {
                                await FirestoreManager.setPersonAsEnrolled(
                                    user_email);
                              }

                              Navigator.pushNamedAndRemoveUntil(
                                context,
                                HomePage.routeName,
                                (Route<dynamic> route) => false,
                              );
                            }
                          } else {
                            _recorder.start();
                            timer.start();
                            setState(() {});
                          }
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
            Spacer(),
            Container(
              height: screenHeight * 0.45,
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Center(
                  child: SingleChildScrollView(
                    child: Text(
                      "Tartanhacks is the largest hackathon at CMU! " +
                          "Organized by ScottyLabs, it's a hackathon where, in 36 hours, " +
                          "participants from all over the country work in groups " +
                          " to create innovative projects. This year, Tartanhacks will " +
                          "be held online, so come on over to hack, learn new concepts " +
                          "through our virtual workshops, and meet other hackers!",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: screenHeight * 0.03,
                          height: 1.3),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
