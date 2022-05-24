import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:swork_raon/common/JToast.dart';
import 'package:swork_raon/model/All_health_check_manager.dart';
import 'package:swork_raon/model/Pet_data_manager.dart';
import 'package:swork_raon/model/one_pet_data.dart';
import 'package:swork_raon/rapivet/4_RegisterPet.dart';
import 'package:swork_raon/rapivet/home.dart';
import 'package:swork_raon/rapivet/login.dart';
import 'package:swork_raon/rapivet/scene_sub_functions/2_2_Login_subfuncs.dart';
import 'package:swork_raon/rapivet/scene_sub_functions/4_2_ResterPet_subfuncs.dart';
import 'package:swork_raon/rapivet/scene_sub_functions/Api_manager.dart';
import 'package:swork_raon/rapivet/scene_sub_functions/common_ui.dart';
import 'package:swork_raon/rapivet/scene_sub_functions/test/0_API_Test_subfuncs.dart';

import '../common/rapivetStatics.dart';

class WelcomePage extends StatefulWidget {
  WelcomePage({Key key}) : super(key: key);
  @override
  _WelcomeHomeState createState() => _WelcomeHomeState();
}

bool _isLoading = false;
double animationIntervalMilSec = 1888;
int animIndex = 0;
bool isStopTimer = false;

class _WelcomeHomeState extends State<WelcomePage>
    with TickerProviderStateMixin {
  @override
  void initState() {
    initializeAPP();
    super.initState();
  }

  @override
  void dispose() {
    isStopTimer = true;
    super.dispose();
  }

  void initializeAPP() async {
    _isLoading = true;

    try {
      // Wait for Firebase to initialize and set `_initialized` state to true
      Future.delayed(Duration(milliseconds: 888));
      await Firebase.initializeApp();
      rapivetStatics.auth = FirebaseAuth.instance;
    } catch (e) {}

    setState(() {
      _isLoading = false;
    });
  }

  void onClickRegister() async {
    setState(() {
      _isLoading = true;
    });

    // 1. init prefs --------------------------------
    rapivetStatics.prefs = await SharedPreferences.getInstance();

    // get pets' name list from server
    if (rapivetStatics.is_skip_get_petList == false) {
      rapivetStatics.cat_kind_set = await register_subFuncs()
          .get_pet_type_infos(rapivetStatics.url_get_type_cat);
      rapivetStatics.dog_kind_set = await register_subFuncs()
          .get_pet_type_infos(rapivetStatics.url_get_type_dog);
    }

    rapivetStatics.is_logged_on_user =
        rapivetStatics.prefs.getBool("is_logged_on_user");
    rapivetStatics.is_simple_loggined =
        rapivetStatics.prefs.getBool("is_simple_login");

    if (rapivetStatics.is_logged_on_user == null)
      rapivetStatics.is_logged_on_user = false;

    if (rapivetStatics.is_simple_loggined == null)
      rapivetStatics.is_simple_loggined = false;

    rapivetStatics.token = rapivetStatics.prefs.getString("token");

    // 1. 로그인되지 않은 유저라면 로그인 페이지로
    if (rapivetStatics.is_logged_on_user == null ||
        rapivetStatics.is_logged_on_user == false) {
      // ios
      if (Platform.isIOS || rapivetStatics.is_force_to_ios) {
        String token = await api_test_subFuncs().test_ios_signup();
        if (token.trim() == "") {
          JToast().show_toast(
            "Impossível dar continuidade.",
            false,
          );
        } else {
          // save login
          // do job after first login
          List<one_pet_data> petData = await Api_manager().get_pet_list(token);
          rapivetStatics.pet_data_list = petData;
          Login_subFuncs().operate_after_login(
            context,
            token,
            is_simple_login: true,
          );
        }
        return;
      }

      // Android
      Navigator.pushReplacement(
        context,
        PageTransition(
          type: PageTransitionType.fade,
          child: LoginPage(),
        ),
      );

      return;
    }

    List<String> loadedMyPetList; // local style

    // 2. 로그인된 유저라면 ... (서버에서 가져오기)
    if (rapivetStatics.is_logged_on_user) {
      List<one_pet_data> petData =
          await Api_manager().get_pet_list(rapivetStatics.token);

      // 서버에 펫데이터가 없다면: 등록화면으로
      if (petData == null || petData == [] || petData.length == 0) {
        loadedMyPetList = null;
      }
      // 서버에 펫데이터가 있다면 홈(메인)화면으로
      else {
        rapivetStatics.current_pet_index = 0;
        rapivetStatics.pet_data_list = petData;

        // get pet health info from server
        await All_health_check_manager().get_all_health_check_infos();

        // 홈 화면으로 이동
        Navigator.pushReplacement(
          context,
          PageTransition(
            type: PageTransitionType.fade,
            child: HomePage(),
          ),
        );
        return;
      }
    }

    // 3. 동물 데이터가 있다면 불러올 것.temp (local 대비용) --------------------
    loadedMyPetList = rapivetStatics.prefs.getStringList("mypets");

    if (loadedMyPetList != null) {
      rapivetStatics.is_logged_on_user = false;
      rapivetStatics.current_pet_index = 0;
      rapivetStatics.pet_data_list = Pet_data_manager().load_local_petDB();
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (BuildContext context) => HomePage()));
    }

    // 4. 동물 데이터가 없다면 애완동물 등록 페이지로
    if (loadedMyPetList == null) {
      JToast().show_toast("Faça o cadastramento do primeiro pet.", false);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => RegisterPet_scene(
            COME_FROM.WELCOME,
            PET_REGISTER_MODE.ADD,
          ),
        ),
      );
    }

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
                              letterSpacing: -0.38,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 3. img main
                  Expanded(
                    flex: 1,
                    child: Container(
                      width: sWidth * 0.9,
                      child: Image.asset("assets/raon_welcome.png"),
                    ),
                  ),

                  // 4. register btn
                  Padding(padding: new EdgeInsets.all(13)),
                  Container(
                    child: get_one_btn(
                      sWidth * 0.9,
                      rapivetStatics.app_blue,
                      "Vamos lá",
                      onClickRegister,
                      in_height: 53,
                    ),
                  ),
                  // 5. signup/login btn
                  Padding(padding: new EdgeInsets.all(38)),
                ],
              ),
              show_loading(_isLoading, sHeight, sWidth, this),
            ],
          ),
        ),
      ),
    );
  }
}
