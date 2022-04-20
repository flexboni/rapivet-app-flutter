import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image/image.dart' as imglib;
import 'package:camera/camera.dart';
import 'package:swork_raon/0_Commons_totally/Vector2d.dart';

import 'dart:math';

import 'TimeChecker.dart';
import 'forData/JArea.dart';

class JImgProc {
  // CameraImage BGRA8888 -> PNG
  // Color
  imglib.Image convertBGRA8888(CameraImage image) {
    return imglib.Image.fromBytes(
      image.width,
      image.height,
      image.planes[0].bytes,
      format: imglib.Format.bgra,
    );
  }

// CameraImage YUV420_888 -> PNG -> Image (compresion:0, filter: none)
// Black
  imglib.Image convertYUV420(CameraImage image) {
    final int width = image.width;
    final int height = image.height;
    final int uvRowStride = image.planes[1].bytesPerRow;
    final int uvPixelStride = image.planes[1].bytesPerPixel;
    // print("uvRowStride: " + uvRowStride.toString());
    // print("uvPixelStride: " + uvPixelStride.toString());
    var img = imglib.Image(width, height); // Create Image buffer

    for (int x = 0; x < image.width; x++) {
      for (int y = 0; y < image.height; y++) {
        final int uvIndex =
            uvPixelStride * (x / 2).floor() + uvRowStride * (y / 2).floor();
        final int index = y * width + x;
        final yp = image.planes[0].bytes[index];
        final up = image.planes[1].bytes[uvIndex];
        final vp = image.planes[2].bytes[uvIndex];
        // Calculate pixel color
        /*
        int r = (yp + vp * 1436 / 1024 - 179).round().clamp(0, 255);
        int g = (yp - up * 46549 / 131072 + 44 - vp * 93604 / 131072 + 91)
            .round()
            .clamp(0, 255);
        int b = (yp + up * 1814 / 1024 - 227).round().clamp(0, 255);*/

        int r = (yp + vp * 1.4023 - 179).round().clamp(0, 255);
        int g = (yp - up * 0.355140 + 44 - vp * 0.714141 + 91)
            .round()
            .clamp(0, 255);
        int b = (yp + up * 1.77148 - 227).round().clamp(0, 255);

        // color: 0x FF  FF  FF  FF
        //           A   B   G   R
        img.data[index] = (0xFF << 24) | (b << 16) | (g << 8) | r;
      }
    }

    return img;
  }

  List<int> convertInt2Bytes(value, Endian order, int bytesSize) {
    try {
      final kMaxBytes = 8;
      var bytes = Uint8List(kMaxBytes)
        ..buffer.asByteData().setInt64(0, value, order);
      List<int> intArray;
      if (order == Endian.big) {
        intArray = bytes.sublist(kMaxBytes - bytesSize, kMaxBytes).toList();
      } else {
        intArray = bytes.sublist(0, bytesSize).toList();
      }
      return intArray;
    } catch (e) {
      print('util convert error: $e');
    }
    return null;
  }

//////////////////////////////////////////////
  imglib.Image make_half_changeTEST(imglib.Image img) {
    final point = img.getBytes();

    for (int i = 0; i < img.height / 2; i++) {
      for (int j = 0; j < img.width; j++) {
        int index = (i * img.width * 4 + j * 4);

        point[index + 0] = 255;
        point[index + 1] = 255;
      }
    }

    return img;
  }

