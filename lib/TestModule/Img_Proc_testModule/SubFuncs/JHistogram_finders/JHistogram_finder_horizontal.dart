import 'dart:typed_data';

import 'package:flutter/material.dart';
import '../../../../0_CommonThisApp/MakeOrder_inList.dart';

import '../forData/JArea.dart';

class JHistogram_finder_horizontal {

  // 0. 히스토그램 영상 만들기
  Uint8List projection_horizontal(Uint8List bytesIn, int height, int width) {

    Uint8List bytesOut = Uint8List(bytesIn.length);
    List<int> projections = List<int>(height);

    // 1. voting
    for (int i = 0; i < height; i++) {
      projections[i] = 0;

      for (int j = 0; j < width; j++) {
        if (bytesIn[i * width + j] > 128) projections[i]++;
      }
    }

    // 2.make img by voting
    for (int i = 0; i < height; i++) {
      for (int j = 0; j < projections[i]; j++) {
        bytesOut[i * width + j] = 255;
      }
    }

    return bytesOut;
  }

  // 1.1 horizontal projection 된 히스토그램에서  가운데 50% 영역 에서 3번째 최대값(산)의 0.7 리턴 ======================================
  // 3 번째 값을 쓰는 이유는 스틱 양옆으로 찐한 에지가 생길 확률이 있음.
  get_searchinPointX1(Uint8List byteIn, int height, int width) {
    int max_x = _get_third_highestPoint(byteIn, height, width);
    return (max_x * 0.7).toInt();
  }

  get_searchinPointX2(int searchingPoint_X1) {
    // 원래는 최대값의 1/7 이므로 , 굳이 한 번 더 계산할 필요가 없음.
    return (searchingPoint_X1 / 0.7 / 7).toInt();
  }

  _get_third_highestPoint(Uint8List byteIn, int height, int width) {
    int max_x = 0;
    int max_y = -1;

    int heightArea1 = (height / 4).toInt();
    int heightArea2 = (height * 3 / 4).toInt();

    int gap_standard = (height * 0.08).toInt();

    for (int i = heightArea1; i <= heightArea2; i++) {
      int preIndex = i * width;

      for (int j = 0; j < width; j++) {
        if (byteIn[preIndex + j] == 255) {
          if (j > max_x) {
            max_x = j;
            max_y = i;
          }
        }
      }
    }

    max_x = 0;
    int max_y2 = -1;

    // second searching
    for (int i = heightArea1; i < heightArea2; i++) {
      int preIndex = i * width;

      for (int j = 0; j < width; j++) {
        int yGap = max_y - i;
        if (yGap < 0) yGap = -yGap;

        if (yGap < gap_standard) continue;

        if (byteIn[preIndex + j] == 255) {
          if (j > max_x) {
            max_x = j;
            max_y2 = i;
          }
        }
      }
    }

    // third searching
    max_x = 0;

    for (int i = heightArea1; i < heightArea2; i++) {
      int preIndex = i * width;

      for (int j = 0; j < width; j++) {
        int yGap = max_y - i;
        if (yGap < 0) yGap = -yGap;

        int yGap2 = max_y2 - i;
        if (yGap2 < 0) yGap2 = -yGap2;

        if (yGap < gap_standard || yGap2 < gap_standard) continue;

        if (byteIn[preIndex + j] == 255) {
          if (j > max_x) {
            max_x = j;
          }
        }
      }
    }

    return max_x;
  }

  // 히스토그램 영상에서 골(짜기)를 찾을 수 있음.
  get_valley_points_byVertical(
      byteIn, height, width, int searchinPointX1, bool is_to_print) {
    List result = _make_histoGroups(byteIn, height, width, searchinPointX1);
    List<int> histoGroupss = result[0];
    List<int> histoGroups_pointsY = result[1];

    if (is_to_print) {
      for (int i = 0; i < histoGroupss.length; i++) {
        print(histoGroupss[i]);
      }
    }

    // 2. 조건에 만족하는 골(짜기)의 중앙에 표시를 해주자.
    List<int> valleys = List<int>();

    for (int i = 1; i < histoGroupss.length - 1; i++) {
      int previous_group = histoGroupss[i - 1];
      int current_group = histoGroupss[i];
      int next_group = histoGroupss[i + 1];

      if (previous_group > 0 && next_group > 0 && current_group < 0) {
        // 골짜기로 판단됨
        if (-current_group > previous_group * 2 &&
            -current_group > next_group * 2) {
         // print(current_group);

          // 후보 골짜기임.
          int valley_pointY =
              ((histoGroups_pointsY[i] + histoGroups_pointsY[i - 1]) / 2)
                  .toInt();
          valleys.add(valley_pointY);
        }
      }
    }

    print(valleys.length);
    return valleys;
  }

