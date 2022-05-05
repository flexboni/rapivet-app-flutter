import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:page_transition/page_transition.dart';
import 'package:swork_raon/model/All_health_check_manager.dart';
import 'package:swork_raon/rapivet/10_Result_plus.dart';
import 'package:swork_raon/rapivet/6_userInfo.dart';
import 'package:swork_raon/rapivet/7_Test_Guide.dart';
import 'package:swork_raon/rapivet/9_Result.dart';
import 'package:swork_raon/rapivet/scene_sub_functions/5_2_main_subFuncs.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../common/rapivetStatics.dart';
import '../4_RegisterPet.dart';
import '../5_Main.dart';
import '4_2_ResterPet_subfuncs.dart';

/*
*
*                       get_explain_of_textfield_up(s_width, "Email"),
                      Padding(padding: new EdgeInsets.all(2)),
                      get_one_textfield(
                          s_width, appblue, _email_txtedit_control, ""),
                      Padding(padding: new EdgeInsets.all(3)),
                      get_explain_of_textfield_down(s_width, "Ex. sau@email.com"),
*
* */

enum DOWN_BAR_STATUS { MAIN, TEST, RESULT, RESULT2, MENU }

TextInputType _get_keyboard_type(
    bool is_using_number_only, is_name_keyboard, is_phone_number) {
  if (is_using_number_only)
    return TextInputType.number;
  else if (is_phone_number)
    return TextInputType.phone;
  else if (is_name_keyboard)
    return TextInputType.name;
  else
    return TextInputType.text;
}

@override
Widget get_one_textfield(double s_width, Color appblue,
    TextEditingController in_controller, String hint_text,
    {bool is_readonly = false,
    bool is_detecting_touch = false,
    VoidCallback CallBack_whenTouch = null,
    bool is_password = false,
    bool is_using_number_only = false,
    bool is_name_keyboard = false,
    bool is_to_show_pw_visibleMark = false,
    VoidCallback Callback_click_pw_show_btn = null,
    bool is_to_show_opendown_btn = false,
    bool is_to_show_kg_mark = false,
    bool is_phone_number = false,
    double btn_height = 55,
    Color txtColor = Colors.black54}) {
  return Container(
    height: btn_height,
    width: s_width,
    alignment: Alignment.center,
    child: Stack(
      children: [
        Container(
          width: s_width * 1,
          alignment: Alignment.center,
          child: Container(
            width: s_width * 0.9,
            child: TextField(
                autofocus: false,
                obscureText: is_password,
                controller: in_controller,
                readOnly: is_readonly,
                //textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 13,
                    color: txtColor,
                    fontFamily: "Roboto",
                    fontWeight: FontWeight.bold),
                keyboardType: _get_keyboard_type(
                    is_using_number_only, is_name_keyboard, is_phone_number),
                // style: TextStyle(fontSize: 12),
                onTap: () {
                  if (is_detecting_touch) CallBack_whenTouch();
                },
                decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      borderSide: BorderSide(
                          color: rapivetStatics.normal_ui_line_color, width: 1),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: rapivetStatics.selected_ui_line_color,
                          width: 1.0),
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    filled: true,
                    contentPadding: EdgeInsets.symmetric(
                        horizontal: s_width * 0.1, vertical: btn_height / 3),
                    hintStyle: TextStyle(color: Colors.black.withOpacity(0.28)),
                    hintText: hint_text,
                    fillColor: Colors.white)),
          ),
        ),
        Visibility(
          visible: is_to_show_pw_visibleMark,
          child: Container(
              padding: new EdgeInsets.fromLTRB(0, 0, 20, 0),
              alignment: Alignment.centerRight,
              child: RawMaterialButton(
                  shape: CircleBorder(),
                  onPressed: () {
                    Callback_click_pw_show_btn();
                  },
                  child: (is_password)
                      ? Icon(
                          Icons.visibility_off_rounded,
                          color: Colors.black.withOpacity(0.75),
                        )
                      : Icon(
                          Icons.visibility,
                          color: Colors.black.withOpacity(0.75),
                        ))),
        ),
        Visibility(
          visible: is_to_show_opendown_btn && in_controller.text.length < 27,
          child: Container(
              //color: Colors.red,
              padding: new EdgeInsets.fromLTRB(0, 0, s_width * 0.1, 0),
              alignment: Alignment.centerRight,
              child: Container(
                  height: 13, child: Image.asset('assets/updown_arrows.png'))),
        ),
        Visibility(
          visible: is_to_show_kg_mark,
          child: Container(
              padding: new EdgeInsets.fromLTRB(0, 0, s_width * 0.1, 0),
              alignment: Alignment.centerRight,
              child: Text("KG")),
        ),
      ],
    ),
  );
}

