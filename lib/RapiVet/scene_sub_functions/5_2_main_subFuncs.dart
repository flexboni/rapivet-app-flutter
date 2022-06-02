import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:swork_raon/common/rapivet_statics.dart';
import 'package:swork_raon/model/Pet_data_manager.dart';
import 'package:swork_raon/model/one_pet.dart';

class main_subfuncs {
  operate_onclcik_right() {
    RapivetStatics.currentPetIndex++;

    if (RapivetStatics.currentPetIndex >= RapivetStatics.petDataList.length) {
      RapivetStatics.currentPetIndex = 0;
    }
  }

  operate_onclick_left() {
    RapivetStatics.currentPetIndex--;

    if (RapivetStatics.currentPetIndex < 0) {
      RapivetStatics.currentPetIndex = RapivetStatics.petDataList.length - 1;
    }
  }

  get_name_and_age() {
    int index = RapivetStatics.currentPetIndex;
    String str = RapivetStatics.petDataList[index].name;
    print("name::: " + str);

    String str2 = RapivetStatics.petDataList[index].birthday;

    DateTime now = DateTime.now();
    DateTime birthday = DateTime(
        RapivetStatics.petDataList[index].year,
        RapivetStatics.petDataList[index].month,
        RapivetStatics.petDataList[index].day);

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
    int index = RapivetStatics.currentPetIndex;
    one_pet_data this_pet_data = RapivetStatics.petDataList[index];

    String kind_name = Pet_data_manager().get_kind_name(this_pet_data);

    String str = kind_name +
        "   |   " +
        this_pet_data.yyyymmddBirthdayToPT() +
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
                child: Image.asset(asset_path /*"assets/tutorial/tuto1.jpg"*/,
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
    print(RapivetStatics.currentPetIndex);
    one_pet_data this_pet_data =
        RapivetStatics.petDataList[RapivetStatics.currentPetIndex];

    if (this_pet_data.uid == "") {
      return Image.file(
        File(this_pet_data.localPicture),
        fit: BoxFit.cover,
      );
    } else {
      return Image.network(this_pet_data.urlPicture, fit: BoxFit.cover);
    }
  }

  DecorationImage get_thumb_img_in_userInfo(int index) {
    one_pet_data this_pet_data = RapivetStatics.petDataList[index];
    print(this_pet_data.urlPicture);

    if (this_pet_data.uid == "") {
      return DecorationImage(
          image: FileImage(File(this_pet_data.localPicture), scale: 0.2),
          fit: BoxFit.cover);
    } else {
      return DecorationImage(
        image: CachedNetworkImageProvider(this_pet_data.urlPicture, scale: 0.2),
        fit: BoxFit.cover,
      );
      // image: NetworkImage(this_pet_data.pic_url, scale: 0.2),
      // fit: BoxFit.cover);
    }
  }

  DecorationImage get_thumb_img({bool is_using_local_img = false}) {
    // main / pet_register 씬에서 공용으로 사용함.
    one_pet_data this_pet_data;

    if (RapivetStatics.petDataList == null ||
        RapivetStatics.petDataList == [] ||
        RapivetStatics.petDataList.length == 0) {
      is_using_local_img = true;
    } else {
      this_pet_data =
          RapivetStatics.petDataList[RapivetStatics.currentPetIndex];
      print(this_pet_data.urlPicture);
    }

    print(is_using_local_img);
    print(RapivetStatics.currentPetPicturePath);

    try {
      if (is_using_local_img &&
          RapivetStatics.currentPetPicturePath != null &&
          RapivetStatics.currentPetPicturePath != "") {
        return DecorationImage(
            image: FileImage(File(RapivetStatics.currentPetPicturePath),
                scale: 0.2),
            fit: BoxFit.cover);
      }
      // 로컬 모드에서만 작동함.
      else if (this_pet_data.uid == "") {
        return DecorationImage(
            image: FileImage(
                File(RapivetStatics
                    .petDataList[RapivetStatics.currentPetIndex].localPicture),
                scale: 0.2),
            fit: BoxFit.cover);
      } else {
        return DecorationImage(
            image: NetworkImage(this_pet_data.urlPicture, scale: 0.2),
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
