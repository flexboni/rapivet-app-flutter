import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:swork_raon/common/JToast.dart';
import 'package:swork_raon/model/one_user_data.dart';
import 'package:swork_raon/rapivet/6_userInfo.dart';
import 'package:swork_raon/rapivet/scene_sub_functions/3_2_Signup_subFuncs.dart';
import 'package:swork_raon/rapivet/scene_sub_functions/Api_manager.dart';

import '../common/rapivet_statics.dart';
import 'scene_sub_functions/common_ui.dart';

enum SIGN_UP_MODE { SIGNUP, MODIFY }

SIGN_UP_MODE _signup_mode;
one_user_data _in_user_data;

class SignUpPage extends StatefulWidget {
  SignUpPage(SIGN_UP_MODE in_signup_mode, {one_user_data user_data = null}) {
    _signup_mode = in_signup_mode;
    _in_user_data = user_data;
  }

  @override
  State<StatefulWidget> createState() => _SignUpPageState();
}

bool _is_agreed = true;

TextEditingController _email_txtedit_control;
TextEditingController _name_txtedit_control;
TextEditingController _phoneNum_txtedit_control;
TextEditingController _adress1_txtedit_control;
TextEditingController _adress2_txtedit_control;
TextEditingController _pw1_txtedit_control;
TextEditingController _pw2_txtedit_control;

TextEditingController _dialog_phoneNum_txtedit_control;
TextEditingController _dialog_zip_txtedit_control,
    _dialog_smsCode_txtedit_control;

