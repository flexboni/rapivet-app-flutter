import 'dart:async';

import 'package:flutter/cupertino.dart';



// developer setting
double _max_opa_val =0.7;
double _min_opa_val = 0.3;
double _ani_interval = 0.01;
int _ani_gap = 33;


// passive
double _camera_area_height;
bool _is_animating = false;

double _opacity = 0;
bool _is_plus_opacity = true;

class animated_guide extends StatefulWidget {
  animated_guide(double _in_camera_area_height) {
    _camera_area_height = _in_camera_area_height;
  }

  @override
  _animated_guide createState() => _animated_guide();
}

class _animated_guide extends State<animated_guide> {

  @override
  void initState() {
    _is_animating= true;
    _is_plus_opacity = true;
    _opacity = 0;
    _update_progress();
  }

  @override
  void dispose() {
    _is_animating= false;
    super.dispose();
  }

  void _update_progress() async {
    Timer.periodic(Duration(milliseconds: _ani_gap), (timer) {

      if(_is_animating==false){
        timer.cancel();
      }

      if(_is_plus_opacity){
        _opacity = _opacity+_ani_interval;
      }else{
        _opacity = _opacity-_ani_interval;
      }

      if(_opacity>=_max_opa_val){
        _opacity = _max_opa_val;
        _is_plus_opacity = false;
      }

      if(_opacity<=_min_opa_val){
        _opacity = _min_opa_val;
        _is_plus_opacity = true;
      }

      setState(() {

      });

    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        alignment: Alignment.center,
        height: _camera_area_height,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Opacity(
              opacity: _opacity,
              child: Container(
                  height: _camera_area_height,
                  width: _camera_area_height * 0.5,
                  // color: Colors.red.withOpacity(0.5),
                  child: FittedBox(
                      fit: BoxFit.fill,
                      child: Image.asset("assets/guide.png"))),
            ),
          ],
        ));
  }
}
