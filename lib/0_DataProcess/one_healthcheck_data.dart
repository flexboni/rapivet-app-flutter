import 'package:intl/intl.dart';
import 'package:swork_raon/0_CommonThisApp/rapivetStatics.dart';
import 'package:swork_raon/RapiVet/10_Result_plus.dart';

class one_healthcheck_data {
  String pet_uid;

  int round;
  String time_to_display;
  String last_test_Date_str;
  String next_test_Date_str;

  int keton;
  int glucose;
  int leukocyte;
  int nitrite;
  int blood;
  int ph;
  int proteinuria;

  bool is_normal(RESULT_PLUS_MODE result_mode) {
    if (result_mode == RESULT_PLUS_MODE.KETON) {
      if (keton <= 1)
        return true;
      else
        return false;
    }

    if (result_mode == RESULT_PLUS_MODE.GLUCOSE) {
      if (glucose <= 1)
        return true;
      else
        return false;
    }

    if (result_mode == RESULT_PLUS_MODE.LEUKOZYTEN) {
      if (leukocyte == 0)
        return true;
      else
        return false;
    }

    if (result_mode == RESULT_PLUS_MODE.NITRITE) {
      if (nitrite == 0)
        return true;
      else
        return false;
    }

    if (result_mode == RESULT_PLUS_MODE.BLOOD) {
      if (blood == 0)
        return true;
      else
        return false;
    }

    if (result_mode == RESULT_PLUS_MODE.PH) {
      if (ph==0 || ph == 1 || ph == 2)
        return true;
      else
        return false;
    }

    if (result_mode == RESULT_PLUS_MODE.PROTEIN) {
      if (proteinuria <= 1)
        return true;
      else
        return false;
    }
  }

  set_data(
      String in_pet_uid,
      String round_str,
      String keton_str,
      String glucose_str,
      String leukocyte_str,
      String nitrite_str,
      String blood_str,
      String ph_str,
      String proteinuria_str,
      String created_at) {
    pet_uid = in_pet_uid;
    print("pet uid:: " + pet_uid);

    // utc time --> local time
    time_to_display = rapivetStatics.converTime_to_displlay(created_at);
    last_test_Date_str = rapivetStatics.converTime_to_displlay(created_at,
        is_without_year: true);
    next_test_Date_str = rapivetStatics.converTime_to_displlay(created_at,
        is_without_year: true, is_plus_oneMonth: true);

    print(time_to_display);

    round = int.parse(round_str);

    keton = int.parse(keton_str);
    glucose = int.parse(glucose_str);
    leukocyte = int.parse(leukocyte_str);
    nitrite = int.parse(nitrite_str);
    blood = int.parse(blood_str);
    ph = int.parse(ph_str);
    proteinuria = int.parse(proteinuria_str);
  }
}