class _SignUpPageState extends State<StatefulWidget>
    with TickerProviderStateMixin {
  bool _is_loading = false;
  String phone_num;
  int sms_auth_failed_count = 0;

  @override
  void initState() {
    super.initState();
    _is_loading = false;
    sms_auth_failed_count = 0;

    _email_txtedit_control = TextEditingController();
    _name_txtedit_control = TextEditingController();
    _phoneNum_txtedit_control = TextEditingController();
    _adress1_txtedit_control = TextEditingController();
    _adress2_txtedit_control = TextEditingController();
    _pw1_txtedit_control = TextEditingController();
    _pw2_txtedit_control = TextEditingController();

    _dialog_phoneNum_txtedit_control = TextEditingController();
    _dialog_zip_txtedit_control = TextEditingController();
    _dialog_smsCode_txtedit_control = TextEditingController();

    if (_signup_mode == SIGN_UP_MODE.MODIFY) {
      _email_txtedit_control.text = _in_user_data.email;
      _name_txtedit_control.text = _in_user_data.name;
      _phoneNum_txtedit_control.text = _in_user_data.phone_num;
      _adress1_txtedit_control.text = _in_user_data.address1.trim();
      _adress2_txtedit_control.text = _in_user_data.address2.trim();
      _pw1_txtedit_control.text = "ぁあぃいnothingchanged";
      _pw2_txtedit_control.text = "ぁあぃいnothingchanged";
    }
  }

  @override
  Widget build(BuildContext context) {
    double s_width = MediaQuery.of(context).size.width;
    double s_height = MediaQuery.of(context).size.height;

    const Color appblue = Color.fromARGB(255, 111, 145, 190);

    void _setAgreedToTOS(bool newValue) {
      setState(() {
        _is_agreed = newValue;
      });
    }

    void _callback_get_zip() async {
      print("----------------------");
      String zip = _dialog_zip_txtedit_control.text.trim();
      print(zip);
      setState(() {
        _is_loading = true;
      });

      String result = await Signup_subfuncs().get_adress_from_zip(zip);
      if (result == "error") {
        JToast().show_toast("해당 zip로 주소를 찾을 수 없습니다.", true);
      } else {
        _adress1_txtedit_control.text = result;
      }

      setState(() {
        _is_loading = false;
      });
    }

    void _callback_check_sms_code() async {
      String code = _dialog_smsCode_txtedit_control.text.trim();
      String result = await Signup_subfuncs().check_sms_code(code);

      if (result == "failed-invalid" && sms_auth_failed_count < 3) {
        sms_auth_failed_count++;
        print(sms_auth_failed_count);
        showDialogPopup(
            context,
            s_width,
            _dialog_smsCode_txtedit_control,
            "Por favor insira o código enviado pelo sms.",
            "123455",
            _callback_check_sms_code,
            () {});
      }

      if (result == "success") {
        // 전화번호 입력
        _phoneNum_txtedit_control.text = phone_num;
      }
    }

    void _callback_show_smsCode_input() async {
      print(_dialog_phoneNum_txtedit_control.text);

      String txt_val = _dialog_phoneNum_txtedit_control.text;
      txt_val = txt_val.replaceAll(" ", "");
      txt_val = txt_val.replaceAll("+", "");
      txt_val = txt_val.replaceAll("-", "");
      _dialog_phoneNum_txtedit_control.text = txt_val;

      // 1. send sms code!!
      RapivetStatics.smsVerificationId = "null";
      RapivetStatics.smsVerificationError = "null";
      sms_auth_failed_count = 0;
      phone_num = Signup_subfuncs()
          .get_phone_num(_dialog_phoneNum_txtedit_control.text);

      await Signup_subfuncs().request_sms_code(phone_num);

      // wait -----------------------------------------------------------------
      setState(() {
        _is_loading = true;
      });

      bool is_okay_to_go = false;

      for (int i = 0; i < 50; i++) {
        await Future.delayed(Duration(milliseconds: 200));

        if (RapivetStatics.smsVerificationId != "null") {
          print("Ready to enter code !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
          is_okay_to_go = true;
          i = 99999;
        } else {
          print("wait.....");
        }

        if (RapivetStatics.smsVerificationError != "null") {
          // 에러가 있다면 표시하라
          JToast().show_toast("Impossível dar continuidade.", false);
        }
      }

      setState(() {
        _is_loading = false;
      });

      if (is_okay_to_go == false) return;
      // ------------------------------------------------------------------------

      // show input-sms-code popup
      _dialog_smsCode_txtedit_control.text = "";
      showDialogPopup(
          context,
          s_width,
          _dialog_smsCode_txtedit_control,
          "Por favor insira o código enviado pelo sms.",
          "123456",
          _callback_check_sms_code,
          () {});
    }

    void _showDialog_phone() {
      _dialog_phoneNum_txtedit_control.text = "+55";
      showDialogPopup(
          context,
          s_width,
          _dialog_phoneNum_txtedit_control,
          "Por favor coloque o número de telefone.",
          "+5512345-1234",
          _callback_show_smsCode_input,
          () {},
          is_using_number_only: false,
          is_phone_number: true);
    }

    void _showDialog_address() {
      _dialog_phoneNum_txtedit_control.text = "";
      showDialogPopup(
          context,
          s_width,
          _dialog_zip_txtedit_control,
          "Por favor insira o código postal",
          "01001-000",
          _callback_get_zip,
          () {});
    }

    callback_touch_adress1() {
      print("callback_click_adress1");
      _showDialog_address();
    }

    callback_touch_phonenumber() {
      _showDialog_phone();
    }

    callback_goback() {
      if (_signup_mode == SIGN_UP_MODE.MODIFY) {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (BuildContext context) => userInfo_scene()));
      } else {
        Navigator.pop(context);
      }
    }

    void onClick_signup() async {
      setState(() {
        _is_loading = true;
      });

      if (_signup_mode == SIGN_UP_MODE.SIGNUP) {
        List result = await Signup_subfuncs().operate_signup(
            _email_txtedit_control,
            _name_txtedit_control,
            _phoneNum_txtedit_control,
            // _adress1_txtedit_control,
            // _adress2_txtedit_control,
            _pw1_txtedit_control,
            _pw2_txtedit_control);

        if (result[0] == false) {
          JToast().show_toast(result[1], true);
        } else {
          // 가입 성공 & 다시 로그인
          String token = await Api_manager().login(
              _email_txtedit_control.text.trim(),
              _pw1_txtedit_control.text.trim());

          if (token != "") {
            RapivetStatics.token = token;
            RapivetStatics.prefs.setString("token", token);
            RapivetStatics.prefs.setBool("is_logged_on_user", true);
            RapivetStatics.isLoggedOnUser = true;
          } else {
            print("fatal error!!!!!");
          }

          JToast().show_toast(
              "Cadastro realizado com sucesso. Faça o cadastramento do primeiro pet.",
              false);
          Signup_subfuncs().move_to_petRegister(context);
        }
      } else if (_signup_mode == SIGN_UP_MODE.MODIFY) {
        print("modify!!!");

        // 1. 비밀 번호 변경
        bool was_changed_pw = await Signup_subfuncs().operate_change_pw(
            _pw1_txtedit_control, _pw2_txtedit_control, RapivetStatics.token);

        // 2. 나머지 데잍터 변경
        if (was_changed_pw) {
          bool was_succeed = await Signup_subfuncs().update_user_info(
              _adress1_txtedit_control,
              _adress2_txtedit_control,
              _phoneNum_txtedit_control,
              RapivetStatics.token);

          if (was_succeed) {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (BuildContext context) => userInfo_scene()));
          }
        }
      }

      setState(() {
        _is_loading = false;
      });
    }

    void onClick_make_randomData_by_developer() {
      Signup_subfuncs().make_random_data(
          _email_txtedit_control,
          _name_txtedit_control,
          _phoneNum_txtedit_control,
          _pw1_txtedit_control,
          _pw2_txtedit_control);
    }

    return WillPopScope(
      onWillPop: () async {
        callback_goback();
        return false;
      },
      child: Scaffold(
          backgroundColor: RapivetStatics.appBG,
          body: AnnotatedRegion<SystemUiOverlayStyle>(
            value: SystemUiOverlayStyle.dark,
            child: SafeArea(
              child: Stack(
                children: [
                  SingleChildScrollView(
                    physics: BouncingScrollPhysics(),
                    scrollDirection: Axis.vertical,
                    child: Container(
                      width: s_width,
                      child: Column(
                        children: [
                          Padding(padding: new EdgeInsets.all(45)),
                          // email------------------------------------------------------
                          get_explain_of_textfield_up(s_width, "E-mail"),
                          Padding(padding: new EdgeInsets.all(3)),
                          get_one_textfield(
                            s_width,
                            appblue,
                            _email_txtedit_control,
                            "",
                            is_readonly: (_signup_mode == SIGN_UP_MODE.MODIFY),
                          ),
                          Padding(padding: new EdgeInsets.all(3)),
                          get_explain_of_textfield_down(
                              s_width, "Ex. sau@email.com"),
                          Padding(padding: new EdgeInsets.all(8)),
                          // nome -------------------------------------------------------
                          get_explain_of_textfield_up(s_width, "Nome"),
                          Padding(padding: new EdgeInsets.all(3)),
                          get_one_textfield(
                              s_width, appblue, _name_txtedit_control, "",
                              is_readonly:
                                  (_signup_mode == SIGN_UP_MODE.MODIFY)),
                          Padding(padding: new EdgeInsets.all(3)),
                          get_explain_of_textfield_down(
                              s_width, "Ex. Joao Paulo"),
                          Padding(padding: new EdgeInsets.all(8)),
                          // phone --------------------------------------------------------
                          get_explain_of_textfield_up(s_width, "Celular"),
                          Padding(padding: new EdgeInsets.all(3)),
                          get_one_textfield(
                              s_width, appblue, _phoneNum_txtedit_control, "",
                              is_readonly: true,
                              is_detecting_touch: true,
                              CallBack_whenTouch: callback_touch_phonenumber),
                          Padding(padding: new EdgeInsets.all(3)),
                          get_explain_of_textfield_down(
                              s_width, "Ex. +5512345-1234"),
                          Padding(padding: new EdgeInsets.all(8)),
                          // adress 1 ------------------------------------------------------
                          Visibility(
                            visible: (_signup_mode == SIGN_UP_MODE.MODIFY),
                            child: Column(
                              children: [
                                get_explain_of_textfield_up(
                                    s_width, "Endereço 1"),
                                Padding(padding: new EdgeInsets.all(3)),
                                get_one_textfield(s_width, appblue,
                                    _adress1_txtedit_control, "",
                                    is_readonly: true,
                                    is_detecting_touch: true,
                                    CallBack_whenTouch: callback_touch_adress1),
                                Padding(padding: new EdgeInsets.all(3)),
                                get_explain_of_textfield_down(
                                    s_width, "Ex. San Paulo"),
                                Padding(padding: new EdgeInsets.all(8)),
                                // adress 2 ---------------------------------------------------
                                get_explain_of_textfield_up(
                                    s_width, "Endereço 2"),
                                Padding(padding: new EdgeInsets.all(3)),
                                get_one_textfield(s_width, appblue,
                                    _adress2_txtedit_control, ""),
                                Padding(padding: new EdgeInsets.all(3)),
                                get_explain_of_textfield_down(
                                    s_width, "Ex. Banchome 1-211"),
                                Padding(padding: new EdgeInsets.all(8)),
                              ],
                            ),
                          ),
                          // pw1 -------------------------------------------------------
                          get_explain_of_textfield_up(
                              s_width, "Digite sua senha"),
                          Padding(padding: new EdgeInsets.all(3)),
                          get_one_textfield(
                              s_width, appblue, _pw1_txtedit_control, "",
                              is_password: true),
                          Padding(padding: new EdgeInsets.all(3)),
                          get_explain_of_textfield_down(s_width,
                              "Conter no mínimo 6 caracteres (letras maiúsculas, minúsculas, números e símbolos)"),
                          Padding(padding: new EdgeInsets.all(8)),
                          // pw2 -----------------------------------------------------
                          get_explain_of_textfield_up(
                              s_width, "Confirme sua senha"),
                          Padding(padding: new EdgeInsets.all(3)),
                          get_one_textfield(
                              s_width, appblue, _pw2_txtedit_control, "",
                              is_password: true),
                          Padding(padding: new EdgeInsets.all(3)),
                          get_explain_of_textfield_down(s_width,
                              "Conter no mínimo 6 caracteres (letras maiúsculas, minúsculas, números e símbolos)"),
                          Padding(padding: new EdgeInsets.all(8)),
                          // agree check --------------------------------------------
                          Container(
                            width: s_width * 0.9,
                            child: FittedBox(
                              child: Row(
                                children: <Widget>[
                                  Checkbox(
                                      value: _is_agreed,
                                      onChanged: _setAgreedToTOS),
                                  GestureDetector(
                                    onTap: () => {_setAgreedToTOS(!_is_agreed)},
                                    child: const Text(
                                      'Quero receber novidades e promoções exclusivas     ',
                                      style: TextStyle(
                                          color: Color.fromARGB(
                                              255, 111, 145, 190)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Padding(padding: new EdgeInsets.all(18)),
                          // btn ---------------------------------------------------------
                          get_one_btn(
                              s_width * 0.9, RapivetStatics.appBlue, "SALVAR",
                              () {
                            onClick_signup();
                          }, in_height: 50),
                          Padding(padding: new EdgeInsets.all(20)),
                          Padding(padding: new EdgeInsets.all(8)),
                          // Container(
                          //   height: 46.88,
                          //   width: s_width * 0.8,
                          //   child: ElevatedButton(
                          //       style: OutlinedButton.styleFrom(
                          //         shape: new RoundedRectangleBorder(
                          //             borderRadius:
                          //                 new BorderRadius.circular(20.0)),
                          //         tapTargetSize:
                          //             MaterialTapTargetSize.shrinkWrap,
                          //         backgroundColor:
                          //             RapivetStatics.app_blue.withOpacity(0.8),
                          //       ),
                          //       onPressed: () async {
                          //         Navigator.push(
                          //             context,
                          //             MaterialPageRoute(
                          //                 builder: (BuildContext context) =>
                          //                     Api_test_scene()));
                          //       },
                          //       child: Text(
                          //         'API TEST',
                          //         style: TextStyle(
                          //           color: Colors.white,
                          //           fontSize: 20.88,
                          //         ),
                          //       )),
                          // ),
                          // Padding(padding: new EdgeInsets.all(38)),
                        ],
                      ),
                    ),
                  ),
                  get_upbar(() {}, false, "Criar Conta",
                      in_width: s_width, callback_goBack: callback_goback),
                  common_show_loading(s_height, s_width, 0, this, _is_loading),
                ],
              ),
            ),
          )),
    );
  }

  ///////// ======================================================================================

//===============================================================================================
}
