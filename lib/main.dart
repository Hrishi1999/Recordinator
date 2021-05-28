import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Color(0xFFF8F0F0), // transparent status bar
    statusBarIconBrightness: Brightness.light // dark text for status bar
  ));
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        fontFamily: 'Sans',
        accentColor: Color(0xFFFEB29F)
      ),
      home: MyHomePage(title: 'Recordinator'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static const duration = const Duration(seconds: 1);
  int _seconds = 0;
  String _btnLabelRecord = "Record";
  String _btnLabelStop = "Stop";
  IconData _playIcon = Icons.play_arrow_rounded;
  IconData _pauseIcon = Icons.stop_rounded;
  IconData _saveIcon = Icons.save_rounded;
  bool _isRecording = false;
  bool _isPermitted = false;
  bool _isPlaying = false;
  Timer timer;

  FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  bool _mRecorderIsInited;
  String tempPath = '';

  FlutterSoundPlayer _player = FlutterSoundPlayer();
  bool _mPlayerIsInited;

  double _currentSliderValue = 0;

  Future<void> getTempDir() async {
    var tempDir = await getTemporaryDirectory();
    tempPath = '${tempDir.path}/flutter_sound.aac';
  }

  String getTime(int seconds) {
    int secs;
    int mins;
    int hours;
    secs = seconds % 60;
    mins = ((seconds / 60)%60).toInt();
    hours = ((seconds/60)~/60).toInt();
    return hours.toString() + "h " + mins.toString() + "m " + secs.toString() + "s ";
  }

  void askPermissions() async {
    if (await Permission.microphone.request().isGranted) {
      setState(() {
        _isPermitted = true;
      });
    }
  }

  Future<void> record() async {
    await _recorder.startRecorder(
      toFile: tempPath,
      codec: Codec.aacADTS,
    );
  }

  Future<void> stopRecorder() async {
    await _recorder.stopRecorder();
  }

  void play() async {
    await _player.startPlayer(
      fromURI: tempPath,
      codec: Codec.aacADTS,
      whenFinished: (){setState((){print('finished');});}
    );
    setState(() {});
  }

  Future<void> stopPlayer() async {
    if (_player != null) {
      await _player.stopPlayer();
    }
  }

  void handleTick() {
    if(_isRecording) {
      setState(() {
        _seconds = _seconds + 1;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _recorder.openAudioSession().then((value) {
      setState(() {
        _mRecorderIsInited = true;
      });
    });
    _player.openAudioSession().then((value) {
      setState(() {
        _mPlayerIsInited = true;
      });
    });
    askPermissions();
    getTempDir();
    if (timer == null) {
      timer = Timer.periodic(duration, (Timer t) {
        handleTick();
      });
    }
  }

  @override
  void dispose() {
    _recorder.closeAudioSession();
    _recorder = null;
    _player.closeAudioSession();
    _player = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Recordinator', style: TextStyle(fontSize: 25, color: Color(0xFF231C1C), fontWeight: FontWeight.w400)),
        elevation: 0,
        backgroundColor: Color(0xFFF8F0F0),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0, 
        backgroundColor: Color(0xFFF8F0F0),
        // selectedItemColor: Theme.of(context).accentColor,
        selectedItemColor: Color(0xFFFF9B94),
        selectedFontSize: 17,
        unselectedFontSize: 17,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.mic, size: 25),
            label: 'Record',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list, size: 25),
            label: 'Recordings'
          )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(getTime(_seconds), 
              style: TextStyle(fontSize: 25),
            ),
            SizedBox(height: 20,),
            SizedBox(
              width: 150.0,
              height: 50.0,
              child: FloatingActionButton.extended(
              elevation: 0, 
              icon: Icon(_isRecording ? _pauseIcon : _playIcon),
              label: Text(_isRecording ? _btnLabelStop : _btnLabelRecord), 
              onPressed: () {
                if (_isRecording) {
                  _seconds = 0;
                  stopRecorder();
                  play();
                }
                else {
                  record();
                }
                setState(() {
                  _isRecording = !_isRecording;
                });
              }, 
              )
            ),
            Container(height: 170, width: MediaQuery.of(context).size.width,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(30.0, 40, 30, 0),
                child: Card(
                  color: Color(0xFFFFCCBC),
                  child: Column(
                    children: [
                      Slider(
                        value: _currentSliderValue,
                        min: 0,
                        max: 100,
                        activeColor: Colors.white,
                        inactiveColor: Colors.grey,
                        label: _currentSliderValue.round().toString(),
                        onChanged: (double value) {
                          setState(() {
                            _currentSliderValue = value;
                          });
                        },
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          FloatingActionButton(
                            backgroundColor: Colors.white,
                            child: Icon(_isPlaying ? _pauseIcon : _playIcon),
                            elevation: 0, 
                            onPressed: () {
                              if (_isPlaying) {
                                stopPlayer();
                              }
                              else {
                                play();
                              }
                              setState(() {
                                _isRecording = !_isRecording;
                              });
                            }, 
                          ),
                          SizedBox(width: 10,),
                          FloatingActionButton(
                            backgroundColor: Colors.white,
                            child: Icon(_saveIcon),
                            elevation: 0, 
                            onPressed: () {
                              if (_isRecording) {
                                _seconds = 0;
                                stopRecorder();
                                play();
                              }
                              else {
                                record();
                              }
                              setState(() {
                                _isRecording = !_isRecording;
                              });
                            }, 
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
