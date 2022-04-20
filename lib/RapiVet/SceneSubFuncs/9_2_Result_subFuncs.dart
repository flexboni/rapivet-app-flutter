import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:page_transition/page_transition.dart';
import 'package:swork_raon/0_CommonThisApp/rapivetStatics.dart';
import 'package:http/http.dart' as phttp;
import 'package:swork_raon/0_DataProcess/one_healthcheck_data.dart';
import 'package:swork_raon/0_DataProcess/one_pet_data.dart';
import 'package:swork_raon/RapiVet/10_Result_plus.dart';

import '0_commonUI.dart';

class Result_subFuncs {
  Future<List<one_healthcheck_data>> get_currentPet_healthCehck_db() async {
    one_pet_data this_pet_data =
        rapivetStatics.pet_data_list[rapivetStatics.current_pet_index];
    String token = rapivetStatics.token;
    String pet_uid = this_pet_data.uid;

    String url = rapivetStatics.baseURL + "/pet/health_check_list/" + pet_uid;
    print(url);

    var uri = Uri.parse(url);

    var response = await phttp.get(
      uri,
      headers: {HttpHeaders.authorizationHeader: "Bearer " + token},
    );

    print("${response.headers}");
    print("${response.statusCode}");
    print("${response.body}");

    var json_data = json.decode(response.body);

    try {
      if (json_data["msg"] == "success") {
        List data_list = json_data["data"];
        return _raw_data_toList(data_list, pet_uid);
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  Future<List<one_healthcheck_data>> get_onePet_healthCehck_db(
      String pet_uid) async {
    String token = rapivetStatics.token;

    String url = rapivetStatics.baseURL + "/pet/health_check_list/" + pet_uid;
    print(url);

    var uri = Uri.parse(url);

    var response = await phttp.get(
      uri,
      headers: {HttpHeaders.authorizationHeader: "Bearer " + token},
    );

    print("${response.headers}");
    print("${response.statusCode}");
    print("${response.body}");

    var json_data = json.decode(response.body);

    try {
      if (json_data["msg"] == "success") {
        List data_list = json_data["data"];
        return _raw_data_toList(data_list, pet_uid);
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  List<one_healthcheck_data> _raw_data_toList(List dblist, String pet_uid) {
    int data_count = dblist.length;

    List<one_healthcheck_data> health_check_list = [];

    for (int i = 0; i < data_count; i++) {
      one_healthcheck_data this_healthCheck_data = one_healthcheck_data();

      String round = dblist[i]["round"];
      String keton = dblist[i]["keton"];
      String glucose = dblist[i]["glucose"];
      String leukocyte = dblist[i]["leukocyte"];
      String nitrite = dblist[i]["nitrite"];
      String blood = dblist[i]["blood"];
      String ph = dblist[i]["ph"];
      String proteinuria = dblist[i]["proteinuria"];
      String created_at = dblist[i]["created_at"];

      this_healthCheck_data.set_data(pet_uid, round, keton, glucose, leukocyte,
          nitrite, blood, ph, proteinuria, created_at);

      health_check_list.add(this_healthCheck_data);
    }

    return health_check_list;
  }

  List<one_healthcheck_data> reverse_order(
      List<one_healthcheck_data> in_health_datas) {
    List<one_healthcheck_data> out_health_datas = [];

    for (int i = in_health_datas.length - 1; i >= 0; i--) {
      out_health_datas.add(in_health_datas[i]);
    }

    return out_health_datas;
  }

  List<String> get_check_dates(List<one_healthcheck_data> check_datas) {
    List<String> _health_check_dates = [];

    for (int i = 0; i < check_datas.length; i++) {
      String timeStr = check_datas[i].time_to_display;
      _health_check_dates.add(timeStr);
    }

    return _health_check_dates;
  }

  // get link =====
  get_link_info(String token) async {
    var uri = Uri.parse(rapivetStatics.baseURL + "/operation/links");

    var response = await phttp.get(
      uri,
      headers: {HttpHeaders.authorizationHeader: "Bearer " + token},
    );

    print("${response.headers}");
    print("${response.statusCode}");
    print("${response.body}");

    var json_data = json.decode(response.body);

    print("--------------------");
    String img_url = json_data["data"][0]["url"];

    return img_url;
  }

  // ui ======================================
  get_current_checkUI(BuildContext context, double s_width,
      one_healthcheck_data this_healthCheck_data) {
    try {
      return Column(children: [
        for (int i = 0; i < 7; i++)
          _get_one_result_listUI(context, s_width, this_healthCheck_data, i),
      ]);
    } catch (e) {
      return Container();
    }
  }

  _get_one_result_listUI(BuildContext context, double s_width,
      one_healthcheck_data this_healthCheck_data, int index) {
    Color this_red = Color.fromARGB(255, 213, 48, 8);
    Color this_grey = Colors.grey.withOpacity(0.8);
    String title = rapivetStatics.healthCheck_title[index];

    /*
    "Cetonas",
    "Glicose",
    "Leucócitos",
    "Nitrito",
    "Sangue",
    "pH",
    "Proteínas",
    * */

    bool _is_normal = false;
    RESULT_PLUS_MODE target_mode = RESULT_PLUS_MODE.KETON;

    if (index == 0) {
      _is_normal = this_healthCheck_data.is_normal(RESULT_PLUS_MODE.KETON);
      target_mode = RESULT_PLUS_MODE.KETON;
    }

    if (index == 1) {
      _is_normal = this_healthCheck_data.is_normal(RESULT_PLUS_MODE.GLUCOSE);
      target_mode = RESULT_PLUS_MODE.GLUCOSE;
    }

    if (index == 2) {
      _is_normal = this_healthCheck_data.is_normal(RESULT_PLUS_MODE.LEUKOZYTEN);
      target_mode = RESULT_PLUS_MODE.LEUKOZYTEN;
    }

    if (index == 3) {
      _is_normal = this_healthCheck_data.is_normal(RESULT_PLUS_MODE.NITRITE);
      target_mode = RESULT_PLUS_MODE.NITRITE;
    }

    if (index == 4) {
      _is_normal = this_healthCheck_data.is_normal(RESULT_PLUS_MODE.BLOOD);
      target_mode = RESULT_PLUS_MODE.BLOOD;
    }

    if (index == 5) {
      _is_normal = this_healthCheck_data.is_normal(RESULT_PLUS_MODE.PH);
      target_mode = RESULT_PLUS_MODE.PH;
    }

    if (index == 6) {
      _is_normal = this_healthCheck_data.is_normal(RESULT_PLUS_MODE.PROTEIN);
      target_mode = RESULT_PLUS_MODE.PROTEIN;
    }

    return Container(
      child: Stack(
        children: [
          Column(
            children: [
              // 위치잡기
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 50,
                    width: s_width * 0.8,
                  ),
                ],
              ),
              // 하단 구분선
              Container(
                height: 1,
                width: s_width * 0.8,
                color: Colors.black.withOpacity(0.1),
              )
            ],
          ),
          // 체크 항목 타이틀
          Container(
            height: 50,
            child: Row(
              children: [
                Padding(
                    padding: new EdgeInsets.fromLTRB(s_width * 0.1, 0, 0, 0)),
                Text(title),
              ],
            ),
          ),
          // 의심/정상 표시
          Container(
            height: 50,
            child: Row(
              children: [
                Padding(
                    padding: new EdgeInsets.fromLTRB(s_width * 0.45, 0, 0, 0)),
                (_is_normal)
                    ? get_one_roundITEM(
                        s_width * 0.28, 30, "NORMAL", Colors.white, this_grey)
                    : get_one_roundITEM(
                        s_width * 0.28, 30, "SUPEITA", Colors.white, this_red),
              ],
            ),
          ),
          // 상세결과 이동
          Container(
            height: 50,
            child: Row(
              children: [
                Padding(
                    padding: new EdgeInsets.fromLTRB(s_width * 0.78, 0, 0, 0)),
                OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.white, width: 0),
                    ),
                    onPressed: () {
                      print(target_mode);
                      rapivetStatics.selected_result_plus_mode = target_mode;
                      Navigator.pushReplacement(
                          context,
                          PageTransition(
                              type: PageTransitionType.fade,
                              child: Result_plus_scene()));
                    },
                    child: Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: Colors.black.withOpacity(0.58),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  get_current_checkUI_test(double s_width) {
    Color this_red = Color.fromARGB(255, 213, 48, 8);
    Color this_grey = Colors.grey;

    return Column(
      children: [
        for (int i = 0; i < 4; i++)
          Container(
            child: Stack(
              children: [
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          height: 50,
                          width: s_width * 0.8,
                        ),
                      ],
                    ),
                    Container(
                      height: 1,
                      width: s_width * 0.8,
                      color: Colors.black.withOpacity(0.1),
                    )
                  ],
                ),
                Container(
                  height: 50,
                  child: Row(
                    children: [
                      Padding(
                          padding:
                              new EdgeInsets.fromLTRB(s_width * 0.1, 0, 0, 0)),
                      Text("Cetonas"),
                    ],
                  ),
                ),
                Container(
                  height: 50,
                  child: Row(
                    children: [
                      Padding(
                          padding:
                              new EdgeInsets.fromLTRB(s_width * 0.45, 0, 0, 0)),
                      get_one_roundITEM(s_width * 0.28, 30, "SUPEITA",
                          Colors.white, this_red),
                    ],
                  ),
                ),
                Container(
                  height: 50,
                  child: Row(
                    children: [
                      Padding(
                          padding:
                              new EdgeInsets.fromLTRB(s_width * 0.78, 0, 0, 0)),
                      OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.white, width: 0),
                          ),
                          onPressed: () {},
                          child: Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: Colors.black.withOpacity(0.58),
                          )),
                    ],
                  ),
                ),
              ],
            ),
          ),
        for (int i = 0; i < 3; i++)
          Container(
            child: Stack(
              children: [
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          height: 50,
                          width: s_width * 0.8,
                        ),
                      ],
                    ),
                    Container(
                      height: 1,
                      width: s_width * 0.8,
                      color: Colors.black.withOpacity(0.1),
                    )
                  ],
                ),
                Container(
                  height: 50,
                  child: Row(
                    children: [
                      Padding(
                          padding:
                              new EdgeInsets.fromLTRB(s_width * 0.1, 0, 0, 0)),
                      Text("Leucocitos"),
                    ],
                  ),
                ),
                Container(
                  height: 50,
                  child: Row(
                    children: [
                      Padding(
                          padding:
                              new EdgeInsets.fromLTRB(s_width * 0.45, 0, 0, 0)),
                      get_one_roundITEM(s_width * 0.28, 30, "NORMAL",
                          Colors.white, Colors.grey.withOpacity(0.8)),
                    ],
                  ),
                ),
                Container(
                  height: 50,
                  child: Row(
                    children: [
                      Padding(
                          padding:
                              new EdgeInsets.fromLTRB(s_width * 0.78, 0, 0, 0)),
                      OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.white, width: 0),
                          ),
                          onPressed: () {},
                          child: Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: Colors.black.withOpacity(0.58),
                          )),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  @override
  void show_dialog_date(BuildContext context, List<String> _types_set,
      VoidCallback callback_setState, int _selected_val, double s_width) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          insetPadding: EdgeInsets.all(10),
          child: Container(
            height: 380,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 290,
                  width: MediaQuery.of(context).size.width * 0.9,
                  child: Padding(
                    padding: new EdgeInsets.fromLTRB(0, 20, 0, 20),
                    child: RawScrollbar(
                      thumbColor: rapivetStatics.app_blue.withOpacity(0.5),
                      thickness: 1.8,
                      child: SingleChildScrollView(
                        physics: BouncingScrollPhysics(),
                        scrollDirection: Axis.vertical,
                        child: Column(
                          children: [
                            for (int i = 0; i < _types_set.length; i++)
                              Container(
                                height: 40,
                                padding: new EdgeInsets.fromLTRB(s_width*0.035, 0, 0, 0),
                                child: RadioListTile(
                                  title: Text(
                                    _types_set[i],
                                    style: TextStyle(
                                        color: (i == _selected_val)
                                            ? rapivetStatics.app_blue
                                            : Colors.black.withOpacity(0.58),
                                        fontSize: 11.5),
                                  ),
                                  value: i,
                                  groupValue: (i == _selected_val) ? i : -1,
                                  activeColor: rapivetStatics.app_blue,
                                  onChanged: (int value) {
                                    // _value = value;
                                    rapivetStatics.selected_check_index =
                                        value;
                                    // print();
                                    Navigator.pop(context);
                                    FocusScope.of(context).unfocus();
                                    callback_setState();
                                  },
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(padding: new EdgeInsets.all(1)),
                OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.white, width: 0),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      FocusScope.of(context).unfocus();
                      callback_setState();
                    },
                    child: Text(
                      "Fechar",
                      style: TextStyle(
                          color: rapivetStatics.app_blue.withOpacity(0.7)),
                    )),
              ],
            ),
          ),
        );
      },
    );
  }
}
