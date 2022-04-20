import 'dart:io';

import 'package:http/http.dart' as phttp;
import 'dart:convert';

class api_test_subFuncs {
  String baseURL =
    //  "http://ec2-13-125-243-18.ap-northeast-2.compute.amazonaws.com:6500/api/v1/user/";
    // "http://ec2-3-35-77-71.ap-northeast-2.compute.amazonaws.com:6500/api/v1";
    "https://stg.rapi-vet.com/api/v1";
  /*
  *
  * swagger로 api 테스트 진행하실때 token 넣는 형식은 ( Bearer adfdf)입니다.
  *  Bearer하고 space 한칸 띄워주세요
  *
  *
  * */

  // user -------------------------------------------------
  Future<String> test_login(String email, String pw) async {
    String url = baseURL + "/user/login";
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

  test_social_login(String email) async{
    String url = baseURL + "/user/social_login";
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
    // print(json_data["data"]);
    try {
      String token = json_data["data"]["token"];
      return token;
    } catch (e) {
      return "";
    }
  }

  test_social_signup(String email, String name) async {
    String url = baseURL + "/user/social_signup";
    var uri = Uri.parse(url);

    Map<String, String> headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization' : 'Bearer adfdf'
    };

    Map data = {
      "email": email,
      "name": name,
      "social_name":"facebook"
    };

    var body = json.encode(data);

    // var response = await phttp.post(uri,
    //     headers: {HttpHeaders.authorizationHeader: "Bearer adfdf"}, body: body);

    var response = await phttp.post(uri,
        headers: headers, body: body);

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

  test_ios_signup() async{
    String url = baseURL +"/user/ios/signup";
    print(url);
    var uri = Uri.parse(url);

    Map<String, String> headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };

    var response = await phttp.get(uri, headers: headers);
    print("${response.body}"); // 성공: "code":"0","msg":"success"}

    try {
      var json_data = json.decode(response.body);
      String token = json_data["data"]["token"];
      print(token);
      return token;
    } catch (e) {
      return "";
    }
  }

  test_signup(String email, String pw) async {
    String url = baseURL + "/user/signup";
    print(url);
    var uri = Uri.parse(url);

    Map<String, String> headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };

    Map data = {
      "email": email,
      "name": "test1",
      "password": pw,
      "confirm_password": pw,
      "address1": "donghae city",
      "address2": "bukpyong dong",
      "cell_phone": "0102121234"
    };

    var body = json.encode(data);

    var response = await phttp.post(uri, headers: headers, body: body);

    print("${response.headers}");
    print("${response.statusCode}"); // 성공 200
    print("${response.body}"); // 성공: "code":"0","msg":"success"}

