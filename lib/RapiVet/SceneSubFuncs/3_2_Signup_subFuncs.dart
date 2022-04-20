import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as phttp;
import 'package:swork_raon/0_Commons_totally/JToast.dart';
import 'dart:convert';
import '../../0_CommonThisApp/rapivetStatics.dart';
import '../4_RegisterPet.dart';
import 'dart:math';

class Signup_subfuncs {
  Future<String> get_adress_from_zip(String zip) async {
    print(zip);

    zip = zip.replaceAll("-", "");
    zip = zip.replaceAll(".", "");
    zip = zip.replaceAll("_", "");

    try {
      int zip_int = int.parse(zip);
    } catch (e) {
      return "error";
    }

    String url = "https://viacep.com.br/ws/" + zip + "/json/";
    var uri = Uri.parse(url);

    var response = await phttp.get(uri);
    print(response.body);

    if (response.body.indexOf("cep") != -1 &&
        response.body.indexOf("logradouro") != -1 &&
        response.body.indexOf("complemento") != -1) {
      // ok
    } else {
      return "error";
    }

    var json_data = json.decode(response.body);

    print(json_data["cep"]);

    String out_str = json_data["logradouro"] +
        ", " +
        json_data["complemento"] +
        ", " +
        json_data["bairro"] +
        ", " +
        json_data["localidade"] +
        ", " +
        json_data["uf"] +
        ", " +
        json_data["cep"];

    return out_str;
  }

  get_phone_num(String phone_num) {
    phone_num = phone_num.replaceAll(" ", "");
    phone_num = phone_num.replaceAll("-", "");

    if (phone_num.substring(0, 2) == "82") {
      // 한국 테스트
      phone_num = "+" + phone_num;
    } else {
      // 브라질
    }

    return phone_num;
  }

  request_sms_code(String phone_num) async {
    rapivetStatics.auth.userChanges();
    rapivetStatics.auth.authStateChanges();

    await rapivetStatics.auth.verifyPhoneNumber(
      phoneNumber: phone_num,
      timeout: const Duration(seconds: 60),
      codeSent: (String verificationId, int resendToken) async {
        print(verificationId);
        print(resendToken);

        rapivetStatics.sms_verificationId = verificationId;
        // PhoneAuthCredential credential = PhoneAuthProvider.credential(verificationId: verificationId, smsCode: "123456");
        // UserCredential user = await auth.signInWithCredential(credential);
        // print(user.additionalUserInfo);
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        // TIME OVER
      },
      verificationFailed: (FirebaseAuthException e) {
        print("verification 1st error!!!");
        print(e);
        rapivetStatics.sms_verification_error = e.toString();
      },
    );
  }

  Future<String> check_sms_code(String sms_code) async {
    String user_uid = rapivetStatics.sms_verificationId;

    PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: user_uid, smsCode: sms_code);

