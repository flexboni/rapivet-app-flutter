import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:swork_raon/common/JToast.dart';
import 'package:swork_raon/model/All_health_check_manager.dart';
import 'package:swork_raon/model/Pet_data_manager.dart';
import 'package:swork_raon/model/one_pet.dart';
import 'package:swork_raon/rapivet/scene_sub_functions/2_2_Login_subfuncs.dart';
import 'package:swork_raon/rapivet/scene_sub_functions/4_2_ResterPet_subfuncs.dart';
import 'package:swork_raon/rapivet/scene_sub_functions/Api_manager.dart';
import 'package:swork_raon/rapivet/scene_sub_functions/common_ui.dart';
import 'package:swork_raon/rapivet/scene_sub_functions/test/0_API_Test_subfuncs.dart';

import '../common/rapivet_statics.dart';

class WelcomePage extends StatefulWidget {
  WelcomePage({Key? key}) : super(key: key);

  @override
  _WelcomeHomeState createState() => _WelcomeHomeState();
}

bool _isLoading = false;
double animationIntervalMilSec = 1888;
int animIndex = 0;

class _WelcomeHomeState extends State<WelcomePage>
    with TickerProviderStateMixin {
  void onClickRegister() async {
    setState(() {
      _isLoading = true;
    });

    // 1. init prefs --------------------------------
    RapivetStatics.prefs = await SharedPreferences.getInstance();
    // get pets' name list from server
    if (RapivetStatics.isSkipGetPetList == false) {
      RapivetStatics.cats = await register_subFuncs()
          .get_pet_type_infos(RapivetStatics.urlGetTypeCat);
      RapivetStatics.dogs = await register_subFuncs()
          .get_pet_type_infos(RapivetStatics.urlGetTypeDog);
    }
    RapivetStatics.isLoggedOnUser =
        RapivetStatics.prefs?.getBool("is_logged_on_user") ?? false;
    RapivetStatics.isSimpleLoggedIn =
        RapivetStatics.prefs?.getBool("is_simple_login")!;
    if (RapivetStatics.isLoggedOnUser == null) {
      RapivetStatics.isLoggedOnUser = false;
    }
    if (RapivetStatics.isSimpleLoggedIn == null) {
      RapivetStatics.isSimpleLoggedIn = false;
    }
    RapivetStatics.token = RapivetStatics.prefs?.getString("token")!;

    // 1. 로그인되지 않은 유저라면 로그인 페이지로
    if (RapivetStatics.isLoggedOnUser == false) {
      // ios
      if (Platform.isIOS || RapivetStatics.isForcedIOS) {
        String token = await api_test_subFuncs().test_ios_signup();
        if (token.trim() == "") {
          JToast().show_toast(
            "Impossível dar continuidade.",
            false,
          );
        } else {
          // save login
          // do job after first login
          List<OnePet> petData = await Api_manager().get_pet_list(token);
          RapivetStatics.petDataList = petData;
          Login_subFuncs().operate_after_login(
            context,
            token,
            is_simple_login: true,
          );
        }
        return;
      }

      // Android
      // TODO
      // Navigator.pushReplacement(
      //   context,
      //   PageTransition(
      //     type: PageTransitionType.fade,
      //     child: LoginPage(),
      //   ),
      // );
      return;
    }

    List<String>? loadedMyPetList; // local style

    // 2. 로그인된 유저라면 ... (서버에서 가져오기)
    if (RapivetStatics.isLoggedOnUser && RapivetStatics.token != null) {
      List<OnePet> petData =
          await Api_manager().get_pet_list(RapivetStatics.token!);

      // 서버에 펫데이터가 없다면: 등록화면으로
      if (petData == [] || petData.length == 0) {
        loadedMyPetList = null;
      }
      // 서버에 펫데이터가 있다면 홈(메인)화면으로
      else {
        RapivetStatics.currentPetIndex = 0;
        RapivetStatics.petDataList = petData;

        // get pet health info from server
        await All_health_check_manager().get_all_health_check_infos();

        // 홈 화면으로 이동
        // TODO
        // Navigator.pushReplacement(
        //   context,
        //   PageTransition(
        //     type: PageTransitionType.fade,
        //     child: HomePage(),
        //   ),
        // );
        return;
      }
    }

    // 3. 동물 데이터가 있다면 불러올 것.temp (local 대비용) --------------------
    loadedMyPetList = RapivetStatics.prefs?.getStringList("mypets");
    if (loadedMyPetList != null) {
      RapivetStatics.isLoggedOnUser = false;
      RapivetStatics.currentPetIndex = 0;
      RapivetStatics.petDataList = Pet_data_manager().load_local_petDB();
      // TODO
      // Navigator.pushReplacement(
      //   context,
      //   MaterialPageRoute(
      //     builder: (BuildContext context) => HomePage(),
      //   ),
      // );
    }

    // 4. 동물 데이터가 없다면 애완동물 등록 페이지로
    if (loadedMyPetList == null) {
      JToast().show_toast("Faça o cadastramento do primeiro pet.", false);
      // TODO
      // Navigator.pushReplacement(
      //   context,
      //   MaterialPageRoute(
      //     builder: (BuildContext context) => RegisterPet_scene(
      //       COME_FROM.WELCOME,
      //       PET_REGISTER_MODE.ADD,
      //     ),
      //   ),
      // );
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
                              color: RapivetStatics.appBlue,
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
                      RapivetStatics.appBlue,
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
