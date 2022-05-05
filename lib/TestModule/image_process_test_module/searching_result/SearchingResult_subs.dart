import 'package:image/image.dart' as imglib;
import 'package:swork_raon/TestModule/image_process_test_module/searching_result/Lab_manager.dart';
import 'package:swork_raon/TestModule/image_process_test_module/searching_result/color_int_rgb.dart';
import 'package:swork_raon/common/Vector2d.dart';

import 'Area_color_sets.dart';

class SearchingResult_subs {
  /*
  *
  * int color_area_width = returnResult[1];
    List<Vector2d> compareRect_pos_list = returnResult[2];
    List<Vector2d> stickRect_pos_list = returnResult[3];
  *
  * */

  List<Area_color_sets> get_colorAreas_fromImg(imglib.Image img,
      List<Vector2d> pos_list, int color_area_width, bool is_stick_area) {
    final point = img.getBytes();

    int width = img.width;

    int r = (color_area_width / 2).toInt();

    // 0~43 or 0~6, 이 메소드의 궁극적인 리턴값
    List<Area_color_sets> area_color_set_list = [];

    for (int list_i = 0; list_i < pos_list.length; list_i++) {
      Area_color_sets this_area_color_set = Area_color_sets();
      this_area_color_set.area_name = _set_areaName(is_stick_area, list_i);
      print(this_area_color_set.area_name);
      this_area_color_set.is_using = true;

      Vector2d pos = pos_list[list_i];
      int x = pos.x;
      int y = pos.y;

      print("pos: " + x.toString() + "  " + y.toString());

      // 네모가 없는 영역도 색상 구해줌
      // 네모가 없는 영역 구분 위해 10000을 더해줬음.
      if (x >= 10000 || y >= 10000) {
        x = x - 10000;
        y = y - 10000;
        this_area_color_set.is_using = false;
      }

      print("pos(converted): " + x.toString() + "  " + y.toString());

      List<ColorIntRGB> this_area_colors_list = [];

      for (int p = y - r; p <= y + r; p++) {
        for (int t = x - r; t <= x + r; t++) {
          int index = (p * width * 4 + t * 4);

          int r = point[index];
          int g = point[index + 1];
          int b = point[index + 2];

          ColorIntRGB color_rgb = ColorIntRGB(r: r, g: g, b: b);
          this_area_colors_list.add(color_rgb);
        }
      }

      // 범위내 모든 화소들을 입력해줌.
      this_area_color_set.area_colors = this_area_colors_list;
      this_area_color_set.width = this_area_color_set.height = r + r + 1;

      // ...
      //this_area_color_set.get_av_rgb();
      //this_area_color_set.print_av_rgb_forCheck();

      area_color_set_list.add(this_area_color_set);
    }

    return area_color_set_list;
  }

  String _set_areaName(bool is_stick_area, int list_index) {
    if (is_stick_area)
      return "stick_rect_" + list_index.toString();
    else
      return "compare_rect_" + list_index.toString();
  }

  // 개별 보정 영역 ============================================================

  correction_compare_area_7(Area_color_sets target_color_set) {
    int wanted_r = (target_color_set.av_rgb.g.toDouble() * 1.17).toInt();
    if (wanted_r < target_color_set.av_rgb.r) {
      target_color_set.av_rgb.r = wanted_r;
    }

    // lab 다시 얻어서 리턴
    target_color_set.av_lab = _get_lab_from_rgb(target_color_set.av_rgb);
    return target_color_set;
  }

  correction_compare_area_29(Area_color_sets target_color_set) {
    int wanted_r = (target_color_set.av_rgb.g.toDouble() * 1.15).toInt();
    if (wanted_r < target_color_set.av_rgb.r) {
      target_color_set.av_rgb.r = wanted_r;
    }

    // lab 다시 얻어서 리턴
    target_color_set.av_lab = _get_lab_from_rgb(target_color_set.av_rgb);
    return target_color_set;
  }

  correction_compare_area_12(Area_color_sets target_color_set) {
    int wanted_r = (target_color_set.av_rgb.g.toDouble() * 0.84).toInt();
    if (wanted_r < target_color_set.av_rgb.r) {
      target_color_set.av_rgb.r = wanted_r;
    }

    // lab 다시 얻어서 리턴
    target_color_set.av_lab = _get_lab_from_rgb(target_color_set.av_rgb);
    return target_color_set;
  }

  correction_compare_area_13(Area_color_sets target_color_set) {
    int wanted_r = (target_color_set.av_rgb.g.toDouble() * 0.95).toInt();
    if (wanted_r < target_color_set.av_rgb.r) {
      target_color_set.av_rgb.r = wanted_r;
    }

    // lab 다시 얻어서 리턴
    target_color_set.av_lab = _get_lab_from_rgb(target_color_set.av_rgb);
    return target_color_set;
  }

  correction_compare_area_5(Area_color_sets target_color_set) {
    // 백혈구 참조 5번, 붉은 빛 error 관련 보정
    int gap = target_color_set.av_rgb.r - target_color_set.av_rgb.g;
    if (gap > 10) {
      target_color_set.av_rgb.r = target_color_set.av_rgb.g + 10;
    }

    // lab 다시 얻어서 리턴
    target_color_set.av_lab = _get_lab_from_rgb(target_color_set.av_rgb);
    return target_color_set;
  }

  _get_lab_from_rgb(ColorIntRGB rgb) {
    return Lab_manager()
        .rgb2lab(rgb.r, rgb.g, rgb.b, is_directTo_ColorLab: true);
  }
}
