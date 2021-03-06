import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:page_transition/page_transition.dart';
import 'package:swork_raon/common/rapivet_statics.dart';
import 'package:swork_raon/model/All_health_check_manager.dart';
import 'package:swork_raon/rapivet/12_QA_read.dart';
import 'package:swork_raon/rapivet/main.dart';
import 'package:swork_raon/rapivet/result.dart';
import 'package:swork_raon/rapivet/scene_sub_functions/5_2_main_subFuncs.dart';
import 'package:swork_raon/rapivet/scene_sub_functions/common_ui.dart';
import 'package:url_launcher/url_launcher.dart';

extension GlobalKeyExtension on GlobalKey {
  Rect get globalPaintBounds {
    final renderObject = currentContext?.findRenderObject();
    var translation = renderObject?.getTransformTo(null)?.getTranslation();
    if (translation != null && renderObject.paintBounds != null) {
      return renderObject.paintBounds
          .shift(Offset(translation.x, translation.y));
    } else {
      return null;
    }
  }
}

bool _to_show_tutorial = false;
bool _is_tuto1_visiblle = false;
bool _is_tuto2_visiblle = false;

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _HomeState();
}

class _HomeState extends State<StatefulWidget> {
  bool is_ready_to_remove_line = false;
  final grayMark_containerKey = GlobalKey();

  @override
  void initState() {
    // print("width: "+ MediaQuery.of(context).size.width.toString());

    bool was_shown_tutorial =
        RapivetStatics.prefs.getBool("was_shown_tutorial");

    if (was_shown_tutorial == null || was_shown_tutorial == false) {
      _to_show_tutorial = true;
    } else {
      _to_show_tutorial = false;
    }

    if (_to_show_tutorial) {
      _is_tuto1_visiblle = _is_tuto2_visiblle = true;
      print("_is_tuto1_visiblle: " + _is_tuto1_visiblle.toString());
    }

    is_ready_to_remove_line = false;
    remove_line();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(statusBarColor: Colors.transparent));
    // TODO: implement build
    double s_width = MediaQuery.of(context).size.width;
    double s_height = MediaQuery.of(context).size.height;
    double statusBarHeight = MediaQuery.of(context).padding.top;

    callback_setstate() {
      setState(() {});
    }

    callback_close_tutorial1() {
      setState(() {
        _is_tuto1_visiblle = false;
      });
    }

