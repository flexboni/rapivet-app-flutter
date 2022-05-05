import 'dart:convert';

import 'package:swork_raon/common/rapivetStatics.dart';
import 'package:swork_raon/model/one_pet_data.dart';
import 'package:swork_raon/rapivet/4_RegisterPet.dart';
import 'package:swork_raon/rapivet/scene_sub_functions/4_2_ResterPet_subfuncs.dart';
import 'package:swork_raon/rapivet/scene_sub_functions/Api_manager.dart';
import 'package:swork_raon/utils/string_utils.dart';

class Pet_data_manager {
  test() {
    List<String> loaded_myPetlist =
        rapivetStatics.prefs.getStringList("mypets");
    if (loaded_myPetlist == null || loaded_myPetlist == []) {
      print("no data!!!!!!!");
    } else {
      print("we have data!!!!!!!!!");
    }

    // 1. save ----------------------------
    Map<String, String> petdata = {
      "name": "a",
      "birthday": "8.05.1682",
      "type": "2",
      "gender": "m",
      "is_neuter": "n",
      "kind": "Bulldog"
    };

    String json_str = json.encode(petdata);

    List<String> petdata_list = [];
    petdata_list.add(json_str);

    rapivetStatics.prefs.setStringList("mypets", petdata_list);

    // 2. load
    loaded_myPetlist = rapivetStatics.prefs.getStringList("mypets");
    print(loaded_myPetlist.length);
  }

  // add or modify data on server
  Future<List> add_or_modify_data_onServer(
      register_input_dataset _input_dataset,
      PET_REGISTER_MODE in_pet_register_mode,
      {int modifying_index = -1}) async {
    // convert birthday in format

    String birth_day_yyyymmdd = _convert_birthDay_yyyymmdd(
        _input_dataset.birthday_txtedit_control.text.trim());

    // get pet type index
    int pet_kind_index = get_animal_kind_index(_input_dataset);

    // make map data
    Map<String, String> petdata = {
      "name": _input_dataset.nome_txtedit_control.text.trim(),
      "pet_name": _input_dataset.nome_txtedit_control.text.trim(),
      "birthday": birth_day_yyyymmdd,
      "type": (_input_dataset.enum_pet_type == REG_PET_TYPE.DOG) ? "1" : "0",
      "gender": (_input_dataset.enum_sexo == REG_SEXO.MALE) ? "1" : "0",
      "is_neuter":
          (_input_dataset.enum_e_castrado == REG_E_CASTRADO.Y) ? "1" : "0",
      "kind": pet_kind_index.toString(),
      "weight": _input_dataset.weight_txtedit_control.text.trim(),
      "img_data": (in_pet_register_mode == PET_REGISTER_MODE.ADD)
          ? rapivetStatics.pet_img_base64
          : "",
    };

    // register to server (add)
    String pet_uid = "";

    if (in_pet_register_mode == PET_REGISTER_MODE.ADD) {
      pet_uid = await Api_manager().pet_register(petdata);
    }
    // modify
    else {
      String modify_pet_uid =
          rapivetStatics.pet_data_list[rapivetStatics.current_pet_index].uid;
      pet_uid = await Api_manager().pet_update(modify_pet_uid, petdata);

      // image 업데이트
      if (rapivetStatics.pet_img_base64 != "") {
        print("이미지도 업데이트!!!");
        await Api_manager().pet_photo_update(rapivetStatics.token,
            modify_pet_uid, rapivetStatics.pet_img_base64);
      }

      print("pet uid=====================");
      print(modify_pet_uid);
      print(pet_uid);
      print("============================");
    }

    if (pet_uid == "") return null;

    // load pet list
    List<one_pet_data> petDatas =
        await Api_manager().get_pet_list(rapivetStatics.token);
    if (petDatas == null || petDatas == []) return null;

    // get current index
    int current_index = _get_pet_index_of_serverData(petDatas, pet_uid);

    print("================");
    print(petDatas.length);
    print(current_index);

    List result = [];
    result.add(current_index);
    result.add(petDatas);

    return result; // 0-->index
  }

  // add or modify data locally
  Future<int> add_or_modify_data_locally(register_input_dataset _input_dataset,
      String pet_pic_path, PET_REGISTER_MODE in_pet_register_mode,
      {int modifying_index = -1}) async {
    // return 값
    // 작업중인 index
    // 전체 PET 데이터는 load_pet_data_list_accordingly 로 빼면 된다.

    // convert birthday in format
    String birth_day_yyyymmdd = _convert_birthDay_yyyymmdd(
        _input_dataset.birthday_txtedit_control.text.trim());

    // get pet type index
    int pet_kind_index = get_animal_kind_index(_input_dataset);

    Map<String, String> petdata = {
      "name": _input_dataset.nome_txtedit_control.text.trim(),
      "birthday": birth_day_yyyymmdd,
      "type": (_input_dataset.enum_pet_type == REG_PET_TYPE.DOG) ? "1" : "0",
      "gender": (_input_dataset.enum_sexo == REG_SEXO.MALE) ? "1" : "0",
      "is_neuter":
          (_input_dataset.enum_e_castrado == REG_E_CASTRADO.Y) ? "1" : "0",
      "kind": pet_kind_index.toString(),
      "weight": _input_dataset.weight_txtedit_control.text.trim(),
      "local_pic": rapivetStatics.current_pet_pic_path,
    };

    String json_str = json.encode(petdata);
    print(json_str);

    // 1. load
    List<String> loaded_myPetlist =
        rapivetStatics.prefs.getStringList("mypets");

    if (loaded_myPetlist == null) loaded_myPetlist = [];

    // 2. add & save
    if (in_pet_register_mode == PET_REGISTER_MODE.MODIFY) {
      //  replace case
      print("modifying index: " + rapivetStatics.current_pet_index.toString());
      loaded_myPetlist[rapivetStatics.current_pet_index] = json_str;
    } else {
      // add case
      loaded_myPetlist.add(json_str);
    }

    rapivetStatics.prefs.setStringList("mypets", loaded_myPetlist);

    // 3. load all
    loaded_myPetlist = rapivetStatics.prefs.getStringList("mypets");
    print(loaded_myPetlist.length);

    // 4. return index
    for (int i = 0; i < loaded_myPetlist.length; i++) {
      if (loaded_myPetlist[i] == json_str) return i;
    }
  }

