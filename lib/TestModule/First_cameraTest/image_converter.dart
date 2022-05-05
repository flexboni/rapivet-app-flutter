// imgLib -> Image package from https://pub.dartlang.org/packages/image
import 'dart:io';
import 'dart:io' show Platform;
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:image/image.dart' as imglib;
import 'package:swork_raon/TestModule/image_process_test_module/JHistogram_finders/JHistogram_finder_vertical.dart';
import 'package:swork_raon/TestModule/image_process_test_module/JImgProc.dart';
import 'package:swork_raon/TestModule/image_process_test_module/Stick/Check_stick.dart';
import 'package:swork_raon/TestModule/image_process_test_module/TimeChecker.dart';
import 'package:swork_raon/TestModule/image_process_test_module/forData/JArea.dart';
import 'package:swork_raon/TestModule/image_process_test_module/p_searchAngle.dart';

import '../image_process_test_module/JHistogram_finders/JHistogram_finder_horizontal.dart';

Future<List<int>> convertImagetoPng(CameraImage image) async {
  DateTime currentTime1 = DateTime.now();

  JImgProc jimg_proc = JImgProc();

  try {
    imglib.Image img;

    print("here");
    print(img.height);
    print(img.width);

    if (image.format.group == ImageFormatGroup.yuv420) {
      img = await jimg_proc.convertYUV420(image);
    } else if (image.format.group == ImageFormatGroup.bgra8888) {
      img = jimg_proc.convertBGRA8888(image);
    }

    print("img len: " + img.length.toString());

    DateTime currentTime2 = DateTime.now();
    imglib.PngEncoder pngEncoder = new imglib.PngEncoder();

    // Convert to png
    List<int> png = pngEncoder.encodeImage(img);

    DateTime currentTime3 = DateTime.now();

    print("걸린시간");
    print(currentTime2.difference(currentTime1).inMilliseconds);
    print(currentTime3.difference(currentTime2).inMilliseconds);

    return png;
  } catch (e) {
    print(">>>>>>>>>>>> ERROR:" + e.toString());
  }
  return null;
}