  List JDrawMarks(
      imglib.Image img,
      int height_of_testIMG,
      List<JArea> vertical_maxArea_list,
      List<int> XareaPoints,
      List<int> StickArea_pointsX,
      int compensate_x,
      bool is_rotated180,
      {Color color = Colors.cyan,
      bool is_checking_find_area_well = true}) {
    // return result
    // 0: draw marked image for user to check
    // 1: area_width : circle drawed width, 실제 색상 가진 영역이라고 봄. (실제비교에서는 동그라미 아닌 네모 사용예정)
    // 2: List<Vector2d> compareRect_pos_list
    // 3: List<Vector2d> stickRect_pos_list

    List returnResult = [];
    List<Vector2d> compareRect_pos_list = [];
    List<Vector2d> stickRect_pos_list = [];

    double scale = img.height / height_of_testIMG;
    final point = img.getBytes();

    int height = img.height;
    int width = img.width;

    int area_width = vertical_maxArea_list[0].end_pos -
        vertical_maxArea_list[0].start_pos; // 배색표 네모 대표 넓이
    area_width = (area_width * 0.3 * scale).toInt();

    int mark_index = 0;
    int mark_max_index = 43; // total 44 rec area

    // it's force true
    print("is_rotated 180:::::::::: " + is_rotated180.toString());

    // (draw marks on recs) 배색표 마크
    for (int i = 0; i < vertical_maxArea_list.length; i++) {
      for (int j = 0; j < XareaPoints.length; j++) {
        if (is_rotated180) {
          // means: no draw here (skip this areas)
          if (mark_index == mark_max_index - 0 ||
              mark_index == mark_max_index - 1 ||
              mark_index == mark_max_index - 5 ||
              mark_index == mark_max_index - 16 ||
              mark_index == mark_max_index - 17 ||
              mark_index == mark_max_index - 20 ||
              mark_index == mark_max_index - 21 ||
              mark_index == mark_max_index - 27 ||
              mark_index == mark_max_index - 32) {

            // 얘네들도 활용해야함..
            int y = vertical_maxArea_list[i].end_pos +
                vertical_maxArea_list[i].start_pos;
            y = (y / 2 * scale).toInt();

            int x = (XareaPoints[j] * scale).toInt();

            compareRect_pos_list.add(new Vector2d(x+10000, y+10000));
            mark_index++;
            continue;
          }
        } else {
          // not use this animore
          if (mark_index == 0 || mark_index == 1 || mark_index == 5 /*....*/) {
            compareRect_pos_list.add(new Vector2d(-1, -1));
            mark_index++;
            continue;
          }
        }

        mark_index++;

        int y = vertical_maxArea_list[i].end_pos +
            vertical_maxArea_list[i].start_pos;
        y = (y / 2 * scale).toInt();

        int x = (XareaPoints[j] * scale).toInt();

        compareRect_pos_list.add(new Vector2d(x, y));

        for (int p = y - (area_width / 2).round();
            p <= y + area_width / 2;
            p++) {
          for (int t = x - (area_width / 2).round();
              t <= x + area_width / 2;
              t++) {
            if (p < 0 || t < 0 || p >= height || t >= width) continue;

            int r = (y - p) * (y - p) + (x - t) * (x - t);
            double distance = sqrt(r);
            if (distance <= area_width / 2) {
              int index = (p * width * 4 + t * 4);

              if (color == Colors.cyan) {
                point[index] = 0;
                point[index + 1] = 255;
                point[index + 2] = 255;
              } else {
                point[index] = 255;
                point[index + 1] = 0;
                point[index + 2] = 0;
              }
            }
          }
        }
      }
    }

    // (draw marks on stick) stick 에 영역 표시하자!
    int stick_centerY = ((vertical_maxArea_list[2].start_pos +
                vertical_maxArea_list[1].end_pos) /
            2)
        .toInt();

    stick_centerY = (stick_centerY * scale).round();
    int cirlce_r = (area_width / 2).round();

    for (int i = 0; i < StickArea_pointsX.length; i++) {
      int stick_centerX = (StickArea_pointsX[i] * scale).toInt() + compensate_x;

      stickRect_pos_list.add(new Vector2d(stick_centerX, stick_centerY));

      for (int p = stick_centerY - cirlce_r;
          p <= stick_centerY + cirlce_r;
          p++) {
        for (int t = stick_centerX - cirlce_r;
            t <= stick_centerX + cirlce_r;
            t++) {
          if (p < 0 || t < 0 || p >= height || t >= width) continue;

          double r = (stick_centerY - p) * (stick_centerY - p) +
              (stick_centerX.toDouble() - t) * (stick_centerX.toDouble() - t);
          double distance = sqrt(r);
          if (distance <= area_width / 2) {
            int index = (p * width * 4 + t * 4);

            if (color == Colors.cyan) {
              point[index] = 0;
              point[index + 1] = 255;
              point[index + 2] = 255;
            } else {
              point[index] = 255;
              point[index + 1] = 0;
              point[index + 2] = 0;
            }
          }
        }
      }
    }

    // for test only
    if(is_checking_find_area_well){
      img = _check_find_areaWell(img,compareRect_pos_list);
      img = _check_find_areaWell(img,stickRect_pos_list);
    }

    returnResult.add(img);
    returnResult.add(area_width);
    returnResult.add(compareRect_pos_list);
    returnResult.add(stickRect_pos_list);

    return returnResult;
  }


