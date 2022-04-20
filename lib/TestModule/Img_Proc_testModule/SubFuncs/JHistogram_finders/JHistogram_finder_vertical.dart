import 'package:flutter/material.dart';
import '../../../../0_CommonThisApp/JPosition.dart';
import '../../../../0_CommonThisApp/MakeOrder_inList.dart';
import 'dart:typed_data';
import '../forData/JArea.dart';

class JHistogram_finder_vertical {
  Uint8List projection_horizontal(Uint8List bytesIn, int height, int width) {
    Uint8List bytesOut = Uint8List(bytesIn.length);
    List<int> projections = List<int>(width);

    // 1. voting
    for (int j = 0; j < width; j++) {
      projections[j] = 0;

      for (int i = 0; i < height; i++) {
        if (bytesIn[i * width + j] > 128) projections[j]++;
      }
    }

    // 2.make img by voting
    for (int j = 0; j < width; j++) {
      for (int i = 0; i < projections[j]; i++) {
        bytesOut[i * width + j] = 255;
      }
    }

    return bytesOut;
  }

  find_horizontal_area(Uint8List bytesIn, int height, int width,List<JArea> vertical_maxArea_list, int target_area_index) {

    // 샘플에어리어 버티컬 라인 0번째를 먼저 너며줌.
    try{
      List<int> XareaPoints =  _operate_find_horizontal_area(bytesIn, height,width, vertical_maxArea_list,target_area_index);
      return XareaPoints;
    }catch(e){
      return null;
    }
  }

  _operate_find_horizontal_area(Uint8List bytesIn, int height, int width,List<JArea> vertical_maxArea_list, int area_index) {

    int searching_y =
    ((vertical_maxArea_list[area_index].end_pos - vertical_maxArea_list[area_index].start_pos) *
        0.208) //0.48, 해당값으로 민감도 조정 가능함.
        .toInt();
    int rec_side_width =
        vertical_maxArea_list[area_index].end_pos - vertical_maxArea_list[area_index].start_pos;


    // get average rec_width, gap_width
    int standard_w = (rec_side_width * 0.5).toInt();
    print("standard_w: " + standard_w.toString());

    List result = _make_histoGroups(bytesIn, height, width, searching_y);
    List<int> histoGroupss = result[0];
    List<int> histoGroups_pointsX = result[1];

    List<int> XareaPoints = [];

   // print("................");
    for (int i = 0; i < histoGroupss.length; i++) {
    //  print(histoGroupss[i]);
    }
   // print("................");

    int areaCount = 0;

    for (int i = 1; i < histoGroupss.length - 1; i++) {
      // 1. 골짜기여야 하고
      if (histoGroupss[i - 1] > 0 &&
          histoGroupss[i] < 0 &&
          histoGroupss[i + 1] > 0) {
        // 2. 특정 크기 이상이여야 하고.
        if (histoGroupss[i].abs() >= standard_w) {
          // 3. 필요없는 듯 양옆의 산이 특정 크기 이하여야 하고 (둘중에 하나라도... 붙는 경우가 있드라)
          if (true /*histoGroupss[i - 1].abs() < standard_w ||
              histoGroupss[i + 1].abs() < standard_w*/
          ) {
           // print("후보 영역 검출 1 !!!");

            // 골짜기 영역 가운데 픽셀과 양옆의 최상단에 값이 존재해야함.
            int centerX =
            ((histoGroups_pointsX[i] + histoGroups_pointsX[i - 1]) / 2)
                .toInt();

            if (bytesIn[centerX - 1] == 255 &&
                bytesIn[centerX] == 255 &&
                bytesIn[centerX + 1] == 255) {
             // print("후보 영역 검출 2 !!!");
              XareaPoints.add(centerX);
              areaCount++;
            }
          }
        }
      }
    }

    if(areaCount != 11) return null;

    // 신뢰도 테스트 areaPoints 는 이미 순서대로 정돈됨
    // 각 포인트의 거리가 rec_side_width*1.15를 넘을 수 없음.
    // 화질 엄격도를 어느정도 정할 수 있음.
    bool is_trust = true;

    for (int i = 0; i < XareaPoints.length - 1; i++) {
      int gap = XareaPoints[i + 1] - XareaPoints[i];
      if (gap > rec_side_width * 1.35) {
        print("신뢰도 불합격!!!!");
        is_trust = false;
        i = 10000;
      }
    }

    print("area count: " + areaCount.toString());
    print("is_trust: " + is_trust.toString());

    if(is_trust) return XareaPoints;
    else return null;
  }