  // remove data
  Future<List<one_pet_data>> remove_pet_data(
      List<one_pet_data> pet_data_list, int index) async {
    if (rapivetStatics.is_logged_on_user) {
      // delete it
      String uid = rapivetStatics.pet_data_list[index].uid;
      String token = rapivetStatics.token;

      await Api_manager().pet_delete(token, uid);

      List<one_pet_data> petDatas = await Api_manager().get_pet_list(token);
      return petDatas;
    }
    // local only ---------------------------------------------
    else {
      // 1. load
      List<String> loaded_myPetlist =
          rapivetStatics.prefs.getStringList("mypets");

      // 2. delete index
      loaded_myPetlist.removeAt(index);

      // 3. save it
      rapivetStatics.prefs.setStringList("mypets", loaded_myPetlist);

      // 3. load all for test
      loaded_myPetlist = rapivetStatics.prefs.getStringList("mypets");
      print(loaded_myPetlist.length);

      // load data
      return await load_pet_data_list_accordingly_localOnly();
    }
  }

  bool do_we_have_local_petsDB() {
    List<String> loaded_myPetlist =
        rapivetStatics.prefs.getStringList("mypets");

    if (loaded_myPetlist == null || loaded_myPetlist.length == 0)
      return false;
    else
      return true;
  }

  List<one_pet_data> load_local_petDB() {
    List<String> loaded_myPetlist =
        rapivetStatics.prefs.getStringList("mypets");
    List<one_pet_data> pet_data_list = [];

    for (int i = 0; i < loaded_myPetlist.length; i++) {
      var this_json = json.decode(loaded_myPetlist[i]);

      one_pet_data this_one_pet_data = one_pet_data();

      this_one_pet_data.name = this_json["name"];
      this_one_pet_data.birthday = this_json["birthday"];
      this_one_pet_data.type = this_json["type"];
      this_one_pet_data.gender = this_json["gender"];
      this_one_pet_data.is_neuter = this_json["is_neuter"];
      this_one_pet_data.weight = this_json["weight"];
      this_one_pet_data.kind = this_json["kind"];
      this_one_pet_data.local_pic = this_json["local_pic"];

      this_one_pet_data = _get_birthday_ymd(this_one_pet_data);

      pet_data_list.add(this_one_pet_data);
    }

    return pet_data_list;
  }

  List<one_pet_data> get_birthday_ymd_inList(List<one_pet_data> petDatas) {
    for (int i = 0; i < petDatas.length; i++) {
      petDatas[i] = _get_birthday_ymd(petDatas[i]);
    }

    return petDatas;
  }

  one_pet_data _get_birthday_ymd(one_pet_data this_one_pet_data) {
    String birthday_str = this_one_pet_data.birthday;

    print(birthday_str);

    this_one_pet_data.birthday_year = int.parse(birthday_str.substring(0, 4));
    this_one_pet_data.birthday_month = int.parse(birthday_str.substring(4, 6));
    this_one_pet_data.birthday_day = int.parse(birthday_str.substring(6, 8));

    return this_one_pet_data;
  }

  Future<List<one_pet_data>> load_pet_data_list_accordingly_localOnly() async {
    // if user is logged on, get data from server
    // or get data from local

    // if (rapivetStatics.is_logged_on_user) {
    // } else {
    //   return load_local_petDB();
    // }

    return load_local_petDB();
  }

  String _convert_birthDay_yyyymmdd(String birthday) {
    StringUtils sw = new StringUtils();

    List<String> outlist = sw.getSeparatedValues(birthday, ".");

    String year = "";
    String month = "";
    String day = "";

    year = outlist[2].trim();
    month = outlist[1].trim();

    // month str -> index
    month = (rapivetStatics.month_in_pt.indexOf(month) + 1).toString();
    if (month.length == 1) {
      month = "0" + month;
    }

    if (outlist[0].trim().length == 1) {
      day = "0" + outlist[0].trim();
    } else {
      day = outlist[0].trim();
    }

    String out_date = year + month + day;
    print(out_date);

    return out_date;
  }

  // type index <--> type name
  String get_kind_name(one_pet_data this_pet_data) {
    int index = int.parse(this_pet_data.kind);

    if (this_pet_data.type == "1")
      return rapivetStatics.dog_kind_set[index];
    else
      return rapivetStatics.cat_kind_set[index];
  }

  int get_animal_kind_index(register_input_dataset _input_dataset) {
    String type_name = _input_dataset.breed_txtedit_control.text.trim();

    if (_input_dataset.enum_pet_type == REG_PET_TYPE.DOG) {
      for (int i = 0; i < rapivetStatics.dog_kind_set.length; i++) {
        if (rapivetStatics.dog_kind_set[i] == type_name) return i;
      }
    } else {
      for (int i = 0; i < rapivetStatics.cat_kind_set.length; i++) {
        if (rapivetStatics.cat_kind_set[i] == type_name) return i;
      }
    }

    return 0;
  }

  int _get_pet_index_of_serverData(List<one_pet_data> pet_datas, String uid) {
    for (int i = 0; i < pet_datas.length; i++) {
      if (pet_datas[i].uid == uid) return i;
    }

    return -1;
  }
}
