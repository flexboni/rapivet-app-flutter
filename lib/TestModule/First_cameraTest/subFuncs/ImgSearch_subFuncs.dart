import 'dart:convert';
import 'dart:math';
import 'package:image/image.dart' as imglib;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:swork_raon/0_CommonThisApp/rapivetStatics.dart';
import 'package:swork_raon/0_DataProcess/one_pet_data.dart';
import 'package:swork_raon/RapiVet/9_Result.dart';
import 'package:swork_raon/RapiVet/SceneSubFuncs/0_commonUI.dart';
import 'package:swork_raon/RapiVet/SceneSubFuncs/Api_manager.dart';
import 'package:swork_raon/TestModule/First_cameraTest/horizontal_checker.dart';
import 'package:swork_raon/TestModule/First_cameraTest/testStatics.dart';
import 'package:swork_raon/TestModule/Img_Proc_testModule/SubFuncs/SearchingResult/Search_ultimate_result.dart';
import 'package:swork_raon/TestModule/Img_Proc_testModule/SubFuncs/SearchingResult/stickResult_dataset.dart';

import '../../Loading_imgsearch.dart';
import 'dart:io' show Platform;
// find check area ======================================================================================

void _moveto_loading(BuildContext context) {
  Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (BuildContext context) => Loading_imgSearch()));
}

stickResult_dataset _operate_search_ultimate_result() {
  print(testStatics.stickRect_area_colorSets_list.length);

  stickResult_dataset result_dataset =
      Search_ultimate_result().operate_find_ultimate_result();

  return result_dataset;
}

@override
Widget get_find_end_check(BuildContext context, double s_width, double s_height,
    VoidCallback Callback_loading_on) {
  if (testStatics.is_to_show_jpg_to_check) {
    double s_ratio = s_height / s_width;

    print(s_ratio);

    return get_find_end_check_twoLine(context, s_width, Callback_loading_on);

  } else {
    return get_guide_searching(s_width);
  }
}

get_find_end_check_oneLine(
    BuildContext context, double s_width, VoidCallback Callback_loading_on) {
  return Container(
    padding: new EdgeInsets.fromLTRB(s_width * 0.1, 0, s_width * 0.1, 0),
    width: s_width * 0.8,
    child: FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("ESTA na posicao correta ?"),
          Padding(padding: new EdgeInsets.fromLTRB(s_width * 0.05, 0, 0, 0)),
          get_one_btn(s_width / 6, rapivetStatics.app_blue, "sim", () {
            _get_result_and_upload_it(Callback_loading_on, context);
          }, in_height: 18, font_size: 10),
          Padding(padding: new EdgeInsets.fromLTRB(s_width * 0.05, 0, 0, 0)),
          get_one_btn(s_width / 6, rapivetStatics.app_blue, "não", () {
            _moveto_loading(context);
          }, in_height: 18, font_size: 10),
        ],
      ),
    ),
  );
}

get_find_end_check_twoLine(
    BuildContext context, double s_width, VoidCallback Callback_loading_on) {
  return Container(
    padding: new EdgeInsets.fromLTRB(s_width * 0.1, 0, s_width * 0.1, 0),
    width: s_width * 0.8,
    child: FittedBox(
      fit: BoxFit.scaleDown,
      child: Column(
        children: [
          Text("ESTA na posicao correta ?"),
          Padding(padding: new EdgeInsets.all(8)),
          Row(
            children: [
              get_one_btn(s_width / 5, rapivetStatics.app_blue, "sim", () {
                _get_result_and_upload_it(Callback_loading_on, context);
              }, in_height: 28, font_size: 12),
              Padding(
                  padding: new EdgeInsets.fromLTRB(s_width * 0.08, 0, 0, 0)),
              get_one_btn(s_width / 5, rapivetStatics.app_blue, "não", () {
                _moveto_loading(context);
              }, in_height: 28, font_size: 12),
            ],
          ),
        ],
      ),
    ),
  );
}

