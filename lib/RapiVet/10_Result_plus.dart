// ignore_for_file: camel_case_types

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:page_transition/page_transition.dart';
import 'package:swork_raon/common/JToast.dart';
import 'package:swork_raon/model/one_health_check.dart';
import 'package:swork_raon/rapivet/result.dart';

import 'home.dart';
import 'scene_sub_functions/10_2_ResultPlus_subFuncs.dart';
import 'scene_sub_functions/9_2_Result_subFuncs.dart';
import 'scene_sub_functions/common_ui.dart';

enum RESULT_PLUS_MODE {
  KETON,
  GLUCOSE,
  PROTEIN,
  BLOOD,
  NITRITE,
  LEUKOZYTEN,
  PH,
  NOTHING
}

bool? _isLoading;
List<OneHealthCheck> _oneHealthCheckList = [];

class Result_plus_scene extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _result_plus_scene_home();
}

class _result_plus_scene_home extends State<StatefulWidget>
    with TickerProviderStateMixin {
  callbackSetState() {
    setState(() {
      print("callback  state");
    });
  }

  @override
  void initState() {
    _isLoading = false;
    get_data_fromServer();
    super.initState();
  }

  get_data_fromServer() async {
    setState(() {
      _isLoading = true;
    });

    _oneHealthCheckList = await Result_subFuncs().getCurrentPetHealthCheckDB();

    if (_oneHealthCheckList == [] || _oneHealthCheckList.length == 0) {
      JToast().show_toast("Informação não encontrada.", true);

      Navigator.pushReplacement(context,
          PageTransition(type: PageTransitionType.fade, child: HomePage()));
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    double s_width = MediaQuery.of(context).size.width;
    double s_height = MediaQuery.of(context).size.height;

    double result_talbe_width = s_width * 0.5;
    double result_talbe_height = 33;

    goback_to_main() {
      Navigator.pushReplacement(context,
          PageTransition(type: PageTransitionType.fade, child: HomePage()));
    }

    goback_to_RESULT() {
      Navigator.pushReplacement(context,
          PageTransition(type: PageTransitionType.fade, child: ResultPage()));
    }

    callback_setstate() {
      setState(() {});
    }

    // TODO: implement build
    return WillPopScope(
      onWillPop: () async {
        //goback_to_main();
        goback_to_RESULT();
        return false;
      },
      child: Scaffold(
          backgroundColor: RapivetStatics.appBG,
          body: AnnotatedRegion<SystemUiOverlayStyle>(
            value: SystemUiOverlayStyle.dark,
            child: SafeArea(
              child: Stack(
                children: [
                  SingleChildScrollView(
                    physics: BouncingScrollPhysics(),
                    scrollDirection: Axis.vertical,
                    child: Visibility(
                      visible: !_isLoading,
                      child: Column(
                        children: [
                          Padding(padding: new EdgeInsets.all(38)),
                          ResultPlus_subFuncs()
                              .get_result_btns(s_width, callback_setstate),
                          Padding(padding: new EdgeInsets.all(6)),
                          // 테이블 그리기
                          ResultPlus_subFuncs().get_graphTable(
                              context, s_width, _oneHealthCheckList),
                          Padding(padding: new EdgeInsets.all(13)),
                          Row(
                            children: [
                              Padding(
                                  padding: new EdgeInsets.fromLTRB(
                                      s_width * 0.05, 0, 0, 0)),
                              Container(
                                  height: 13,
                                  child: Image.asset('assets/footmark.png')),
                              Padding(
                                  padding: new EdgeInsets.fromLTRB(
                                      s_width * 0.025, 0, 0, 0)),
                              Text(
                                "SUSTEITA DE DOENÇA",
                                style: TextStyle(
                                    fontSize: 17,
                                    color: Colors.black.withOpacity(0.7)),
                              ),
                            ],
                          ),
                          Padding(padding: new EdgeInsets.all(7)),
                          ResultPlus_subFuncs().get_dieases_btns(s_width),
                          Padding(padding: new EdgeInsets.all(50)),
                        ],
                      ),
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      get_upbar(() {}, false, "RELATÓRIO", in_width: s_width,
                          callback_goBack: () {
                        //goback_to_main();
                        goback_to_RESULT();
                      }),
                    ],
                  ),
                  // show_notReadyyet(s_width, s_height),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      get_temp_downbar(context, callback_setstate,
                          DOWN_BAR_STATUS.RESULT2, s_width),
                      //  Padding(padding: new EdgeInsets.all(8)),
                    ],
                  ),
                  get_overlay_btns(
                      context, callback_setstate, s_width, s_height),
                  show_loading(_isLoading, s_height, s_width, this),
                ],
              ),
            ),
          )),
    );
  }
}
