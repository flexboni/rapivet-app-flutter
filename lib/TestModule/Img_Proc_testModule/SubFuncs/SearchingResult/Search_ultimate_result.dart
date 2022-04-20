import 'package:flutter_icons/flutter_icons.dart';
import 'package:swork_raon/TestModule/First_cameraTest/testStatics.dart';
import 'package:swork_raon/TestModule/Img_Proc_testModule/SubFuncs/SearchingResult/Area_color_sets.dart';
import 'package:swork_raon/TestModule/Img_Proc_testModule/SubFuncs/SearchingResult/Color_int_rgb.dart';
import 'package:swork_raon/TestModule/Img_Proc_testModule/SubFuncs/SearchingResult/Color_lab.dart';
import 'package:swork_raon/TestModule/Img_Proc_testModule/SubFuncs/SearchingResult/Lab_manager.dart';
import 'package:swork_raon/TestModule/Img_Proc_testModule/SubFuncs/SearchingResult/SearchingResult_subs.dart';
import 'package:swork_raon/TestModule/Img_Proc_testModule/SubFuncs/SearchingResult/stickResult_dataset.dart';

enum COMPARE_MODE { LAB_ONLY_USING_AB, LAB_ONLY_USING_LAB, RGB_AND_LAB }

class Search_ultimate_result {
  stickResult_dataset operate_find_ultimate_result() {

    stickResult_dataset result_dataset = stickResult_dataset();

    print(
        " in operate_find_ultimate_result ==================================");

    List<Area_color_sets> compArea_colorSets_list =
        testStatics.compareRect_area_colorSets_list;

    List<Area_color_sets> stickArea_colorSets_list =
        testStatics.stickRect_area_colorSets_list;

    // 1. post process: get rgb, get lab, get vv
    for (int i = 0; i < compArea_colorSets_list.length; i++) {
      compArea_colorSets_list[i].get_values();
      compArea_colorSets_list[i].print_forCheck();
    }

    for (int i = 0; i < stickArea_colorSets_list.length; i++) {
      stickArea_colorSets_list[i].get_values();
      stickArea_colorSets_list[i].print_forCheck();
    }

    List rgb_weight = [];
    // 2. COMPARE -1
    // 2-0. keton:: stick 6  vs  c_rect 10, 3, 2, 1 ,0  / neg, trace, +, ++, +++
    // 2-1. glucose:: stick 5  vs  c_rect 9, 21, 20, 19, 18, 17 / norm., 50, 100, 250, 500, 1000
    // 2-2. Protein:: stick 4 vs c_rect 8, 15, 14,  13, 12 / neg., trace, 30, 100, 500
    // 2-3. Blood:: stick 3 vs c_rect 7, 32, 31, 30,     29, 28 / neg. + ca 5-10, ++ 50, +++300, ca. 5-10, ca. 50, ca. 300
    //                                                   ca. 5-10, ca. 50 모두 29값임. vv로 비교.    ca. 300 은 28값과 비교.
    // 2-4. Nitrite:: stick 2 vs c_rect 6, 25,24 / neg., pos., pos.
    // 2-5. Leukozyten:: stick 1 vs c_rect 5, 41, 40, 39 / neg., ca.25, ca. 75, ca.500
    // 2-6. pH:: stick 0 vs c_rect 4, 37, 36, 35, 34, 33 / 5, 6, 6.5, 7, 8, 9

    // 2-0. kelton (켈톤) ======================================================
    print("\n========== 0. kelton (켈톤) ========");
    int result = _compare_areaColor_normally(
        stickArea_colorSets_list[6],
        compArea_colorSets_list,
        [43,10, 3, 2, 1, 0],
        COMPARE_MODE.LAB_ONLY_USING_AB);
    print("result: " + result.toString() + "\n\n");

    result = result - 1;
    if (result < 0) result = 0;

    result_dataset.keton = result;

    // 2.1 glucose (포도당) ====================================================
    print("\n=========== 1. glucose(포도당) ===============");
    result = _compare_areaColor_normally(
        stickArea_colorSets_list[5],
        compArea_colorSets_list,
        [9, 21, 20, 19, 18, 17],
        COMPARE_MODE.RGB_AND_LAB);
    print("result: " + result.toString() + "\n\n");
    result_dataset.glucose = result;

    // 2.2.  protein (단백질) ===================================================

    // 12, 13번, 붉은 빛 관련 보정
    compArea_colorSets_list[12] = SearchingResult_subs()
        .correction_compare_area_12(compArea_colorSets_list[12]);
    compArea_colorSets_list[13] = SearchingResult_subs()
        .correction_compare_area_12(compArea_colorSets_list[13]);

    // 2.2.1 protein (단백질) -- 1 : full lab 검색에서 최소가
    // compArea_colorSets_list 8 이면 결과값이 8이다.
    print("\n=========== 2.1  protein (단백질) 첫번째 검색 ===============");
    rgb_weight = [
      "1.2, 1.2, 1",
      "1.2, 1.2, 1",
      "1.2, 1.2, 1",
      "1.2, 1.2, 1",
      "1.2, 1.2, 1"
    ];

    result = _compare_areaColor_normally(
        stickArea_colorSets_list[4],
        compArea_colorSets_list,
        [8, 15, 14, 13, 12],
        COMPARE_MODE.LAB_ONLY_USING_LAB,
        rgb_weight: rgb_weight);

    print("result: " + result.toString() + "\n\n");

    // 2.2.2 protein (단백질) -- 2
    print("\n=========== 2.2  protein (단백질) 최종검색 ===============");
    rgb_weight = [
      "1.2, 1.2, 1",
      "1.2, 1.2, 1",
      "1.2, 1.2, 1",
      "1.2, 1.2, 1",
      "1.2, 1.2, 1",
      "1.2, 1.2, 1",
      "1.2, 1.2, 1",
      "1.2, 1.2, 1",
      "1.2, 1.2, 1",
    ];

    result = _compare_areaColor_normally(
        stickArea_colorSets_list[4],
        compArea_colorSets_list,
        [27, 16, 42, 43, 8, 15, 14, 13, 12],
        COMPARE_MODE.LAB_ONLY_USING_AB,
        rgb_weight: rgb_weight);
    result = result - 4;
    if (result < 0) result = 0;
    print("result: " + result.toString() + "\n\n");

    result_dataset.proteinuria = result;

    // 2-3. Blood (잠혈) ======================================================
    print("\n=========== 3. Blood  (잠혈) ===============");
    compArea_colorSets_list[7] = SearchingResult_subs()
        .correction_compare_area_7(compArea_colorSets_list[7]);
    compArea_colorSets_list[29] = SearchingResult_subs()
        .correction_compare_area_29(compArea_colorSets_list[29]);

    rgb_weight = [
      "1.4,1.4,0.1",
      "0.5, 1, 1",
      "1, 1, 1",
      "1, 1, 1",
      "1.2, 1.2, 0.5",
      "1.2, 1.2, 0.5"
    ];
    result = _compare_areaColor_normally(
        stickArea_colorSets_list[3],
        compArea_colorSets_list,
        [7, 32, 31, 30, 29, 28],
        COMPARE_MODE.RGB_AND_LAB,
        rgb_weight: rgb_weight);

    // 가장 가까운 값이 compare 29번 (result: 4)이며 vv로 ca 5-10 /ca 50 구분, vv가 0.4 이상이면 50 이하면 5-10

    if (result == 0 || result == 4) {
      // compare 0 과 4가 너무 비슷하므로... 미세한 r/g 비율로 잡아냄 기준 1.06
      double r_rate = stickArea_colorSets_list[3].av_rgb.r.toDouble() /
          stickArea_colorSets_list[3].av_rgb.g.toDouble();

      //if(r_rate >= 1.06) result =0;
      if(r_rate >= 1) result =0;
      else result =4 ;
    }

    if (result == 4) {
      double vv = stickArea_colorSets_list[3].get_vv();
      if (vv > 0.4) result = 5; // ca 50
    }

    if (result == 5) result = 6;

    result_dataset.blood = result;
    print("result: " + result.toString() + "\n\n");

    // 2-4. Nitrite (아질산염) =================================================
    print("\n=========== 4. Nitrite  (아질산염) ===============");
    result = _compare_areaColor_normally(stickArea_colorSets_list[2],
        compArea_colorSets_list, [16, 26,27, 6, 25, 24], COMPARE_MODE.RGB_AND_LAB);
    print("result: " + result.toString() + "\n\n");

    result = result - 3;
    if (result < 0) result = 0;

    result_dataset.nitrite = result;


    // 2-5. Leukozyten (백혈구) ===============================================
    print("\n=========== 5. Leukozyten (백혈구) ===============");
    rgb_weight = [
      "1, 1, 1",
      "1, 1, 1",
      "1, 1, 1",
      "1.1, 1.1, 1.1",
      "1.1, 1.1, 1.1",
      "1.2, 1.1, 1",
      "1.2, 1.1, 1"
    ];
    // 백혈구 참조 5번, 붉은 빛 관련 보정
    compArea_colorSets_list[5] = SearchingResult_subs()
        .correction_compare_area_5(compArea_colorSets_list[5]);
    // 결과 도출
    result = _compare_areaColor_normally(stickArea_colorSets_list[1],
        compArea_colorSets_list, [16,26,27, 5, 41, 40, 39], COMPARE_MODE.RGB_AND_LAB,
        rgb_weight: rgb_weight);
    result = result - 3;
    if (result < 0) result = 0;
    print("result: " + result.toString() + "\n\n");

    result_dataset.leukocyte = result;

    // 2-6. PH ================================================================
    print("\n=========== 6. ph (ph) ===============");
    rgb_weight = [
      "1.2,1.2,0.8",
      "1.2,1.2,0.8",
      "1.2,1.2,0.8",
      "1.2,1.2,0.8",
      "1.2,1.2,0.8",
      "1.2,1.2,0.8",
    ];

    result = _compare_areaColor_normally(
        stickArea_colorSets_list[0],
        compArea_colorSets_list,
        [4, 37, 36, 35, 34, 33],
        COMPARE_MODE.LAB_ONLY_USING_AB,
        rgb_weight: rgb_weight);
    print("result: " + result.toString() + "\n\n");

    result_dataset.ph = result;

    result_dataset.test_print();

    return result_dataset;
  }


