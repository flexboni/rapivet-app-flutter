import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:swork_raon/common/JToast.dart';
import 'package:swork_raon/common/rapivetStatics.dart';
import 'package:swork_raon/model/All_health_check_manager.dart';
import 'package:swork_raon/model/one_pet_data.dart';
import 'package:swork_raon/rapivet/5_Main.dart';
import 'package:swork_raon/rapivet/scene_sub_functions/Api_manager.dart';

import '../4_RegisterPet.dart';

class Login_subFuncs {
  operate_social_sign(BuildContext context, String email, String name) async {
    String token = "";

    // 1. 회원가입 시도
    List result = await Api_manager().social_signup(email, name);
    if (result[0] == true) {
      // 회원가입 성공, 토큰으로 로그인 표시
      token = result[1].toString();
      print(token);
    } else {
      // 회원가입 실패, 로그인 시도
      print("=============================");
      result = await Api_manager().social_login(email);
      if (result[0] == true) {
        token = result[1].toString();
        print(token);
      }
    }

    if (token != "") {
      List<one_pet_data> petDatas = await Api_manager().get_pet_list(token);

      print(petDatas.length);
      rapivetStatics.pet_data_list = petDatas;

      Login_subFuncs().operate_after_login(context, token);
    }
  }

  operate_after_login(BuildContext context, String token,
      {bool is_simple_login = false}) async {
    rapivetStatics.prefs.setString("token", token);
    rapivetStatics.prefs.setBool("is_logged_on_user", true);
    rapivetStatics.prefs.setBool("is_simple_login", is_simple_login);

    rapivetStatics.token = token;
    rapivetStatics.is_logged_on_user = true;

    if (rapivetStatics.pet_data_list == [] ||
        rapivetStatics.pet_data_list == null ||
        rapivetStatics.pet_data_list.length == 0) {
      JToast().show_toast("Faça o cadastramento do primeiro pet.", false);
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) =>
                  RegisterPet_scene(COME_FROM.WELCOME, PET_REGISTER_MODE.ADD)));
    } else {
      await All_health_check_manager().get_all_health_check_infos();

      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (BuildContext context) => Main_scene()));
    }
  }
}
