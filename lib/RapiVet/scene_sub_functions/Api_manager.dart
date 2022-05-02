import 'dart:io';

import 'package:http/http.dart' as phttp;
import 'dart:convert';

import 'package:swork_raon/0_CommonThisApp/rapivetStatics.dart';
import 'package:swork_raon/0_Commons_totally/AntiCacheURL.dart';
import 'package:swork_raon/0_Commons_totally/JToast.dart';
import 'package:swork_raon/0_DataProcess/Pet_data_manager.dart';
import 'package:swork_raon/0_DataProcess/one_pet_data.dart';
import 'package:swork_raon/0_DataProcess/one_user_data.dart';
import 'package:swork_raon/TestModule/Img_Proc_testModule/SubFuncs/SearchingResult/stickResult_dataset.dart';

class Api_manager {
  Future<String> login(String email, String pw) async {
    String url = rapivetStatics.baseURL + "/user/login";
    print(url);
    var uri = Uri.parse(url);

    Map<String, String> headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };

    Map data = {
      "email": email,
      "password": pw,
    };

    var body = json.encode(data);

    var response = await phttp.post(uri, headers: headers, body: body);

    print("${response.headers}");
    print("${response.statusCode}");
    print("${response.body}");

    var json_data = json.decode(response.body);
    print(json_data["code"]);
    print(json_data["msg"]);
    // print(json_data["data"]);
    try {
      String token = json_data["data"]["token"];
      return token;
    } catch (e) {
      return "";
    }
  }

  Future<int> get_user_pet_count(String token) async {
    var uri = Uri.parse(rapivetStatics.baseURL + "/user/info");

    var response = await phttp.get(
      uri,
      headers: {HttpHeaders.authorizationHeader: "Bearer " + token},
    );

    print("${response.headers}");
    print("${response.statusCode}");
    print("${response.body}");

    var json_data = json.decode(response.body);
    List pet_info = json_data["data"]["pet_info"];

    if (json_data["msg"] == "success")
      return pet_info.length;
    else
      return -1;
  }

  // pet----------------------------------------------------------------
  Future<String> pet_register(Map<String, String> mapData) async {
    // converting
    String url = rapivetStatics.baseURL + "/pet/register";
    print(url);
    var uri = Uri.parse(url);

    print(rapivetStatics.token);

    Map<String, String> headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      "Authorization": "Bearer " + rapivetStatics.token
    };

    var body = json.encode(mapData);

    var response = await phttp.post(uri, headers: headers, body: body);

    print("${response.headers}");
    print("${response.statusCode}");
    print("${response.body}");

    var json_data = json.decode(response.body);
    if (json_data["msg"] == "success")
      return json_data["data"]["uid"].toString();

    if (json_data["noshow"] == "0") {
      JToast().show_toast(json_data["msg"].toString(), true);
    } else {
      JToast().show_toast(json_data["code"].toString(), true);
    }

    return "";
  }

  Future<String> pet_update(String pet_uid, Map<String, String> mapData) async {
    String url = rapivetStatics.baseURL + "/pet/update";
    print(url);
    var uri = Uri.parse(url);

    Map<String, String> headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      "Authorization": "Bearer " + rapivetStatics.token
    };

    Map data = {"pet_uid": pet_uid, "pet_info": mapData};

    var body = json.encode(data);
    var response = await phttp.post(uri, headers: headers, body: body);

    print("${response.headers}");
    print("${response.statusCode}");
    print("${response.body}");

    var json_data = json.decode(response.body);
    if (json_data["msg"] == "success")
      return json_data["data"]["pet_uid"].toString();

    if (json_data["noshow"] == "0") {
      JToast().show_toast(json_data["msg"].toString(), true);
    } else {
      JToast().show_toast(json_data["code"].toString(), true);
    }

    return "";
  }

  Future<one_user_data> get_user_data(String token) async{

    var uri = Uri.parse( rapivetStatics.baseURL +"/user/info");

    var response = await phttp.get(
      uri,
      headers: {HttpHeaders.authorizationHeader: "Bearer " + token},
    );

    print("${response.headers}");
    print("${response.statusCode}");
    print("${response.body}");

    var json_data = json.decode(response.body);

    print("user info ======================");
    print(json_data);

    if (json_data["msg"] == "success") {
      one_user_data this_user_data = _Json_data_to_userData(json_data);
      return this_user_data;
    }

    if (json_data["noshow"] == "0") {
      JToast().show_toast(json_data["msg"], true);
    }

    return null;
  }

  Future<List<one_pet_data>> get_pet_list(String token) async {
    var uri = Uri.parse(rapivetStatics.baseURL + "/pet/read");

    print(token);

    var response = await phttp.get(
      uri,
      headers: {HttpHeaders.authorizationHeader: "Bearer " + token},
    );

    print("${response.headers}");
    print("${response.statusCode}");
    print("${response.body}");

    var json_data = json.decode(response.body);

    print("======================");
    print(json_data);

    if (json_data["msg"] == "success") {
      return _json_data_to_petDatas(json_data);
    }

    if (json_data["noshow"] == "0") {
      JToast().show_toast(json_data["msg"], true);
    }

    return null;
  }

  pet_delete(String token, String pet_uid) async {
    String url = rapivetStatics.baseURL + "/pet/delete";
    var uri = Uri.parse(url);

    Map<String, String> headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      "Authorization": "Bearer " + token
    };

    Map data = {
      "pet_uid": pet_uid,
    };

    var body = json.encode(data);
    var response = await phttp.delete(uri, headers: headers, body: body);

    print("${response.headers}");
    print("${response.statusCode}");
    print("${response.body}");
  }

  pet_photo_update(String token, String pet_uid, String img_base64) async {
    String url = "https://434undgut1.execute-api.ap-northeast-2.amazonaws.com/pet/stg_upload_pet_img";
    // rapivetStatics.baseURL + "/pet/photo/update";
    var uri = Uri.parse(url);

    Map<String, String> headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      "Authorization": "Bearer " + token
    };

  //  Map data = {"pet_uid": pet_uid, "img_data": img_base64};
    Map data = {"pet_uid": pet_uid, "data": img_base64};

    var body = json.encode(data);
    var response = await phttp.post(uri, headers: headers, body: body);

    print("${response.headers}");
    print("${response.statusCode}");
    print("${response.body}");
  }


  // pet health --------------------------------------------------------------
  Future<String> pet_health_check_register (String pet_uid, String token, stickResult_dataset stick_result) async{
    String url = rapivetStatics.baseURL_v2 + "/pet/health_check_register";
    //String url = baseURL + "/pet/health_check_register";
    print(url);
    var uri = Uri.parse(url);

    Map<String, String> headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      "Authorization": "Bearer " + token
    };

    Map data = {
      "pet_uid": pet_uid,
      "keton": stick_result.keton.toString(),
      "glucose": stick_result.glucose.toString(),
      "leukocyte": stick_result.leukocyte.toString(),
      "nitrite": stick_result.nitrite.toString(),
      "blood": stick_result.blood.toString(),
      "ph": stick_result.ph.toString(),
      "proteinuria": stick_result.proteinuria.toString(),
    };

    var body = json.encode(data);

    var response = await phttp.post(uri, headers: headers, body: body);

    print("head-------------------------------------------------");
    print("${response.headers}");
    print("statusCode--------------------------------------------");
    print("${response.statusCode}");
    print("body--------------------------------------------------");
    print("${response.body}");

    var json_data = json.decode(response.body);
    String uid = json_data["data"]["uid"].toString();

    return uid;
  }

  pet_stick_photo_upload(String test_uid, String token, String img_base64) async{

    String url = "https://pvf126ou9d.execute-api.ap-northeast-2.amazonaws.com/pet/stg_upload_stick_img";

    var uri = Uri.parse(url);

    Map<String, String> headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      "Authorization": "Bearer " + token
    };

    Map data = {
      "uid": test_uid,
      "data": img_base64
    };

    var body = json.encode(data);

    var response = await phttp.post(uri, headers: headers, body: body);

    print("head-------------------------------------------------");
    print("${response.headers}");
    print("statusCode--------------------------------------------");
    print("${response.statusCode}");
    print("body--------------------------------------------------");
    print("${response.body}");
  }

  // signup -----------------------------------------------------------
  Future<String> search_pw(String email) async {
    String url = rapivetStatics.baseURL + "/user/search_password";
    var uri = Uri.parse(url);

    Map<String, String> headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer adfdf'
    };

    Map data = {
      "email": email,
    };

    var body = json.encode(data);

    var response = await phttp.post(uri, headers: headers, body: body);

    print("${response.headers}");
    print("${response.statusCode}");
    print("${response.body}");

    var json_data = json.decode(response.body);

    if (json_data["msg"] == "success") {
      return "success";
    } else if (json_data["noshow"] == "0") {
      return json_data["msg"];
    } else {
      return "";
    }
  }

  Future<List> social_signup(String email, String name) async {
    String url = rapivetStatics.baseURL + "/user/social_signup";
    var uri = Uri.parse(url);

    Map<String, String> headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer adfdf'
    };

    Map data = {"email": email, "name": name, "social_name": "google"};

    var body = json.encode(data);

    var response = await phttp.post(uri, headers: headers, body: body);

    print("${response.headers}");
    print("${response.statusCode}");
    print("${response.body}");

    List result = [];

    var json_data = json.decode(response.body);
    print(json_data["code"]);
    print(json_data["msg"]);

    String msg = json_data["msg"];

    if(msg == "success"){
      result.add(true);
    }else{
      result.add(false);
      return result;
    }

    try {
      String token = json_data["data"]["token"];
      print(token);
      result.add(token);
    } catch (e) {

    }

    return result;
  }

  Future<List> social_login(String email) async{
    String url =rapivetStatics. baseURL + "/user/social_login";
    var uri = Uri.parse(url);

    Map<String, String> headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization' : 'Bearer adfdf'
    };

    Map data = {
      "email": email,
    };

    var body = json.encode(data);

    var response = await phttp.post(uri,
        headers: headers, body: body);

    print("${response.headers}");
    print("${response.statusCode}");
    print("${response.body}");

    var json_data = json.decode(response.body);
    print(json_data["code"]);
    print(json_data["msg"]);

    List result = [];
    // print(json_data["data"]);
    try {
      String token = json_data["data"]["token"];
      result.add(true);
      result.add(token);
    } catch (e) {
      result.add(false);
    }

    return result;
  }

  // sub-funcs--------------------------------------------------------------
  one_user_data _Json_data_to_userData(var json_data){

    one_user_data this_user_data = one_user_data();

    this_user_data.email = json_data["data"]["user_info"]["email"].toString();
    this_user_data.name = json_data["data"]["user_info"]["name"].toString();
    this_user_data.phone_num = json_data["data"]["user_info"]["cell_phone"].toString();
    this_user_data.address1 = json_data["data"]["user_info"]["address1"].toString();
    this_user_data.address2 = json_data["data"]["user_info"]["address2"].toString();

    return this_user_data;
  }


  List<one_pet_data> _json_data_to_petDatas(var json_data) {
    List<one_pet_data> pet_datas = [];

    for (int i = 0; i < 100; i++) {
      try {
        one_pet_data this_pet_data = new one_pet_data();

        this_pet_data.uid = json_data["data"][i]["uid"].toString();
        this_pet_data.name = json_data["data"][i]["name"].toString();

        this_pet_data.birthday = json_data["data"][i]["birthday"].toString();
        this_pet_data.type = json_data["data"][i]["type"].toString();
        this_pet_data.gender = json_data["data"][i]["gender"].toString();
        this_pet_data.is_neuter = json_data["data"][i]["is_neuter"].toString();
        this_pet_data.kind = json_data["data"][i]["kind"].toString();
        // this_pet_data.name = json_data["data"][i]["weight"].toString();
        this_pet_data.weight = json_data["data"][i]["weight"].toString();
        this_pet_data.pic_url = json_data["data"][i]["photo_url"].toString();
        // 이거 안 하면 수정하면 반영 바로 안 됨.
        this_pet_data.pic_url =
            AntiCacheURL().URLAntiCacheRandomizer(this_pet_data.pic_url);

        pet_datas.add(this_pet_data);
      } catch (e) {
        i = 999999;
      }
    }

    // post process
    pet_datas = Pet_data_manager().get_birthday_ymd_inList(pet_datas);

    return pet_datas;
  }
}