  imglib.Image _check_find_areaWell(imglib.Image img, List<Vector2d> pos_list){

    final point = img.getBytes();
    int height = img.height;
    int width = img.width;

    for(int list_i = 0; list_i<pos_list.length; list_i++){
      Vector2d pos = pos_list[list_i];
      int x = pos.x;
      int y = pos.y;

      if(x==-1 ||y==-1) continue;

      for(int p =y-1; p<=y+1; p++){
        for(int t =x-1; t<=x+1; t++){

          int index = (p * width * 4 + t * 4);

          point[index] = 0;
          point[index + 1] = 0;
          point[index + 2] = 0;

          if(list_i == 0){
            point[index] = 255;
          }
        }
      }
    }

    return img;
  }

  // vertical_maxArea_list : 배색표 세로 영역 표시

  imglib.Image Jreverse(imglib.Image src) {
    final p = src.getBytes();

    for (var i = 0, len = p.length; i < len; i += 4) {
      final l = imglib.getLuminanceRgb(p[i], p[i + 1], p[i + 2]);
      p[i] = 255 - l;
      p[i + 1] = 255 - l;
      p[i + 2] = 255 - l;
    }

    return src;
  }

  imglib.Image graybytes_to_IMG(Uint8List byteGray, imglib.Image src) {
    final p = src.getBytes();

    int index = 0;

    for (var i = 0, len = p.length; i < len; i += 4) {
      p[i] = byteGray[index];
      p[i + 1] = byteGray[index];
      p[i + 2] = byteGray[index];

      index++;
    }

    return src;
  }

  Uint8List Jgrayscale(imglib.Image src) {
    DateTime currentTime1 = DateTime.now();
    final p = src.getBytes();
    DateTime currentTime2 = DateTime.now();
    show_timeChecker("get byte", currentTime1, currentTime2);

    Uint8List new_p = Uint8List((p.length / 3).toInt());
    int index = 0;

    for (var i = 0, len = p.length; i < len; i += 4) {
      int l = imglib.getLuminanceRgb(p[i], p[i + 1], p[i + 2]);
      new_p[index] = l;
      index++;
    }
    return new_p;
  }

  Uint8List reverseBytes(Uint8List inbytes, int height, int width) {
    for (int i = 0; i < height; i++) {
      for (int j = 0; j < width; j++) {
        int index = i * width + j;
        inbytes[index] = 255 - inbytes[index];

        if (inbytes[index] < 0) inbytes[index] = 0;
      }
    }

    return inbytes;
  }

  Uint8List sum_bytes(
      Uint8List bytes1, Uint8List bytes2, int height, int width) {
    Uint8List bytesOut = Uint8List(bytes1.length);

    for (int i = 0; i < height; i++) {
      for (int j = 0; j < width; j++) {
        int index = i * width + j;

        int val = bytes1[index] + bytes2[index];
        if (val > 255) val = 255;
        if (val < 0) val = 0;

        bytesOut[index] = val;
      }
    }

    return bytesOut;
  }

