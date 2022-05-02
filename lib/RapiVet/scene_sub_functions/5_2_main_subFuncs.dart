import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:swork_raon/0_CommonThisApp/rapivetStatics.dart';
import 'package:swork_raon/0_DataProcess/Pet_data_manager.dart';
import 'package:swork_raon/0_DataProcess/one_healthcheck_data.dart';
import 'package:swork_raon/0_DataProcess/one_pet_data.dart';

import '9_2_Result_subFuncs.dart';

class main_subfuncs {
  operate_onclcik_right() {
    rapivetStatics.current_pet_index++;

    if (rapivetStatics.current_pet_index >=
        rapivetStatics.pet_data_list.length) {
      rapivetStatics.current_pet_index = 0;
    }
  }

  operate_onclick_left() {
    rapivetStatics.current_pet_index--;

    if (rapivetStatics.current_pet_index < 0) {
      rapivetStatics.current_pet_index =
          rapivetStatics.pet_data_list.length - 1;
    }
  }

  get_name_and_age() {
    int index = rapivetStatics.current_pet_index;
    String str = rapivetStatics.pet_data_list[index].name;
    print("name::: " + str);

    String str2 = rapivetStatics.pet_data_list[index].birthday;

    DateTime now = DateTime.now();
    DateTime birthday = DateTime(
        rapivetStatics.pet_data_list[index].birthday_year,
        rapivetStatics.pet_data_list[index].birthday_month,
        rapivetStatics.pet_data_list[index].birthday_day);

    Duration duration = now.difference(birthday);
    int gap_days = duration.inDays;

    int age = (gap_days / 365).toInt();

    if (age == 0) {
      str = str;
    } else if (age == 1) {
      str = str + ",  1 ano";
    } else {
      str = str + ",  " + age.toString() + " anos";
    }

    return str;
  }

  get_secondLine_infos() {
    int index = rapivetStatics.current_pet_index;
    one_pet_data this_pet_data = rapivetStatics.pet_data_list[index];

    String kind_name = Pet_data_manager().get_kind_name(this_pet_data);

    String str = kind_name +
        "   |   " +
        this_pet_data.yyyymmddBirhday_to_pt() +
        "   |   " +
        this_pet_data.weight +
        "Kg";

    return str;
  }

  is_short_deivce_not_tablet(double s_width, double s_height) {
    print(s_height);

    // 테블릿은 아니면서 작은 화면 비율의 폰
    double s_ratio = s_width / s_height;
    if (s_ratio >= 1.88 || s_height >= 500) {
      return false;
    } else {
      return true;
    }
  }

  show_tutorial(double s_width, double s_height, bool is_visible,
      VoidCallback Callback_close, String asset_path) {
    return Visibility(
      visible: is_visible,
      child: Container(
        width: s_width,
        height: s_height,
        color: Colors.black,
        child: Stack(
          children: [
            Container(
                height: s_height,
                width: s_width,
                color: Colors.black,
                child: Image.asset(asset_path/*"assets/tutorial/tuto1.jpg"*/,
                    fit: BoxFit.fitHeight)),
            Padding(
              padding:
                  new EdgeInsets.fromLTRB(s_width * 0.8, s_width * 0.1, 0, 0),
              child: Container(
                width: s_width * 0.1,
                child: InkWell(
                  onTap: () {
                    Callback_close();
                  },
                  child: Image.asset("assets/tutorial/tutorial_end.png",
                      fit: BoxFit.fitHeight),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget get_img() {
    print(rapivetStatics.current_pet_index);
    one_pet_data this_pet_data =
        rapivetStatics.pet_data_list[rapivetStatics.current_pet_index];

    if (this_pet_data.uid == "") {
      return Image.file(
        File(this_pet_data.local_pic),
        fit: BoxFit.cover,
      );
    } else {
      return Image.network(this_pet_data.pic_url, fit: BoxFit.cover);
    }
  }

  DecorationImage get_thumb_img_in_userInfo(int index) {
    one_pet_data this_pet_data = rapivetStatics.pet_data_list[index];
    print(this_pet_data.pic_url);

    if (this_pet_data.uid == "") {
      return DecorationImage(
          image: FileImage(File(this_pet_data.local_pic), scale: 0.2),
          fit: BoxFit.cover);
    } else {
      return DecorationImage(
        image: CachedNetworkImageProvider(this_pet_data.pic_url, scale: 0.2),
        fit: BoxFit.cover,
      );
      // image: NetworkImage(this_pet_data.pic_url, scale: 0.2),
      // fit: BoxFit.cover);
    }
  }

  DecorationImage get_thumb_img({bool is_using_local_img = false}) {
    // main / pet_register 씬에서 공용으로 사용함.
    one_pet_data this_pet_data;

    if (rapivetStatics.pet_data_list == null ||
        rapivetStatics.pet_data_list == [] ||
        rapivetStatics.pet_data_list.length == 0) {
      is_using_local_img = true;
    } else {
      this_pet_data =
          rapivetStatics.pet_data_list[rapivetStatics.current_pet_index];
      print(this_pet_data.pic_url);
    }

    print(is_using_local_img);
    print(rapivetStatics.current_pet_pic_path);

    try {
      if (is_using_local_img &&
          rapivetStatics.current_pet_pic_path != null &&
          rapivetStatics.current_pet_pic_path != "") {
        return DecorationImage(
            image: FileImage(File(rapivetStatics.current_pet_pic_path),
                scale: 0.2),
            fit: BoxFit.cover);
      }
      // 로컬 모드에서만 작동함.
      else if (this_pet_data.uid == "") {
        return DecorationImage(
            image: FileImage(
                File(rapivetStatics
                    .pet_data_list[rapivetStatics.current_pet_index].local_pic),
                scale: 0.2),
            fit: BoxFit.cover);
      } else {
        return DecorationImage(
            image: NetworkImage(this_pet_data.pic_url, scale: 0.2),
            fit: BoxFit.cover);
      }
    } catch (e) {
      print("get image error!!!!!");
      return DecorationImage(
          image: NetworkImage("https://imevergreen.com/raonhealth/cat.JPG",
              scale: 0.2),
          fit: BoxFit.cover);
    }
  }
}
