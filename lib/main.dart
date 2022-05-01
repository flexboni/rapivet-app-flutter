import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:swork_raon/rapivet/main.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp]); //< 세로로만 UI 표시 설정

  // SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
  //   statusBarColor: Colors.black,
  // ));
  // Firebase.initializeApp();
  runApp(MainPage());
}
