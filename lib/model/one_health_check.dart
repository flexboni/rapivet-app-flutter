import 'package:swork_raon/common/rapivet_statics.dart';
import 'package:swork_raon/rapivet/10_Result_plus.dart';

class OneHealthCheck {
  String? petUID;

  int? round;
  String? timeToDisplay;
  String? lastTestDate;
  String? nextTestDate;

  int? ketone;
  int? glucose;
  int? leukocyte;
  int? nitrite;
  int? blood;
  int? ph;
  int? proteinuria; // 단백뇨

  bool? isNormal(RESULT_PLUS_MODE resultMode) {
    if (resultMode == RESULT_PLUS_MODE.KETON) {
      if (this.ketone != null) {
        return this.ketone! <= 1;
      }
    }

    if (resultMode == RESULT_PLUS_MODE.GLUCOSE) {
      if (this.glucose != null) {
        return this.glucose! <= 1;
      }
    }

    if (resultMode == RESULT_PLUS_MODE.LEUKOZYTEN) {
      return this.leukocyte == 0;
    }

    if (resultMode == RESULT_PLUS_MODE.NITRITE) {
      return this.nitrite == 0;
    }

    if (resultMode == RESULT_PLUS_MODE.BLOOD) {
      return this.blood == 0;
    }

    if (resultMode == RESULT_PLUS_MODE.PH) {
      return this.ph == 0 || this.ph == 1 || this.ph == 2;
    }

    if (resultMode == RESULT_PLUS_MODE.PROTEIN) {
      if (this.proteinuria != null) {
        return this.proteinuria! <= 1;
      }
    }

    return false;
  }

  setData(
    String inPetUID,
    String round,
    String ketone,
    String glucose,
    String leukocyte,
    String nitrite,
    String blood,
    String ph,
    String proteinuria,
    String createdAt,
  ) {
    petUID = inPetUID;

    // utc time --> local time
    timeToDisplay = RapivetStatics.convertTimeToDisplay(createdAt);
    lastTestDate =
        RapivetStatics.convertTimeToDisplay(createdAt, isWithoutYear: true);
    nextTestDate = RapivetStatics.convertTimeToDisplay(
      createdAt,
      isWithoutYear: true,
      isPlusOneMonth: true,
    );
    this.round = int.parse(round);
    this.ketone = int.parse(ketone);
    this.glucose = int.parse(glucose);
    this.leukocyte = int.parse(leukocyte);
    this.nitrite = int.parse(nitrite);
    this.blood = int.parse(blood);
    this.ph = int.parse(ph);
    this.proteinuria = int.parse(proteinuria);
  }
}
