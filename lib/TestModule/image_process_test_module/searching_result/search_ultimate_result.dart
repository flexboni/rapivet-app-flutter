import 'package:swork_raon/TestModule/First_cameraTest/testStatics.dart';
import 'package:swork_raon/TestModule/image_process_test_module/searching_result/Area_color_sets.dart';
import 'package:swork_raon/TestModule/image_process_test_module/searching_result/Lab_manager.dart';
import 'package:swork_raon/TestModule/image_process_test_module/searching_result/SearchingResult_subs.dart';
import 'package:swork_raon/TestModule/image_process_test_module/searching_result/color_int_rgb.dart';
import 'package:swork_raon/TestModule/image_process_test_module/searching_result/color_lab.dart';
import 'package:swork_raon/TestModule/image_process_test_module/searching_result/stickResult_dataset.dart';

enum COMPARE_MODE { LAB_ONLY_USING_AB, LAB_ONLY_USING_LAB, RGB_AND_LAB }

class SearchUltimateResult {
  StickResultDataset operateFindUltimateResult() {
    StickResultDataset resultDataset = StickResultDataset();

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
    //                                                   ca. 5-10, ca. 50 ?????? 29??????. vv??? ??????.    ca. 300 ??? 28?????? ??????.
    // 2-4. Nitrite:: stick 2 vs c_rect 6, 25,24 / neg., pos., pos.
    // 2-5. Leukozyten:: stick 1 vs c_rect 5, 41, 40, 39 / neg., ca.25, ca. 75, ca.500
    // 2-6. pH:: stick 0 vs c_rect 4, 37, 36, 35, 34, 33 / 5, 6, 6.5, 7, 8, 9

    // 2-0. kelton (??????) ======================================================
    print("\n========== 0. kelton (??????) ========");
    int result = compareAreaColorNormally(
        stickArea_colorSets_list[6],
        compArea_colorSets_list,
        [43, 10, 3, 2, 1, 0],
        COMPARE_MODE.LAB_ONLY_USING_AB);
    print("result: " + result.toString() + "\n\n");

    result = result - 1;
    if (result < 0) result = 0;

    resultDataset.keton = result;

    // 2.1 glucose (?????????) ====================================================
    print("\n=========== 1. glucose(?????????) ===============");
    result = compareAreaColorNormally(
        stickArea_colorSets_list[5],
        compArea_colorSets_list,
        [9, 21, 20, 19, 18, 17],
        COMPARE_MODE.RGB_AND_LAB);
    print("result: " + result.toString() + "\n\n");
    resultDataset.glucose = result;

    // 2.2.  protein (?????????) ===================================================

    // 12, 13???, ?????? ??? ?????? ??????
    compArea_colorSets_list[12] = SearchingResult_subs()
        .correction_compare_area_12(compArea_colorSets_list[12]);
    compArea_colorSets_list[13] = SearchingResult_subs()
        .correction_compare_area_12(compArea_colorSets_list[13]);

    // 2.2.1 protein (?????????) -- 1 : full lab ???????????? ?????????
    // compArea_colorSets_list 8 ?????? ???????????? 8??????.
    print("\n=========== 2.1  protein (?????????) ????????? ?????? ===============");
    rgb_weight = [
      "1.2, 1.2, 1",
      "1.2, 1.2, 1",
      "1.2, 1.2, 1",
      "1.2, 1.2, 1",
      "1.2, 1.2, 1"
    ];

    result = compareAreaColorNormally(
        stickArea_colorSets_list[4],
        compArea_colorSets_list,
        [8, 15, 14, 13, 12],
        COMPARE_MODE.LAB_ONLY_USING_LAB,
        rgbWeightList: rgb_weight);

    print("result: " + result.toString() + "\n\n");

    // 2.2.2 protein (?????????) -- 2
    print("\n=========== 2.2  protein (?????????) ???????????? ===============");
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

    result = compareAreaColorNormally(
        stickArea_colorSets_list[4],
        compArea_colorSets_list,
        [27, 16, 42, 43, 8, 15, 14, 13, 12],
        COMPARE_MODE.LAB_ONLY_USING_AB,
        rgbWeightList: rgb_weight);
    result = result - 4;
    if (result < 0) result = 0;
    print("result: " + result.toString() + "\n\n");

    resultDataset.proteinuria = result;

    // 2-3. Blood (??????) ======================================================
    print("\n=========== 3. Blood  (??????) ===============");
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
    result = compareAreaColorNormally(
        stickArea_colorSets_list[3],
        compArea_colorSets_list,
        [7, 32, 31, 30, 29, 28],
        COMPARE_MODE.RGB_AND_LAB,
        rgbWeightList: rgb_weight);

    // ?????? ????????? ?????? compare 29??? (result: 4)?????? vv??? ca 5-10 /ca 50 ??????, vv??? 0.4 ???????????? 50 ????????? 5-10

    if (result == 0 || result == 4) {
      // compare 0 ??? 4??? ?????? ???????????????... ????????? r/g ????????? ????????? ?????? 1.06
      double r_rate = stickArea_colorSets_list[3].av_rgb.r.toDouble() /
          stickArea_colorSets_list[3].av_rgb.g.toDouble();

      //if(r_rate >= 1.06) result =0;
      if (r_rate >= 1)
        result = 0;
      else
        result = 4;
    }

    if (result == 4) {
      double vv = stickArea_colorSets_list[3].get_vv();
      if (vv > 0.4) result = 5; // ca 50
    }

    if (result == 5) result = 6;

    resultDataset.blood = result;
    print("result: " + result.toString() + "\n\n");

    // 2-4. Nitrite (????????????) =================================================
    print("\n=========== 4. Nitrite  (????????????) ===============");
    result = compareAreaColorNormally(
        stickArea_colorSets_list[2],
        compArea_colorSets_list,
        [16, 26, 27, 6, 25, 24],
        COMPARE_MODE.RGB_AND_LAB);
    print("result: " + result.toString() + "\n\n");

    result = result - 3;
    if (result < 0) result = 0;

    resultDataset.nitrite = result;

    // 2-5. Leukozyten (?????????) ===============================================
    print("\n=========== 5. Leukozyten (?????????) ===============");
    rgb_weight = [
      "1, 1, 1",
      "1, 1, 1",
      "1, 1, 1",
      "1.1, 1.1, 1.1",
      "1.1, 1.1, 1.1",
      "1.2, 1.1, 1",
      "1.2, 1.1, 1"
    ];
    // ????????? ?????? 5???, ?????? ??? ?????? ??????
    compArea_colorSets_list[5] = SearchingResult_subs()
        .correction_compare_area_5(compArea_colorSets_list[5]);
    // ?????? ??????
    result = compareAreaColorNormally(
        stickArea_colorSets_list[1],
        compArea_colorSets_list,
        [16, 26, 27, 5, 41, 40, 39],
        COMPARE_MODE.RGB_AND_LAB,
        rgbWeightList: rgb_weight);
    result = result - 3;
    if (result < 0) result = 0;
    print("result: " + result.toString() + "\n\n");

    resultDataset.leukocyte = result;

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

    result = compareAreaColorNormally(
        stickArea_colorSets_list[0],
        compArea_colorSets_list,
        [4, 37, 36, 35, 34, 33],
        COMPARE_MODE.LAB_ONLY_USING_AB,
        rgbWeightList: rgb_weight);
    print("result: " + result.toString() + "\n\n");

    resultDataset.ph = result;

    resultDataset.test_print();

    return resultDataset;
  }

