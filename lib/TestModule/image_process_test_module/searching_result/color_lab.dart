import 'dart:math';

import 'package:swork_raon/TestModule/image_process_test_module/searching_result/search_ultimate_result.dart';

class ColorLab {
  double l, a, b;

  ColorLab({
    double l = 0,
    double a = 0,
    double b = 0,
  }) {
    this.l = l;
    this.a = a;
    this.b = b;
  }

  double compare(COMPARE_MODE compareMode, ColorLab lab_1, ColorLab lab_2) {
    // use a b only
    if (compareMode == COMPARE_MODE.LAB_ONLY_USING_AB) {
      double gapA = lab_1.a - lab_2.a;
      double gapB = lab_1.b - lab_2.b;

      double sums = gapA * gapA + gapB * gapB;
      double diff = sqrt(sums);

      return diff / 100;
    }

    // 각 채널의 유사도를 먼저 계산 후 평균값을 구하는 것이 적합해 보임.
    if (compareMode == COMPARE_MODE.LAB_ONLY_USING_LAB) {
      double similarityL = (1 - lab_1.l / lab_2.l).abs() * 100;
      double similarityA = (1 - lab_1.a / lab_2.a).abs() * 100;
      double similarityB = (1 - lab_1.b / lab_2.b).abs() * 100;

      double w1 = 1.0;
      double w2 = 1.0;
      double w3 = 1.0;

      return ((similarityL * w1) + (similarityA * w2) + (similarityB * w3)) / 3;
    }

    return 0;
  }
}
