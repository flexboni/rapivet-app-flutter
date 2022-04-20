import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:swork_raon/0_DataProcess/one_healthcheck_data.dart';
import 'package:swork_raon/0_DataProcess/one_pet_data.dart';
import 'package:swork_raon/RapiVet/10_Result_plus.dart';
import 'package:intl/intl.dart';

enum COME_FROM { WELCOME, USER_INFO, MAIN } // check: doc_navigator.dart

class rapivetStatics {
  // developer
  static bool is_force_to_ios = true; // should be false!!
  static bool is_skip_get_petList = false; // should be false!!!
  static bool is_make_random_cellphone = false; // should be false!!!

  static int pic_max_width = 800; // 800
  static int test_takePic_waitSec = 60; // 60

  static Color app_blue = Color.fromARGB(255, 112, 146, 191);
  static Color app_bg = Color.fromARGB(255, 249, 249, 249);

  // urls ====================================================================
  static String baseURL =
      //  "http://ec2-3-35-77-71.ap-northeast-2.compute.amazonaws.com:6500/api/v1";
      "https://stg.rapi-vet.com/api/v1";

  static String baseURL_v2 = "https://stg.rapi-vet.com/api/v2";

  static String url_get_type_dog = baseURL + "/pet/kind/1";
  static String url_get_type_cat = baseURL + "/pet/kind/2";

  // passive ================================================================
  static bool is_logined = false;
  static SharedPreferences prefs = null;
  static String current_pet_pic_path = ""; // 사진이 로컬에 저장될 수 도 있고
  static String current_pet_pic_url = ""; // 사진이 url 에 저장될 수 도 있다.
  static bool is_showing_menuBtns = false;
  static FirebaseAuth auth;

  // main (home) --------------------------
  static List<one_pet_data> pet_data_list;
  static int current_pet_index = 0; // 현재 보여주고, 수정할 때 target index로 사용

  // for ui -------------------------------

  static Color normal_ui_line_color = Colors.grey.withOpacity(0.28);
  static Color selected_ui_line_color = app_blue;
  static Color app_black = Color.fromARGB(255, 48, 48, 48);

  static String cell_num_ex = "5512345-1234";

  static String sms_verificationId = "null";
  static String sms_verification_error = "null";

  // register
  static List<String> dog_kind_set = [];
  static List<String> cat_kind_set = [];
  static String pet_img_base64 = "";

  // login - info
  static bool is_logged_on_user = false;
  static String token = "";
  static bool is_simple_loggined = false; // currenty using in iOS

  static List<String> month_in_pt = [
    "Janeiro",
    "Fevereiro",
    "Março",
    "Abril",
    "Maio",
    "Junho",
    "Julho",
    "Agosto",
    "Setembro",
    "Outubro",
    "Novembro",
    "Dezembro"
  ];

  // result
  static List<String> healthCheck_title = [
    "Cetonas",
    "Glicose",
    "Leucócitos",
    "Nitrito",
    "Sangue",
    "pH",
    "Proteínas",
  ];

  static int selected_check_index = 0;

  static List<List<one_healthcheck_data>> allPets_healthCheck_list = [];

  // result_plus
  static RESULT_PLUS_MODE selected_result_plus_mode = RESULT_PLUS_MODE.KETON;

  // test
  static bool is_to_show_cam_guide = true;

  // time convert
  static converTime_to_displlay(String time_inFormat,
      {String in_format = "dd-MM-yyyy hh:mm",
        bool is_without_year = false, bool is_plus_oneMonth = false}) {
    var dateFormat = DateFormat(in_format); // you can change the format here
    var utcDate = dateFormat
        .format(DateTime.parse(time_inFormat)); // pass the UTC time here
    DateTime localDate = dateFormat.parse(utcDate, true).toLocal();

    if(is_plus_oneMonth) localDate =localDate.add(Duration(days: 30));

    String day = localDate.day.toString();
    if (day.length == 1) day = "0" + day;
    String month = rapivetStatics.month_in_pt[localDate.month - 1];
    String year = localDate.year.toString();

    String hour = localDate.hour.toString();
    String min = localDate.minute.toString();

    if (hour.length == 1) hour = "0" + hour;
    if (min.length == 1) min = "0" + min;

    String _time_to_display =
        day + ". " + month + ". " + year + "    " + hour + ":" + min;

    if (is_without_year) {
      _time_to_display = day + ". " + month + ", " + hour + ":" + min;
    }

    return _time_to_display;
  }
}
