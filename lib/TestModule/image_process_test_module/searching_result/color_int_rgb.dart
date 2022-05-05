import 'dart:math';

import 'package:swork_raon/utils/string_utils.dart';

class ColorIntRGB {
  int r;
  int g;
  int b;

  ColorIntRGB({
    int r = 0,
    int g = 0,
    int b = 0,
  }) {
    this.r = r;
    this.g = g;
    this.b = b;
  }

  double compareInDouble(ColorIntRGB rgb_1, ColorIntRGB rgb_2) {
    double gapR = rgb_1.r.toDouble() / 255 - rgb_2.r.toDouble() / 255;
    double gapG = rgb_1.g.toDouble() / 255 - rgb_2.g.toDouble() / 255;
    double gapB = rgb_1.b.toDouble() / 255 - rgb_2.b.toDouble() / 255;

    return sqrt(pow(gapR, 2) + pow(gapG, 2) + pow(gapB, 2));
  }

  ColorIntRGB setColorWeight(String weight, ColorIntRGB rgb) {
    List<String> weights = StringUtils().getSeparatedValues(weight, ",");

    double weight_r = double.parse(weights[0].trim());
    double weight_g = double.parse(weights[1].trim());
    double weight_b = double.parse(weights[2].trim());

    double raw_r = rgb.r * weight_r;
    if (raw_r > 255) raw_r = 255;

    double raw_g = rgb.g * weight_g;
    if (raw_g > 255) raw_g = 255;

    double raw_b = rgb.b * weight_b;
    if (raw_b > 255) raw_b = 255;

    int this_r = raw_r.round();
    int this_g = raw_g.round();
    int this_b = raw_b.round();

    return ColorIntRGB(r: this_r, g: this_g, b: this_b);
  }
}