  get_vertical_samples_area(Uint8List bytesIn, height, width,
      int searchinPointX2, List<int> valleys) {
    // 화소가 연결된 최대 5개를 찾음 (조건: 1. 연결되어야함 2. 골짜기를 포함해야함)

    List result = _make_histoGroups(bytesIn, height, width, searchinPointX2);
    List<int> histoGroupss = result[0];
    List<int> histoGroups_pointsY = result[1];

    Uint8List flags = Uint8List(bytesIn.length);
    List<int> maxGroups = List<int>();

    while (true) {
      int max_i = -1;
      int max_val = 0;

      for (int i = 1; i < histoGroupss.length - 1; i++) {
        int previous = histoGroupss[i - 1];
        int current = histoGroupss[i];
        int next = histoGroupss[i + 1];

        if (current > 0 && previous < 0 && next < 0 && flags[i] == 0) {
          if (current > max_val) {
            // 골짜기를 포함하는지?
            bool is_having_valley = false;
            for (int t = 0; t < valleys.length; t++) {
              if (histoGroups_pointsY[i - 1] < valleys[t] &&
                  valleys[t] < histoGroups_pointsY[i]) {
                is_having_valley = true;
                t = 10000;
                continue;
              }
            }

            if (is_having_valley) {
              max_val = current;
              max_i = i;
              i = 10000; // 계산량을 줄이자.
              continue;
            }
          }
        }
      }

      // 변경이 없으면,
      if (max_i == -1) {
        break;
      } else {
        maxGroups.add(max_i);
        flags[max_i] = 1;
      }
    }
    print("maxGroups");
    print(maxGroups.length);

    // max groups to JArea list

    List<JArea> max_JAreaLists = new List<JArea>();
    for (int i = 0; i < maxGroups.length; i++) {
      int targetIndex = maxGroups[i];
      JArea this_area = new JArea();
      this_area.start_pos = histoGroups_pointsY[targetIndex - 1];
      this_area.end_pos = histoGroups_pointsY[targetIndex];
      max_JAreaLists.add(this_area);
    }

    return max_JAreaLists;
  }

  analyze_maxAreas(int height, List<JArea> maxArea_list) {
    // result 0: true/false, 1: msg
    List result = [];

    maxArea_list = _normalize_maxArea(maxArea_list);
    print("after normalize: " + maxArea_list.length.toString());

    // case 1. 4개 미만이면 실패
    if (maxArea_list.length < 4) {
      result.add(false);
      result.add("case1: The count of max-Area should be larger than 3");
      return result;
    }

    // case 2. 6개 이상이면 실패
    if (maxArea_list.length >= 6) {
      result.add(false);
      result.add("case2: The count of max-Area should be less than 6");
      return result;
    }

    // case3. 5개이면 가운데 놈을 지운다.
    maxArea_list= _remove_centerArea(maxArea_list);
    print("after remove center: " + maxArea_list.length.toString());

    // 가운데를 지워서 4개가 되면 패스~
    if(maxArea_list.length==4){

      // 마지막 신뢰도::  2번째 3번째 사이의 거리가 평균 넓이의 1.5배 이상되어야함.
      maxArea_list=MakeOrder_inList().makekOrder_byStartPos(maxArea_list);
      int width_average = _get_JAread_width_averate(maxArea_list);

      if(_last_creditTest(maxArea_list, width_average)){
        result.add(true);
        result.add("good job");
        result.add(maxArea_list);
      }else{
        result.add(false);
        result.add("case3: found wrong groups!");
      }

    }else{
      result.add(false);
      result.add("unknown reason");
    }

    return result;
  }

  _remove_centerArea(List<JArea> maxArea_list) {
    int minStartPos = 9999;
    int maxEndPos = -1;

    for (int i = 0; i < maxArea_list.length; i++) {
      if (maxArea_list[i].start_pos < minStartPos) {
        minStartPos = maxArea_list[i].start_pos;
      }
      if (maxArea_list[i].end_pos > maxEndPos) {
        maxEndPos = maxArea_list[i].end_pos;
      }
    }

    int centerPoint = ((maxEndPos + minStartPos) / 2).toInt();

    List<JArea> new_maxArea_list = [];

    for (int i = 0; i < maxArea_list.length; i++) {
      if (maxArea_list[i].start_pos < centerPoint &&
          centerPoint < maxArea_list[i].end_pos) {
        // remove
      }else{
        new_maxArea_list.add(maxArea_list[i]);
      }
    }

    return new_maxArea_list;
  }