  // roughly stick finding ----------------------------------------------------
  Uint8List get_area(Uint8List bytesIn, int height, int width,
      List<JArea> JAreaList_ys, List<int> XareaPoints){

    Uint8List bytesOut = Uint8List(bytesIn.length);

    for(int i=0; i<height; i++){
      for(int j=0; j<width; j++){

          // y로 2번째와 3번째 구역 사이 (스틱이 있어야 하는 자리)
          int y1 = JAreaList_ys[1].end_pos;
          int y2 = JAreaList_ys[2].start_pos;

          int gap= y2-y1;

          if(i>=y1+gap*0.3 && i<=y2-gap*0.3){

            int index= i*width+j;
            bytesOut[index] = bytesIn[index];
          }
      }
    }

    return bytesOut;
  }

  Uint8List bg_flattening(Uint8List bytesIn, int height, int width){
    Uint8List bytesOut = Uint8List(bytesIn.length);

    int max_val = 0;

    // find most bright pixel in img
    for(int i=0; i<height; i++){
      for(int j=0; j<width; j++){
        int val = bytesIn[i*width+j];

        if(val > max_val){
          max_val = val;
        }
      }
    }

    // flattening
    for(int i=0; i<height; i++){
      for(int j =0; j<width; j++){
        int index= i*width+j;

        if(bytesIn[index]==0) continue;

        int targetVal = (bytesIn[index]*255.0/max_val).toInt();
        if(targetVal>255) targetVal = 255;

        bytesOut[index] = targetVal;
      }
    }

    return bytesOut;
  }

  find_lastRec_in_stick(Uint8List bytesIn,List<JArea> JAreaList_ys,List<int> XareaPoints, int height, int width){

    int y1 = JAreaList_ys[1].end_pos;
    int y2 = JAreaList_ys[2].start_pos;
    int gap_by2 = ((y2-y1)/2).toInt();

    bool is_finded_lastRect = false;
    int fg_average=0;

    // xareapoint 6번째와 7번째 사이에 마지막 스틱 검색지가 있다. * 마지막 검색지 네모를 찾는다.
    for(int i=y1+gap_by2; i<y1+gap_by2+1;i++){

        int gap = XareaPoints[6]- XareaPoints[5];
        int targetPoing_x = (XareaPoints[5]+gap*0.7).toInt();

        int sum=0;

        for(int p=-1; p<=1; p++){
          for(int t=-1; t<=1 ; t++){
            sum += bytesIn[(i+p)*width+targetPoing_x+t];
          }
        }

        fg_average = (sum/9).toInt();

        targetPoing_x = XareaPoints[9];

        sum=0;

        for(int p=-1; p<=1; p++){
          for(int t=-1; t<=1 ; t++){
            sum += bytesIn[(i+p)*width+targetPoing_x+t];
          }
        }

        int bg_average =(sum/9).toInt();

       // print(fg_average);
        //print("//////////////////");
        //print(bg_average);

        if(fg_average+40 < bg_average){
          print("finded 1 !!!");
          is_finded_lastRect = true;
        }
    }

    if(is_finded_lastRect== false) return null;

    // 마지막 탐색지 사각형 영역 탐색 ---------------------------------------------
    int searchingY =y1+gap_by2; // 탐색기준   y
    int gap = XareaPoints[6]- XareaPoints[5];
    int searchingX = (XareaPoints[5]+gap*0.7).toInt(); // 탐색기준  x

    // 왼쪽 탐색 -----------
    int leftX = 0;
    for(int j=searchingX; j>=searchingX-gap; j--){
      int this_val = bytesIn[searchingY*width+j];
      int gap_val = this_val-fg_average;
      gap_val = gap_val.abs();

      if(gap_val <20){
        // just pass
      }else{
        leftX = j;
        j=-100; continue;
      }
    }

    // 오른쪽 탐색---------------
    int rightX  = 0;
    for(int j=searchingX; j<= searchingX+gap; j++){
      int this_val = bytesIn[searchingY*width+j];
      int gap_val = this_val-fg_average;
      gap_val = gap_val.abs();

      if(gap_val <20){
        // just pass
      }else{
        rightX = j;
        j=1000000; continue;
      }
    }

   // print("@@@@@@@@@@@@@@@@");
   // print(leftX);
   // print(rightX);

    JPosition jPosition = JPosition();
    jPosition.x = ((rightX+leftX)/2).toInt();
    jPosition.y = searchingY;

    return jPosition;
 }

