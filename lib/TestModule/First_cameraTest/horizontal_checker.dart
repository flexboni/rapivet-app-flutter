import 'dart:async';

import 'package:flutter/material.dart';
import 'package:motion_sensors/motion_sensors.dart';

class horizontal_checker extends StatefulWidget {
  @override
  _horizontal_checker_home createState() => _horizontal_checker_home();
}

double _yaw, _pitch, _roll;
double y_val=0, x_val=0;

class _horizontal_checker_home extends State<horizontal_checker> {
  StreamSubscription _streamSubscriptions;
  
  @override
  void initState() {
    super.initState();

    motionSensors.isOrientationAvailable().then((available) {
      if (available) {
        _streamSubscriptions =
            motionSensors.orientation.listen((OrientationEvent event) {
          setState(() {
            _yaw = event.yaw;
            _pitch = event.pitch;
            _roll = event.roll;


            double _pith_abs = _pitch.abs();
            double _roll_abs = _roll.abs();

            if(_pith_abs>0.2 || _roll_abs>0.2){

              double factor = 0;

              if(_pith_abs > _roll_abs){
                factor = _pith_abs/0.2;
              }else{
                factor = _roll_abs/0.2;
              }

              _pitch = _pitch/factor;
              _roll = _roll/factor;
            }

            y_val = 2.5 * _pitch +0.5;
            x_val = 2.5 * _roll+0.5;

          });
        }, cancelOnError: true);
      }
    });
  }

  @override
  void dispose() {
    _streamSubscriptions.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    double s_width = MediaQuery.of(context).size.width;
    double s_height = MediaQuery.of(context).size.height;
    double circle_w = s_width / 8;
    double s_circle_w = circle_w/3;

    _get_padding_top(){
      return (circle_w - s_circle_w)*y_val;
    }

    _get_padding_left(){
      return (circle_w - s_circle_w)*x_val;
    }

    return Container(
      child: Stack(
        children: [
          Opacity(
            opacity: 0.5,
            child: Container(
                alignment: Alignment.center,
                width: circle_w,
                child: Image.asset("assets/circle_blue.png")),
          ),
          Opacity(
            opacity: 0.5,
            child: Padding(
              padding: EdgeInsets.fromLTRB(_get_padding_left(), _get_padding_top(), 0, 0),
              child: Container(
                  width: circle_w / 3,
                  child: Image.asset("assets/circle_white.png")),
            ),
          ),
        ],
      ),
    );

    // return Column(
    //   children: [
    //     Text(
    //       _pitch.toString(),
    //       style: TextStyle(color: Colors.red),
    //     ),
    //     Text(
    //       _roll.toString(),
    //       style: TextStyle(color: Colors.red),
    //     ),
    //   ],
    // );
  }
}
