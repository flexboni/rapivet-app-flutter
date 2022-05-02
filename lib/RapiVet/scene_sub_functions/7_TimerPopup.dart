import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:swork_raon/0_CommonThisApp/rapivetStatics.dart';
import 'package:swork_raon/TestModule/First_cameraTest/ImgSearch_main.dart';

import 'common_ui.dart';
import '7_2_Test_Guide_subFuncs.dart';

bool _is_showingTimer;
double s_width, s_height;

int _timeRemain = 60;
String _timeRemain_str = "";
bool _exitTimer = false;

DateTime _timer_startTime = DateTime(1983);

class TimerPopup extends StatefulWidget {
  TimerPopup(bool in_is_showingTimer, double in_s_width, double in_s_height) {
    print("in_is_showingTimer: " + in_is_showingTimer.toString());

    _is_showingTimer = in_is_showingTimer;
    s_width = in_s_width;
    s_height = in_s_height;
    _timer_startTime = DateTime.now();
  }

  @override
  _timerPopup createState() => _timerPopup();
}

class _timerPopup extends State<TimerPopup> {
  @override
  void initState() {
    super.initState();
    _exitTimer = false;
    _timeRemain = 60;
    _startTimer();
  }

  @override
  void dispose() {
    _exitTimer = true;
    _endTimer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: _is_showingTimer,
      child: Container(
          color: Colors.black.withOpacity(0.8),
          width: s_width,
          child: Column(
            children: [
              Padding(padding: new EdgeInsets.fromLTRB(0, s_height / 4, 0, 0)),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(
                    Radius.circular(18),
                  ),
                ),
                width: s_width * 0.9,
                child: Column(
                  children: [
                    Padding(padding: new EdgeInsets.all(18)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                            alignment: Alignment.topCenter,
                            width: 23,
                            child: Image.asset(
                              "assets/dogface.png",
                              fit: BoxFit.fitWidth,
                            )),
                        Padding(padding: new EdgeInsets.all(3)),
                        Text(
                          "Contagem Regressiva",
                          style: TextStyle(
                              fontSize: 15,
                              color: Colors.black.withOpacity(0.8)),
                        ),
                      ],
                    ),
                    Padding(padding: new EdgeInsets.all(7)),
                    Text(
                      _timeRemain_str,
                      style: TextStyle(
                          fontSize: 43,
                          fontWeight: FontWeight.bold,
                          fontFamily: "Roboto",
                          color: Colors.black.withOpacity(0.8)),
                    ),
                    Padding(padding: new EdgeInsets.all(10)),
                    Text(
                      "Já se passou 1 minuto?",
                      style: TextStyle(
                          fontSize: 15, color: Colors.black.withOpacity(0.88)),
                    ),
                    Padding(padding: new EdgeInsets.all(15)),
                    get_one_btn(
                        s_width * 0.8, rapivetStatics.app_blue, "Próximo", () {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  ImgSearchHome()));
                    }, in_height: 50),
                    Padding(padding: new EdgeInsets.all(8)),
                    get_one_btn(
                        s_width * 0.8, rapivetStatics.app_blue, "Fechar", () {
                      _endTimer();
                    }, in_height: 50),
                    Padding(padding: new EdgeInsets.all(15)),
                  ],
                ),
              ),
            ],
          )),
    );
  }

  _startTimer() {
    try {
      setState(() {
        _exitTimer = false;
        _timeRemain = 60;
        _timer_startTime = DateTime.now();
        _update();
      });
    } catch (e) {
      print("catch: " + "_startTimer");
    }
  }

  _endTimer() {
    try {
      setState(() {
        //_exitTimer = true;
        _is_showingTimer = false;
      });
    } catch (e) {
      print("catch: " + "_endTimer");
    }
  }

  _update() {
    int time_called = 0;

    Timer.periodic(Duration(milliseconds: 13), (timer) {
      if (_exitTimer) timer.cancel();

      if (_is_showingTimer == false) return;

      time_called = time_called + 13;

      Duration gap = DateTime.now().difference(_timer_startTime);

      int remainedTime =
          rapivetStatics.test_takePic_waitSec * 1000 - gap.inMilliseconds;

      _timeRemain = remainedTime;
      _timeRemain_str = Test_Guide_subFuncs().millsec_to_MMssmm(_timeRemain);

      if (_timeRemain <= 0) {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (BuildContext context) => ImgSearchHome()));
        timer.cancel();
      }

      try {
        setState(() {});
      } catch (e) {}

      if (time_called % 200 == 0) {
        try {
          setState(() {});
        } catch (e) {}
      }
    });
  }
}