  // FOR CHECKING --------------------------------------------------------------------------------------------------

  Uint8List check_ultimate_area(Uint8List bytesIn, int height, int width,
      List<JArea> JAreaList_ys, List<int> centerPoint_xs) {
    Uint8List bytesOut = Uint8List(bytesIn.length);

    for (int i = 0; i < height; i++) {
      for (int j = 0; j < width; j++) {
        bytesOut[i * width + j] = bytesIn[i * width + j];
      }
    }

    int oneArea_width = JAreaList_ys[3].end_pos - JAreaList_ys[3].start_pos;

    for (int j = 0; j < width; j++) {
      for (int t = 0; t < JAreaList_ys.length; t++) {

        int start_pos = (JAreaList_ys[t].start_pos+ (oneArea_width*0.5*0.62)).toInt();
        int end_pos =  (JAreaList_ys[t].end_pos - (oneArea_width*0.5*0.62)).toInt();

        int index1 = start_pos * width + j;
        int index2 = end_pos * width + j;

        bytesOut[index1] = 128;
        bytesOut[index2] = 128;
      }
    }

    for (int i = 0; i < height; i++) {
      for (int t = 0; t < centerPoint_xs.length; t++) {
        int index1 = centerPoint_xs[t] - (oneArea_width*0.5*0.38).toInt();
        int index2 = centerPoint_xs[t] + (oneArea_width*0.5*0.38).toInt();

        bytesOut[i*width+index1] = bytesOut[i*width+index2] = 128;
      }
    }

    return bytesOut;
  }

  // for checking -------------
  Uint8List check_searchingX_Line(
      Uint8List bytesIn, int height, int width, int searching_y) {
    Uint8List bytesOut = Uint8List(bytesIn.length);

    for (int i = 0; i < height; i++) {
      for (int j = 0; j < width; j++) {
        if (i == searching_y)
          bytesOut[i * width + j] = 128;
        else
          bytesOut[i * width + j] = bytesIn[i * width + j];
      }
    }

    return bytesOut;
  }

  _make_histoGroups(Uint8List bytesIn, int height, int width, int searching_y) {
    int lastVal = -1;
    int count = 0;

    List<int> histoGroupss = [];
    List<int> histoGroups_pointsX = [];

    // 해당 라인을 탐색하면서 색이 변하는 영역을 -와 +로 구분하여 그룹화 ====================================
    for (int j = 0; j < width; j++) {
      int thisVal = bytesIn[searching_y * width + j];

      if (thisVal != lastVal && j != 0) {
        if (thisVal == 255) count = -count;

        histoGroupss.add(count);
        histoGroups_pointsX.add(j);

        count = 1;
      } else if (j == width - 1) {
        if (thisVal == 0) count = -count;

        histoGroupss.add(count);
        histoGroups_pointsX.add(j);
      } else {
        count++;
      }

      lastVal = thisVal;
    }

    List result = [];
    result.add(histoGroupss);
    result.add(histoGroups_pointsX);

    return result;
  }
}