  Uint8List makeHalfBlack(Uint8List byteGray, int height, int width) {
    Uint8List bytesOut = Uint8List(byteGray.length);

    for (int i = 0; i < height; i++) {
      for (int j = 0; j < width; j++) {
        if (j < width / 2 && i < height / 2)
          bytesOut[i * width + j] = 255;
        else
          bytesOut[i * width + j] = byteGray[i * width + j];
      }
    }

    return bytesOut;
  }

  Uint8List Jsobel_together(Uint8List byteGray, int height, int width,
      List<int> mask1, List<int> mask2) {
    Uint8List byteSobel = Uint8List(byteGray.length);

    for (int i = 0; i < height; i++) {
      for (int j = 0; j < width; j++) {
        int mask_i = 0;
        int sum1 = 0;
        int sum2 = 0;

        // calculate mask ------------------------------
        for (int k = i - 1; k <= i + 1; k++) {
          for (int t = j - 1; t <= j + 1; t++) {
            if (k < 0 || k >= height || t < 0 || t >= width) {
              mask_i++;
              continue;
            }

            int index = k * width + t;

            sum1 = sum1 + byteGray[index] * mask1[mask_i];
            sum2 = sum2 + byteGray[index] * mask2[mask_i];
            mask_i++;
          }
        }

        int targetVal_1 = sum1;
        if (targetVal_1 < 0) targetVal_1 = -targetVal_1;
        if (targetVal_1 > 255) targetVal_1 = 255;

        int targetVal_2 = sum2;
        if (targetVal_2 < 0) targetVal_2 = -targetVal_2;
        if (targetVal_2 > 255) targetVal_2 = 255;

        int targetVal = targetVal_1 + targetVal_2;
        if (targetVal > 255) targetVal = 255;

        byteSobel[i * width + j] = targetVal;
      }
    }

    return byteSobel;
  }

  Uint8List Jsobel(Uint8List byteGray, int height, int width, List<int> mask) {
    Uint8List byteSobel = Uint8List(byteGray.length);

    for (int i = 0; i < height; i++) {
      for (int j = 0; j < width; j++) {
        int mask_i = 0;
        int sum = 0;

        // calculate mask ------------------------------
        for (int k = i - 1; k <= i + 1; k++) {
          for (int t = j - 1; t <= j + 1; t++) {
            if (k < 0 || k >= height || t < 0 || t >= width) {
              mask_i++;
              continue;
            }

            if (mask[mask_i] == 0) {
              mask_i++;
              continue;
            }

            sum = sum + byteGray[k * width + t] * mask[mask_i];
            mask_i++;
          }
        }

        int targetVal = sum;
        if (targetVal < 0) targetVal = -targetVal;
        if (targetVal > 255) targetVal = 255;

        byteSobel[i * width + j] = targetVal;
      }
    }

    return byteSobel;
  }

  Uint8List rotate(Uint8List byteGray, int height, int width, double angle) {
    Uint8List bytesOut = Uint8List(byteGray.length);

    double this_cos = cos(angle / 57.3);
    double this_sin = sin(angle / 57.3);

    int search_range_h = (height / 2).toInt();
    int search_range_w = (width / 2).toInt();

    int center_y = (height / 2).toInt();
    int center_x = (width / 2).toInt();

    for (int i = center_y - search_range_h;
        i <= center_y + search_range_h;
        i++) {
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

        bytesOut[i * width + j] = byteGray[real_new_y * width + real_new_x];
      }
    }

    return bytesOut;
  }

  Uint8List projection_vertical(Uint8List bytesIn, int height, int width) {
    Uint8List bytesOut = Uint8List(bytesIn.length);
    List<int> projections = List<int>(width);

    // 1. voting
    for (int j = 0; j < width; j++) {
      projections[j] = 0;

      for (int i = 0; i < height; i++) {
        if (bytesIn[i * width + j] > 128) projections[j]++;
      }
    }

    // 2. make img by voting
    for (int j = 0; j < width; j++) {
      for (int i = 0; i < projections[j]; i++) {
        bytesOut[i * width + j] = 255;
      }
    }

    return bytesOut;
  }
}
