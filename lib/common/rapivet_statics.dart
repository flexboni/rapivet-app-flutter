// ignore_for_file: camel_case_types

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:swork_raon/model/one_health_check.dart';
import 'package:swork_raon/model/one_pet.dart';
import 'package:swork_raon/rapivet/10_Result_plus.dart';

enum COME_FROM { WELCOME, USER_INFO, MAIN } // check: doc_navigator.dart

class RapivetStatics {
  // developer
  static bool isForcedIOS = true; // should be false!!
  static bool isSkipGetPetList = false; // should be false!!!
  static bool isMakeRandomCellphone = false; // should be false!!!

  static int maxWidth = 800; // 800
  static int testTakePicWaitSec = 60; // 60

  static Color appBlue = Color.fromARGB(255, 112, 146, 191);
  static Color appBG = Color.fromARGB(255, 249, 249, 249);

  // urls ====================================================================
  static String baseURL =
      //  "http://ec2-3-35-77-71.ap-northeast-2.compute.amazonaws.com:6500/api/v1";
      "https://stg.rapi-vet.com/api/v1";

  static String baseUrlV2 = "https://stg.rapi-vet.com/api/v2";

  static String urlGetTypeDog = baseURL + "/pet/kind/1";
  static String urlGetTypeCat = baseURL + "/pet/kind/2";

  // passive ================================================================
  static bool isLoggedIn = false;
  static SharedPreferences? prefs;
  static String currentPetPicturePath = ""; // 사진이 로컬에 저장될 수 도 있고
  static String currentPetPicUrl = ""; // 사진이 url 에 저장될 수 도 있다.
  static bool isShowingMenuButtons = false;
  static FirebaseAuth? auth;

  // main (home) --------------------------
  static List<OnePet>? petDataList;
  static int currentPetIndex = 0; // 현재 보여주고, 수정할 때 target index로 사용

  // for ui -------------------------------

  static Color normalUILineColor = Colors.grey.withOpacity(0.28);
  static Color selectedUILineColor = appBlue;
  static Color appBlack = Color.fromARGB(255, 48, 48, 48);

  static String exCellNum = "5512345-1234";

  static String smsVerificationId = "null";
  static String smsVerificationError = "null";

  // register
  static List<String> dogs = [];
  static List<String> cats = [];
  static String petImgBase64 = "";

  // login - info
  static bool isLoggedOnUser = false;
  static String? token = "";
  static bool? isSimpleLoggedIn = false; // currently using in iOS

  static List<String> monthInPT = [
    "Janeiro", // 1월
    "Fevereiro", // 2월
    "Março", // 3월
    "Abril", // 4월
    "Maio", // 5월
    "Junho", // 6월
    "Julho", // 7월
    "Agosto", // 8월
    "Setembro", // 9월
    "Outubro", // 10월
    "Novembro", // 11월
    "Dezembro" // 12월
  ];

  // result
  static List<String> healthCheckTitle = [
    "Cetonas", // 케톤
    "Glicose", // 포도당
    "Leucócitos", // 백혈구
    "Nitrito", // 아질산염
    "Sangue", // 피
    "pH",
    "Proteínas", // 단백질
  ];

  static int selectedCheckIndex = 0;

  static List<List<OneHealthCheck>> allPetsHealthCheckList = [];

  // result_plus
  static RESULT_PLUS_MODE selectedResultPlusMode = RESULT_PLUS_MODE.KETON;

  // test
  static bool isToShowCamGuide = true;

  // time convert
  static convertTimeToDisplay(
    String timeInFormat, {
    String inFormat = "dd-MM-yyyy hh:mm",
    bool isWithoutYear = false,
    bool isPlusOneMonth = false,
  }) {
    var dateFormat = DateFormat(inFormat); // you can change the format here
    var utcDate = dateFormat
        .format(DateTime.parse(timeInFormat)); // pass the UTC time here
    DateTime localDate = dateFormat.parse(utcDate, true).toLocal();

    if (isPlusOneMonth) localDate = localDate.add(Duration(days: 30));

    String day = localDate.day.toString();
    if (day.length == 1) day = "0" + day;
    String month = RapivetStatics.monthInPT[localDate.month - 1];
    String year = localDate.year.toString();

    String hour = localDate.hour.toString();
    String min = localDate.minute.toString();

    if (hour.length == 1) hour = "0" + hour;
    if (min.length == 1) min = "0" + min;

    String _timeToDisplay =
        day + ". " + month + ". " + year + "    " + hour + ":" + min;

    if (isWithoutYear) {
      _timeToDisplay = day + ". " + month + ", " + hour + ":" + min;
    }

    return _timeToDisplay;
  }
}
