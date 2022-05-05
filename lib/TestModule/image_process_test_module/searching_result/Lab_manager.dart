import 'dart:math';

import 'package:swork_raon/TestModule/image_process_test_module/searching_result/color_lab.dart';

class Lab_manager {
  rgb2lab(int int_r, int int_g, int int_b,
      {bool is_directTo_ColorLab = false}) {
    double var_R = int_r.toDouble() / 255;
    double var_G = int_g.toDouble() / 255;
    double var_B = int_b.toDouble() / 255;

    // float[] arr = new float[3];
    double B = gGamma(var_B);
    double G = gGamma(var_G);
    double R = gGamma(var_R);
    double X = 0.412453 * R + 0.357580 * G + 0.180423 * B;
    double Y = 0.212671 * R + 0.715160 * G + 0.072169 * B;
    double Z = 0.019334 * R + 0.119193 * G + 0.950227 * B;

    X /= 0.95047;
    Y /= 1.0;
    Z /= 1.08883;

    double FX = X > 0.008856 ? pow(X, 1.0 / 3.0) : (7.787 * X + 0.137931);
    double FY = Y > 0.008856 ? pow(Y, 1.0 / 3.0) : (7.787 * Y + 0.137931);
    double FZ = Z > 0.008856 ? pow(Z, 1.0 / 3.0) : (7.787 * Z + 0.137931);

    double l = Y > 0.008856 ? (116.0 * FY - 16.0) : (903.3 * Y);
    double a = 500 * (FX - FY);
    double b = 200 * (FY - FZ);

    List lab = [];
    lab.add(l);
    lab.add(a);
    lab.add(b);

    if (is_directTo_ColorLab) {
      ColorLab colorLab = new ColorLab(l: l, a: a, b: b);
      return colorLab;
    }

    return lab;
  }

  double gGamma(double x) {
    return x > 0.04045 ? pow((x + 0.055) / 1.055, 2.4) : x / 12.92;
  }
}
