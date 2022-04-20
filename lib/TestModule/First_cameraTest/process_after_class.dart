import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image/image.dart' as imglib;
import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:swork_raon/0_Commons_totally/Vector2d.dart';
import 'package:swork_raon/TestModule/First_cameraTest/testStatics.dart';
import 'package:swork_raon/TestModule/Img_Proc_testModule/SubFuncs/JImgProc.dart';
import 'package:swork_raon/TestModule/Img_Proc_testModule/SubFuncs/SearchingResult/Area_color_sets.dart';
import 'package:swork_raon/TestModule/Img_Proc_testModule/SubFuncs/SearchingResult/SearchingResult_subs.dart';
import 'package:swork_raon/TestModule/Img_Proc_testModule/SubFuncs/Stick/Detail_Check_stick.dart';

class process_after_class {
  static operate_process_after(List result_list) async {
    // List return_vals = [];
    // 0 return_vals.add(true); //success?
    // 1 return_vals.add("good job"); // msg
    // 2 return_vals.add(origin_img); // original image from frame
    // 3 return_vals.add(detected_angle); // angle
    // 4 return_vals.add(img.height); // converted small img's
    // 5 return_vals.add(img.width);
    // 6 return_vals.add(vertical_maxArea_list); // vertical area
    // 7 return_vals.add(XareaPoints); // horizontal area
    // 8 return_vals.add(is_to_rotate180); //  is_to_rotate180
    // 9 return_vals.add(stick_x_points); // 9. stick x points

    await Future.delayed(Duration(milliseconds: 1));

    imglib.Image original_img = result_list[2];
    double angle = result_list[3];

    bool is_rotated180 = result_list[8]; // it's force true

    imglib.Image img = imglib.copyRotate(original_img, angle,
        interpolation: imglib.Interpolation.linear);

    int x = ((img.width - original_img.width) / 2).toInt();
    int y = ((img.height - original_img.height) / 2).toInt();

    img = imglib.copyCrop(img, x, y, original_img.width, original_img.height);

    // 나중에 넣어야 하는 영역 // 미리 확인 과정
    //List stick_check_result = Detail_Check_stick().get_stick_detail_img(img, result_list[4],result_list[6],result_list[7], result_list[9]);
    // img = Detail_Check_stick().get_stick_detail_img(img, result_list[4],result_list[6],result_list[7], result_list[9]);

    // compensate stick area
    int x_compensate = Detail_Check_stick().get_stick_compensate(
        img, result_list[4], result_list[6], result_list[7], result_list[9]);

    // img = JImgProc().JDrawMarks(img, result_list[4], result_list[6],
    //     result_list[7], result_list[9], 0,is_rotated180, color: Colors.cyan);

    //  copy image: make backup img
    imglib.Image backup_img = imglib.copyRotate(img, 360);

    // draw mark 네모 만들기
    List returnResult = JImgProc().JDrawMarks(
        img,
        result_list[4],
        result_list[6],
        result_list[7],
        result_list[9],
        x_compensate,
        is_rotated180,
        color: Colors.cyan,
        is_checking_find_area_well: false);

    // get return value ------- from JDrawMarks
    img = returnResult[0]; // rec marked img
    int color_area_width = returnResult[1];
    List<Vector2d> compareRect_pos_list = returnResult[2];
    List<Vector2d> stickRect_pos_list = returnResult[3];

    // get colors list from img --- for searching result ----------------
    List<Area_color_sets> compareRect_area_colorSets_list =
        SearchingResult_subs().get_colorAreas_fromImg(
            backup_img, compareRect_pos_list, color_area_width, false);
    List<Area_color_sets> stickRect_area_colorSets_list = SearchingResult_subs()
        .get_colorAreas_fromImg(
            backup_img, stickRect_pos_list, color_area_width, true);

    double compensate_angle = 90;

    //juje: 이 부분 스태틱으로 빼라
    img = imglib.copyRotate(
        (testStatics.is_showing_picture_no_marked) ? backup_img : img,
        compensate_angle,
        interpolation: imglib.Interpolation.linear);

    List<int> jpeg = imglib.encodeJpg(img, quality: 92);

    // make return result
    returnResult = [];
    returnResult.add(jpeg); // rec marked img
    returnResult.add(compareRect_area_colorSets_list);
    returnResult.add(stickRect_area_colorSets_list);
    returnResult.add(backup_img); // origina stick img: imglib.Image


    return returnResult;
  }
}