Widget selectable_button(double width, double height, String text,
    bool is_selected, VoidCallback callback_funcs) {
  return Container(
    width: width,
    height: height,
    child: OutlinedButton(
      onPressed: () {
        callback_funcs();
      },
      child: Text(
        text,
        style: TextStyle(color: Colors.black.withOpacity(0.58), fontSize: 13),
      ),
      style: OutlinedButton.styleFrom(
        backgroundColor:
            (is_selected) ? Colors.blueAccent.withOpacity(0.08) : Colors.white,
        //shape: StadiumBorder(),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        side: BorderSide(
            color: (is_selected)
                ? rapivetStatics.selected_ui_line_color
                : rapivetStatics.normal_ui_line_color),
      ),
    ),
  );
}

@override
Widget get_explain_of_textfield_up(double s_width, String text,
    {bool is_showing_footmark = false}) {
  return Container(
      padding: new EdgeInsets.fromLTRB(s_width * 0.05, 0, 0, 0),
      width: s_width,
      alignment: Alignment.centerLeft,
      child: Row(
        children: [
          Visibility(
            visible: is_showing_footmark,
            child: Padding(
              padding: new EdgeInsets.fromLTRB(0, 0, 8, 0),
              child: Container(
                  height: 13, child: Image.asset('assets/footmark.png')),
            ),
          ),
          Text(
            text,
            style: TextStyle(
                fontSize: 13.88,
                color: rapivetStatics.app_black.withOpacity(0.88),
                fontFamily: "Noto"),
          ),
        ],
      ));
}

@override
Widget get_explain_of_textfield_down(double s_width, String text) {
  return Container(
      padding: new EdgeInsets.fromLTRB(s_width * 0.05, 0, 0, 0),
      width: s_width,
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: TextStyle(
            fontSize: 12,
            color: Colors.black.withOpacity(0.25),
            fontWeight: FontWeight.bold),
      ));
}

@override
Widget get_one_roundITEM(double in_width, double in_height, String text,
    Color txt_color, Color bg_color) {
  return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: bg_color,
        borderRadius: BorderRadius.all(
          Radius.circular(18),
        ),
      ),
      height: in_height,
      width: in_width,
      child: Text(
        text,
        style: TextStyle(
          color: txt_color,
        ),
      ));
}