    try {
      UserCredential user =
          await rapivetStatics.auth.signInWithCredential(credential);
      JToast().show_toast("Código de segurança enviado com sucesso.", true);
      return "success";
    } catch (e) {
      print(e);
      print(e);
      print(e);

      String error_msg = e.toString();

      if (error_msg.indexOf("phone auth credential is invalid") != -1) {
        JToast().show_toast("Código inválido.", true);
        return "failed-invalid";
      }

      if (error_msg.indexOf("has expired") != -1) {
        JToast().show_toast("Código expirado. Por favor tente novamente com o código atualizado.", true);
        return "failed-expired";
      }

      return "failed";
    }
  }

  Future<bool> operate_change_pw(TextEditingController _pw1_txtedit_control,
      TextEditingController _pw2_txtedit_control, String token) async {
    if (_pw1_txtedit_control.text == "ぁあぃいnothingchanged" &&
        _pw2_txtedit_control.text == "ぁあぃいnothingchanged") {
      // nothing to changed
      print(" nothing to changed:: pw");
      return true;
    }

    String url = rapivetStatics.baseURL + "/user/change_password";
    var uri = Uri.parse(url);

    Map<String, String> headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      "Authorization": "Bearer " + token
    };

    Map data = {
      "new_password": _pw1_txtedit_control.text.trim(),
      "confirm_password": _pw2_txtedit_control.text.trim(),
    };

    var body = json.encode(data);
    var response = await phttp.post(uri, headers: headers, body: body);

    print("${response.headers}");
    print("${response.statusCode}"); // 성공 200 / 실패 400
    print("${response.body}"); // 성공: "code":"0","msg":"success"}

    var json_data = json.decode(response.body);

    try {
      String noshow = json_data["noshow"].toString();
      String msg = json_data["msg"].toString();
      if (msg == "success") {
        return true;
      } else {
        if (noshow == "0") {
          JToast().show_toast(msg, true);
        } else {
          JToast().show_toast("회원정보를 수정할 수 없습니다.", true);
        }
      }
    } catch (e) {}

    return false;
  }

  Future<bool> update_user_info(
      TextEditingController _address1_txt_control,
      TextEditingController _address2_txt_control,
      TextEditingController _phone_txt_control,
      String token) async{


    String url = rapivetStatics.baseURL + "/user/update";
    var uri = Uri.parse(url);

    Map<String, String> headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      "Authorization": "Bearer " + token
    };

    Map data = {
      "address1": _address1_txt_control.text.trim(),
      "address2": _address2_txt_control.text.trim(),
      "cell_phone": _phone_txt_control.text.trim(),
    };

    var body = json.encode(data);

    var response = await phttp.post(uri, headers: headers, body: body);

    print("${response.headers}");
    print("${response.statusCode}"); // 성공 200 / 실패 400
    print("${response.body}"); // 성공: "code":"0","msg":"success"}

    var json_data = json.decode(response.body);

    try {
      String noshow = json_data["noshow"].toString();
      String msg = json_data["msg"].toString();
      if (msg == "success") {
        return true;
      } else {
        if (noshow == "0") {
          JToast().show_toast(msg, true);
        } else {
          JToast().show_toast("회원정보를 수정할 수 없습니다.", true);
        }
      }
    } catch (e) {}

    return false;
  }

  Future<List> operate_signup(
      TextEditingController _email_txtedit_control,
      TextEditingController _name_txtedit_control,
      TextEditingController _phoneNum_txtedit_control,
      // TextEditingController _adress1_txtedit_control,
      // TextEditingController _adress2_txtedit_control,
      TextEditingController _pw1_txtedit_control,
      TextEditingController _pw2_txtedit_control) async {
    String url = rapivetStatics.baseURL + "/user/signup";
    var uri = Uri.parse(url);

    Map<String, String> headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };

    Map data = {
      "email": _email_txtedit_control.text.trim(),
      "name": _name_txtedit_control.text.trim(),
      "password": _pw1_txtedit_control.text.trim(),
      "confirm_password": _pw2_txtedit_control.text.trim(),
      // "address1": _adress1_txtedit_control.text.trim(),
      // "address2": _adress2_txtedit_control.text.trim(),
      "cell_phone": _phoneNum_txtedit_control.text.trim(),
    };

    var body = json.encode(data);

    var response = await phttp.post(uri, headers: headers, body: body);

    print("${response.headers}");
    print("${response.statusCode}"); // 성공 200 / 실패 400
    print("${response.body}"); // 성공: "code":"0","msg":"success"}

    // 통신 성공 시 statusCode 200
    // 회원가입 성공 시 body  {"code":"0","msg":"success"}
    // 회원가입 실패 시 대략 이런 느낌. {"code":"100009","msg":"routes.user.signup Error: Duplicate entry 'test1@abc.com' for key 'email'"}
    var json_data = json.decode(response.body);

    String msg = json_data["msg"].toString();
    String noshow = json_data["noshow"].toString();

    List result = [];

    try {
      if (msg == "success") {
        result.add(true); //0
        result.add(msg); // 1

        // String token = json_data["data"]["token"];
        // result.add(token); // 2
      } else {
        result.add(false);

        if (noshow == "0") {
          result.add(msg);
        } else {
          result.add("Impossível realizar o cadastro.");
        }
      }
    } catch (e) {
      result.add(false);
      result.add("Impossível realizar o cadastro.");
    }

    return result;
  }

  void move_to_petRegister(BuildContext context) {
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) =>
                RegisterPet_scene(COME_FROM.WELCOME, PET_REGISTER_MODE.ADD)));
  }

  void make_random_data(
      TextEditingController _email_txtedit_control,
      TextEditingController _name_txtedit_control,
      TextEditingController _phoneNum_txtedit_control,
      TextEditingController _pw1_txtedit_control,
      TextEditingController _pw2_txtedit_control) {
    Random random = new Random();
    int random_int = random.nextInt(100000000);

    _email_txtedit_control.text = "random_" + random_int.toString() + "@a.com";
    _name_txtedit_control.text = "name";
    _phoneNum_txtedit_control.text = "99999999";
    _pw1_txtedit_control.text = "@Test1212";
    _pw2_txtedit_control.text = "@Test1212";
  }
}
