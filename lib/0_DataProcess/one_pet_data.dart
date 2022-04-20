

import 'package:swork_raon/0_CommonThisApp/rapivetStatics.dart';

class one_pet_data {

  String uid =""; // server 사용시 
  String name;
  String birthday; // yyyymmdd
  String type; // dor or cat
  String gender;
  String is_neuter;
  String kind; // breed
  String weight;
  String local_pic; // 로컬 사용시 필요
  String pic_url = ""; // 서버 사용시 필요

  int birthday_year, birthday_month, birthday_day;

  String yyyymmddBirhday_to_pt(){

    int year= int.parse(birthday.substring(0,4));
    int month = int.parse(birthday.substring(4,6));
    int day = int.parse(birthday.substring(6,8));

    return day.toString()+".  "+rapivetStatics.month_in_pt[month-1]+".  "+year.toString();
  }
  /*
  *
  *       "name": name.trim(),
      "birthday": birthday.trim(),
      "type": (enum_pet_type == REG_PET_TYPE.DOG) ? "1" : "2",
      "gender": (enum_sexo == REG_SEXO.MALE) ? "m" : "f",
      "is_neuter": (enum_e_castrado == REG_E_CASTRADO.Y) ? "y" : "n",
      "kind": breed,
      "local_pic": rapivetStatics.current_pet_pic_path,
  * */
}