@override
void show_dialog_petlist(
    BuildContext context,
    List<String> _types_set,
    VoidCallback callback_setState,
    int _value,
    REG_PET_TYPE reg_pet_type,
    register_input_dataset _input_dataset) {
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
                              child: Container(
                                child: RadioListTile(
                                  title: Text(
                                    _types_set[i],
                                    style: TextStyle(
                                        color: (_types_set[i] ==
                                                _input_dataset
                                                    .breed_txtedit_control.text)
                                            ? rapivetStatics.app_blue
                                            : Colors.black.withOpacity(0.58),
                                        fontSize: 11.5),
                                  ),
                                  value: i,
                                  groupValue: _get_current_pet_sort_list(
                                      _input_dataset, _types_set),
                                  activeColor: rapivetStatics.app_blue,
                                  onChanged: (int value) {
                                    _value = value;

                                    if (reg_pet_type == REG_PET_TYPE.DOG) {
                                      _input_dataset.breed_txtedit_control
                                          .text = _types_set[_value];
                                    }
                                    if (reg_pet_type == REG_PET_TYPE.CAT) {
                                      _input_dataset.breed_txtedit_control
                                          .text = _types_set[_value];
                                    }

                                    Navigator.pop(context);
                                    FocusScope.of(context).unfocus();
                                    callback_setState();
                                  },
                                ),
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

int _get_current_pet_sort_list(
    register_input_dataset _input_dataset, List<String> _types_set) {
  for (int i = 0; i < _types_set.length; i++) {
    if (_input_dataset.breed_txtedit_control.text == _types_set[i]) return i;
  }

  return -1;
}

@override
void showDialogPopup(
    BuildContext context,
    double s_width,
    TextEditingController _in_txt_edit_cont,
    String ment,
    String hint,
    VoidCallback callback_btnOK,
    VoidCallback callback_btncancel,
    {bool is_phone_number = false,
    bool is_using_number_only = true}) {
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
            width: s_width * 0.92,
            height: 200,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(padding: new EdgeInsets.all(15)),
                Container(
                  width: s_width * 0.7,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      ment,
                      style: TextStyle(
                          color: rapivetStatics.app_black.withOpacity(0.7)),
                    ),
                  ),
                ),
                Padding(padding: new EdgeInsets.all(12)),
                get_one_textfield(s_width * 0.88, rapivetStatics.app_blue,
                    _in_txt_edit_cont, hint,
                    is_using_number_only: is_using_number_only,
                    is_phone_number: is_phone_number),
                Padding(padding: new EdgeInsets.all(5)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.white, width: 0),
                        ),
                        onPressed: () {
                          callback_btncancel();
                          Navigator.pop(context);
                          FocusScope.of(context).unfocus();
                        },
                        child: Text(
                          "Fechar",
                          style: TextStyle(
                              color: rapivetStatics.app_black.withOpacity(0.7)),
                        )),
                    Padding(
                        padding: new EdgeInsets.fromLTRB(
                            s_width * 0.11, 0, s_width * 0.11, 0)),
                    OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.white, width: 0),
                        ),
                        onPressed: () {
                          callback_btnOK();
                          Navigator.pop(context);
                          FocusScope.of(context).unfocus();
                        },
                        child: Text(
                          "OK",
                          style: TextStyle(
                            color: rapivetStatics.app_blue.withOpacity(0.99),
                          ),
                        )),
                  ],
                ),
                Padding(padding: new EdgeInsets.all(3)),
              ],
            ),
          ));
    },
  );
}

