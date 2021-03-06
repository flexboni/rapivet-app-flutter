import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as phttp;
import 'package:swork_raon/TestModule/image_process_test_module/searching_result/stickResult_dataset.dart';
import 'package:swork_raon/common/AntiCacheURL.dart';
import 'package:swork_raon/common/JToast.dart';
import 'package:swork_raon/common/rapivet_statics.dart';
import 'package:swork_raon/model/Pet_data_manager.dart';
import 'package:swork_raon/model/one_pet.dart';
import 'package:swork_raon/model/one_user_data.dart';

class Api_manager {
  Future<String> login(String email, String pw) async {
    String url = RapivetStatics.baseURL + "/user/login";
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
    var uri = Uri.parse(RapivetStatics.baseURL + "/user/info");

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
    String url = RapivetStatics.baseURL + "/pet/register";
    print(url);
    var uri = Uri.parse(url);

    print(RapivetStatics.token);

    Map<String, String> headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      "Authorization": "Bearer " + RapivetStatics.token
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
    String url = RapivetStatics.baseURL + "/pet/update";
    print(url);
    var uri = Uri.parse(url);

    Map<String, String> headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      "Authorization": "Bearer " + RapivetStatics.token
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

  Future<one_user_data> get_user_data(String token) async {
    var uri = Uri.parse(RapivetStatics.baseURL + "/user/info");

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

  Future<List<OnePet>> get_pet_list(String token) async {
    var uri = Uri.parse(RapivetStatics.baseURL + "/pet/read");

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
    String url = RapivetStatics.baseURL + "/pet/delete";
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
    String url =
        "https://434undgut1.execute-api.ap-northeast-2.amazonaws.com/pet/stg_upload_pet_img";
    // RapivetStatics.baseURL + "/pet/photo/update";
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
  Future<String> pet_health_check_register(
      String pet_uid, String token, StickResultDataset stick_result) async {
    String url = RapivetStatics.baseUrlV2 + "/pet/health_check_register";
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

  pet_stick_photo_upload(
      String test_uid, String token, String img_base64) async {
    String url =
        "https://pvf126ou9d.execute-api.ap-northeast-2.amazonaws.com/pet/stg_upload_stick_img";

    var uri = Uri.parse(url);

    Map<String, String> headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      "Authorization": "Bearer " + token
    };

    Map data = {"uid": test_uid, "data": img_base64};

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
    String url = RapivetStatics.baseURL + "/user/search_password";
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
    String url = RapivetStatics.baseURL + "/user/social_signup";
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

    if (msg == "success") {
      result.add(true);
    } else {
      result.add(false);
      return result;
    }

    try {
      String token = json_data["data"]["token"];
      print(token);
      result.add(token);
    } catch (e) {}

    return result;
  }

  Future<List> social_login(String email) async {
    String url = RapivetStatics.baseURL + "/user/social_login";
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
  one_user_data _Json_data_to_userData(var json_data) {
    one_user_data this_user_data = one_user_data();

    this_user_data.email = json_data["data"]["user_info"]["email"].toString();
    this_user_data.name = json_data["data"]["user_info"]["name"].toString();
    this_user_data.phone_num =
        json_data["data"]["user_info"]["cell_phone"].toString();
    this_user_data.address1 =
        json_data["data"]["user_info"]["address1"].toString();
    this_user_data.address2 =
        json_data["data"]["user_info"]["address2"].toString();

    return this_user_data;
  }

  List<OnePet> _json_data_to_petDatas(var json_data) {
    List<OnePet> pet_datas = [];

    for (int i = 0; i < 100; i++) {
      try {
        one_pet_data this_pet_data = new one_pet_data();

        this_pet_data.uid = json_data["data"][i]["uid"].toString();
        this_pet_data.name = json_data["data"][i]["name"].toString();

        this_pet_data.birthday = json_data["data"][i]["birthday"].toString();
        this_pet_data.type = json_data["data"][i]["type"].toString();
        this_pet_data.gender = json_data["data"][i]["gender"].toString();
        this_pet_data.isNeuter = json_data["data"][i]["is_neuter"].toString();
        this_pet_data.kind = json_data["data"][i]["kind"].toString();
        // this_pet_data.name = json_data["data"][i]["weight"].toString();
        this_pet_data.weight = json_data["data"][i]["weight"].toString();
        this_pet_data.urlPicture = json_data["data"][i]["photo_url"].toString();
        // ?????? ??? ?????? ???????????? ?????? ?????? ??? ???.
        this_pet_data.urlPicture =
            AntiCacheURL().URLAntiCacheRandomizer(this_pet_data.urlPicture);

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
