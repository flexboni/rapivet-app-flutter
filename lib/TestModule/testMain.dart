import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'First_cameraTest/ImgSearch_main.dart';
import 'First_cameraTest/testStatics.dart';

void main() {
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp]); //< 세로로만 UI 표시 설정
  runApp(Iptm_App());
}

class Iptm_App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Camera App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Iptm_App_home(title: 'IMG Proc Test Module '),
    );
  }
}

class Iptm_App_home extends StatefulWidget {
  Iptm_App_home({Key key, this.title}) : super(key: key);
  final String title;
  @override
  _Iptm_App_home_State createState() => _Iptm_App_home_State();
}

class _Iptm_App_home_State extends State<Iptm_App_home> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
        body: Column(
      children: [
        Padding(padding: new EdgeInsets.all(38)),
        Container(
          alignment: Alignment.center,
          height: 68.88,
          child: OutlinedButton(
              onPressed: () {
                testStatics.is_to_show_jpg_to_check = false;

                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) => ImgSearchHome()));
              },
              child: Text(
                '    STICK SEARCHING    ',
                style: TextStyle(color: Colors.redAccent, fontSize: 18.88),
              )),
        ),
      ],
    ));
  }
}
