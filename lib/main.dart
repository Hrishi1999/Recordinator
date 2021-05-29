import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

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
  bool _isRunning = false;

  IconData _playButton = Icons.play_arrow_rounded;
  IconData _stopButton = Icons.stop_rounded;

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

  String getTime(int seconds) {
    int s = seconds % 60; 
    int m = ((seconds / 60) % 60).toInt(); 
    int h = (seconds ~/ 3600).toInt(); 

    return h.toString() + "h " + m.toString() + "m " + s.toString() + "s";
  }

  @override
  void initState() async {
    super.initState();
    if (await Permission.microphone.request().isGranted) {

    }
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
            Text(getTime(_seconds), 
              style: TextStyle( fontFamily: 'MaterialYou', fontSize: 29, fontWeight: FontWeight.w100)
            ),
            Padding(
              padding: const EdgeInsets.only(top: 18.0),
              child: SizedBox(
                width: 150,
                height: 50,
                child: FloatingActionButton.extended(
                  onPressed: () {
                    setState(() {
                      if (_isRunning) {
                        _stopTimer();
                      }
                      else {
                        _startTimer();
                      }
                      _isRunning = !_isRunning;
                    });
                  },
                  elevation: 0,
                  label: Text('Record'),
                  icon: Icon(_isRunning ? _stopButton : _playButton),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