    callback_close_tutorial2() {
      setState(() {
        _is_tuto2_visiblle = false;
        RapivetStatics.prefs.setBool("was_shown_tutorial", true);
      });
    }

    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (BuildContext context) => MainPage()),
        );

        return false;
      },
      child: Scaffold(
          body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Container(
          color: RapivetStatics.appBG,
          child: SafeArea(
            top: false,
            child: Stack(
              children: [
                Stack(
                  children: [
                    Column(
                      children: [
                        // image part
                        Expanded(
                          flex: 1,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              main_subfuncs().get_img(),
                              // Image.file(
                              //   File(
                              //       /*RapivetStatics.current_pet_pic_path*/
                              //       RapivetStatics
                              //           .pet_data_list[
                              //               RapivetStatics.current_pet_index]
                              //           .local_pic),
                              //   fit: BoxFit.cover,
                              // ),
                              Column(
                                // ?????? ??? ???????????? ?????????. ( ??? ?????? ????????? ?????? ?????? ??????)
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Container(
                                    width: s_width,
                                    height: 3,
                                    color: RapivetStatics.appBG,
                                  ),
                                ],
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Container(
                                      alignment: Alignment.bottomLeft,
                                      child: FittedBox(
                                        child: Column(
                                          children: [
                                            Container(
                                              width: s_width * 0.95,
                                              padding: new EdgeInsets.fromLTRB(
                                                  18, 0, 0, 2),
                                              child: Text(
                                                main_subfuncs()
                                                    .get_name_and_age(),
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontFamily: "Noto",
                                                  fontSize: (main_subfuncs()
                                                          .is_short_deivce_not_tablet(
                                                              s_height,
                                                              s_width))
                                                      ? 18
                                                      : 24,
                                                  shadows: <Shadow>[
                                                    Shadow(
                                                      offset: Offset(1.0, 1.0),
                                                      blurRadius: 3.0,
                                                      color: Color.fromARGB(
                                                          238, 0, 0, 0),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            Container(
                                              width: s_width * 0.95,
                                              alignment: Alignment.bottomLeft,
                                              padding: new EdgeInsets.fromLTRB(
                                                  18, 5, 0, 10),
                                              child: FittedBox(
                                                fit: BoxFit.scaleDown,
                                                child: Text(
                                                  main_subfuncs()
                                                      .get_secondLine_infos(),
                                                  maxLines: 1,
                                                  style: TextStyle(
                                                    color: Colors.white
                                                        .withOpacity(1),
                                                    fontSize: (main_subfuncs()
                                                            .is_short_deivce_not_tablet(
                                                                s_height,
                                                                s_width))
                                                        ? 10
                                                        : 12.5,
                                                    shadows: <Shadow>[
                                                      Shadow(
                                                        offset:
                                                            Offset(1.0, 1.0),
                                                        blurRadius: 3.0,
                                                        color: Color.fromARGB(
                                                            238, 0, 0, 0),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      )),
                                  get_paging(s_width),
                                  Padding(padding: new EdgeInsets.all(6)),
                                  Container(
                                    width: s_width,
                                    height: 20,
                                    //  color: RapivetStatics.app_bg,
                                    alignment: Alignment.bottomCenter,
                                    decoration: new BoxDecoration(
                                        color: RapivetStatics.appBG,
                                        borderRadius: new BorderRadius.only(
                                          topLeft: const Radius.circular(20.0),
                                          topRight: const Radius.circular(20.0),
                                        )),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Container(
                                            key: grayMark_containerKey,
                                            width: 40,
                                            child: Image.asset(
                                                'assets/main_img/gray_mark.png')),
                                      ],
                                    ),
                                    //color: Colors.white.withOpacity(0.5),
                                  ),
                                  //Padding(padding: new EdgeInsets.fromLTRB(0, 0, 0, 3))
                                ],
                              ),
                              Visibility(
                                visible: RapivetStatics.petDataList.length > 1,
                                child: Container(
                                  alignment: Alignment.centerLeft,
                                  child: Container(
                                    width: 50,
                                    child: RawMaterialButton(
                                      shape: CircleBorder(),
                                      onPressed: () {
                                        setState(() {
                                          main_subfuncs()
                                              .operate_onclick_left();
                                        });
                                      },
                                      child: Icon(
                                        Icons.arrow_back_ios_rounded,
                                        size: 20,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Visibility(
                                visible: RapivetStatics.petDataList.length > 1,
                                child: Container(
                                  alignment: Alignment.centerRight,
                                  child: Container(
                                    width: 50,
                                    child: RawMaterialButton(
                                      shape: CircleBorder(),
                                      onPressed: () {
                                        setState(() {
                                          main_subfuncs()
                                              .operate_onclcik_right();
                                        });
                                      },
                                      child: Icon(
                                        Icons.arrow_forward_ios_rounded,
                                        size: 20,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(padding: new EdgeInsets.all(7)),
                        // info part
                        Container(
                            padding: new EdgeInsets.fromLTRB(
                                s_width * 0.05, 0, 0, 0),
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "INFORMA????O",
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            )),
                        Padding(padding: new EdgeInsets.all(5)),
                        // first item : doctor Q&A
                        Material(
                          child: InkWell(
                            onTap: () {
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (BuildContext context) =>
                                          QA_read() /*Api_test_scene()*/));
                            },
                            child: Container(
                                width: s_width * 0.9,
                                height: 70,
                                decoration: new BoxDecoration(
                                  color: Colors.white,
                                  borderRadius:
                                      new BorderRadius.all(Radius.circular(10)),
                                ),

                                //   alignment: Alignment.centerLeft,
                                child: Row(
                                  children: [
                                    Padding(
                                        padding: new EdgeInsets.fromLTRB(
                                            15, 0, 0, 0)),
                                    Container(
                                        width: 50,
                                        child: Image.asset(
                                            'assets/main_img/doctor_icon.png')),
                                    Padding(
                                        padding: new EdgeInsets.fromLTRB(
                                            15, 0, 0, 0)),
                                    Expanded(
                                        flex: 1,
                                        child: Container(
                                          alignment: Alignment.centerLeft,
                                          child: FittedBox(
                                            fit: BoxFit.scaleDown,
                                            child: Text(
                                                "Voc?? tem alguma d??vida ou \nquer deixar uma opini??o?",
                                                maxLines: 2,
                                                style: TextStyle(height: 1.2)),
                                          ),
                                        )),
                                    Padding(
                                        padding: new EdgeInsets.fromLTRB(
                                            15, 0, 0, 0)),
                                    Container(
                                        height: 20,
                                        padding: new EdgeInsets.fromLTRB(
                                            0, 0, 13, 0),
                                        // color: Colors.red,
                                        child: FittedBox(
                                            fit: BoxFit.fitHeight,
                                            child: Icon(Icons
                                                .arrow_forward_ios_rounded))),
                                  ],
                                )),
                          ),
                        ),
                        Padding(padding: new EdgeInsets.all(5)),
                        // second item: last test
                        Container(
                            width: s_width * 0.9,
                            height: 70,
                            decoration: new BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                                  new BorderRadius.all(Radius.circular(10)),
                            ),
                            child: Row(
                              children: [
                                Padding(
                                    padding:
                                        new EdgeInsets.fromLTRB(15, 0, 0, 0)),
                                Container(
                                    width: 40,
                                    child: Image.asset(
                                        'assets/main_img/icon_last_test.png')),
                                Padding(
                                    padding:
                                        new EdgeInsets.fromLTRB(10, 0, 0, 0)),
                                Expanded(
                                    flex: 1,
                                    child: Container(
                                      //color: Colors.grey,
                                      alignment: Alignment.centerLeft,
                                      child: FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: Text(All_health_check_manager()
                                              .get_currentPet_last_test_date())),
                                      // child: Text("(T) Not yet tested.")),
                                    )),
                                Padding(
                                    padding:
                                        new EdgeInsets.fromLTRB(15, 0, 0, 0)),
                                Container(
                                  width: s_width * 0.33,
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: get_one_result_btn(
                                        46.88 * 2.5, Colors.white, Colors.red,
                                        () {
                                      Navigator.pushReplacement(
                                          context,
                                          PageTransition(
                                              type: PageTransitionType.fade,
                                              child: ResultPage()));
                                    }, -1, -1, in_height: 46.88),
                                  ),
                                ),
                                Padding(
                                    padding:
                                        new EdgeInsets.fromLTRB(10, 0, 0, 0)),
                              ],
                            )),
                        Padding(padding: new EdgeInsets.all(5)),
                        // third item: next test
                        Container(
                            width: s_width * 0.9,
                            height: 70,
                            decoration: new BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                                  new BorderRadius.all(Radius.circular(10)),
                            ),
                            child: Row(
                              children: [
                                Padding(
                                    padding:
                                        new EdgeInsets.fromLTRB(15, 0, 0, 0)),
                                Container(
                                    width: 35,
                                    child: Image.asset(
                                        'assets/main_img/icon_new_test.png')),
                                Padding(
                                    padding:
                                        new EdgeInsets.fromLTRB(15, 0, 0, 0)),
                                Expanded(
                                    flex: 1,
                                    child: Container(
                                      //color: Colors.grey,
                                      alignment: Alignment.centerLeft,
                                      child: FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: Text(All_health_check_manager()
                                              .get_currentPet_next_test_date())),
                                      // child: Text("(T) Run a new test.")),
                                    )),
                                Padding(
                                    padding:
                                        new EdgeInsets.fromLTRB(15, 0, 0, 0)),
                                Container(
                                  width: s_width * 0.33,
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: get_one_short_btn(46.88 * 2.5,
                                        RapivetStatics.appBlue, "COMPRAR", () {
                                      launch(
                                        "https://www.raonhealth.com/produtos",
                                      );
                                    }),
                                  ),
                                ),
                                Padding(
                                    padding:
                                        new EdgeInsets.fromLTRB(10, 0, 0, 0)),
                              ],
                            )),
                        Padding(padding: new EdgeInsets.all(8)),
                        get_temp_downbar(context, callback_setstate,
                            DOWN_BAR_STATUS.MAIN, s_width),
                      ],
                    ),
                  ],
                ),
                Visibility(
                  visible: is_ready_to_remove_line,
                  child: Column(
                    // ?????? ?????? ????????? ?????? ???????????? ????????? ????????? ????????? ????????? ??????,
                    // ?????? ??????????????? ?????????... ?????? ??????
                    children: [
                      Padding(
                          padding: new EdgeInsets.fromLTRB(0, 0, 0,
                              _get_line_posY() - 0.5 /*- statusBarHeight*/)),
                      Container(
                        width: s_width,
                        height: 1,
                        color: RapivetStatics.appBG,
                      ),
                    ],
                  ),
                ),
                get_overlay_btns(context, callback_setstate, s_width, s_height),
                main_subfuncs().show_tutorial(
                    s_width,
                    s_height,
                    _is_tuto2_visiblle,
                    callback_close_tutorial2,
                    "assets/tutorial/tuto2.jpg"),
                main_subfuncs().show_tutorial(
                    s_width,
                    s_height,
                    _is_tuto1_visiblle,
                    callback_close_tutorial1,
                    "assets/tutorial/tuto1.jpg"),
              ],
            ),
          ),
        ),
      )),
    );
  }

  _get_line_posY() {
    try {
      double bottom = grayMark_containerKey.globalPaintBounds.bottom;
      print(bottom);
      return bottom;
    } catch (e) {
      return 0;
    }
  }

  void remove_line() async {
    // ?????? ?????? ????????? ?????? ???????????? ????????? ????????? ????????? ????????? ??????,
    // ?????? ??????????????? ?????????... ?????? ??????

    await Future.delayed(const Duration(milliseconds: 100));
    setState(() {});
    await Future.delayed(const Duration(milliseconds: 3000));
    is_ready_to_remove_line = true;
    setState(() {});
  }
}