get_guide_searching(double s_width) {
  return Container(
    padding: new EdgeInsets.fromLTRB(s_width * 0.07 ,0, s_width * 0.07, 0),
    width: s_width * 0.9,
    child: FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Posicione a cartela de cores para automaticamente escanear.", maxLines: 1,),
        ],
      ),
    ),
  );
}

// upload result ===============================================================================

void _get_result_and_upload_it(
    VoidCallback Callback_loading_on, BuildContext context) async {
  Callback_loading_on();
  stickResult_dataset result_set = _operate_search_ultimate_result();

  try {
    one_pet_data this_pet_data =
        rapivetStatics.pet_data_list[rapivetStatics.current_pet_index];
    String pet_uid = this_pet_data.uid;
    String token = rapivetStatics.prefs.getString("token");

    // upload data
    print("upload result data");
    String result_uid = await Api_manager()
        .pet_health_check_register(pet_uid, token, result_set);
    print(result_uid);

    // stick img to base64
    List<int> jpeg = imglib.encodeJpg(testStatics.stick_area_img, quality: 95);
    String img_base64 = base64Encode(jpeg);
    print(img_base64);

    // upload img
    print("upload img data");
    await Api_manager().pet_stick_photo_upload(result_uid, token, img_base64);
  } catch (e) {
    print("error in _get_result_and_upload_it");
    return;
  }

  print("move to result!");
  Navigator.pushReplacement(context,
      PageTransition(type: PageTransitionType.fade, child: Result_scene()));
}

// test result area ==============================================================================

@override
Widget get_test_result(
    BuildContext context, bool is_test_mode, Image imageNew) {
  return Visibility(
    visible: is_test_mode,
    child: Container(
      alignment: Alignment.bottomCenter,
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(padding: new EdgeInsets.all(10)),
          Visibility(
            visible: testStatics.is_to_show_result,
            child: Transform.rotate(
              angle: pi / 180 * 90,
              child: Container(
                  height: 320,
                  width: 400,
                  child: FittedBox(fit: BoxFit.fitHeight, child: imageNew)),
            ),
          ),
          Padding(padding: new EdgeInsets.all(50)),
          // horizontal_checker(),
        ],
      ),
    ),
  );
}

// get horizontal_checker widget =================================================================

@override
get_horizontal_checker(double s_width, double camear_area_height) {
  return Container(
    width: s_width,
    height: camear_area_height,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Padding(
          padding:
              new EdgeInsets.fromLTRB(0, 0, 0, camear_area_height / 2 * 0.9),
          child: Container(
              alignment: Alignment.center,
              //color: Colors.red,
              child: horizontal_checker()),
        ),
      ],
    ),
  );
}

// show guide img =================================================================================

show_guide_img(double s_width, double s_height, VoidCallback Callback_setstate) {
  return Visibility(
    visible: rapivetStatics.is_to_show_cam_guide,
    child: Stack(
      children: [
        Container(
          width: s_width,
          height: s_height,
          color: Colors.black.withOpacity(0.9),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(padding: new EdgeInsets.fromLTRB(0, s_height / 12, 0, 0)),
            Container(
              height: s_height *0.45,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset("assets/tutorial/cam_guide.png"),
                ],
              ),
            ),
            Padding(padding: new EdgeInsets.fromLTRB(0, 30, 0, 0)),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                    width: s_width * 0.9,
                    child: Text(
                      "Siga as instruções do vídeo para inserir a tira reagente na cartela de cores. Posicione a cartela de cores para automaticamente escanear. Lembrando que para um resultado melhor tire a foto em ambiente claro sem sombras.",
                      style: TextStyle(color: Colors.white),
                    )),
              ],
            ),
            Padding(padding: new EdgeInsets.fromLTRB(0, 30, 0, 0)),
            get_one_btn(s_width*0.9, rapivetStatics.app_blue.withOpacity(0.8), "OK", (){
              rapivetStatics.is_to_show_cam_guide = false;
              Callback_setstate();
            })
          ],
        ),
      ],
    ),
  );
}
