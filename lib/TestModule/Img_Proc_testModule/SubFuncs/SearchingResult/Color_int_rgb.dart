import 'dart:math';

import 'package:swork_raon/0_CommonThisApp/String_work.dart';

class Color_int_rgb {

  int r;
  int g;
  int b;

  Color_int_rgb( {int in_r=0, int in_g=0, int in_b=0} ) {
    r = in_r;
    g = in_g;
    b = in_b;
  }

  double Compare_in_double (Color_int_rgb rgb_1, Color_int_rgb rgb_2){
    double r1 = rgb_1.r.toDouble()/255;
    double g1 = rgb_1.g.toDouble()/255;
    double b1 = rgb_1.b.toDouble()/255;

    double r2 = rgb_2.r.toDouble()/255;
    double g2 = rgb_2.g.toDouble()/255;
    double b2 = rgb_2.b.toDouble()/255;

    double r_gap = r1-r2;
    double g_gap = g1-g2;
    double b_gap = b1-b2;

    double sums = r_gap*r_gap + g_gap*g_gap + b_gap*b_gap;
    double diff = sqrt(sums);

    return diff;
  }

  Color_int_rgb set_color_weight(String weight_str, Color_int_rgb in_rgb){
    // weight example:: "1.2, 1.1, 1"

    List<String> weights = String_work().get_divided_strs(weight_str, ",");

    double weight_r = double.parse(weights[0].trim());
    double weight_g = double.parse(weights[1].trim());
    double weight_b = double.parse(weights[2].trim());

    double raw_r = in_rgb.r * weight_r;
    if(raw_r>255) raw_r =255;

    double raw_g = in_rgb.g * weight_g;
    if(raw_g>255) raw_g =255;

    double raw_b = in_rgb.b * weight_b;
    if(raw_b>255) raw_b =255;

    int this_r = raw_r.round();
    int this_g = raw_g.round();
    int this_b = raw_b.round();

    return Color_int_rgb(in_r: this_r, in_g: this_g, in_b: this_b);
  }
}