@override
Widget get_one_result_btn(double in_width, Color l_bgcolor, Color r_bgcolor,
    VoidCallback Callback_click, int normal, int suspect,
    {double in_height = 46.88, bool is_}) {
  return Container(
    child: Material(
      child: InkWell(
        onTap: () {
          print('click');

          Callback_click();
        },
        child: Stack(
          children: [
            Container(
              color: Colors.white,
              height: in_height,
              width: in_width,
              child: Image.asset(
                'assets/main_img/result_btn.png',
                fit: BoxFit.fill,
              ),
            ),
            Container(
              width: in_width,
              // color: Colors.blue,
              padding: new EdgeInsets.fromLTRB(0, in_height / 7, 0, 0),
              child: Row(
                //  mainAxisAlignment: MainAxisAlignment,
                children: [
                  Padding(
                      padding:
                          new EdgeInsets.fromLTRB(in_width * 0.2, 0, 0, 0)),
                  Text(
                    All_health_check_manager().get_currentPet_normal_countStr(),
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  Padding(
                      padding:
                          new EdgeInsets.fromLTRB(in_width * 0.37, 0, 0, 0)),
                  Text(
                    All_health_check_manager()
                        .get_currentPet_suspect_countStr(),
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

@override
Widget get_one_short_btn(
    double in_width, Color bgcolor, String text, VoidCallback Callback_click,
    {double in_height = 46.88}) {
  return Container(
    height: in_height,
    width: in_width,
    child: ElevatedButton(
        style: OutlinedButton.styleFrom(
          shape: new RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(30.0)),
          tapTargetSize: MaterialTapTargetSize.padded,
          backgroundColor: bgcolor.withOpacity(0.9),
        ),
        onPressed: () {
          Callback_click();
        },
        child: Text(
          text,
          style: TextStyle(
            fontFamily: 'Noto',
            color: Colors.white,
            fontSize: 13.88,
          ),
        )),
  );
}

@override
Widget get_one_btn(
    double in_width, Color bgcolor, String text, VoidCallback Callback_click,
    {double in_height = 46.88, double font_size = 18.88}) {
  return Container(
    height: in_height,
    width: in_width,
    child: ElevatedButton(
        style: OutlinedButton.styleFrom(
          shape: new RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(30.0)),
          tapTargetSize: MaterialTapTargetSize.padded,
          backgroundColor: bgcolor.withOpacity(0.9),
        ),
        onPressed: () {
          Callback_click();
        },
        child: Text(
          text,
          style: TextStyle(
            fontFamily: 'Noto',
            color: Colors.white,
            fontSize: font_size,
          ),
        )),
  );
}

@override
Widget get_one_login_btn(double in_width, Color bgcolor, Color btncolor,
    String assets_path, String text, VoidCallback Callback_click,
    {double in_height = 46.88, double icon_height = 24}) {
  return Container(
    height: in_height,
    width: in_width,
    child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          side: BorderSide(
              color: rapivetStatics.app_black.withOpacity(0.3), width: 0.75),
          shape: new RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(5.0)),
          tapTargetSize: MaterialTapTargetSize.padded,
          backgroundColor: bgcolor,
        ),
        onPressed: () {
          Callback_click();
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
                height: icon_height,
                child: (assets_path != '')
                    ? Image.asset(assets_path /*'assets/facebook_sign.png'*/)
                    : Text("")),
            Text(
              text,
              maxLines: 1,
              style: TextStyle(
                // fontFamily: "Noto",
                color: btncolor,
                fontSize: 12.88,
              ),
            ),
          ],
        )),
  );
}

@override
Widget get_upbar(
    VoidCallback Callback_setstate, bool is_using_rightPart, String title,
    {double in_width = 300,
    VoidCallback callback_goBack,
    bool is_modify_mode = false}) {
  Container _get_thumb_img(bool is_using_local_img) {
    return Container(
        alignment: Alignment.center,
        child: Container(
          height: 38,
          width: 38,
          decoration: BoxDecoration(
            //shape: BoxShape.circle,
            borderRadius: BorderRadius.all(
              Radius.circular(10),
            ),
            image: main_subfuncs()
                .get_thumb_img(is_using_local_img: is_using_local_img),
          ),
        )

        // child: widget(child: Image.file(File(Statics.pet_pic_path_test)))),
        );
  }

  _get_rightPart() {
    // print("get_rightPart");
    // print(rapivetStatics.current_pet_pic_path);

    // 로그인 유저가 수정할 경우는 기존 url 이미지 이용해야함.
    print("----");
    print(rapivetStatics.is_logged_on_user);
    print(rapivetStatics.current_pet_pic_path);
    print(is_modify_mode);

    if (rapivetStatics.is_logged_on_user &&
        is_modify_mode &&
        rapivetStatics.current_pet_pic_path == "") {
      return _get_thumb_img(false);
    } else if (rapivetStatics.current_pet_pic_path == "") {
      return Container(
          alignment: Alignment.center,
          child: Icon(
            Icons.camera_alt,
            color: Colors.black.withOpacity(0.5),
          ));
    } else {
      return _get_thumb_img(true);
    }
  }

  return Container(
    // color: Colors.white,
    height: 55,
    width: in_width,

    decoration: BoxDecoration(boxShadow: <BoxShadow>[
      BoxShadow(
          color: Colors.grey.withOpacity(0.2),
          blurRadius: 15.0,
          offset: Offset(0.0, 0.75))
    ], color: Colors.white),

    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.white, width: 0),
              ),
              onPressed: () {
                if (callback_goBack != null) callback_goBack();
              },
              child: Container(
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.arrow_back_ios_rounded,
                    color: Colors.black.withOpacity(0.75),
                  ))),
        ),
        Expanded(flex: 1, child: Container()),
        Text(
          title,
          style: TextStyle(fontFamily: "Noto", fontSize: 18),
        ),
        Expanded(flex: 1, child: Container()),
        Visibility(
          visible: is_using_rightPart,
          child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.white, width: 0),
              ),
              onPressed: () async {
                ImagePicker _picker = ImagePicker();
                // Pick an image
                PickedFile image = await _picker.getImage(
                    source: ImageSource.gallery,
                    maxHeight: rapivetStatics.pic_max_width.toDouble(),
                    maxWidth: rapivetStatics.pic_max_width.toDouble());
                print(image.path);

                // Capture a photo
                rapivetStatics.current_pet_pic_path = image.path;
                print(image.path);

                final bytes = File(image.path).readAsBytesSync();
                rapivetStatics.pet_img_base64 = base64Encode(bytes);

                var file = File(image.path);
                print("fileseze!!");
                print(await file.length());

                Callback_setstate();
              },
              child: _get_rightPart()),
        ),
        Visibility(
            visible: !is_using_rightPart,
            child: Text(
              "aaaaaaa",
              style: TextStyle(color: Colors.white),
            )),
      ],
    ),
  );
}

