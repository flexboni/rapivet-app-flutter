import 'dart:io';
import 'dart:isolate';

import 'package:camera/camera.dart';
import 'package:shared_preferences/shared_preferences.dart';

class myparams {
  CameraImage img;
  String filePath;
  bool is_testMode;
}
