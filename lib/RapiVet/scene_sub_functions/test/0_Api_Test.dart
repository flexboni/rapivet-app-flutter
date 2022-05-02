import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:swork_raon/rapivet/scene_sub_functions/common_ui.dart';
import 'package:swork_raon/rapivet/scene_sub_functions/test/0_API_Test_subfuncs.dart';

class Api_test_scene extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _api_test_scene_home();
}

class _api_test_scene_home extends State<StatefulWidget> {
  bool _is_loading = false;

  // jujewang@naver.com / @Test1234
  final _scaffoldKey = new GlobalKey<ScaffoldState>();

  String token;
  String email = "juje1@a.com";
  String pw = "@Test1212";
  String name = "주재현";

  // passive
  String _first_pet_uid = "";

  @override
  Widget build(BuildContext context) {
    double s_width = MediaQuery.of(context).size.width;

    _set_loading_on() {
      setState(() {
        _is_loading = true;
      });
    }

    _set_loading_off() {
      setState(() {
        _is_loading = false;
      });
    }

    return ModalProgressHUD(
      inAsyncCall: _is_loading,
      child: Scaffold(
          key: _scaffoldKey,
          body: SafeArea(
              child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            scrollDirection: Axis.vertical,
            child: Container(
              child: Column(
                children: [
                  Padding(padding: new EdgeInsets.all(20)),
                  Container(
                      width: s_width,
                      alignment: Alignment.center,
                      child: Text("API TEST")),
                  Padding(padding: new EdgeInsets.all(20)),
                  Container(
                      child: get_one_btn(
                          s_width * 0.8, Colors.blueGrey, "temp - ios Sign up",
                          () async {
                    _set_loading_on();
                    token = await api_test_subFuncs().test_ios_signup();
                    _set_loading_off();
                  })),
                  Padding(padding: new EdgeInsets.all(10)),
                  Container(
                      child: get_one_btn(
                          s_width * 0.8, Colors.blueGrey, "Sign up", () async {
                    _set_loading_on();
                    await api_test_subFuncs().test_signup(email, pw);
                    _set_loading_off();
                  })),
                  Padding(padding: new EdgeInsets.all(10)),

                  // social signup
                  Container(
                      child: get_one_btn(
                          s_width * 0.8, Colors.blueGrey, "Social Sign up",
                          () async {
                    _set_loading_on();
                    token = await api_test_subFuncs()
                        .test_social_signup(email, name);
                    print(token);
                    _set_loading_off();
                  })),
                  Padding(padding: new EdgeInsets.all(10)),

                  // social login
                  Container(
                      child: get_one_btn(
                          s_width * 0.8, Colors.blueGrey, "Social Log in",
                          () async {
                    _set_loading_on();
                    token = await api_test_subFuncs().test_social_login(email);
                    print(token);
                    _set_loading_off();
                  })),
                  Padding(padding: new EdgeInsets.all(10)),

                  Container(
                      child: get_one_btn(
                          s_width * 0.8, Colors.blueGrey, "Log in", () async {
                    _set_loading_on();
                    token = await api_test_subFuncs().test_login(email, pw);
                    print(token);
                    _set_loading_off();
                  })),
                  Padding(padding: new EdgeInsets.all(10)),
                  Container(
                      child: get_one_btn(
                          s_width * 0.8, Colors.blueGrey, "Search PW",
                          () async {
                    _set_loading_on();
                    await api_test_subFuncs().test_search_pw(email);
                    print(token);
                    _set_loading_off();
                  })),

                  // get user info ---------------------------------------
                  Padding(padding: new EdgeInsets.all(10)),
                  Container(
                      child: get_one_btn(
                          s_width * 0.8, Colors.blueGrey, "get user info",
                          () async {
                    _set_loading_on();
                    await api_test_subFuncs().test_get_user_info(token);
                    print(token);
                    _set_loading_off();
                  })),

                  // update user -----------------------------------------
                  Padding(padding: new EdgeInsets.all(10)),
                  Container(
                      child: get_one_btn(
                          s_width * 0.8, Colors.blueGrey, "update user info",
                          () async {
                    _set_loading_on();
                    await api_test_subFuncs().test_update_user(token);
                    print(token);
                    _set_loading_off();
                  })),

                  // pet--------------------------------------------------
                  Padding(padding: new EdgeInsets.all(30)),
                  Container(
                      child: get_one_btn(
                          s_width * 0.8, Colors.blueGrey, "pet register",
                          () async {
                    _set_loading_on();
                    await api_test_subFuncs().test_pet_register(token);
                    //print(token);
                    _set_loading_off();
                  })),
                  Padding(padding: new EdgeInsets.all(10)),
                  Container(
                      child: get_one_btn(
                          s_width * 0.8, Colors.blueGrey, "get pet info",
                          () async {
                    _set_loading_on();
                    var response =
                        await api_test_subFuncs().test_get_pet_info(token);
                    _first_pet_uid =
                        api_test_subFuncs().get_pet_uid(response, 0);
                    //print(token);
                    _set_loading_off();
                  })),
                  Padding(padding: new EdgeInsets.all(10)),
                  Container(
                      child: get_one_btn(
                          s_width * 0.8, Colors.blueGrey, "pet update",
                          () async {
                    _set_loading_on();
                    await api_test_subFuncs()
                        .test_pet_update(token, _first_pet_uid);
                    //print(token);
                    _set_loading_off();
                  })),
                  Padding(padding: new EdgeInsets.all(10)),
                  Container(
                      child: get_one_btn(
                          s_width * 0.8, Colors.blueGrey, "pet photo update",
                          () async {
                    _set_loading_on();
                    await api_test_subFuncs()
                        .test_pet_update(token, _first_pet_uid);
                    //print(token);
                    _set_loading_off();
                  })),
                  Padding(padding: new EdgeInsets.all(10)),
                  Container(
                      child: get_one_btn(
                          s_width * 0.8, Colors.blueGrey, "pet delete",
                          () async {
                    _set_loading_on();
                    await api_test_subFuncs()
                        .test_pet_delete(token, _first_pet_uid);
                    //print(token);
                    _set_loading_off();
                  })),

                  Padding(padding: new EdgeInsets.all(30)),

                  // pet stick test -------------------------------------------
                  Container(
                      child: get_one_btn(
                          s_width * 0.8, Colors.blueGrey, "pet health register",
                          () async {
                    _set_loading_on();
                    await api_test_subFuncs()
                        .test_pet_health_check_register(_first_pet_uid, token);
                    //print(token);
                    _set_loading_off();
                  })),
                  Padding(padding: new EdgeInsets.all(10)),
                  Container(
                      child: get_one_btn(s_width * 0.8, Colors.blueGrey,
                          "pet health list read", () async {
                    _set_loading_on();
                    await api_test_subFuncs()
                        .test_pet_health_check_list_read(_first_pet_uid, token);
                    //print(token);
                    _set_loading_off();
                  })),
                  Padding(padding: new EdgeInsets.all(10)),
                  Container(
                      child: get_one_btn(s_width * 0.8, Colors.blueGrey,
                          "get - pet health check : today", () async {
                    _set_loading_on();
                    await api_test_subFuncs()
                        .test_get_pet_health_today(_first_pet_uid, token);
                    //print(token);
                    _set_loading_off();
                  })),
                  Padding(padding: new EdgeInsets.all(10)),
                  Container(
                      child: get_one_btn(
                          s_width * 0.8, Colors.blueGrey, "stick photo update",
                          () async {
                    _set_loading_on();
                    await api_test_subFuncs()
                        .test_pet_stick_photo_upload("2021110712361187", token);
                    //print(token);
                    _set_loading_off();
                  })),

                  Padding(padding: new EdgeInsets.all(30)),

                  // Q&A -------------------------------------------------
                  Container(
                      child: get_one_btn(
                          s_width * 0.8, Colors.blueGrey, "Q&A write",
                          () async {
                    _set_loading_on();
                    await api_test_subFuncs().test_qa_write(token);
                    //print(token);
                    _set_loading_off();
                  })),
                  Padding(padding: new EdgeInsets.all(10)),
                  Container(
                      child: get_one_btn(
                          s_width * 0.8, Colors.blueGrey, "Q&A read", () async {
                    _set_loading_on();
                    await api_test_subFuncs().test_get_QnA(token);
                    //print(token);
                    _set_loading_off();
                  })),

                  Padding(padding: new EdgeInsets.all(100)),
                ],
              ),
            ),
          ))),
    );
  }
}