@override
Widget get_paging(double s_width) {
  int total_count = rapivetStatics.pet_data_list.length;
  int current_index = rapivetStatics.current_pet_index;

  print(total_count);
  print(current_index);
  print(total_count);
  print(current_index);

  return Container(
    width: s_width * 0.5,
    child: FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (int i = 0; i < total_count; i++)
            Row(
              children: [
                Container(
                    height: 4,
                    child: (i == current_index)
                        ? Image.asset("assets/main_img/page_on.png")
                        : Image.asset("assets/main_img/page_off.png")),
                (i == total_count - 1)
                    ? Padding(padding: new EdgeInsets.all(0.001))
                    : Padding(padding: new EdgeInsets.all(2))
              ],
            ),
        ],
      ),
    ),
  );
}

@override
Widget common_show_loading(
    double s_height,
    double s_width,
    double statusBarHeight,
    TickerProviderStateMixin tickerProvider,
    bool is_loading) {
  return Visibility(
    visible: is_loading,
    child: Container(
      height: s_height,
      width: s_width,
      color: Colors.black.withOpacity(0.38),
      child: SpinKitCircle(
        color: Colors.white,
        size: 50.0,
        controller: AnimationController(
            vsync: tickerProvider, duration: const Duration(milliseconds: 888)),
      ),
    ),
  );
}

//#region downbar ==============================================================

@override
Widget get_temp_downbar(BuildContext context, VoidCallback Callback_setstate,
    DOWN_BAR_STATUS current_status, double s_width) {
  double btn_width = s_width * 0.135;

  return Container(
    color: rapivetStatics.app_bg,
    child: Column(
      children: [
        Padding(padding: new EdgeInsets.all(5)),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // HOME
            _get_one_downbar_btn(context, Callback_setstate, current_status,
                DOWN_BAR_STATUS.MAIN, btn_width),
            _get_one_downbar_btn(context, Callback_setstate, current_status,
                DOWN_BAR_STATUS.TEST, btn_width),
            _get_one_downbar_btn(context, Callback_setstate, current_status,
                DOWN_BAR_STATUS.RESULT, btn_width),
            _get_one_downbar_btn(context, Callback_setstate, current_status,
                DOWN_BAR_STATUS.RESULT2, btn_width),
            Column(
              children: [
                InkWell(
                  onTap: () {
                    rapivetStatics.is_showing_menuBtns = true;
                    Callback_setstate();
                  },
                  child: Container(
                      alignment: Alignment.center,
                      child: Container(
                        height: btn_width,
                        width: btn_width,
                        decoration: BoxDecoration(
                          //shape: BoxShape.circle,
                          borderRadius: BorderRadius.all(
                            Radius.circular(10),
                          ),
                          image: main_subfuncs().get_thumb_img(),
                        ),
                      )

                      // child: widget(child: Image.file(File(Statics.pet_pic_path_test)))),
                      ),
                ),
                Padding(padding: new EdgeInsets.all(3.5)),
              ],
            ),
          ],
        ),
        Padding(padding: new EdgeInsets.all(5)),
      ],
    ),
  );
}

