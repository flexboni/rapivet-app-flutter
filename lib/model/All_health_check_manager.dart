//  전체 애완동물 헬스 결과 데이터를 관ㄹ

// 메인에 관련 ui를 딜레이 없이 보여주기 위함.

// 로드할 때ㅣ welcome --> main ,,,  result (시작시에)

import 'package:swork_raon/common/rapivet_statics.dart';
import 'package:swork_raon/rapivet/10_Result_plus.dart';
import 'package:swork_raon/rapivet/scene_sub_functions/9_2_Result_subFuncs.dart';

import 'one_health_check.dart';

class All_health_check_manager {
  get_all_health_check_infos() async {
    print("get pet health info from server======");
    List<List<OneHealthCheck>> allPets_healthCheck_list = [];

    for (int i = 0; i < RapivetStatics.petDataList.length; i++) {
      String pet_uid = RapivetStatics.petDataList[i].uid;
      print("pet uid:::::" + pet_uid);
      List<OneHealthCheck> _hCheck_list =
          await Result_subFuncs().get_onePet_healthCehck_db(pet_uid);
      print("health check data count:: " + _hCheck_list.length.toString());
      allPets_healthCheck_list.add(_hCheck_list);
    }

    RapivetStatics.allPetsHealthCheckList = allPets_healthCheck_list;
    print(RapivetStatics.allPetsHealthCheckList.length);
  }

  String get_currentPet_last_test_date() {
    print("get_currentPet_last_test_date");

    one_health_check currentPet_last_checkInfo =
        _get_currentPet_last_checkInfo();

    if (currentPet_last_checkInfo == null) return "Informação não encontrada.";

    return currentPet_last_checkInfo.lastTestDate;
  }

  String get_currentPet_next_test_date() {
    print("get_currentPet_last_test_date");

    one_health_check currentPet_last_checkInfo =
        _get_currentPet_last_checkInfo();

    if (currentPet_last_checkInfo == null) return "-";

    return currentPet_last_checkInfo.nextTestDate;
  }

  String get_currentPet_normal_countStr() {
    one_health_check currentPet_last_checkInfo =
        _get_currentPet_last_checkInfo();

    if (currentPet_last_checkInfo == null) return "0";

    int normal_count = 0;

    if (currentPet_last_checkInfo.isNormal(RESULT_PLUS_MODE.KETON))
      normal_count++;
    if (currentPet_last_checkInfo.isNormal(RESULT_PLUS_MODE.GLUCOSE))
      normal_count++;
    if (currentPet_last_checkInfo.isNormal(RESULT_PLUS_MODE.PROTEIN))
      normal_count++;
    if (currentPet_last_checkInfo.isNormal(RESULT_PLUS_MODE.BLOOD))
      normal_count++;
    if (currentPet_last_checkInfo.isNormal(RESULT_PLUS_MODE.NITRITE))
      normal_count++;
    if (currentPet_last_checkInfo.isNormal(RESULT_PLUS_MODE.LEUKOZYTEN))
      normal_count++;
    if (currentPet_last_checkInfo.isNormal(RESULT_PLUS_MODE.PH)) normal_count++;

    return normal_count.toString();
  }

  String get_currentPet_suspect_countStr() {
    one_health_check currentPet_last_checkInfo =
        _get_currentPet_last_checkInfo();

    if (currentPet_last_checkInfo == null) return "0";

    int normal_count = 0;

    if (currentPet_last_checkInfo.isNormal(RESULT_PLUS_MODE.KETON))
      normal_count++;
    if (currentPet_last_checkInfo.isNormal(RESULT_PLUS_MODE.GLUCOSE))
      normal_count++;
    if (currentPet_last_checkInfo.isNormal(RESULT_PLUS_MODE.PROTEIN))
      normal_count++;
    if (currentPet_last_checkInfo.isNormal(RESULT_PLUS_MODE.BLOOD))
      normal_count++;
    if (currentPet_last_checkInfo.isNormal(RESULT_PLUS_MODE.NITRITE))
      normal_count++;
    if (currentPet_last_checkInfo.isNormal(RESULT_PLUS_MODE.LEUKOZYTEN))
      normal_count++;
    if (currentPet_last_checkInfo.isNormal(RESULT_PLUS_MODE.PH)) normal_count++;

    normal_count = 7 - normal_count;

    return normal_count.toString();
  }

  // get current pet's health check info
  one_health_check _get_currentPet_last_checkInfo() {
    String pet_uid =
        RapivetStatics.petDataList[RapivetStatics.currentPetIndex].uid;

    print("_get_currentPet_last_checkInfo()");
    print(RapivetStatics.allPetsHealthCheckList.length);

    for (int i = 0; i < RapivetStatics.allPetsHealthCheckList.length; i++) {
      List<OneHealthCheck> _hCheck_list =
          RapivetStatics.allPetsHealthCheckList[i];

      // print(RapivetStatics.allPets_healthCheck_list[i][0].toString());

      if (_hCheck_list == null ||
          _hCheck_list == [] ||
          _hCheck_list.length == 0) {
        print(pet_uid);
        print("no data");
        continue;
      }

      print(_hCheck_list[0].petUID);

      if (_hCheck_list[0].petUID == pet_uid) {
        print("finded!!!");
        return _hCheck_list[_hCheck_list.length - 1];
      }
    }

    return null;
  }
}
