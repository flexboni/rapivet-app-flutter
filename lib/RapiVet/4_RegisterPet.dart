import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:swork_raon/0_Commons_totally/JToast.dart';
import 'package:swork_raon/0_DataProcess/one_pet_data.dart';

import '../0_CommonThisApp/app_strings.dart';
import '../0_CommonThisApp/rapivetStatics.dart';
import 'scene_sub_functions/4_2_ResterPet_subfuncs.dart';
import 'scene_sub_functions/common_ui.dart';

enum PET_REGISTER_MODE { ADD, MODIFY }

enum REG_SEXO { NOT_SELECTED, MALE, FEMALE }
enum REG_E_CASTRADO { NOT_SELECTED, Y, N }
enum REG_PET_TYPE { NOT_SELECTED, DOG, CAT }

PET_REGISTER_MODE _pet_register_mode;
COME_FROM _comeFrom;

one_pet_data _modifying_pet_data;

class RegisterPet_scene extends StatefulWidget {
  RegisterPet_scene(
      COME_FROM in_comeFrom, PET_REGISTER_MODE in_pet_register_mode,
      {int modifying_pet_index}) {
    _comeFrom = in_comeFrom;
    _pet_register_mode = in_pet_register_mode;

    if (_pet_register_mode == PET_REGISTER_MODE.ADD) {
      rapivetStatics.current_pet_pic_path = "";
    } else if (_pet_register_mode == PET_REGISTER_MODE.MODIFY) {
      if (rapivetStatics.is_logged_on_user) {
        // 서버에서 불러오기
        _modifying_pet_data =
            rapivetStatics.pet_data_list[rapivetStatics.current_pet_index];
        rapivetStatics.current_pet_pic_path = "";
      } else {
        // 로컬에서 불러오기
        _modifying_pet_data =
            rapivetStatics.pet_data_list[rapivetStatics.current_pet_index];
        rapivetStatics.current_pet_pic_path = _modifying_pet_data.local_pic;
      }
    }
  }

  @override
  State<StatefulWidget> createState() => _registerpet_scene_home();
}