Widget _get_one_downbar_btn(
    BuildContext context,
    VoidCallback Callback_setstate,
    DOWN_BAR_STATUS current_status,
    DOWN_BAR_STATUS this_downbar_item,
    double btn_width) {
  return Column(
    children: [
      GestureDetector(
        onTap: () {
          print("tap");

          if (current_status == this_downbar_item) return;

          if (this_downbar_item == DOWN_BAR_STATUS.MAIN) {
            Navigator.pushReplacement(
                context,
                PageTransition(
                    type: PageTransitionType.fade, child: Main_scene()));
          }

          if (this_downbar_item == DOWN_BAR_STATUS.TEST) {
            Navigator.pushReplacement(
                context,
                PageTransition(
                    type: PageTransitionType.fade, child: Test_Guide()));
          }

          if (this_downbar_item == DOWN_BAR_STATUS.RESULT) {
            Navigator.pushReplacement(
                context,
                PageTransition(
                    type: PageTransitionType.fade, child: Result_scene()));
          }

          if (this_downbar_item == DOWN_BAR_STATUS.RESULT2) {
            Navigator.pushReplacement(
                context,
                PageTransition(
                    type: PageTransitionType.fade, child: Result_plus_scene()));
          }
        },
        child: Container(
            height: btn_width,
            width: btn_width,
            alignment: Alignment.center,
            child: Image.asset(_get_downbarIcon_iamgeAssets(
                current_status, this_downbar_item))),
      ),
      Padding(padding: new EdgeInsets.all(3.5)),
      Visibility(
        visible: (current_status == this_downbar_item),
        child: Container(
          width: btn_width,
          height: btn_width / 4,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              _get_downBar_txt(current_status),
              style: TextStyle(color: rapivetStatics.app_blue, fontSize: 12),
              maxLines: 1,
            ),
          ),
        ),
      ),
    ],
  );
}

_get_downBar_txt(DOWN_BAR_STATUS down_bar_selected) {
  if (down_bar_selected == DOWN_BAR_STATUS.MAIN) return "Home";

  if (down_bar_selected == DOWN_BAR_STATUS.TEST) return "Teste";

  if (down_bar_selected == DOWN_BAR_STATUS.RESULT) return "Resultao";

  if (down_bar_selected == DOWN_BAR_STATUS.RESULT2) return "Relatório";
}

_get_downbarIcon_iamgeAssets(
    DOWN_BAR_STATUS down_bar_selected, DOWN_BAR_STATUS this_downbar_item) {
  if (this_downbar_item == DOWN_BAR_STATUS.MAIN) {
    if (this_downbar_item == down_bar_selected) {
      return "assets/downbtns/down_main_selected.png";
    } else {
      return "assets/downbtns/down_main.png";
    }
  }

  if (this_downbar_item == DOWN_BAR_STATUS.TEST) {
    if (this_downbar_item == down_bar_selected) {
      return "assets/downbtns/down_test_selected.png";
    } else {
      return "assets/downbtns/down_test.png";
    }
  }

  if (this_downbar_item == DOWN_BAR_STATUS.RESULT) {
    if (this_downbar_item == down_bar_selected) {
      return "assets/downbtns/down_result_selected.png";
    } else {
      return "assets/downbtns/down_result.png";
    }
  }

  if (this_downbar_item == DOWN_BAR_STATUS.RESULT2) {
    if (this_downbar_item == down_bar_selected) {
      return "assets/downbtns/down_result2_selected.png";
    } else {
      return "assets/downbtns/down_result2.png";
    }
  }
}

//#endregion ===================================================================

@override
Widget show_notReadyyet(double s_width, double s_height,
    {bool is_full_screen = false}) {
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Container(
        alignment: Alignment.center,
        width: s_width,
        height: (is_full_screen) ? s_height * 0.9 : s_height * 2 / 3,
        color: Colors.black.withOpacity(0.7),
        child: Text(
          "Not ready yet...",
          style: TextStyle(color: Colors.white),
        ),
      ),
    ],
  );
}