  _normalize_maxArea(List<JArea> maxArea_list) {
    // max area 중간값을 가져오자
    List<int> maxArea_width_list = [];

    for (int i = 0; i < maxArea_list.length; i++) {
      int width = maxArea_list[i].end_pos - maxArea_list[i].start_pos;
      maxArea_width_list.add(width);
    }

    maxArea_width_list = MakeOrder_inList().makeOrder_byMax(maxArea_width_list);

    int medium_index = ((maxArea_width_list.length - 1) / 2.0).toInt();

    int medium_width = maxArea_width_list[medium_index];

    // 중간값의 18% 이상 오차가 있으면 안 됨.
    int max_width = (medium_width * 1.18).toInt();
    int min_width = (medium_width * 0.82).toInt();

    List<JArea> new_maxArea_list = [];

    for (int i = 0; i < maxArea_width_list.length; i++) {
      int width = maxArea_list[i].end_pos - maxArea_list[i].start_pos;
      if (width <= max_width && width >= min_width) {
        new_maxArea_list.add(maxArea_list[i]);
      }
    }

    return new_maxArea_list;
  }

  _make_histoGroups(bytesIn, height, width, int searchinPointX) {
    int lastVal = -1;
    int count = 0;

    List<int> histoGroupss = List<int>();
    List<int> histoGroups_pointsY = List<int>();

    // 해당 라인을 탐색하면서 색이 변하는 영역을 -와 +로 구분하여 그룹화 ====================================
    for (int i = 0; i < height; i++) {
      int thisVal = bytesIn[i * width + searchinPointX].toInt();
      if (thisVal != lastVal && i != 0) {
        if (thisVal == 255) count = -count;

        histoGroupss.add(count);
        histoGroups_pointsY.add(i);

        count = 1;
      } else if (i == height - 1) {
        if (thisVal == 0) count = -count;

        histoGroupss.add(count);
        histoGroups_pointsY.add(i);
      } else {
        count++;
      }

      lastVal = thisVal;
    }

    List result = new List();
    result.add(histoGroupss);
    result.add(histoGroups_pointsY);

    return result;
  }

  _get_JAread_width_averate(List<JArea> JAreaLists){

    int sum = 0;

    for(int i=0; i<JAreaLists.length; i++){
      int gap = JAreaLists[i].end_pos - JAreaLists[i].start_pos;
      sum+=gap;
    }

    return (sum/JAreaLists.length).toInt();
  }

  _last_creditTest(List<JArea> maxArea_list, int average_width){
    int point1 = ((maxArea_list[1].end_pos + maxArea_list[1].start_pos)/2).toInt();
    int point2 = ((maxArea_list[2].end_pos + maxArea_list[2].start_pos)/2).toInt();

    if(point2-point1 > average_width*1.5) return true;
    else return false;
  }

  // 서칭라인에 다른색깔 표시해서 보자
  Uint8List check_searchingX_img(
      Uint8List byteIn, int height, int width, int searcing_x) {
    Uint8List bytesOut = Uint8List(byteIn.length);

    for (int i = 0; i < height; i++) {
      for (int j = 0; j < width; j++) {
        if (j == searcing_x) {
          bytesOut[i * width + j] = 128;
        } else {
          bytesOut[i * width + j] = byteIn[i * width + j];
        }
      }
    }

    return bytesOut;
  }

  Uint8List check_valleys_img(
      Uint8List bytesIn, int height, int width, List<int> valleys) {
    Uint8List bytesOut = Uint8List(bytesIn.length);

    for (int i = 0; i < height; i++) {
      for (int j = 0; j < width; j++) {
        if (valleys.contains(i)) {
          bytesOut[i * width + j] = 128;
        } else {
          bytesOut[i * width + j] = bytesIn[i * width + j];
        }
      }
    }

    return bytesOut;
  }

  Uint8List check_areas_in_img(
      Uint8List bytesIn, int height, int width, List<JArea> maxArea_list) {
    List<int> pointLists = _JAreaList_to_intList(maxArea_list);
    Uint8List bytesOut = Uint8List(bytesIn.length);

    for (int i = 0; i < height; i++) {
      for (int j = 0; j < width; j++) {
        if (pointLists.indexOf(i) != -1) {
          bytesOut[i * width + j] = 128;
        } else {
          bytesOut[i * width + j] = bytesIn[i * width + j];
        }
      }
    }

    return bytesOut;
  }