  int _compare_areaColor_normally(
      Area_color_sets stick_area_colorSet,
      List<Area_color_sets> compArea_colorSets_list,
      List<int> compArea_colorSets_index_list,
      COMPARE_MODE compare_mode,
      {List rgb_weight = null}) {
    // get standard value
    Color_int_rgb standard_rgb = stick_area_colorSet.av_rgb;
    Color_lab stndard_lab = stick_area_colorSet.av_lab;

    double min_val = 99999;
    int min_i = -1; //juje

    print("Compare start:: " + stick_area_colorSet.area_name);

    for (int i = 0; i < compArea_colorSets_index_list.length; i++) {
      int this_index = compArea_colorSets_index_list[i];

      Color_int_rgb compare_rgb = compArea_colorSets_list[this_index].av_rgb;
      Color_lab compare_lab = compArea_colorSets_list[this_index].av_lab;

      // weight 넣어주기
      if (rgb_weight != null) {
        String this_rgb_weight_str = rgb_weight[i]; // "1.2, 1.1, 1"
        compare_rgb =
            Color_int_rgb().set_color_weight(this_rgb_weight_str, compare_rgb);
        compare_lab = Lab_manager().rgb2lab(
            compare_rgb.r, compare_rgb.g, compare_rgb.b,
            is_directTo_Color_lab: true);
      }

      double this_compare_val = _get_compareResult(
          compare_mode, standard_rgb, stndard_lab, compare_rgb, compare_lab);

      if (this_compare_val < min_val) {
        min_val = this_compare_val;
        min_i = i;
      }

      print("with " +
          compArea_colorSets_list[this_index].area_name +
          " :  " +
          this_compare_val.toString());
    }

    return min_i;
  }