@override
Widget get_overlay_btns(BuildContext context, VoidCallback Callback_setstate,
    double s_width, double s_height) {
  Color over_btn_fg_color = Colors.black.withOpacity(1);
  Color over_btn_bg_color = Colors.blueGrey.withOpacity(0.88);
  Color over_fontColor = Colors.white.withOpacity(0.6);

  print(rapivetStatics.is_showing_menuBtns);

  return Visibility(
    visible: rapivetStatics.is_showing_menuBtns,
    child: Container(
      width: s_width,
      height: s_height,
      alignment: Alignment.bottomRight,
      color: Colors.black.withOpacity(0.85),
      child: Container(
        height: s_height,
        padding: new EdgeInsets.fromLTRB(
          0,
          0,
          28,
          38,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  "Minha área",
                  style: TextStyle(color: over_fontColor),
                ),
                Padding(padding: new EdgeInsets.all(10)),
                Container(
                  width: 60,
                  height: 60,
                  child: RawMaterialButton(
                    shape: CircleBorder(),
                    onPressed: () {
                      rapivetStatics.is_showing_menuBtns = false;
                      Callback_setstate();
                      Navigator.pushReplacement(
                          context,
                          PageTransition(
                              type: PageTransitionType.fade,
                              child: userInfo_scene()));
                    },
                    fillColor: over_btn_bg_color,
                    child: Icon(
                      Icons.info_rounded,
                      size: 35,
                      color: over_btn_fg_color,
                    ),
                  ),
                ),
              ],
            ),
            Padding(padding: new EdgeInsets.all(12)),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  "Meu PET",
                  style: TextStyle(color: over_fontColor),
                ),
                Padding(padding: new EdgeInsets.all(10)),
                Container(
                  width: 60,
                  height: 60,
                  child: RawMaterialButton(
                    shape: CircleBorder(),
                    onPressed: () {
                      rapivetStatics.is_showing_menuBtns = false;
                      Callback_setstate();

                      Navigator.pushReplacement(
                          context,
                          PageTransition(
                              type: PageTransitionType.fade,
                              child: RegisterPet_scene(
                                  COME_FROM.MAIN, PET_REGISTER_MODE.ADD)));
                      //
                      // Navigator.pushReplacement(
                      //     context,
                      //     MaterialPageRoute(
                      //         builder: (BuildContext context) =>
                      //             RegisterPet_scene(
                      //                 COME_FROM.MAIN, PET_REGISTER_MODE.ADD)));
                    },
                    fillColor: over_btn_bg_color,
                    child: Icon(
                      Icons.pets_rounded,
                      size: 35,
                      color: over_btn_fg_color,
                    ),
                  ),
                ),
              ],
            ),
            Padding(padding: new EdgeInsets.all(12)),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  "Produtos",
                  style: TextStyle(color: over_fontColor),
                ),
                Padding(padding: new EdgeInsets.all(10)),
                Container(
                  width: 60,
                  height: 60,
                  child: RawMaterialButton(
                      shape: CircleBorder(),
                      onPressed: () {
                        launch(
                          "https://www.raonhealth.com/produtos",
                        );
                      },
                      fillColor: over_btn_bg_color,
                      child: Container(
                          height: 30,
                          width: 30,
                          child: Image(
                              image: AssetImage('assets/icon_shop.png')))),
                ),
              ],
            ),
            // Padding(padding: new EdgeInsets.all(12)),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.end,
            //   children: [
            //     Text(
            //       "SERVIÇO VIP",
            //       style: TextStyle(color: over_fontColor),
            //     ),
            //     Padding(padding: new EdgeInsets.all(10)),
            //     Container(
            //       width: 60,
            //       height: 60,
            //       child: RawMaterialButton(
            //         shape: CircleBorder(),
            //         onPressed: () {
            //           JToast().show_toast("página em preparação", true);
            //         },
            //         fillColor: over_btn_bg_color,
            //         child: Container(
            //             height: 32,
            //             width: 32,
            //             child: Image(image: AssetImage('assets/icon_vip.png'))),
            //       ),
            //     ),
            //   ],
            // ),
            Padding(padding: new EdgeInsets.all(12)),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  child: RawMaterialButton(
                    shape: CircleBorder(),
                    onPressed: () {
                      rapivetStatics.is_showing_menuBtns = false;
                      Callback_setstate();
                    },
                    fillColor: over_btn_bg_color,
                    child: Icon(
                      Icons.close,
                      size: 25,
                      color: over_btn_fg_color,
                    ),
                  ),
                ),
              ],
            ),
            Padding(padding: new EdgeInsets.all(12)),
          ],
        ),
      ),
    ),
  );
}

