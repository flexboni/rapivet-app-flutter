

import 'package:image/image.dart' as imglib;
import 'dart:io';

import 'package:swork_raon/TestModule/Img_Proc_testModule/SubFuncs/SearchingResult/Area_color_sets.dart';

class testStatics{

  // developer ==================================

  static bool is_showing_picture_no_marked = false; // should be false


  // passive ================================
  static Directory save_directory = null;

  static bool is_to_captureFrame = false;
  static bool is_looking_for_captrueFrame = false;
  static String current_capturedFileName ="asdasdasd/sfsdfsdfwelkjsdf.aa";
  static bool is_to_show_result = false;

  static bool is_finded_area = false;
  static bool is_loading_forSearching = false;
  static bool is_to_show_jpg_to_check = false;

  static List<int> jpg_to_check = null;
  static imglib.Image stick_area_img;

  static List<Area_color_sets> compareRect_area_colorSets_list;
  static List<Area_color_sets> stickRect_area_colorSets_list;
}