  _JAreaList_to_intList(List<JArea> JAreaList) {
    List<int> intList = new List<int>();

    for (int i = 0; i < JAreaList.length; i++) {
      intList.add(JAreaList[i].start_pos);
      intList.add(JAreaList[i].end_pos);
    }

    return intList;
  }

  // 1.x test for display: horizontal projection 된 히스토그램에서  가운데 50% 영역 에서 최고점 찾기
  Uint8List focus_on_center_test(Uint8List byteIn, int height, int width) {
    Uint8List bytesOut = Uint8List(byteIn.length);

    for (int i = 0; i < height; i++) {
      for (int j = 0; j < width; j++) {
        if (i <= height / 4 || i >= height * 3 / 4) {
          bytesOut[i * width + j] = 0;
        } else {
          bytesOut[i * width + j] = byteIn[i * width + j];
        }
      }
    }

    return bytesOut;
  }

  // 2.1
  List search_vertical_area(Uint8List byteIn, int height, int width,
      int searchingX, bool is_to_print) {
    List returnVal = List();
    /*
    *
    * return val
    * 1. success (bool)
    * 2. msg
    * 3. max jarea list 1
    * 4. max jarea list 2
    *
    * */

    int lastVal = -1;
    int count = 0;

    List<int> histoGroupss = List<int>();
    List<int> histoGroups_pointsY = List<int>();

    // 1. 해당 라인을 탐색하면서 색이 변하는 영역을 -와 +로 구분하여 그룹화 ====================================
    for (int i = 0; i < height; i++) {
      int thisVal = byteIn[i * width + searchingX].toInt();
      if (thisVal != lastVal && i != 0) {
        if (thisVal == 255) count = -count;

        histoGroupss.add(count);
        histoGroups_pointsY.add(i);

        count = 1;
      } else if (i == height - 1) {
        if (thisVal == 0) count = -count;

        histoGroupss.add(count);
        histoGroups_pointsY.add(i);
      } else {
        count++;
      }

      lastVal = thisVal;
    }

    // 2. 최대값 그룹 영역 찾기 1/2 =============================================================================
    int max_sum = 0;
    int max_i_1 = _get_max_histoGroup(histoGroupss);
    int max_i_2 = _get_max_histoGroup(histoGroupss, exclude_index: max_i_1);

    if (max_i_1 == -1 || max_i_2 == -1) {
      print("case1: 2개의 최대값 영역을 찾 을 수 없음.. in search_vertical_area");
      // 예외처리
      returnVal.add(false);
      returnVal.add("no area");
      return returnVal;
    }

    // 3. area 로 받아오기
    List<JArea> area1_list = get_maxArea(histoGroups_pointsY, max_i_1);
    List<JArea> area2_list = get_maxArea(histoGroups_pointsY, max_i_2);

    // 3-2. area 영역 비교
    int area1_gap = area1_list[2].end_pos - area1_list[0].end_pos;
    int area2_gap = area2_list[2].end_pos - area2_list[0].end_pos;

    int gap = area2_gap - area1_gap;
    if (gap < 0) gap = -gap;

    if (gap > 6) {
      print("case2: 2개의 최대값 영역 차이가 큼.. in search_vertical_area");
      returnVal.add(false);
      returnVal.add("big gap");
      // 예외처리
      return returnVal;
    }

    // print for checking ------------------------
    if (is_to_print) {
      for (int i = 0; i < histoGroupss.length; i++) {
        if (max_i_1 == i) print("여기서 부터 최대값 1!");
        if (max_i_2 == i) print("여기서 부터 최대값 2!");

        print(histoGroupss[i]);
      }

      for (int i = 0; i < area1_list.length; i++) {
        area1_list[i].print_area();
      }
      for (int i = 0; i < area2_list.length; i++) {
        area2_list[i].print_area();
      }
    }

    print("gap between groups: " + gap.toString());

    returnVal.add(true);
    returnVal.add("good job");
    returnVal.add(area1_list);
    returnVal.add(area2_list);

    return returnVal;
  }

