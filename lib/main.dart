import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Recordinator',
      theme: ThemeData(
        accentColor: Color(0xFFFB9A94),
      ),
      home: RecordPage(title: 'Recordinator'),
    );
  }
}

class RecordPage extends StatefulWidget {
  RecordPage({Key key, this.title}) : super(key: key);
  
  final String title;

  @override
  _RecordPageState createState() => _RecordPageState();
}

class _RecordPageState extends State<RecordPage> {

  int _seconds = 0;

  Timer _timer;
  bool _isRecording = false;

  IconData _playButton = Icons.play_arrow_rounded;
  IconData _stopButton = Icons.stop_rounded;

  FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  bool _recorderIsInited = false; 
  bool _recorded = false;

  FlutterSoundPlayer _player = FlutterSoundPlayer();
  StreamSubscription _playerSubscription;
  bool _playerIsIntited = false;
  bool _isPlaying = false;

  double currentValue = 0;
  double maxValue = 0;

  void _startTimer() {
    _seconds = 0;
    if (_timer != null) {
      _timer.cancel();
    }
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _seconds++;
      });
    });
  }

  void _stopTimer() {
    _seconds = 0;
    _timer.cancel();
  }

  String _getTime(int seconds) {
    int s = seconds % 60; 
    int m = ((seconds / 60) % 60).toInt(); 
    int h = (seconds ~/ 3600).toInt(); 

    return h.toString() + "h " + m.toString() + "m " + s.toString() + "s";
  }

  void _getPermissions () async {
    await Permission.microphone.request();
    await Permission.storage.request();
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('yyyy-MM-dd – kk:mm').format(now);
    return directory.path + '/$formattedDate.mp3';
  } 

  Future<void> record() async {
    await _recorder.startRecorder(
      toFile: _localPath.toString(),
      codec: Codec.aacADTS,
    );
  }

  Future<void> stopRecorder() async {
    await _recorder.stopRecorder();
  }

  void play() async {
    cancelSubscription();
    _player.setSubscriptionDuration(Duration(milliseconds: 10));
    setState(() {
      _isPlaying = true;
    });
    await _player.startPlayer(
      fromURI: _localPath.toString(),
      codec: Codec.mp3,
      whenFinished: (){setState((){});}
    );
    setupListener();
    setState(() {});
  }

  Future<void> stopPlayer() async {
    cancelSubscription();
    setState(() {
      _isPlaying = false;
    });
    if (_player != null) {
      await _player.stopPlayer();
    }
  }

  void setupListener() {
    cancelSubscription();
    _playerSubscription = _player.onProgress.listen((event) {
      setState(() {
        currentValue = event.position.inSeconds.toDouble();
        maxValue = event.duration.inSeconds.toDouble();
      });
    });
  }

  void cancelSubscription() {
    if (_playerSubscription != null) {
      _playerSubscription.cancel();
      _playerSubscription = null;
    }
  }

  @override
  void initState() {
    super.initState();
    _getPermissions();

    _recorder.openAudioSession().then((value) {
      setState(() {
        _recorderIsInited = true;
      });
    });

    _player.openAudioSession().then((value) {
      setState(() {
        _playerIsIntited = true;
      });
    });

  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Color(0xFFFDF2F0),
    ));
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Color(0xFFFDF2F0),
        title: Text(widget.title,
          style: TextStyle(color: Color(0xFF463C37), fontFamily: 'MaterialYou', fontSize: 25, fontWeight: FontWeight.w100),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
      currentIndex: 0,
      backgroundColor: Color(0xFFFDF2F0),
      selectedItemColor: Theme.of(context).accentColor,
      items: [
          BottomNavigationBarItem(
            icon: new Icon(Icons.mic_none_rounded),
            label: 'Record',
          ),
          BottomNavigationBarItem(
            icon: new Icon(Icons.list),
            label: 'Recordings',
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(_getTime(_seconds), 
              style: TextStyle( fontFamily: 'MaterialYou', fontSize: 29, fontWeight: FontWeight.w100)
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 18, 0, 18),
              child: SizedBox(
                width: 150,
                height: 50,
                child: FloatingActionButton.extended(
                  onPressed: () {
                    setState(() {
                      if (_isRecording) {
                        _stopTimer();
                        stopRecorder();
                        _recorded = true;
                      }
                      else {
                        _startTimer();
                        record();
                      }
                      _isRecording = !_isRecording;
                    });
                  },
                  elevation: 0,
                  label: Text('Record'),
                  icon: Icon(_isRecording ? _stopButton : _playButton),
                ),
              ),
            ),
            Container(
              height: _recorded ? 180 : 0,
              width: MediaQuery.of(context).size.width - 35,
              child: Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                color: Color(0xFFFDF2F0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: Slider(
                        activeColor: Theme.of(context).accentColor,
                        value: currentValue,
                        min: 0,
                        max: maxValue,
                        divisions: maxValue == 0.0 ? 1 : maxValue.toInt(),
                        onChanged: (double value) {
                          setState(() {
                            if (value == maxValue) {
                              stopPlayer();
                            }
                            currentValue = value;                            
                          });
                        },
                        onChangeStart: (double value) {
                          if (!_player.isStopped) {
                            _player.pausePlayer();
                            setState(() {
                              _isPlaying = false;
                            });
                          }
                        },
                        onChangeEnd: (double value) async {
                          await _player.seekToPlayer(Duration(seconds: value.toInt()));
                          if (!_player.isStopped) {
                            _player.resumePlayer();   
                            setState(() {
                              _isPlaying = true;
                            });                     
                          }
                        }
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(_getTime(currentValue.toInt()), style: TextStyle(color: Color(0xFF463C37), fontFamily: 'MaterialYou', fontSize: 17, fontWeight: FontWeight.w100)), 
                        Text(' / ', style: TextStyle(fontSize: 25, fontWeight: FontWeight.w300)),
                        Text(_getTime(maxValue.toInt()), style: TextStyle(color: Color(0xFF463C37), fontFamily: 'MaterialYou', fontSize: 17, fontWeight: FontWeight.w100)), 
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          FloatingActionButton(
                            elevation: 0,
                            child: Icon(_isPlaying ? _stopButton : _playButton),
                            backgroundColor: Colors.white,
                            onPressed: () {
                              setState(() {
                                if (_isPlaying) {
                                  stopPlayer();
                                }
                                else {
                                  play();
                                }
                              });
                            }
                          ),
                          SizedBox(width: 10,),
                          FloatingActionButton(
                            elevation: 0,
                            child: Icon(Icons.save_rounded),
                            backgroundColor: Colors.white,
                            onPressed: () {
                              
                            }
                          )
                        ],
                      ),
                    )
                  ],
                ),
              )
            )
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Be careful : you must `close` the audio session when you have finished with it.
    _recorder.closeAudioSession();
    _recorder = null;
    cancelSubscription();
    super.dispose();
  }
}
