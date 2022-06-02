import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:swork_raon/common/JToast.dart';
import 'package:swork_raon/common/app_strings.dart';
import 'package:swork_raon/model/Pet_data_manager.dart';
import 'package:swork_raon/model/one_pet.dart';
import 'package:swork_raon/model/one_user_data.dart';
import 'package:swork_raon/rapivet/home.dart';
import 'package:swork_raon/rapivet/scene_sub_functions/5_2_main_subFuncs.dart';
import 'package:swork_raon/rapivet/scene_sub_functions/6_2_userInfo_subFuncs.dart';
import 'package:swork_raon/rapivet/scene_sub_functions/Api_manager.dart';

import '../common/rapivet_statics.dart';
import 'scene_sub_functions/common_ui.dart';
import 'sign_up.dart';

one_user_data _this_user_data;

bool _is_showing_adress = false;
bool _is_showing_phoneNum = false;

class userInfo_scene extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _userInfo_home();
}

class _userInfo_home extends State<StatefulWidget>
    with TickerProviderStateMixin {
  bool _is_loading = false;

  _operate_delete(List<OnePet> _pet_data_list, int _index) async {
    setState(() {
      _is_loading = true;
    });

    RapivetStatics.petDataList =
        await Pet_data_manager().remove_pet_data(_pet_data_list, _index);

    int pet_data_count = RapivetStatics.petDataList.length;

    if (RapivetStatics.currentPetIndex >= pet_data_count) {
      RapivetStatics.currentPetIndex = pet_data_count - 1;
    }

    setState(() {
      _is_loading = false;
    });
  }

  @override
  void initState() {
    super.initState();

    _is_showing_adress = false;
    _is_showing_phoneNum = false;

    _this_user_data = one_user_data();
    _this_user_data.name = ".";
    _this_user_data.email = ".";
    _this_user_data.phone_num = ".";

    if (RapivetStatics.isLoggedOnUser) load_data_fromServer();
  }

  load_data_fromServer() async {
    setState(() {
      _is_loading = true;
    });

    // 굳이 다시 데이터 불러올 필요는 없다. 하지만 시간 딜레이 없으면, 이미지 수정 시
    // 바로 반영되는 것을 볼 수 없다.
    await Future.delayed(Duration(milliseconds: 2888));

    String token = RapivetStatics.token;
    _this_user_data = await Api_manager().get_user_data(token);
    if (RapivetStatics.isMakeRandomCellphone)
      _this_user_data.phone_num = "1000000000";

    List<OnePet> petDatas = await Api_manager().get_pet_list(token);
    RapivetStatics.petDataList = petDatas;

    if (_this_user_data.address1 != "") {
      _is_showing_adress = true;
    }

    if (_this_user_data.phone_num != "") {
      _is_showing_phoneNum = true;
    }

    setState(() {
      _is_loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    double s_width = MediaQuery.of(context).size.width;
    double s_height = MediaQuery.of(context).size.height;

    Color iconColor = Colors.black.withOpacity(0.6);
    Color normalFont_color = Colors.black.withOpacity(0.48);

    void _show_deleteDialog(List<OnePet> _pet_data_list, int _index) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: new Text(
              "",
              style: TextStyle(fontSize: 1, fontWeight: FontWeight.normal),
            ),
            content: Row(
              children: [
                Icon(
                  Icons.pets_rounded,
                  color: Colors.black87.withOpacity(0.48),
                ),
                Padding(padding: new EdgeInsets.all(5)),
                new Text(
                  "Deseja excluír o pet?",
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87.withOpacity(0.7)),
                ),
              ],
            ),
            actions: <Widget>[
              new FlatButton(
                child: new Text(
                  "não",
                  style: TextStyle(color: Colors.black54),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  FocusScope.of(context).unfocus();
                },
              ),
              new FlatButton(
                child: new Text(
                  "sim",
                  style: TextStyle(color: Colors.black54),
                ),
                onPressed: () async {
                  Navigator.pop(context);
                  FocusScope.of(context).unfocus();
                  await _operate_delete(_pet_data_list, _index);
                },
              ),
            ],
          );
        },
      );
    }

    // TODO: implement build
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (BuildContext context) => HomePage()));

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
                    child: Visibility(
                      visible: !_is_loading,
                      child: Column(
                        children: [
                          Padding(padding: new EdgeInsets.all(45)),
                          Visibility(
                            visible: /*!RapivetStatics.is_simple_loggined ||*/ !Platform
                                .isIOS,
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Padding(
                                        padding: new EdgeInsets.fromLTRB(
                                            s_width * 0.05, 0, 0, 0)),
                                    Icon(
                                      Icons.person,
                                      color: normalFont_color,
                                    ),
                                    Padding(padding: new EdgeInsets.all(5)),
                                    Text(
                                      _this_user_data.name,
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                          fontSize: 17,
                                          color: normalFont_color),
                                    ),
                                  ],
                                ),
                                Padding(padding: new EdgeInsets.all(10)),
                                Visibility(
                                  visible: _is_showing_phoneNum,
                                  child: Column(
                                    children: [
                                      Container(
                                        decoration: get_circle_boxDecoration(),
                                        //color: Colors.redAccent,
                                        width: s_width * 0.9,
                                        height: 48,
                                        child: Row(
                                          children: [
                                            Padding(
                                                padding:
                                                    new EdgeInsets.all(13)),
                                            Icon(Icons.phone, color: iconColor),
                                            Padding(
                                                padding:
                                                    new EdgeInsets.all(10)),
                                            Text(
                                              _this_user_data.phone_num,
                                              textAlign: TextAlign.left,
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  color: normalFont_color),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Padding(padding: new EdgeInsets.all(6)),
                                    ],
                                  ),
                                ),
                                Container(
                                  decoration: get_circle_boxDecoration(),
                                  //color: Colors.redAccent,
                                  width: s_width * 0.9,
                                  height: 48,
                                  child: Row(
                                    children: [
                                      Padding(padding: new EdgeInsets.all(13)),
                                      Icon(
                                        Icons.email,
                                        color: iconColor,
                                      ),
                                      Padding(padding: new EdgeInsets.all(10)),
                                      Text(
                                        _this_user_data.email,
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                            fontSize: 14,
                                            color: normalFont_color),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(padding: new EdgeInsets.all(6)),
                                Visibility(
                                  visible: _is_showing_adress,
                                  child: Column(
                                    children: [
                                      Container(
                                        //decoration: get_shadow_boxDecoration(),
                                        decoration: get_circle_boxDecoration(),
                                        //color: Colors.redAccent,
                                        width: s_width * 0.9,
                                        height: 55,
                                        child: Row(
                                          children: [
                                            Padding(
                                                padding:
                                                    new EdgeInsets.all(13)),
                                            Icon(
                                              Icons.location_on_rounded,
                                              color: iconColor,
                                            ),
                                            Padding(
                                                padding:
                                                    new EdgeInsets.all(10)),
                                            Container(
                                              width: s_width * 0.9 * 0.7,
                                              child: Text(
                                                _this_user_data.address2 +
                                                    ", " +
                                                    _this_user_data.address1,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                textAlign: TextAlign.left,
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    color: normalFont_color),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Padding(padding: new EdgeInsets.all(6)),
                                    ],
                                  ),
                                ),
                                Material(
                                  child: InkWell(
                                    onTap: () {
                                      JToast().show_toast(
                                          "página em preparação", true);
                                    },
                                    child: Container(
                                      decoration: get_circle_boxDecoration(),
                                      //color: Colors.redAccent,
                                      width: s_width * 0.9,
                                      height: 48,
                                      child: Row(
                                        children: [
                                          Padding(
                                              padding: new EdgeInsets.all(13)),
                                          //Icon(Icons.verified_sharp, color: iconColor),
                                          Opacity(
                                            opacity: 0.75,
                                            child: Container(
                                                height: 27,
                                                child: Image.asset(
                                                    'assets/userinfo_img/icon_news.png')),
                                          ),
                                          Padding(
                                              padding: new EdgeInsets.all(10)),
                                          Text(
                                            "Promoções",
                                            textAlign: TextAlign.left,
                                            style: TextStyle(
                                                fontSize: 14,
                                                color: normalFont_color),
                                          ),
                                          Padding(
                                              padding: new EdgeInsets.all(5)),
                                          Opacity(
                                            opacity: 0.75,
                                            child: Container(
                                                height: 22,
                                                child: Image.asset(
                                                    'assets/userinfo_img/icon_star.png')),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(padding: new EdgeInsets.all(10)),
                                Visibility(
                                  visible:
                                      (_this_user_data.phone_num.trim() != ""),
                                  child: get_one_btn(s_width * 0.9,
                                      RapivetStatics.appBlue, "Editar", () {
                                    Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (BuildContext context) =>
                                                SignUpPage(
                                                  SIGN_UP_MODE.MODIFY,
                                                  user_data: _this_user_data,
                                                )));
                                  }, in_height: 50),
                                ),
                                Visibility(
                                    visible:
                                        (_this_user_data.phone_num.trim() !=
                                            ""),
                                    child: Padding(
                                        padding: new EdgeInsets.all(10))),
                                Container(
                                    width: s_width,
                                    height: 7,
                                    color: Colors.black.withOpacity(0.025)),
                                Padding(padding: new EdgeInsets.all(11)),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              Padding(
                                padding: new EdgeInsets.fromLTRB(
                                    s_width * 0.05, 0, 0, 0),
                              ),
                              Icon(
                                Icons.pets_rounded,
                                color: normalFont_color,
                              ),
                              Padding(padding: new EdgeInsets.all(5)),
                              Text(
                                "Meu Pet",
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                    fontSize: 17, color: normalFont_color),
                              ),
                            ],
                          ),
                          Padding(padding: new EdgeInsets.all(8)),
                          for (int i = 0;
                              i < RapivetStatics.petDataList.length;
                              i++)
                            Container(
                              // padding: new EdgeInsets.fromLTRB(0, 8, 0, 8),
                              child: Column(
                                children: [
                                  Padding(padding: new EdgeInsets.all(4)),
                                  Stack(
                                    children: [
                                      Row(
                                        children: [
                                          Padding(
                                              padding: new EdgeInsets.fromLTRB(
                                                  s_width * 0.05, 0, 0, 0)),
                                          Container(
                                            height: 52,
                                            width: 52,
                                            decoration: BoxDecoration(
                                              //shape: BoxShape.circle,
                                              borderRadius: BorderRadius.all(
                                                Radius.circular(15),
                                              ),
                                              image: main_subfuncs()
                                                  .get_thumb_img_in_userInfo(i),
                                            ),
                                          ),
                                          Padding(
                                              padding: new EdgeInsets.fromLTRB(
                                                  20, 0, 0, 0)),
                                          Text(
                                            RapivetStatics.petDataList[i].name,
                                            textAlign: TextAlign.left,
                                            style: TextStyle(
                                                fontSize: 17,
                                                color: normalFont_color,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                      Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            Container(
                                              width: 50,
                                              height: 50,
                                              child: RawMaterialButton(
                                                shape: CircleBorder(),
                                                onPressed: () {
                                                  userinfo_subfuncs()
                                                      .goto_register_to_modify(
                                                          context, i);
                                                },
                                                child: Opacity(
                                                  opacity: 0.75,
                                                  child: Container(
                                                      height: 18,
                                                      child: Image.asset(
                                                          'assets/userinfo_img/icon_edit.png')),
                                                ),
                                              ),
                                            ),
                                            Opacity(
                                              opacity: 0.35,
                                              child: Container(
                                                  height: 15,
                                                  child: Image.asset(
                                                      'assets/userinfo_img/icon_vertical_line.png')),
                                            ),
                                            Container(
                                              width: 50,
                                              height: 50,
                                              child: RawMaterialButton(
                                                shape: CircleBorder(),
                                                onPressed: () {
                                                  if (RapivetStatics
                                                          .petDataList.length ==
                                                      1) {
                                                    JToast().show_toast(
                                                        app_strings()
                                                            .STR_cant_del_all_pet,
                                                        false);
                                                    return;
                                                  }
                                                  _show_deleteDialog(
                                                      RapivetStatics
                                                          .petDataList,
                                                      i);
                                                },
                                                child: Opacity(
                                                  opacity: 0.75,
                                                  child: Container(
                                                      height: 18,
                                                      child: Image.asset(
                                                          'assets/userinfo_img/icon_delete.png')),
                                                ),
                                              ),
                                            ),
                                            Padding(
                                                padding:
                                                    new EdgeInsets.fromLTRB(0,
                                                        0, s_width * 0.05, 0)),
                                          ]),
                                    ],
                                  ),
                                  Padding(padding: new EdgeInsets.all(4)),
                                  Visibility(
                                      visible: (i <
                                              RapivetStatics
                                                      .petDataList.length -
                                                  1)
                                          ? true
                                          : false,
                                      child: Container(
                                        height: 2.5,
                                        width: s_width * 0.9,
                                        color: Colors.grey.withOpacity(0.05),
                                      ))
                                ],
                              ),
                            ),
                          Padding(padding: new EdgeInsets.all(33)),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    child: get_upbar(() {}, false, "Minha área",
                        in_width: s_width, callback_goBack: () {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (BuildContext context) => HomePage()));
                    }),
                  ),
                  //    show_notReadyyet(s_width,s_height,is_full_screen: true)
                  show_loading(_is_loading, s_height, s_width, this),
                ],
              ),
            ),
          )),
    );
  }
}
