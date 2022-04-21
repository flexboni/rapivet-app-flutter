import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:swork_raon/RapiVet/SceneSubFuncs/0_commonUI.dart';
import 'package:swork_raon/RapiVet/SceneSubFuncs/1_2_Welcome_subfuncs.dart';

import '../0_CommonThisApp/rapivetStatics.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp]); //< 세로로만 UI 표시 설정

  // SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
  //   statusBarColor: Colors.black,
  // ));
  // Firebase.initializeApp();
  runApp(WelcomePage());
}

bool _isLoading = false;

class WelcomePage extends StatelessWidget {
  //final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rapivet',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: WelcomePageStateful(title: 'Rapivet'),
    );
  }
}

class WelcomePageStateful extends StatefulWidget {
  WelcomePageStateful({Key key, this.title}) : super(key: key);
  final String title;
  @override
  _WelcomeHomeState createState() => _WelcomeHomeState();
}

// List<String> animationSet = [
//   "assets/test_img/dog.JPG",
//   "assets/test_img/cat.JPG",
//   "assets/test_img/dog2.JPG"
// ];
//List<String> animationSet = ["assets/test_img/ani1.png","assets/test_img/ani2.png"];

double animationIntervalMilSec = 1888;
int animIndex = 0;
bool isStopTimer = false;

class _WelcomeHomeState extends State<WelcomePageStateful>
    with TickerProviderStateMixin {
  @override
  void initState() {
    initializeAPP();
    super.initState();
    // _update_animation();
  }

  @override
  void dispose() {
    isStopTimer = true;

    super.dispose();
  }

  void initializeAPP() async {
    _isLoading = true;

    // 1. firebase --------------------------
    try {
      // Wait for Firebase to initialize and set `_initialized` state to true
      Future.delayed(Duration(milliseconds: 888));
      await Firebase.initializeApp();
      rapivetStatics.auth = FirebaseAuth.instance;

      setState(() {
        // _initialized = true;
      });
    } catch (e) {
      // Set `_error` state to true if Firebase initialization fails
      setState(() {
        // _error = true;
      });
    }

    // await welcome_subFuncs().init_scene(context);

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(statusBarColor: Colors.transparent));

    double leftOffset = 30;
    double sWidth = MediaQuery.of(context).size.width;
    double sHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: SafeArea(
            child: Stack(
          children: [
            Column(
              children: [
                // 1. welcome msg
                Padding(padding: new EdgeInsets.all(38)),
                Container(
                  alignment: Alignment.centerLeft,
                  padding: new EdgeInsets.fromLTRB(leftOffset, 0, 0, 0),
                  child: Text(
                    "BEM VINDO",
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 38,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                // 2. company msg
                Padding(padding: new EdgeInsets.all(3)),
                Container(
                  alignment: Alignment.centerLeft,
                  padding: new EdgeInsets.fromLTRB(leftOffset, 0, 0, 0),
                  child: RichText(
                      text: TextSpan(
                          // text : "",
                          style: DefaultTextStyle.of(context).style,
                          children: <TextSpan>[
                        TextSpan(
                          text: "RAON",
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 16,
                            color: rapivetStatics.app_blue,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.none,
                          ),
                        ),
                        TextSpan(
                          text: " protege a saúde\ndos seus Pets.",
                          style: TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 16,
                              color: Colors.black.withOpacity(0.78),
                              fontWeight: FontWeight.normal,
                              decoration: TextDecoration.none,
                              height: 1.45,
                              letterSpacing: -0.38),
                        ),
                      ])),
                  // child: Text(
                  //   "RAON protege a saude\ndos seu pets de estimacao.",
                  //   style: TextStyle(fontSize: 15),
                  // )
                ),

                // 3. img main
                Expanded(
                    flex: 1,
                    child: Container(
                        width: sWidth * 0.9,
                        child: Image.asset("assets/raon_welcome.png"))),

                // 4. register btn
                Padding(padding: new EdgeInsets.all(13)),
                Container(
                    child: get_one_btn(
                        sWidth * 0.9, rapivetStatics.app_blue, "Vamos lá",
                        () async {
                  setState(() {
                    _isLoading = true;
                  });
                  welcome_subFuncs().operate_start(context);
                  setState(() {
                    _isLoading = false;
                  });
                  // Navigator.push(
                  //     context,
                  //     MaterialPageRoute(
                  //         builder: (BuildContext context) =>  Login_scene() /*Api_test_scene()*/));
                }, in_height: 53)),
                // 5. signup/login btn
                Padding(padding: new EdgeInsets.all(38)),
                // Container(
                //     child: get_one_btn(
                //         s_width * 0.8, rapivetStatics.app_blue, "Q&A", () {
                //       Navigator.push(
                //           context,
                //           MaterialPageRoute(
                //               builder: (BuildContext context) =>  QA_read() /*Api_test_scene()*/));
                //     }, in_height: 53)),
                // Padding(padding: new EdgeInsets.all(38)),
              ],
            ),
            show_loading(_isLoading, sHeight, sWidth, this),
          ],
        )),
      ),
    );
  }

  // void _update_animation() async {
  //   double times = 0;
  //
  //   Timer.periodic(Duration(milliseconds: 100), (timer) {
  //     if (is_stop_timer) {
  //       is_stop_timer = false;
  //       timer.cancel();
  //     }
  //
  //     times += 100;
  //     if (times >= animation_interval_milSec) {
  //       times = 0;
  //       anim_index++;
  //
  //       if (anim_index >= animationSet.length) anim_index = 0;
  //
  //       setState(() {});
  //     }
  //   });
  // }
}
