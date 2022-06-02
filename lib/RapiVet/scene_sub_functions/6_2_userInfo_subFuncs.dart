import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:swork_raon/common/rapivet_statics.dart';

import '../4_RegisterPet.dart';

class userinfo_subfuncs {
  goto_register_to_modify(BuildContext context, int index) {
    RapivetStatics.currentPetIndex = index;

    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) => RegisterPet_scene(
                COME_FROM.USER_INFO, PET_REGISTER_MODE.MODIFY)));
  }
}
