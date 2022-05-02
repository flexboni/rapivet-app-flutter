import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:swork_raon/0_CommonThisApp/rapivetStatics.dart';
import 'package:swork_raon/0_DataProcess/Pet_data_manager.dart';
import 'package:swork_raon/0_DataProcess/one_pet_data.dart';

import '../4_RegisterPet.dart';

class userinfo_subfuncs {
  goto_register_to_modify(BuildContext context, int index) {
    rapivetStatics.current_pet_index = index;

    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) =>
                RegisterPet_scene(COME_FROM.USER_INFO, PET_REGISTER_MODE.MODIFY)));
  }


}
