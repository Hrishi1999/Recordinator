import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:recordinator/record.dart';


class RecordingsPage extends StatefulWidget {
  RecordingsPage({Key key, this.title}) : super(key: key);
  
  final String title;

  @override
  _RecordingsPageState createState() => _RecordingsPageState();
}

class _RecordingsPageState extends State<RecordingsPage> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        iconTheme: IconThemeData(
          color: Colors.black, //change your color here
        ),
        backgroundColor: Color(0xFFFDF2F0),
        title: Text(widget.title,
          style: TextStyle(color: Color(0xFF463C37), fontFamily: 'MaterialYou', fontSize: 25, fontWeight: FontWeight.w100),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
      currentIndex: 1,
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
        onTap: (int index) {
          print('tapped');
          if (index == 0) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => RecordPage(title: 'Record',)),
            );   
          }
        },
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              height: 75,
              width: MediaQuery.of(context).size.width - 35,
              child: Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                color: Color(0xFFFDF2F0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              SizedBox(
                                height: 42,
                                width: 42,
                                child: FloatingActionButton(
                                  child: Icon(Icons.play_arrow_rounded),
                                  elevation: 0,
                                  onPressed: () {

                                  },
                                ),
                              ),
                              SizedBox(width: 8,),
                              Text('Title', style: TextStyle( fontFamily: 'MaterialYou', fontSize: 21, fontWeight: FontWeight.w100)),
                            ],
                          ),
                          
                          Text('0h 0m 0s', style: TextStyle( fontFamily: 'MaterialYou', fontSize: 17, fontWeight: FontWeight.w100))
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
