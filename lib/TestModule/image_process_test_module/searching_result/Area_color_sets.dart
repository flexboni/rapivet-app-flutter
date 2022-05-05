import 'package:swork_raon/TestModule/image_process_test_module/searching_result/Lab_manager.dart';
import 'package:swork_raon/TestModule/image_process_test_module/searching_result/color_int_rgb.dart';
import 'package:swork_raon/TestModule/image_process_test_module/searching_result/color_lab.dart';

class Area_color_sets {
  // 처음 생성할 때 자동으로 넣어주는 부분
  String area_name; // ex: compare_0, stick_6

  bool is_using = false;

  List<ColorIntRGB> area_colors;

  int width;
  int height;

  // 수동으로 구해야 하는 부분 - 메소드
  ColorIntRGB av_rgb;
  ColorLab av_lab;
  double vv;

  int pixel_count = 0;

  //  rgb to lab
  // get avrage rgb --ok

  get_values() {
    // if(is_using ==false) return;

    _get_av_rgb();
    _get_av_lab();
  }

  _get_av_rgb() {
    int total_r = 0;
    int total_g = 0;
    int total_b = 0;

    pixel_count = 0;

    for (int i = 0; i < area_colors.length; i++) {
      int r = area_colors[i].r;
      int g = area_colors[i].g;
      int b = area_colors[i].b;

      total_r += r;
      total_g += g;
      total_b += b;

      pixel_count++;
    }

    int _av_r = (total_r / pixel_count).round();
    int _av_g = (total_g / pixel_count).round();
    int _av_b = (total_b / pixel_count).round();

    av_rgb = ColorIntRGB(r: _av_r, g: _av_g, b: _av_b);
  }

  _get_av_lab() {
    int r = av_rgb.r;
    int g = av_rgb.g;
    int b = av_rgb.b;

    List converted_lab = Lab_manager().rgb2lab(r, g, b);
    double lab_l = converted_lab[0];
    double lab_a = converted_lab[1];
    double lab_b = converted_lab[2];

    av_lab = new ColorLab(l: lab_l, a: lab_a, b: lab_b);
  }

  print_forCheck() {
    print("@ " + area_name);
    if (is_using == false) {
      print("no used");
      return;
    }
    print("average RGB in area:::  R: " +
        av_rgb.r.toString() +
        "  G: " +
        av_rgb.g.toString() +
        "  B: " +
        av_rgb.b.toString());

    print("average Lab in area:::  L: " +
        av_lab.l.toString() +
        "  a: " +
        av_lab.a.toString() +
        "  b: " +
        av_lab.b.toString());

    print("infos::: pixel count: " + pixel_count.toString());
    print("infos::: height: " + height.toString());
    print("infos::: width: " + width.toString());
    print(".   ");
  }

  get_vv() {
    double vv_sum = 0;
    int vv_count = 0;

    for (int i = 0; i < height; i++) {
      for (int j = 0; j < width; j++) {
        int center_r = area_colors[i * width + j].r;
        int center_g = area_colors[i * width + j].g;
        int center_b = area_colors[i * width + j].b;

        int rs = 0, gs = 0, bs = 0;
        int count = 0;

        for (int p = i - 1; p <= i + 1; p++) {
          for (int t = j - 2; t <= j + 2; t++) {
            if (p < 0 || t < 0 || p >= height || t >= width) {
              continue;
            }

            if (p == i && j == t) continue;

            int this_r = area_colors[p * width + t].r;
            int this_g = area_colors[p * width + t].g;
            int this_b = area_colors[p * width + t].b;

            rs += this_r;
            gs += this_g;
            bs += this_b;

            count++;
          }
        }

        center_r = center_r * count;
        center_g = center_g * count;
        center_b = center_b * count;

        int gap_r = (center_r - rs).abs();
        int gap_g = (center_g - gs).abs();
        int gap_b = (center_b - bs).abs();

        if (gap_r > 255) gap_r = 255;
        if (gap_g > 255) gap_g = 255;
        if (gap_b > 255) gap_b = 255;

        vv_sum += gap_r.toDouble() / 255 +
            gap_g.toDouble() / 255 +
            gap_b.toDouble() / 255;
        vv_count++;
      }
    }

    double vv = vv_sum.toDouble() / vv_count.toDouble();

    return vv;
  }
}
