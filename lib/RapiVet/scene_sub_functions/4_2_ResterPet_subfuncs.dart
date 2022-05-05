import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as phttp;
import 'package:swork_raon/common/AntiCacheURL.dart';
import 'package:swork_raon/common/JToast.dart';
import 'package:swork_raon/model/Pet_data_manager.dart';
import 'package:swork_raon/model/one_pet_data.dart';
import 'package:swork_raon/rapivet/5_Main.dart';
import 'package:swork_raon/rapivet/6_userInfo.dart';
import 'package:swork_raon/rapivet/main.dart';

import '../../common/app_strings.dart';
import '../../common/rapivetStatics.dart';
import '../4_RegisterPet.dart';

class register_input_dataset {
  TextEditingController nome_txtedit_control;
  TextEditingController birthday_txtedit_control;
  TextEditingController breed_txtedit_control;
  TextEditingController weight_txtedit_control;
  REG_SEXO enum_sexo;
  REG_E_CASTRADO enum_e_castrado;
  REG_PET_TYPE enum_pet_type;
  String pet_pic_path;
}

class register_subFuncs {
  get_pet_type_infos(String url) async {
    // String url = rapivetStatics.url_get_type_dog;

    url = AntiCacheURL().URLAntiCacheRandomizer(url);
    print(url);

    var uri = Uri.parse(url);
    var response = await phttp.get(uri);

    List<String> strList = [];

    if (response.statusCode == 200) {
      var responseBody = utf8.decode(response.bodyBytes);

      //response.body
      String raw_result = responseBody;
      print(raw_result);
      var raw_res = json.decode(raw_result);

      var res = raw_res["data"]["items"];

      print(res[0]["kind"]);

      for (int i = 0; i < res.length; i++) {
        String this_kind = res[i]["kind"];
        strList.add(this_kind);
      }
    }

    return strList;
  }

  int _check_data(PET_REGISTER_MODE _pet_register_mode,
      register_input_dataset _input_dataset, String pet_pic_path) {
    if (_input_dataset.nome_txtedit_control.text.trim() == "") {
      JToast().show_toast(app_strings().STR_enter_name, true);
      return -1;
    }

    if (_input_dataset.birthday_txtedit_control.text.trim() == "") {
      JToast().show_toast(app_strings().STR_enter_birthday, true);
      return -1;
    }

    if (_input_dataset.enum_sexo == REG_SEXO.NOT_SELECTED) {
      JToast().show_toast(app_strings().STR_choose_sex, true);
      return -1;
    }

    if (_input_dataset.enum_e_castrado == REG_E_CASTRADO.NOT_SELECTED) {
      JToast().show_toast(app_strings().STR_choose_neu, true);
      return -1;
    }

    if (_input_dataset.enum_pet_type == REG_PET_TYPE.NOT_SELECTED) {
      JToast().show_toast(app_strings().STR_select_cat_dog_first, true);
      return -1;
    }

    if (_input_dataset.breed_txtedit_control.text.trim() == "") {
      JToast().show_toast(app_strings().STR_choose_breed, true);
      return -1;
    }

    if (_input_dataset.weight_txtedit_control.text.trim() == "") {
      JToast().show_toast(app_strings().STR_enter_weight, true);
      return -1;
    }

    if (_pet_register_mode == PET_REGISTER_MODE.ADD && pet_pic_path == "") {
      JToast().show_toast(app_strings().STR_add_pic, true);
      return -1;
    }

    return 0;
  }

  Future<List> process_data_onServer(PET_REGISTER_MODE _pet_register_mode,
      register_input_dataset _input_dataset, String pet_pic_path,
      {int modifying_index = -1}) async {
    /*
    *     List result = [];
        result.add(current_index);
        result.add(petDatas);
    * */

    // 데이터 체크
    int result = _check_data(_pet_register_mode, _input_dataset, pet_pic_path);
    if (result == -1) return null;

    List result_list = await Pet_data_manager()
        .add_or_modify_data_onServer(_input_dataset, _pet_register_mode);

    return result_list;
  }

