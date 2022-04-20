

import 'dart:math';

import 'package:swork_raon/TestModule/Img_Proc_testModule/SubFuncs/SearchingResult/Search_ultimate_result.dart';

class Color_lab {
  double l, a, b;

  Color_lab({
    double in_l = 0,
    double in_a = 0,
    double in_b = 0,
  }) {
    l = in_l;
    a = in_a;
    b = in_b;
  }

  double compare (COMPARE_MODE compare_mode, Color_lab lab_1, Color_lab lab_2 ){

    // use a b only
    if(compare_mode == COMPARE_MODE.LAB_ONLY_USING_AB){
      double a_gap = lab_1.a - lab_2.a;
      double b_gap = lab_1.b - lab_2.b;

      double sums = a_gap*a_gap+b_gap*b_gap;
      double diff = sqrt(sums);

      return diff/100;
    }

    if(compare_mode == COMPARE_MODE.LAB_ONLY_USING_LAB){
      double l_gap = lab_1.l - lab_2.l;
      double a_gap = lab_1.a - lab_2.a;
      double b_gap = lab_1.b - lab_2.b;

      double sums = l_gap*l_gap+ a_gap*a_gap+b_gap*b_gap;
      double diff = sqrt(sums);

      return diff/100;
    }

    return 0;
  }
}
