import 'package:flutter/material.dart';
import 'package:image/image.dart' as imglib;
import 'package:swork_raon/TestModule/Img_Proc_testModule/SubFuncs/JHistogram_finders/JHistogram_finder_vertical.dart';
import 'package:swork_raon/TestModule/Img_Proc_testModule/SubFuncs/forData/JArea.dart';
import 'dart:typed_data';

import '../JImgProc.dart';

class Detail_Check_stick {



 // List get_stick_detail_img(
  int  get_stick_compensate(
    imglib.Image img,
    int height_of_testIMG,
    List<JArea> JAreaList_ys,
    List<int> XareaPoints,
    List<int> StickArea_pointsX,
  ) {

    /*
    *
    * */
    // preview 테스트는 이미지 높이 178로 축소하여 진행.
    // 일괄적인 알고리즘 적용을 위해 프레임 원 이미지를 높이 480으로 축소(or 확대)하여 알고리즘 진행
    // 디바이스마다 프레임 이미지의 높이/넓이 다르다

    // 1. 동일 알고리즘 적용 위해 크기 통일
    img = imglib.copyResize(img, height: 480); // w > h
    double scale = img.height / height_of_testIMG;

    // 2. stick center y  찾자.
    int stick_centerY =
        ((JAreaList_ys[2].start_pos + JAreaList_ys[1].end_pos) / 2).toInt();

    // 3. stick area y 찾자
    stick_centerY = (stick_centerY * scale).round();

    // 4. imglib.img to gray arrayllist
    JImgProc jimg_proc = JImgProc();
    Uint8List bytesGray = jimg_proc.Jgrayscale(img);
    Uint8List bytesNew = Uint8List(bytesGray.length);

    // 5. extract stick image 이미지 영역 추출
    int height = img.height;
    int width = img.width;

    double y1 = JAreaList_ys[1].end_pos * scale;
    double y2 = JAreaList_ys[2].start_pos * scale;
    double gap = y2 - y1;

    int stick_area_h = ((y2 - gap * 0.3) - (y1 + gap * 0.3)).toInt();

    for (int i = 0; i < height; i++) {
      for (int j = 0; j < width; j++) {
        // real stick area

        if (i >= y1 + gap * 0.3 && i <= y2 - gap * 0.3) {
          int index = i * width + j;
          bytesNew[index] = bytesGray[index];
        }
      }
    }

    // make it bright: max val pixel 188 --> make 188 to 256
    bytesNew = JHistogram_finder_vertical()
        .bg_flattening(bytesNew, img.height, img.width);

    List results1 = _get_exact_x_point(StickArea_pointsX[2], scale, stick_area_h, stick_centerY, height, width, bytesNew);
    print("!!!!!!!!!!!!!!!!!!");
    List results2 = _get_exact_x_point(StickArea_pointsX[5], scale, stick_area_h, stick_centerY, height, width, bytesNew);

    if(results1[0]==true && results2[0]==true){
      double gap = (results1[3]+results2[3])/2;
      print("compensate: "+gap.round().toString());
      return gap.round();
    }else{
      print("compensate: 0");
      return 0;
    }
  }