  int _get_max_histoGroup(List<int> histoGroupss, {int exclude_index = -1}) {
    int max_sum = 0;
    int max_i = -1;

    for (int i = 1; i < histoGroupss.length - 5; i++) {
      if (i == exclude_index) continue;

      // - 영역에서 시작해서 - 영역으로 끝날 것.
      if (histoGroupss[i - 1] < 0 && histoGroupss[i + 5] < 0) {
        // 반드시 2개의 -값이 포함될 것
        if (histoGroupss[i + 1] < 0 &&
            histoGroupss[i + 1] > -5 &&
            histoGroupss[i + 3] < 0 &&
            histoGroupss[i + 3] > -5) {
          int sum = 0;
          for (int t = 0; t < 5; t++) {
            sum += histoGroupss[i + t];
          }

          if (sum > max_sum) {
            max_sum = sum;
            max_i = i;
          }
        }
      }
    }

    return max_i;
  }

  List<JArea> get_maxArea(List<int> histoGroups_pointsY, int max_i) {
    List<JArea> jarea_list = List<JArea>();

    JArea jarea = new JArea();
    jarea.start_pos = histoGroups_pointsY[max_i - 1];
    jarea.end_pos = histoGroups_pointsY[max_i];
    jarea_list.add(jarea);

    jarea = new JArea();
    jarea.start_pos = histoGroups_pointsY[max_i + 1];
    jarea.end_pos = histoGroups_pointsY[max_i + 2];
    jarea_list.add(jarea);

    jarea = new JArea();
    jarea.start_pos = histoGroups_pointsY[max_i + 3];
    jarea.end_pos = histoGroups_pointsY[max_i + 4];
    jarea_list.add(jarea);

    return jarea_list;
  }

  // 3. remove stick and bg area
  Uint8List remove_stickArea_and_bg(Uint8List byteIn, int height, int width,
      List<JArea> maxAreaList, int targetSample_index){

    Uint8List bytesOut = Uint8List(byteIn.length);

    for(int j=0; j<width; j++){
      for(int t =targetSample_index; t<targetSample_index+1; t++){

        int gap = maxAreaList[t].end_pos - maxAreaList[t].start_pos;

        for(int i=(maxAreaList[t].start_pos+gap*0.2).toInt(); i<=maxAreaList[t].end_pos; i++){
          int index= i*width+j;
          bytesOut[index] = byteIn[index];
        }

        // 사각형(에지) 윗 부분을 가로선으로 대치
        for(int i=maxAreaList[t].start_pos; i<=(maxAreaList[t].start_pos+gap*0.2).toInt(); i++){
          bytesOut[i*width+j] = byteIn[(i+gap*0.4).toInt()*width+j];
        }
      }
    }

    return bytesOut;
  }

  Uint8List OLDremove_stickArea_and_bg(Uint8List byteIn, int height, int width,
      List<JArea> area1, List<JArea> area2) {
    Uint8List bytesOut = Uint8List(byteIn.length);

    if (area1[0].start_pos > area2[0].start_pos) {
      // change
      List<JArea> area3 = area1;
      List<JArea> area4 = area2;

      area2 = area3;
      area1 = area4;
    }

    for (int i = 0; i < height; i++) {
      for (int j = 0; j < width; j++) {
        if (i < area1[0].start_pos ||
            i > area2[2].end_pos ||
            (i > area1[2].end_pos && i < area2[0].start_pos)) {
          bytesOut[i * width + j] = 0;
        } else {
          int index = i * width + j;
          bytesOut[index] = byteIn[index];
        }
      }
    }

    return bytesOut;
  }

  // 4. Vertical projection & find
  get_searcingAreaY(
      List<JArea> JAreaList1_byHeight, List<JArea> JAreaList2_byHeight) {
    int sum = 0;

    for (int i = 0; i < 3; i++) {
      int gap1 =
          JAreaList1_byHeight[i].end_pos - JAreaList1_byHeight[i].start_pos;
      int gap2 =
          JAreaList2_byHeight[i].end_pos - JAreaList2_byHeight[i].start_pos;

      sum = sum + gap1 + gap2;
    }

    int searchingLine_y = (sum / 6.0 * 1.2).toInt();
    return searchingLine_y;
  }

  check_img_searchingLineY(
      Uint8List bytesIn, int height, int width, int searchingLine_y) {
    Uint8List bytesOut = Uint8List(bytesIn.length);

    for (int i = 0; i < height; i++) {
      for (int j = 0; j < width; j++) {
        int index = i * width + j;

        if (i == searchingLine_y) {
          bytesOut[index] = 128;
        } else {
          bytesOut[index] = bytesIn[index];
        }
      }
    }

    return bytesOut;
  }
}