@override
Widget get_one_temp_resultTable(
    double result_talbe_width, double result_talbe_height) {
  return Container(
    child: Row(
      children: [
        Column(
          children: [
            Container(
              width: result_talbe_width * 0.9,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Icon(
                    MaterialCommunityIcons.rectangle,
                    size: 15,
                    color: rapivetStatics.app_blue,
                  ),
                  Padding(padding: new EdgeInsets.fromLTRB(5, 0, 0, 0)),
                  Text(
                    "Normal",
                    style: TextStyle(
                        color: Colors.black.withOpacity(0.58), fontSize: 12),
                  ),
                ],
              ),
            ),
            Padding(padding: new EdgeInsets.all(4)),
            Stack(
              children: [
                Container(
                  width: result_talbe_width,
                  height: 33,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.28),
                    borderRadius: BorderRadius.all(
                      Radius.circular(18),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: result_talbe_width / 6 - 2,
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            width: 2,
                            height: 8,
                            color: Colors.black.withOpacity(0.5),
                          ),
                        ],
                      ),
                      Container(
                        width: result_talbe_width / 6 - 2,
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            width: 2,
                            height: 8,
                            color: Colors.black.withOpacity(0.5),
                          ),
                        ],
                      ),
                      Container(
                        width: result_talbe_width / 6 - 2,
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            width: 2,
                            height: 8,
                            color: Colors.black.withOpacity(0.5),
                          ),
                        ],
                      ),
                      Container(
                        width: result_talbe_width / 6 - 2,
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            width: 2,
                            height: 8,
                            color: Colors.black.withOpacity(0.5),
                          ),
                        ],
                      ),
                      Container(
                        width: result_talbe_width / 6 - 2,
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            width: 2,
                            height: 8,
                            color: Colors.black.withOpacity(0.5),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    Padding(
                        padding: new EdgeInsets.fromLTRB(
                            result_talbe_width / 6, 0, 0, 0)),
                    Container(
                      width: result_talbe_width * 2 / 6,
                      height: result_talbe_height,
                      color: rapivetStatics.app_blue.withOpacity(0.68),
                    ),
                  ],
                ),
                Container(
                  height: result_talbe_height,
                  child: Row(
                    children: [
                      Padding(
                          padding: new EdgeInsets.fromLTRB(
                              result_talbe_width * 4 / 6 + 5, 0, 0, 0)),
                      Icon(
                        Icons.circle,
                        size: 10,
                        color: Colors.redAccent,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Padding(padding: new EdgeInsets.all(4)),
            Text(
              "  5.0    6.0    7.0    8.0    9.0    10.0  ",
              style: TextStyle(
                  fontSize: 10, color: Colors.black.withOpacity(0.58)),
            ),
          ],
        ),
      ],
    ),
  );
}

@override
Widget show_loading(bool is_show, double s_height, double s_width,
    TickerProviderStateMixin tickerProvider) {
  return Visibility(
    visible: is_show,
    child: Container(
      height: s_height,
      width: s_width,
      color: Colors.black.withOpacity(0.38),
      child: SpinKitCircle(
        color: Colors.white,
        size: 50.0,
        controller: AnimationController(
            vsync: tickerProvider, duration: const Duration(milliseconds: 888)),
      ),
    ),
  );
}

get_circle_boxDecoration() {
  return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.all(
        Radius.circular(25),
      ),
      boxShadow: [
        BoxShadow(
          blurRadius: 0,
          spreadRadius: 0.8,
          color: Colors.grey.withOpacity(0.188),
        )
      ]);
}

get_shadow_boxDecoration() {
  return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.all(
        Radius.circular(18),
      ),
      boxShadow: [
        BoxShadow(
          blurRadius: 4,
          spreadRadius: 3,
          color: Colors.grey.withOpacity(0.188),
        )
      ]);
}
