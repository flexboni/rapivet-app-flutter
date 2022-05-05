import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:swork_raon/TestModule/First_cameraTest/testStatics.dart';

import 'First_cameraTest/ImgSearch_main.dart';

class Loading_imgSearch extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _loading_imgSearch();
}

class _loading_imgSearch extends State<StatefulWidget> {
  @override
  void initState() {
    _moveto_imgSearch_main();
  }

  @override
  void dispose() {
    super.dispose();
  }

  _moveto_imgSearch_main() async {
    await Future.delayed(Duration(milliseconds: 888));

    testStatics.is_to_show_jpg_to_check = false;

    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (BuildContext context) => ImgSearchHome()));
  }

  @override
  Widget build(BuildContext context) {
    double s_width = MediaQuery.of(context).size.width;
    // TODO: implement build
    return Scaffold(
        backgroundColor: Colors.black,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
                alignment: Alignment.center,
                width: s_width,
                color: Colors.black54,
                child: Text(
                  "Loading",
                  style: TextStyle(color: Colors.white),
                )),
          ],
        ));
  }
}
