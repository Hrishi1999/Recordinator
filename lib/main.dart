import 'package:flutter/material.dart';
import 'record.dart';
import 'recordings.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}
class _MyAppState extends State<MyApp> {

  int _pageIndex = 0;
  PageController _pageController;

  List<Widget> pages = [
    RecordPage(),
    RecordingsPage(),
  ];

  @override
  void initState(){
    super.initState();
    _pageController = PageController(initialPage: _pageIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

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