  int compareAreaColorNormally(
    Area_color_sets stickAreaColorSet,
    List<Area_color_sets> compAreaColorSetsList,
    List<int> compAreaColorSetsIndexList,
    COMPARE_MODE compareMode, {
    List rgbWeightList,
  }) {
    // get standard value
    ColorIntRGB standardRGB = stickAreaColorSet.av_rgb;
    ColorLab standardLAB = stickAreaColorSet.av_lab;

    double min = 99999;
    int min_i = -1; //juje

    for (int i = 0; i < compAreaColorSetsIndexList.length; i++) {
      int index = compAreaColorSetsIndexList[i];
      ColorIntRGB compareRGB = compAreaColorSetsList[index].av_rgb;
      ColorLab compareLAB = compAreaColorSetsList[index].av_lab;

      // weight ????????????
      if (rgbWeightList != null) {
        compareRGB = ColorIntRGB().setColorWeight(rgbWeightList[i], compareRGB);
        compareLAB = Lab_manager().rgb2lab(
          compareRGB.r,
          compareRGB.g,
          compareRGB.b,
          is_directTo_ColorLab: true,
        );
      }

      double compareValue = getCompareResult(
        compareMode,
        standardRGB,
        standardLAB,
        compareRGB,
        compareLAB,
      );

      if (compareValue < min) {
        min = compareValue;
        min_i = i;
      }
    }

    return min_i;
  }

  double getCompareResult(
    COMPARE_MODE compareMode,
    ColorIntRGB standardRGB,
    ColorLab standardLAB,
    ColorIntRGB compareRGB,
    ColorLab compareLAB,
  ) {
    double rgbDiff = ColorIntRGB().compareInDouble(standardRGB, compareRGB);
    double labDiffUsingAB = ColorLab().compare(
      COMPARE_MODE.LAB_ONLY_USING_AB,
      standardLAB,
      compareLAB,
    );
    double labDiffUsingLAB = ColorLab().compare(
      COMPARE_MODE.LAB_ONLY_USING_LAB,
      standardLAB,
      compareLAB,
    );
    double diff = 0;

    if (compareMode == COMPARE_MODE.LAB_ONLY_USING_AB) {
      diff = labDiffUsingAB;
    } else if (compareMode == COMPARE_MODE.LAB_ONLY_USING_LAB) {
      diff = labDiffUsingLAB;
    } else if (compareMode == COMPARE_MODE.RGB_AND_LAB) {
      diff = rgbDiff + labDiffUsingAB;
    }

    return diff;
  }
}
