import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:swork_raon/rapivet/welcome.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  //< 세로로만 UI 표시 설정
  SystemChrome.setPreferredOrientations(
    [DeviceOrientation.portraitUp],
  );

  runApp(MainPage());
}

class MainPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rapivet',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: WelcomePage(),
    );
  }
}
