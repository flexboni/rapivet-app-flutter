import 'package:swork_raon/common/rapivet_statics.dart';

class OnePet {
  String uid = ""; // server 사용시
  String? name;
  String? birthday; // yyyymmdd
  String? type; // dor or cat
  String? gender;
  String? isNeuter;
  String? kind; // breed
  String? weight;
  String? localPicture; // 로컬 사용시 필요
  String? urlPicture = ""; // 서버 사용시 필요

  int? year, month, day;

  String yyyymmddBirthdayToPT() {
    int year = int.parse(birthday!.substring(0, 4));
    int month = int.parse(birthday!.substring(4, 6));
    int day = int.parse(birthday!.substring(6, 8));

    return day.toString() +
        ".  " +
        RapivetStatics.monthInPT[month - 1] +
        ".  " +
        year.toString();
  }
}
