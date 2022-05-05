import 'dart:typed_data';

import 'package:swork_raon/TestModule/image_process_test_module/forData/JArea.dart';

class Check_stick {
  bool is_stick_too_close_outline(
      int height, int width, List<int> XareaPoints) {
    int endX_point =
        XareaPoints[10] + ((XareaPoints[10] - XareaPoints[9]) * 0.65).round();

    if (endX_point >= width)
      return true;
    else
      return false;
  }

  check_fitted(Uint8List stickIMG, int height, int width,
      List<JArea> JAreaList_ys, List<int> XareaPoints) {
    Uint8List thresholded_img = Uint8List(stickIMG.length);

    int y1 = JAreaList_ys[1].end_pos;
    int y2 = JAreaList_ys[2].start_pos;

    int rec_width = JAreaList_ys[1].end_pos - JAreaList_ys[1].start_pos;

    int centerY_stick = ((y1 + y2) / 2).toInt(); // 기준 탐색선

    int endX_point =
        XareaPoints[10] + ((XareaPoints[10] - XareaPoints[9]) * 0.65).round();

    int target_bg_color = 0;
    int count = 0;

    int gap = y2 - y1;

    for (int i = y1 + (gap * 0.4).toInt(); i < y2 - gap * 0.4; i++) {
      if (stickIMG[i * width + endX_point] == 0) continue;

      target_bg_color += stickIMG[i * width + endX_point];
      count++;
    }

    target_bg_color = (target_bg_color / count - 30).toInt();

    // 이미지 만들기
    for (int i = 0; i < height; i++) {
      for (int j = 0; j < width; j++) {
        if (stickIMG[i * width + j] > target_bg_color) {
          thresholded_img[i * width + j] = 255;
        } else {
          thresholded_img[i * width + j] = 0;
        }

        if (j == endX_point || j == XareaPoints[10] + (rec_width * 0.1).round())
          thresholded_img[i * width + j] = 188;
      }
    }

    int search_startX = XareaPoints[10] + (rec_width * 0.05).round();
    int search_endX = endX_point;

    int black_pixel_count = 0;
    int searched_count = 0;
    for (int j = search_startX; j <= search_endX; j++) {
      int val1 = thresholded_img[centerY_stick * width + j];
      int val2 = thresholded_img[(centerY_stick - 1) * width + j];
      int val3 = thresholded_img[(centerY_stick + 1) * width + j];
      int val4 = thresholded_img[(centerY_stick - 2) * width + j];
      int val5 = thresholded_img[(centerY_stick + 2) * width + j];

      if (val1 == 0 || val2 == 0 || val3 == 0 || val4 == 0 || val5 == 0) {
        black_pixel_count++;
      }

      searched_count++;
    }

    double black_ratio = black_pixel_count * 1.0 / searched_count;
    if (black_ratio > 0.28) {
      print("black ratio:::: " + black_ratio.toString());
      print("스틱 배치 오류!!!!");
      // JToast().show_toast("스틱 배치 오류", true);
      return null;
    }

    print(search_endX - search_startX);
    print("black ratio:::: " + black_ratio.toString());
    print("black pixel count:::: " + black_pixel_count.toString());

    return thresholded_img;
  }

  // 축소된 버전
  List<int> get_stick_x_points(List<int> XareaPoints) {
    List<int> stick_x_porints = [];

    // find start point
    int gap = XareaPoints[5] - XareaPoints[4];
    int startPoint = (XareaPoints[4] + gap * 0.91).toInt(); // 스틱과 배색표 위치에 의존적

    // find end point
    gap = XareaPoints[10] - XareaPoints[9];
    int endPoint = (XareaPoints[9] + gap * 0.8).toInt(); // 스틱과 배색표 위체에 의존적

    int total_gap = endPoint - startPoint;
    double av_gap = total_gap / 6.0;

    for (int i = 0; i < 7; i++) {
      stick_x_porints.add((startPoint + av_gap * i).round());
    }

    return stick_x_porints;
  }
}
