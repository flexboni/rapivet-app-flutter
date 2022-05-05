import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';

/*
*
* this method is base on this paper:
* https://scienceon.kisti.re.kr/srch/selectPORSrchArticle.do?cn=JAKO201225067515414&dbt=NART
*
* */

class p_searchAngle {
  double remember_V0;

  double start_search(
      Uint8List in_img,
      int height,
      int width,
      double start_angle,
      double end_angle,
      double plus_angle,
      bool is_have_before_angle,
      double before_angle,
      double before_angle_V0) {
    int search_range_h = (height / 2).toInt() - 3;
    int search_range_w = (width / 2).toInt() - 3;

    int center_y = (height / 2).toInt();
    int center_x = (width / 2).toInt();

    double max_V0 = 0;
    double remember_angle = -1;

    for (double angle = start_angle; angle <= end_angle; angle += plus_angle) {
      // print(angle);
      double this_cos = cos(angle / 57.3);
      double this_sin = sin(angle / 57.3);

      // keeping from re-calculate at same angle.
      if (is_have_before_angle && before_angle == angle) {
        if (before_angle_V0 > max_V0) {
          max_V0 = before_angle_V0;
          remember_angle = angle;
          is_have_before_angle = false;
          continue;
        }
      }

      List<int> Ni = List<int>(search_range_h * 2 + 1);
      int Ni_i = 0;

      for (int i = center_y - search_range_h;
          i <= center_y + search_range_h;
          i++) {
        Ni[Ni_i] = 0;
        for (int j = center_x - search_range_w;
            j <= center_x + search_range_w;
            j++) {
          // calculate new x: coordinate 1
          int new_x =
              (this_cos * (j - center_x) + this_sin * (i - center_y)).toInt();
          int real_new_x = new_x + center_x; // tarnsform coordinate to img

          // calculate new y: coordinate 2
          int new_y =
              (-this_sin * (j - center_x) + this_cos * (i - center_y)).toInt();
          int real_new_y = new_y + center_y; // tarnsform coordinate to img

          if (real_new_x < 0 ||
              real_new_y < 0 ||
              real_new_y >= height ||
              real_new_x >= width) {
            continue;
          }

          if (in_img[real_new_y * width + real_new_x] > 128) {
            Ni[Ni_i]++;
          }
        }

        Ni_i++;
      }

      int sum = 0;

      for (int i = 0; i < Ni_i; i++) {
        sum += Ni[i];
      }

      // M: average
      double M = sum * 1.0 / Ni_i;

      // calculate V0
      double sum2 = 0;

      for (int i = 0; i < Ni_i; i++) {
        sum2 = sum2 + (Ni[i] - M) * (Ni[i] - M);
      }

      double V0 = sum2 / Ni_i;

      if (V0 > max_V0) {
        max_V0 = V0;
        remember_angle = angle;
        remember_V0 = max_V0;
      }
    }

    return remember_angle;
  }
}