  Future<int> process_data_locally(PET_REGISTER_MODE _pet_register_mode,
      register_input_dataset _input_dataset, String pet_pic_path,
      {int modifying_index = -1}) async {
    // 실패한 경우 -1 리턴,
    // 성공한 경우 인덱스값 리턴,

    // 1. 데이터 확인

    int result = _check_data(_pet_register_mode, _input_dataset, pet_pic_path);
    if (result == -1) return result;

    return await Pet_data_manager().add_or_modify_data_locally(
        _input_dataset, pet_pic_path, _pet_register_mode);
  }

  pop_operate(BuildContext context, COME_FROM come_from) {
    if (come_from == COME_FROM.WELCOME) {
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (BuildContext context) => MainPage()));
    } else if (come_from == COME_FROM.USER_INFO) {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) => userInfo_scene()));
    } else if (come_from == COME_FROM.MAIN) {
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (BuildContext context) => Main_scene()));
    }
  }

  move_operate(BuildContext context, COME_FROM _come_from) {
    if (_come_from == COME_FROM.WELCOME) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (BuildContext context) => Main_scene()),
      );
    } else if (_come_from == COME_FROM.USER_INFO) {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) => userInfo_scene()));
    } else if (_come_from == COME_FROM.MAIN) {
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (BuildContext context) => Main_scene()));
    }
  }

  // date time convert ----------------------------------------------------
  String convert_datetime_in_pt(DateTime in_dateTime) {
    String month_str = in_dateTime.month.toString();

    int month_index = int.parse(month_str) - 1;

    String month_pt = rapivetStatics.month_in_pt[month_index];

    String str = in_dateTime.day.toString() +
        ".  " +
        month_pt +
        ".  " +
        in_dateTime.year.toString();

    return str;
  }

  // ---------------------------------------------------------------------

  register_input_dataset set_initial_data(
      one_pet_data _modifying_pet_data, register_input_dataset _input_dataset) {
    _input_dataset.nome_txtedit_control.text = _modifying_pet_data.name;
    _input_dataset.birthday_txtedit_control.text =
        _modifying_pet_data.yyyymmddBirhday_to_pt();
    _input_dataset.weight_txtedit_control.text = _modifying_pet_data.weight;

    _input_dataset.breed_txtedit_control.text =
        Pet_data_manager().get_kind_name(_modifying_pet_data);

    if (_modifying_pet_data.gender == "1")
      _input_dataset.enum_sexo = REG_SEXO.MALE;
    else
      _input_dataset.enum_sexo = REG_SEXO.FEMALE;

    if (_modifying_pet_data.is_neuter == "1")
      _input_dataset.enum_e_castrado = REG_E_CASTRADO.Y;
    else
      _input_dataset.enum_e_castrado = REG_E_CASTRADO.N;

    if (_modifying_pet_data.type == "1")
      _input_dataset.enum_pet_type = REG_PET_TYPE.DOG;
    else
      _input_dataset.enum_pet_type = REG_PET_TYPE.CAT;

    return _input_dataset;
  }

  operate_register_pet(
      BuildContext context,
      COME_FROM _comeFrom,
      PET_REGISTER_MODE _pet_register_mode,
      register_input_dataset _input_dataset,
      {bool is_local_mode = false}) async {
    int result = -1;

    // 1. 로컬에 다이렉트로 저장하는 경우
    if (is_local_mode) {
      result = await process_data_locally(_pet_register_mode, _input_dataset,
          rapivetStatics.current_pet_pic_path);

      // 성공한 경우 ----------------------------------------
      rapivetStatics.current_pet_index = result;
      rapivetStatics.pet_data_list =
          await Pet_data_manager().load_pet_data_list_accordingly_localOnly();
    }
    // 2. 서버에 다이렉트로 저장하는 경우
    else {
      List result_list = await process_data_onServer(_pet_register_mode,
          _input_dataset, rapivetStatics.current_pet_pic_path);

      if (result_list == null)
        result = -1;
      else {
        rapivetStatics.current_pet_index = result_list[0];
        rapivetStatics.pet_data_list = result_list[1];

        print(rapivetStatics.pet_data_list.length);
        result = 1;
      }
    }

    print("result: " + result.toString());

    if (result != -1) {
      // if(_pet_register_mode==PET_REGISTER_MODE.ADD){
      //   rapivetStatics.current_pet_index = rapivetStatics.pet_data_list.length-1;
      // }

      register_subFuncs().move_operate(context, _comeFrom);
    }

    print(result);
  }
}