  double _get_compareResult(
      COMPARE_MODE compare_mode,
      Color_int_rgb standard_rgb,
      Color_lab standard_lab,
      Color_int_rgb compare_rgb,
      Color_lab compare_lab) {
    double rgb_diff =
        Color_int_rgb().Compare_in_double(standard_rgb, compare_rgb);
    double lab_diff_using_ab = Color_lab()
        .compare(COMPARE_MODE.LAB_ONLY_USING_AB, standard_lab, compare_lab);
    double lab_diff_using_lab = Color_lab()
        .compare(COMPARE_MODE.LAB_ONLY_USING_LAB, standard_lab, compare_lab);

    print("rgb diff: " +
        rgb_diff.toString() +
        "   " +
        "lab diff (ab): " +
        lab_diff_using_ab.toString() +
        "   " +
        "lab diff (lab): " +
        lab_diff_using_lab.toString());

    double diff = 0;

    if (compare_mode == COMPARE_MODE.LAB_ONLY_USING_AB) {
      diff = lab_diff_using_ab;
    } else if (compare_mode == COMPARE_MODE.LAB_ONLY_USING_LAB) {
      diff = lab_diff_using_lab;
    } else if (compare_mode == COMPARE_MODE.RGB_AND_LAB) {
      diff = rgb_diff + lab_diff_using_ab;
    }

    return diff;
  }
}