  List _get_exact_x_point(int pointX, double scale, int stick_area_h,
      int stick_centerY, int height, int width, Uint8List bytesStickonly) {

    // 6. x points n 번째 스틱값 기준 이진화 작업
    // 특정 범위안에서 평균값 검색

    int standard_x = (pointX * scale).toInt();
    int search_r = (stick_area_h / 6).round();
    int count = 0;
    int all_val = 0;

    Uint8List bytesNew = new Uint8List(bytesStickonly.length);

    for (int i = stick_centerY - search_r; i <= stick_centerY + search_r; i++) {
      for (int j = standard_x - search_r; j <= standard_x + search_r; j++) {
        all_val += bytesStickonly[i * width + j];
        count++;
      }
    }

    int av_val = (all_val / count).round();

    // 7. 스틱값에 따라 이진화 개시
    for (int i = 0; i < height; i++) {
      for (int j = 0; j < width; j++) {
        int index = i * width + j;

        if (bytesStickonly[index] == 0) {
          bytesNew[index] = 0;
        }

        if (bytesStickonly[index] < av_val + 20) {
          bytesNew[index] = 0;
        } else {
          bytesNew[index] = 255;
        }
      }
    }

    // 8. 반사 픽셀 보상
    for (int j = standard_x - stick_area_h;
        j < standard_x + stick_area_h;
        j++) {
      int i = stick_centerY;
      int index = i * width + j;

      if (bytesNew[index] == 0 &&
          bytesNew[index + 1] == 255 &&
          bytesNew[index + 2] == 0) {
        bytesNew[index + 1] = 0;
      }

      if (bytesNew[index] == 0 &&
          bytesNew[index + 1] == 255 &&
          bytesNew[index + 2] == 255 &&
          bytesNew[index + 3] == 0) {
        bytesNew[index + 1] = 0;
        bytesNew[index + 2] = 0;
      }
    }


    // 9. 탐색

    int startX = -1;
    int endX =100000;

    // 왼쪽 탐색
    bool is_finded = false;
    for(int j=standard_x; j>=standard_x-stick_area_h; j--){
      int index = stick_centerY*width+j;

      if(bytesNew[index]==255 && is_finded ==false){
        startX =j+1;
        is_finded = true;
        j=-1;
        continue;
      }
    }

    // 오른쪽 탐색
    is_finded = false;
    for(int j=standard_x; j<=standard_x + stick_area_h; j++){
      int index = stick_centerY*width+j;

      if(bytesNew[index]==255 && is_finded ==false){
        endX =j-1;
        is_finded = true;
        j=999999;
        continue;
      }
    }

    JArea jarea = JArea();
    jarea.start_pos = startX;
    jarea.end_pos = endX;

    // 9. check
    print("stick area h::: "+stick_area_h.toString());
    print("one_rec_width:::  " +(endX-startX).toString()); // 스틱 검출네모의 넓이
    print("ratio:: "+ ((endX-startX)/stick_area_h).toString());

    print("origin x:: "+ standard_x.toString());
    print("new x::: "+((endX+startX)/2).round().toString());


    double ratio= (endX-startX)/stick_area_h;
    bool is_success = false;

    if(ratio >= 1.0 && ratio <=1.4){
      is_success =true;
    }

    int newX = ((endX+startX)/2).round();

    List results = [];
    results.add(is_success); // 0. result
    results.add(standard_x); // 1. origin x value
    results.add(newX); // 2. new x value
    results.add(newX-standard_x); // 3. gap
    results.add(bytesNew); // 4. img

    return results;
  }

  // stick x 다시 조정
  List _rearrange_stickXs(int new_stick_x_0, int new_stick_x_5, double scale, List<int> StickArea_pointsX, Uint8List bytesNew, int height, int width){

    List<int> new_stickArea_pointsX = [];

    int total_gap = new_stick_x_5 - new_stick_x_0;

    double one_gap = total_gap/5.0;

    for(int i=0; i<6; i++){
      new_stickArea_pointsX.add(new_stick_x_0 + (one_gap*i).round());
    }

    new_stickArea_pointsX.add((StickArea_pointsX[6]*scale).round());

    //  이미지화
    for(int  i=0; i<height; i++){
      for(int j=0; j<7; j++){

        int x = new_stickArea_pointsX[j];

        int index = i*width +x ;
        bytesNew[index] = 218;
      }
    }

    // 원래 스케일대로
    List<int> new_stickArea_pointsX_original = [];

    for(int i=0; i<new_stickArea_pointsX.length; i++){
      new_stickArea_pointsX_original.add((new_stickArea_pointsX[i]/scale).round());
    }

    List results  = [];

    results.add(new_stickArea_pointsX_original);
    results.add(new_stickArea_pointsX);
    results.add(bytesNew);

    return results;
  }
}
