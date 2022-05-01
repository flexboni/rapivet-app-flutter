import 'dart:io';

import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:swork_raon/0_CommonThisApp/rapivetStatics.dart';
import 'package:swork_raon/0_Commons_totally/JToast.dart';
import 'package:swork_raon/0_DataProcess/All_health_check_manager.dart';
import 'package:swork_raon/0_DataProcess/Pet_data_manager.dart';
import 'package:swork_raon/0_DataProcess/one_pet_data.dart';
import 'package:swork_raon/rapivet/SceneSubFuncs/Api_manager.dart';
import 'package:swork_raon/rapivet/SceneSubFuncs/test/0_API_Test_subfuncs.dart';
import 'package:swork_raon/rapivet/login.dart';

import '../4_RegisterPet.dart';
import '../5_Main.dart';
import '2_2_Login_subfuncs.dart';
import '4_2_ResterPet_subfuncs.dart';

class welcome_subFuncs {
  init_scene(BuildContext context) async {}

  void operate_start(BuildContext context) async {
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

    print(rapivetStatics.is_logged_on_user);
    print(rapivetStatics.is_simple_loggined);

    rapivetStatics.token = rapivetStatics.prefs.getString("token");
    // print("saved token: "+rapivetStatics.token);

    // 1. 로그인되지 않은 유저라면 로그인씬으로 ...
    if (rapivetStatics.is_logged_on_user == null ||
        rapivetStatics.is_logged_on_user == false) {
      // ios
      if (Platform.isIOS || rapivetStatics.is_force_to_ios) {
        String token = await api_test_subFuncs().test_ios_signup();
        print(token);
        if (token.trim() == "") {
          JToast().show_toast("Impossível dar continuidade.", false);
        } else {
          // save login
          // do job after first login
          List<one_pet_data> petDatas = await Api_manager().get_pet_list(token);
          rapivetStatics.pet_data_list = petDatas;

          Login_subFuncs()
              .operate_after_login(context, token, is_simple_login: true);
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

    List<String> loaded_myPetlist = null; // local style

    // 2. 로그인된 유저라면 ... (서버에서 가져오기)
    if (rapivetStatics.is_logged_on_user) {
      List<one_pet_data> petDatas =
          await Api_manager().get_pet_list(rapivetStatics.token);

      // 서버에 펫데이터가 없다면: 등록화면으로
      if (petDatas == null || petDatas == [] || petDatas.length == 0) {
        loaded_myPetlist = null;
      }
      // 서버에 펫데이터가 있다면 홈(메인)화면으로
      else {
        rapivetStatics.current_pet_index = 0;
        rapivetStatics.pet_data_list = petDatas;

        // get pet health info from server
        await All_health_check_manager().get_all_health_check_infos();

        Navigator.pushReplacement(context,
            PageTransition(type: PageTransitionType.fade, child: Main_scene()));
        //
        // Navigator.pushReplacement(context,
        //     MaterialPageRoute(builder: (BuildContext context) => Main_scene()));

        return;
      }
    }

    // 3. 동물 데이터가 있다면 불러올 것.temp (local 대비용) --------------------
    loaded_myPetlist = rapivetStatics.prefs.getStringList("mypets");

    if (loaded_myPetlist != null) {
      rapivetStatics.is_logged_on_user = false;
      rapivetStatics.current_pet_index = 0;
      rapivetStatics.pet_data_list = Pet_data_manager().load_local_petDB();
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (BuildContext context) => Main_scene()));
    }

    // 4. 동물 데이터가 없다면 애완동물 등록 페이지로
    if (loaded_myPetlist == null) {
      JToast().show_toast("Faça o cadastramento do primeiro pet.", false);

      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) =>
                  RegisterPet_scene(COME_FROM.WELCOME, PET_REGISTER_MODE.ADD)));
    }
  }
}
