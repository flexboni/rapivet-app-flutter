import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:page_transition/page_transition.dart';
import 'package:swork_raon/rapivet/scene_sub_functions/7_TimerPopup.dart';
import 'package:swork_raon/rapivet/scene_sub_functions/common_ui.dart';

import '../common/rapivet_statics.dart';
import 'home.dart';

class Test_Guide extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _test_guide_home();
}

bool _is_showingTimer = false;

class _test_guide_home extends State<StatefulWidget> {
  @override
  void initState() {
    _is_showingTimer = false;
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double s_width = MediaQuery.of(context).size.width;
    double s_height = MediaQuery.of(context).size.height;

    callback_setstate() {
      setState(() {
        print("callback  state");
      });
    }

    goback_to_main() {
      Navigator.pushReplacement(context,
          PageTransition(type: PageTransitionType.fade, child: HomePage()));
    }

    // TODO: implement build
    return WillPopScope(
      onWillPop: () async {
        goback_to_main();
        return false;
      },
      child: Scaffold(
          backgroundColor: RapivetStatics.appBG,
          body: AnnotatedRegion<SystemUiOverlayStyle>(
            value: SystemUiOverlayStyle.dark,
            child: SafeArea(
              child: Stack(
                children: [
                  Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        get_upbar(() {}, false, "MODO DE USAR",
                            in_width: s_width, callback_goBack: () {
                          goback_to_main();
                        }),
                        Padding(padding: new EdgeInsets.all(15)),
                        Container(
                          height: s_height * 0.685,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(
                                      width: s_width,
                                      alignment: Alignment.center,
                                      child: Text(
                                        "ATENÇÃO",
                                        style: TextStyle(
                                            fontSize: 23,
                                            color: Colors.deepOrangeAccent,
                                            fontWeight: FontWeight.bold),
                                      )),
                                  Padding(padding: new EdgeInsets.all(5)),
                                  Container(
                                      width: s_width,
                                      alignment: Alignment.center,
                                      child: Text(
                                        //Antes de fazer o teste verifique as instruções !
                                        "Antes de fazer o teste\nverifique as instruções!",
                                        style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold),
                                      )),
                                  Padding(padding: new EdgeInsets.all(10)),
                                  Container(
                                      alignment: Alignment.topCenter,
                                      width: s_width * 0.9,
                                      child: Image.asset(
                                        "assets/guide_table_img.png",
                                        fit: BoxFit.fitWidth,
                                      )),
                                  Padding(padding: new EdgeInsets.all(10)),
                                  // Container(
                                  //     width: s_width*0.9,
                                  //     alignment: Alignment.center,
                                  //     child: Text(
                                  //       "Lembre-se de aguardar 1minuto apos\ncolocar a tira urina, assim podera obter\num resultado melhor.",
                                  //       style: TextStyle(
                                  //           fontSize: 16, fontWeight: FontWeight.bold),
                                  //     )),
                                  Padding(padding: new EdgeInsets.all(1)),
                                  get_one_btn(s_width * 0.9,
                                      RapivetStatics.appBlue, "CONFIRMAR", () {
                                    setState(() {
                                      RapivetStatics.isToShowCamGuide = true;
                                      _is_showingTimer = true;
                                    });
                                  }, in_height: 50),
                                  Padding(padding: new EdgeInsets.all(12)),
                                ]),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      get_temp_downbar(context, callback_setstate,
                          DOWN_BAR_STATUS.TEST, s_width),
                      //  Padding(padding: new EdgeInsets.all(10)),
                    ],
                  ),
                  //show_notReadyyet(s_width,s_height),
                  TimerPopup(_is_showingTimer, s_width, s_height),
                  get_overlay_btns(
                      context, callback_setstate, s_width, s_height),
                ],
              ),
            ),
          )),
    );
  }
}