Future<List> StickSearching_operation(
    CameraImage image, String save_path, bool is_testMode) async {
  print(
      "new search ==================================================================================");

  // explain.
  // is_testMode 는 실패해도 리턴되어야함.
  // 과정 중에 어떤 이미지가 뽑히는지 확인하기 위함.

  // 1. capture cameraImage
  DateTime currentTime1 = DateTime.now();
  JImgProc jimg_proc = JImgProc();

  // 2. Camera image to imglib.Image
  imglib.Image origin_img;
  if (image.format.group == ImageFormatGroup.yuv420) {
    origin_img = jimg_proc.convertYUV420(image);
  } else if (image.format.group == ImageFormatGroup.bgra8888) {
    origin_img = jimg_proc.convertBGRA8888(image);
  } else if (image.format.group == ImageFormatGroup.jpeg) {
    origin_img = imglib.decodeJpg(image.planes[0].bytes);
    //imglib.decodeImage(data)
  }

  DateTime currentTime2 = DateTime.now();
  show_timeChecker("camera image --> imglib: ", currentTime1, currentTime2);

  // 2-2. ios rotate:
  if (Platform.isIOS) {
    // iOS-specific code
    origin_img = imglib.copyRotate(origin_img, -90);
  }

  // origin_img = imglib.copyRotate(origin_img, 180);

  // 3. resize
  imglib.Image img = imglib.copyResize(origin_img, height: 178); // w > h

  DateTime currentTime3 = DateTime.now();
  show_timeChecker("resize: ", currentTime2, currentTime3);

  // 4-1. make it grayscale
  Uint8List bytesGray = jimg_proc.Jgrayscale(img);
  DateTime currentTime4 = DateTime.now();
  show_timeChecker("Jgrayscale: ", currentTime3, currentTime4);

  // if (is_testMode) {
  //   origin_img = JImgProc().make_half_changeTEST(origin_img);
  //
  //   List test_val = [];
  //   test_val.add(false); //0. success?
  //   test_val.add("test"); // 1. msg
  //   test_val.add(origin_img); // 2. original image from frame
  //   return test_val;
  // }

  // 4-2. sobel mask
  Uint8List byteSobel = jimg_proc.Jsobel_together(
      bytesGray,
      img.height,
      img.width,
      [-1, 0, 1, -2, 0, 2, -1, 0, 1],
      [1, 2, 1, 0, 0, 0, -1, -2, -1]);

  DateTime currentTime5 = DateTime.now();
  show_timeChecker("sobel: ", currentTime4, currentTime5);

  // 5. find skrew -----------------------------------------------------------
  p_searchAngle serachAngle = p_searchAngle();
  double detected_angle = serachAngle.start_search(
      byteSobel, img.height, img.width, -5, 5, 5, false, 0, 0);

  try {
    detected_angle = serachAngle.start_search(
        byteSobel,
        img.height,
        img.width,
        detected_angle - 2,
        detected_angle + 2,
        0.5,
        true,
        detected_angle,
        serachAngle.remember_V0);
  } catch (e) {
    return _make_failResult("faile detect angle");
  }

  print("5. deted angle: " +
      detected_angle.toString() +
      " degree -----------------------------");
  DateTime currentTime7 = DateTime.now();
  show_timeChecker("time- detect angle: ", currentTime5, currentTime7);

  // 6. rotation img (compensate)
  print(
      "6. rotation img (compensate) ------------------------------------------");
  Uint8List byteRotated =
      jimg_proc.rotate(byteSobel, img.height, img.width, detected_angle);
  DateTime currentTime8 = DateTime.now();
  show_timeChecker("time- rotate : ", currentTime7, currentTime8);

  // 7. projection as horizontal
  print(
      "7. projection as horizontal ------------------------------------------");
  JHistogram_finder_horizontal jhFinder_h = JHistogram_finder_horizontal();

  Uint8List projected_horizontal =
      jhFinder_h.projection_horizontal(byteRotated, img.height, img.width);
  DateTime currentTime9 = DateTime.now();
  show_timeChecker(
      "time- projection_horizontal : ", currentTime8, currentTime9);

  // 8. search sample area horizontal direction  -------------------------------------------------
  print(
      "8. search sample area horizontal direction  ------------------------------------------");
  DateTime currentTime_8_1 = DateTime.now(); // time check start

  int searchingX1 = jhFinder_h.get_searchinPointX1(
      projected_horizontal, img.height, img.width);

  List<int> valleys = jhFinder_h.get_valley_points_byVertical(
      projected_horizontal, img.height, img.width, searchingX1, false);

  int searchingX2 = jhFinder_h.get_searchinPointX2(searchingX1);

  List<JArea> vertical_maxArea_list = jhFinder_h.get_vertical_samples_area(
      projected_horizontal, img.height, img.width, searchingX2, valleys);

  List result = jhFinder_h.analyze_maxAreas(img.height, vertical_maxArea_list);

  // case Failed::
  if (result[0] == false) {
    print(result[1]);
    return _make_failResult(result[1]);
  } else {
    vertical_maxArea_list = result[2];
  }

  // 9. projection as vertical --------------------------------------------------------
  print("9. projection as vertical ------------------------------------------");
  Uint8List sample_area_only_img = null;
  JHistogram_finder_vertical jhFinder_v = JHistogram_finder_vertical();
  Uint8List projected_vertical = null;

  bool is_to_rotate180 = false; // 무조건 두짚어 져야함.
  List<int> XareaPoints = null;
/*
  Uint8List sample_area_only_img = jhFinder_h.remove_stickArea_and_bg(
      byteRotated, img.height, img.width, vertical_maxArea_list, 3);

  JHistogram_finder_vertical jhFinder_v = JHistogram_finder_vertical();
  Uint8List projected_vertical = jhFinder_v.projection_horizontal(
      sample_area_only_img, img.height, img.width);

  3 means: The 3rd horizontal line.
  List<int> XareaPoints = jhFinder_v.find_horizontal_area(
      projected_vertical, img.height, img.width, vertical_maxArea_list, 3);*/

  // 뒤짚어서 다시 시도: 탐색 인덱스만 변경됨.
  if (XareaPoints == null) {
    // 0 means: The 1st horizontal line.
    sample_area_only_img = jhFinder_h.remove_stickArea_and_bg(
        byteRotated, img.height, img.width, vertical_maxArea_list, 0);

    projected_vertical = jhFinder_v.projection_horizontal(
        sample_area_only_img, img.height, img.width);

    // XareaPoints 는 배색표 네모 중앙포인트를 의미함.

    // 해당 작업에서 민감도 조정 가능
    XareaPoints = jhFinder_v.find_horizontal_area(
        projected_vertical, img.height, img.width, vertical_maxArea_list, 0);

    if (XareaPoints == null) {
      print("탐색 실패");
      return _make_failResult("fail at horizontal searching");
    }

    is_to_rotate180 = true;
  }

  // 결국 projected_vertical 와 XareaPoints 로 셈플영역 탐색 완료
  //-------------------------------------------------------------------------------------

  DateTime currentTime_8_2 = DateTime.now(); // time check end
  show_timeChecker("time- find area: ", currentTime_8_1, currentTime_8_2);

  // 10. get stick area only
  DateTime currentTime_10_1 = DateTime.now(); // time check end
  bytesGray =
      jimg_proc.rotate(bytesGray, img.height, img.width, detected_angle);
  Uint8List stickIMG = jhFinder_v.get_area(
      bytesGray, img.height, img.width, vertical_maxArea_list, XareaPoints);
  //stickIMG = jhFinder_v.bg_flattening(stickIMG, img.height, img.width);

  // 나중에 사용할 수 도 있음.
  // JPosition centerPos_last_rect = jhFinder_v.find_lastRec_in_stick(
  //     stickIMG, vertical_maxArea_list, XareaPoints, img.height, img.width);

  // 11. check if stick is fitted ?
  Check_stick check_stick = Check_stick();
  bool is_too_close = check_stick.is_stick_too_close_outline(
      img.height, img.width, XareaPoints);

  if (is_too_close) {
    print("too close of stick starting!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
    return _make_failResult("too close of stick starting");
  }

  stickIMG = check_stick.check_fitted(
      stickIMG, img.height, img.width, vertical_maxArea_list, XareaPoints);

  if (stickIMG == null) {
    print("stick location error !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
    return _make_failResult("stick location error !!!!!!!");
  }

  // 12. get stick x points
  print("get stick x points!!!");
  List<int> stick_x_points = check_stick.get_stick_x_points(XareaPoints);

  //final prefs = await SharedPreferences.getInstance();
  //prefs.setBool("is_finded", true);

  DateTime currentTime_10_2 = DateTime.now(); // time check end
  show_timeChecker("time- find stick: ", currentTime_10_1, currentTime_10_2);

  // Uint8List areaCheckIMG = jhFinder_v.check_ultimate_area(
  //     byteRotated, img.height, img.width, vertical_maxArea_list, XareaPoints);

  // make img to display in UI
  List<int> jpg_to_display_inTestMode = null;
  print("make jpg!!!!");
  if (is_testMode) {
    // 테스트모드에서 보고 싶은 영상 여기 넣으면 됨.
    img = jimg_proc.graybytes_to_IMG(stickIMG, img);
    //img = jimg_proc.graybytes_to_RGB(projected_vertical, img);

    jpg_to_display_inTestMode = imglib.encodeJpg(img, quality: 80);
    print("jpeg:::: " + jpg_to_display_inTestMode.length.toString());
  }

  // print(save_path);
  // File(save_path).writeAsBytes(jpeg);

  //if(is_to_rotate180) detected_angle = detected_angle+180;

  List return_vals = [];
  return_vals.add(true); //0. success?
  return_vals.add("good job"); // 1. msg
  return_vals.add(origin_img); // 2. original image from frame
  return_vals.add(detected_angle); // 3. angle
  return_vals.add(img.height); // 4. img height of testIMG
  return_vals.add(img.width); // 5.
  return_vals.add(vertical_maxArea_list); // 6.vertical area
  return_vals.add(XareaPoints); // 7. horizontal area
  return_vals.add(is_to_rotate180); // 8. is_to_rotate180
  return_vals.add(stick_x_points); // 9. stick x points

  return_vals.add(jpg_to_display_inTestMode); // 10. stick are jpg

  return return_vals;
}

List _make_failResult(String msg) {
  List result = [];
  result.add(false);
  result.add(msg);

  return result;
}