class _registerpet_scene_home extends State<StatefulWidget>
    with TickerProviderStateMixin {
  register_input_dataset _input_dataset;

  bool is_loading;

  @override
  void initState() {
    super.initState();

    _input_dataset = register_input_dataset();

    _input_dataset.nome_txtedit_control = TextEditingController();
    _input_dataset.birthday_txtedit_control = TextEditingController();
    _input_dataset.breed_txtedit_control = TextEditingController();
    _input_dataset.weight_txtedit_control = TextEditingController();
    _input_dataset.enum_sexo = REG_SEXO.NOT_SELECTED;
    _input_dataset.enum_e_castrado = REG_E_CASTRADO.NOT_SELECTED;
    _input_dataset.enum_pet_type = REG_PET_TYPE.NOT_SELECTED;

    rapivetStatics.pet_img_base64 = "";
    _initialize();
  }

  _initialize() async {
    is_loading = true;

    // 2. modify: 데이터 뿌려주기
    if (_pet_register_mode == PET_REGISTER_MODE.MODIFY) {
      _input_dataset = register_subFuncs()
          .set_initial_data(_modifying_pet_data, _input_dataset);
    }

    setState(() {
      is_loading = false;
    });
  }

  DateTime confiredDate = DateTime(1983);

  _callback_click_birthday() {
    print("callback_click_birthday");

    DatePicker.showDatePicker(context,
        showTitleActions: true,
        minTime: DateTime(2000, 1, 1),
        maxTime: DateTime.now(), onChanged: (date) {
      print('change $date');
    }, onConfirm: (date) {
      confiredDate = date;

      _input_dataset.birthday_txtedit_control.text =
          register_subFuncs().convert_datetime_in_pt(confiredDate);
      print('confirm $date');

      setState(() {});
    },
        currentTime: (confiredDate == DateTime(1983))
            ? DateTime(2018, 6, 10)
            : confiredDate,
        locale: LocaleType.pt);
  }

  _callback_click_breed() async {
    if (_input_dataset.enum_pet_type == REG_PET_TYPE.NOT_SELECTED) {
      JToast().show_toast(app_strings().STR_select_cat_dog_first, false);
      return;
    }

    setState(() {
      is_loading = true;
    });

    await Future.delayed(Duration(milliseconds: 200));

    if (_input_dataset.enum_pet_type == REG_PET_TYPE.CAT) {
      show_dialog_petlist(
          context,
          rapivetStatics.cat_kind_set,
          _callback_setstate,
          _value,
          _input_dataset.enum_pet_type,
          _input_dataset);
    }

    if (_input_dataset.enum_pet_type == REG_PET_TYPE.DOG) {
      show_dialog_petlist(
          context,
          rapivetStatics.dog_kind_set,
          _callback_setstate,
          _value,
          _input_dataset.enum_pet_type,
          _input_dataset);
    }

    await Future.delayed(Duration(milliseconds: 100));
    setState(() {
      is_loading = false;
    });
  }

  _callback_setstate() {
    setState(() {});
  }

  _callback_goback() {
    register_subFuncs().pop_operate(context, _comeFrom);
  }

  _callback_register_pet() async {
    setState(() {
      is_loading = true;
      FocusScope.of(context).unfocus();
    });

    await register_subFuncs().operate_register_pet(
        context, _comeFrom, _pet_register_mode, _input_dataset,
        is_local_mode: false);

    setState(() {
      is_loading = false;
    });
  }

  int _value = -1;

  @override
  Widget build(BuildContext context) {
    double gap1 = 5;
    double gap2 = 10;

    double s_width = MediaQuery.of(context).size.width;
    double s_height = MediaQuery.of(context).size.height;
    // TODO: implement build
    return WillPopScope(
      onWillPop: () async {
        register_subFuncs().pop_operate(context, _comeFrom);
        return false;
      },
      child: Scaffold(
          backgroundColor: rapivetStatics.app_bg,
          body: AnnotatedRegion<SystemUiOverlayStyle>(
            value: SystemUiOverlayStyle.dark,
            child: SafeArea(
              child: Stack(
                children: [
                  SingleChildScrollView(
                    physics: BouncingScrollPhysics(),
                    scrollDirection: Axis.vertical,
                    child: Container(
                      //  color: Colors.red,
                      width: s_width,
                      child: Column(
                        children: [
                          Container(
                            width: s_width,
                          ),
                          Padding(padding: new EdgeInsets.all(50)),
                          get_explain_of_textfield_up(s_width, "NOME",
                              is_showing_footmark: true),
                          Padding(padding: new EdgeInsets.all(gap1)),
                          get_one_textfield(s_width, rapivetStatics.app_blue,
                              _input_dataset.nome_txtedit_control, "Nome",
                              is_name_keyboard: true),
                          Padding(padding: new EdgeInsets.all(gap2)),
                          get_explain_of_textfield_up(
                              s_width, "DATA DE NASCIMENTO",
                              is_showing_footmark: true),
                          Padding(padding: new EdgeInsets.all(gap1)),
                          get_one_textfield(
                              s_width,
                              rapivetStatics.app_blue,
                              _input_dataset.birthday_txtedit_control,
                              "17. 04. 2020",
                              is_readonly: true,
                              is_detecting_touch: true,
                              CallBack_whenTouch: _callback_click_birthday,
                              is_to_show_opendown_btn: true),
                          // 성별 입력------------------------------------------------
                          Padding(padding: new EdgeInsets.all(gap2)),
                          get_explain_of_textfield_up(s_width, "SEXO",
                              is_showing_footmark: true),
                          Padding(padding: new EdgeInsets.all(gap1)),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              selectable_button(s_width * 0.43, 50, "MACHO",
                                  _input_dataset.enum_sexo == REG_SEXO.MALE,
                                  () {
                                _input_dataset.enum_sexo = REG_SEXO.MALE;
                                _callback_setstate();
                              }),
                              Padding(
                                  padding: new EdgeInsets.fromLTRB(
                                      s_width * 0.04, 0, 0, 0)),
                              selectable_button(s_width * 0.43, 50, "FEMEA",
                                  _input_dataset.enum_sexo == REG_SEXO.FEMALE,
                                  () {
                                _input_dataset.enum_sexo = REG_SEXO.FEMALE;
                                _callback_setstate();
                              }),
                            ],
                          ),
                          // 중성화 여부 ---------------------------------------------
                          Padding(padding: new EdgeInsets.all(gap2)),
                          get_explain_of_textfield_up(s_width, "E CASTRADO",
                              is_showing_footmark: true),
                          Padding(padding: new EdgeInsets.all(gap1)),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              selectable_button(
                                  s_width * 0.43,
                                  50,
                                  "SIM",
                                  _input_dataset.enum_e_castrado ==
                                      REG_E_CASTRADO.Y, () {
                                _input_dataset.enum_e_castrado =
                                    REG_E_CASTRADO.Y;
                                _callback_setstate();
                              }),
                              Padding(
                                  padding: new EdgeInsets.fromLTRB(
                                      s_width * 0.04, 0, 0, 0)),
                              selectable_button(
                                  s_width * 0.43,
                                  50,
                                  "NÃO",
                                  _input_dataset.enum_e_castrado ==
                                      REG_E_CASTRADO.N, () {
                                _input_dataset.enum_e_castrado =
                                    REG_E_CASTRADO.N;
                                _callback_setstate();
                              }),
                            ],
                          ),
                          // 개 or 고양이--------------------------------------------
                          Padding(padding: new EdgeInsets.all(gap2)),
                          get_explain_of_textfield_up(s_width, "PET",
                              is_showing_footmark: true),
                          Padding(padding: new EdgeInsets.all(gap1)),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              selectable_button(
                                  s_width * 0.43,
                                  50,
                                  "CAO",
                                  _input_dataset.enum_pet_type ==
                                      REG_PET_TYPE.DOG, () {
                                if (_input_dataset.enum_pet_type ==
                                    REG_PET_TYPE.CAT) _value = -1;
                                _input_dataset.enum_pet_type = REG_PET_TYPE.DOG;
                                _callback_setstate();
                              }),
                              Padding(
                                  padding: new EdgeInsets.fromLTRB(
                                      s_width * 0.04, 0, 0, 0)),
                              selectable_button(
                                  s_width * 0.43,
                                  50,
                                  "GATO",
                                  _input_dataset.enum_pet_type ==
                                      REG_PET_TYPE.CAT, () {
                                if (_input_dataset.enum_pet_type ==
                                    REG_PET_TYPE.DOG) _value = -1;
                                _input_dataset.enum_pet_type = REG_PET_TYPE.CAT;
                                _callback_setstate();
                              }),
                            ],
                          ),
                          // 종류 -----------------------------------------------------
                          Padding(padding: new EdgeInsets.all(gap2)),
                          get_explain_of_textfield_up(s_width, "RAÇA",
                              is_showing_footmark: true),
                          Padding(padding: new EdgeInsets.all(gap1)),
                          get_one_textfield(
                              s_width,
                              rapivetStatics.app_blue,
                              _input_dataset.breed_txtedit_control,
                              "Rabrador Retriever",
                              is_readonly: true,
                              is_detecting_touch: true,
                              CallBack_whenTouch: _callback_click_breed,
                              is_to_show_opendown_btn: true),
                          // 몸무게 ----------------------------------------------------
                          Padding(padding: new EdgeInsets.all(gap2)),
                          get_explain_of_textfield_up(s_width, "PESO",
                              is_showing_footmark: true),
                          Padding(padding: new EdgeInsets.all(gap1)),
                          get_one_textfield(s_width, rapivetStatics.app_blue,
                              _input_dataset.weight_txtedit_control, "5",
                              is_to_show_kg_mark: true,
                              is_using_number_only: true),
                          Padding(padding: new EdgeInsets.all(gap2 * 2.5)),
                          // 등록 버튼 ------------------------------------------------
                          get_one_btn(
                              s_width * 0.9,
                              rapivetStatics.app_blue.withOpacity(0.8),
                              "Seguinte",
                              _callback_register_pet),
                          Padding(padding: new EdgeInsets.all(23)),
                        ],
                      ),
                    ),
                  ),
                  get_upbar(_callback_setstate, true, "MEU PET",
                      in_width: s_width,
                      callback_goBack: _callback_goback,
                      is_modify_mode:
                          (_pet_register_mode == PET_REGISTER_MODE.MODIFY)),
                  show_loading(is_loading, s_height, s_width, this),
                ],
              ),
            ),
          )),
    );
  }
}