    // 통신 성공 시 statusCode 200
    // 회원가입 성공 시 body  {"code":"0","msg":"success"}
    // 회원가입 실패 시 대략 이런 느낌. {"code":"100009","msg":"routes.user.signup Error: Duplicate entry 'test1@abc.com' for key 'email'"}
  }

  test_update_user(String token) async {
    String url = baseURL + "/user/update";

    var uri = Uri.parse(url);

    Map<String, String> headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      "Authorization": "Bearer " + token
    };

    Map data = {
      "address1": "Busan city",
      "address2": "Dongrae",
      "cell_phone": "01025992319"
    };

    var body = json.encode(data);

    var response = await phttp.post(uri, headers: headers, body: body);

    print("${response.headers}");
    print("${response.statusCode}");
    print("${response.body}");
  }

  test_get_user_info(String token) async {
    var uri = Uri.parse( baseURL+"/user/info");

    var response = await phttp.get(
      uri,
      headers: {HttpHeaders.authorizationHeader: "Bearer " + token},
    );

    print("${response.headers}");
    print("${response.statusCode}");
    print("${response.body}");
  }

  test_search_pw(String email) async {
    String url = baseURL + "/user/search_password";
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

    var response = await phttp.post(uri,
        headers: headers, body: body);

    print("${response.headers}");
    print("${response.statusCode}");
    print("${response.body}");
  }

  // pet ---------------------------------------------
  test_pet_register(String token) async {
    String url = baseURL + "/pet/register";
    print(url);
    var uri = Uri.parse(url);

    Map<String, String> headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      "Authorization": "Bearer " + token
    };

    Map data = {
      "name": "acv",
      "birthday": "20200303",
      "type": "1",
      "gender": "1",
      "is_neuter": "1",
      "weight": "3",
      "kind": "2", // string  only
      "img_data": base64
    };

    var body = json.encode(data);

    var response = await phttp.post(uri, headers: headers, body: body);

    print("${response.headers}");
    print("${response.statusCode}");
    print("${response.body}");
  }

  test_get_pet_info(String token) async {
    var uri = Uri.parse(
        baseURL+"/pet/read");

    // int index = token.indexOf(".");
    // token = token.substring(0,index);
    print(token);

    var response = await phttp.get(
      uri,
      headers: {HttpHeaders.authorizationHeader: "Bearer " + token},
    );

    print("${response.headers}");
    print("${response.statusCode}");
    print("${response.body}");

    return response;
  }

  test_pet_update(String token, String pet_uid) async {
    String url = baseURL +"/pet/update";
    print(url);
    var uri = Uri.parse(url);

    Map<String, String> headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      "Authorization": "Bearer " + token
    };

    Map data = {
      "pet_uid": pet_uid,
      "pet_info" : {
        "pet_name": "btc",
        "birthday": "20200808",
        "type": "1",
        "gender": "1",
        "is_neuter": "1",
        "weight": "8",
        "kind": "2",
        "photo_url":
        "https://d1wivu8awyh10u.cloudfront.net/2021/09/2021093008351826.jpeg",
        "created_at": "2021-08-28"
      }
    };

    var body = json.encode(data);
    var response = await phttp.post(uri, headers: headers, body: body);

    print("${response.headers}");
    print("${response.statusCode}");
    print("${response.body}");
  }

  test_pet_delete(String token, String pet_uid )async{
    String url = baseURL + "/pet/delete";
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

  test_pet_photo_update(String token, String pet_uid) async {
    String url =  baseURL + "/pet/photo/update";
    var uri = Uri.parse(url);


    Map<String, String> headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      "Authorization": "Bearer " + token
    };

    Map data = {
      "pet_uid": pet_uid,
      "img_data": base64
    };

    var body = json.encode(data);
    var response = await phttp.post(uri, headers: headers, body: body);

    print("${response.headers}");
    print("${response.statusCode}");
    print("${response.body}");
  }

  String base64 =
      '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';


  // Pet stick test ---------------------------------------------------

  get_pet_uid(var response, int pet_index){

    var json_data = json.decode(response.body);

    print("--------------------");
    String uid = json_data["data"][pet_index]["uid"];
    print(uid);

    return uid;
  }

  test_get_pet_health_today(String pet_uid, String token) async{

    DateTime now = new DateTime.now();
    String today_str = now.year.toString()+"-"+now.month.toString()+"-"+now.day.toString();

    String url = baseURL + "/pet/health_check_read/"+pet_uid+"/2021-10-04";
    print(url);

    var uri = Uri.parse(url);

    var response = await phttp.get(
      uri,
      headers: {HttpHeaders.authorizationHeader: "Bearer " + token},
    );

    print("${response.headers}");
    print("${response.statusCode}");
    print("${response.body}");
  }

  test_pet_health_check_list_read(String pet_uid, String token) async{
    String url = baseURL + "/pet/health_check_list/"+pet_uid;
    print(url);

    var uri = Uri.parse(url);

    var response = await phttp.get(
      uri,
      headers: {HttpHeaders.authorizationHeader: "Bearer " + token},
    );

    print("${response.headers}");
    print("${response.statusCode}");
    print("${response.body}");
  }

  test_pet_health_check_register (String pet_uid, String token) async{
    String url = "https://stg.rapi-vet.com/api/v2/pet/health_check_register";
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
      "keton": "1",
      "glucose": "1",
      "leukocyte": "1",
      "nitrite": "trace",
      "blood": "3",
      "ph": "1",
      "proteinuria": "2",
      "img_data": base64
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

  test_pet_stick_photo_upload(String test_uid, String token) async{

    String url = "https://pvf126ou9d.execute-api.ap-northeast-2.amazonaws.com/pet/stg_upload_stick_img";

    var uri = Uri.parse(url);

    Map<String, String> headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      "Authorization": "Bearer " + token
    };

    Map data = {
      "uid": test_uid,
      "data": base64
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

  // Q&A --------------------------------------------------------------
  test_qa_write(String token) async{
    String url = baseURL + "/qa/write";
    var uri = Uri.parse(url);

    Map<String, String> headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      "Authorization": "Bearer " + token
    };

    Map data = {
      "question": "question5"
    };

    var body = json.encode(data);

    var response = await phttp.post(uri, headers: headers, body: body);

    print("${response.headers}");
    print("${response.statusCode}");
    print("${response.body}");
  }

  test_get_QnA(String token) async{

    var uri = Uri.parse( baseURL +"/qa/read/1/1000");

    var response = await phttp.get(
      uri,
      headers: {HttpHeaders.authorizationHeader: "Bearer " + token},
    );

    print("${response.headers}");
    print("${response.statusCode}");
    print("${response.body}");

  }

}
