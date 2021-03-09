import 'package:flutter/material.dart';
import 'package:flutter_app/azure_util.dart';
import 'package:flutter_app/pages/login_screen.dart';
import 'package:flutter_app/pages/friends_screen.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:async';
import 'dart:typed_data';
import 'package:sound_stream/sound_stream.dart';
import 'package:flutter_app/authenticate.dart';
import 'package:flutter_app/firebase_util.dart';
import 'package:headset_connection_event/headset_event.dart';

class HomePage extends StatefulWidget {
  static const routeName = '/home-page';

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  RecorderStream _recorder = RecorderStream();

  List<Uint8List> _micChunks = [];
  bool _isRecording = false;
  var isStopped = false;
  DateTime cur_time = DateTime(0);

  HeadsetEvent headsetPlugin = new HeadsetEvent();
  HeadsetState headsetEvent;

  StreamSubscription _recorderStatus;
  StreamSubscription _audioStream;

  Uint8List audioFile;
  String detectedWord = "";
  String user_email = "";
  String user_name = "";
  AnimationController _controller;

  // final computer = Computer();

  var _flutterLocalNotificationsPlugin;
  var platformChannelSpecifics;
  @override
  void initState() {
    super.initState();
    var androidSetting = AndroidInitializationSettings('@mipmap/ic_launcher');
    var iosSetting = IOSInitializationSettings();
    var initializationSettings =
        InitializationSettings(android: androidSetting, iOS: iosSetting);
    _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    _flutterLocalNotificationsPlugin.initialize(initializationSettings);
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'HearMeChannel', 'hearme channel', 'channel of heaerme',
        importance: Importance.max, priority: Priority.high, showWhen: false);
    var iosPlatformChannelSpecifics =
        IOSNotificationDetails(sound: 'slow_spring.board.aiff');
    platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iosPlatformChannelSpecifics);

    /// if headset is plugged
    headsetPlugin.getCurrentState.then((_val) {
      setState(() {
        headsetEvent = _val;
      });
    });

    /// Detect the moment headset is plugged or unplugged
    headsetPlugin.setListener((_val) {
      setState(() {
        headsetEvent = _val;
        if (headsetEvent == HeadsetState.CONNECT) {
          isStopped = false;
        } else {
          isStopped = true;
          _isRecording = false;
        }
      });
    });

    _controller = AnimationController(
      vsync: this,
      lowerBound: 0.5,
      duration: Duration(seconds: 3),
    )..repeat();

    initPlugin();
  }

  @override
  void dispose() {
    _recorderStatus?.cancel();
    _audioStream?.cancel();
    _recorder.stop();
    _micChunks.clear();
    super.dispose();
  }

  Widget _buildContainer(double radius, bool _isRecording) {
    if (!_isRecording) {
      return Container();
    }
    return Container(
      width: radius,
      height: radius,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.pink.withOpacity(1 - _controller.value),
      ),
    );
  }

  Widget _buildBody(screenHeight) {
    return AnimatedBuilder(
      animation:
          CurvedAnimation(parent: _controller, curve: Curves.fastOutSlowIn),
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: <Widget>[
            _buildContainer(150 * _controller.value, _isRecording),
            _buildContainer(200 * _controller.value, _isRecording),
            _buildContainer(250 * _controller.value, _isRecording),
            _buildContainer(300 * _controller.value, _isRecording),
            _buildContainer(350 * _controller.value, _isRecording),
            IconButton(
              iconSize: screenHeight * 0.2,
              color: Colors.white,
              icon: Icon(_isRecording ? Icons.mic_off : Icons.mic),
              onPressed: () async {
                if (_isRecording) {
                  isStopped = true;
                  _recorder.stop();
                  _micChunks.clear();
                } else if (headsetEvent != HeadsetState.CONNECT) {
                  isStopped = false;
                  _recorder.start();
                  processAudio();
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> processAudio() {
    Timer.periodic(Duration(seconds: 3), (timer) async {
      if (DateTime.now().difference(cur_time).inSeconds > 5) {
        if (isStopped) {
          timer.cancel();
        }
        var audioFile = toWav(_micChunks);
        if (audioFile.length < 100000) {
        } else {
          detectedWord = await AzureManager.speechToText(audioFile);
          // var id = await AzureManager.identifyProfile(audioFile);
          // var user_name = await FirestoreManager.getPersonName(user_email);
          print(detectedWord);
          if (detectedWord.contains(user_name)) {
            cur_time = DateTime.now();
            ShowNotification("Call Alert",
                "Hey " + user_name + ", " + "someone is calling you!");
            var caller_name =
                await AzureManager.identifyProfile(audioFile, user_email);
            if (caller_name != null) {
              ShowNotification("Call Alert", "Caller: " + caller_name);
            }
          }
        }
      }
    });
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlugin() async {
    user_email = await FireBaseAuthenticationService.getCurrentUser()
        .then((user) => user.email);
    user_name = await FirestoreManager.getPersonName(user_email);

    _recorderStatus = _recorder.status.listen((status) {
      if (mounted)
        setState(() {
          _isRecording = status == SoundStreamStatus.Playing;
        });
    });

    _audioStream = _recorder.audioStream.listen((data) {
      // print(data.length);
      _micChunks.add(data);
      if (_micChunks.length > 140000 / 2560) {
        _micChunks.removeAt(0);
      }
    });

    await Future.wait([
      _recorder.initialize(),
    ]);
  }

  Future<void> ShowNotification(String noti_title, String noti_subtitle) async {
    await _flutterLocalNotificationsPlugin.show(
        0, noti_title, noti_subtitle, platformChannelSpecifics,
        payload: '');
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
    // double screenWidth = size.width;
    double screenHeight = size.height;

    print(headsetEvent);
    print(isStopped);

    if (headsetEvent == HeadsetState.CONNECT && !isStopped) {
      isStopped = false;
      _recorder.start();
      processAudio();
    }

    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: const Text('HearMe'),
          backgroundColor: Colors.black,
        ),
        body: Center(
          child: Column(
            children: [
              Spacer(),
              Container(
                height: screenHeight * 0.6,
                child: _buildBody(screenHeight),
              ),
              Spacer(),
              Container(
                  height: screenHeight * 0.2,
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            IconButton(
                              icon: Icon(Icons.group_add_rounded),
                              color: Colors.white,
                              iconSize: screenHeight * 0.1,
                              onPressed: () async {
                                _recorder.stop();

                                await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          FriendPage(user_email: user_email),
                                    ));
                                Navigator.pushNamedAndRemoveUntil(
                                  context,
                                  FriendPage.routeName,
                                  (Route<dynamic> route) => false,
                                );
                              },
                            ),
                            Text(
                              "Friends",
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            IconButton(
                              icon: Icon(Icons.logout),
                              color: Colors.white,
                              iconSize: screenHeight * 0.1,
                              onPressed: () {
                                isStopped = true;
                                _recorder.stop();
                                _micChunks.clear();
                                FireBaseAuthenticationService.logOut();
                                Navigator.pushNamedAndRemoveUntil(
                                  context,
                                  LoginPage.routeName,
                                  (Route<dynamic> route) => false,
                                );
                              },
                            ),
                            Text(
                              "Log Out",
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )),
              Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
