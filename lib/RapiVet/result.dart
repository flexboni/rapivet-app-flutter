import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:page_transition/page_transition.dart';
import 'package:swork_raon/common/JToast.dart';
import 'package:swork_raon/common/rapivetStatics.dart';
import 'package:swork_raon/model/All_health_check_manager.dart';
import 'package:swork_raon/model/one_healthcheck_data.dart';
import 'package:swork_raon/rapivet/scene_sub_functions/9_2_Result_subFuncs.dart';
import 'package:swork_raon/rapivet/scene_sub_functions/common_ui.dart';

import 'home.dart';

Color this_red = Color.fromARGB(255, 213, 48, 8);
Color this_grey = Colors.grey;
List<one_healthcheck_data> _hCheck_list = [];
List<String> _hCheck_date_strs = [];
one_healthcheck_data? _current_health_data;
bool? _is_loading;
String ad_img_url = "";

class ResultPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ResultPageState();
}

class _ResultPageState extends State<StatefulWidget>
    with TickerProviderStateMixin {
  @override
  void initState() {
    _is_loading = false;
    getDataFromServer();
    super.initState();
  }

  getDataFromServer() async {
    setState(() {
      _is_loading = true;
    });

    _hCheck_list = await Result_subFuncs().getCurrentPetHealthCheckDB();

    if (_hCheck_list == [] || _hCheck_list.length == 0) {
      JToast().show_toast("Informação não encontrada.", true);

      Navigator.pushReplacement(context,
          PageTransition(type: PageTransitionType.fade, child: HomePage()));
    }

    _hCheck_list = Result_subFuncs().reverse_order(_hCheck_list);
    _hCheck_date_strs = Result_subFuncs().get_check_dates(_hCheck_list);
    rapivetStatics.selected_check_index = 0;
    _current_health_data = _hCheck_list[rapivetStatics.selected_check_index];

    await All_health_check_manager().get_all_health_check_infos();

    // get link information
    ad_img_url = await Result_subFuncs().get_link_info(rapivetStatics.token);

    setState(() {
      _is_loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    double s_width = MediaQuery.of(context).size.width;
    double s_height = MediaQuery.of(context).size.height;

    callback_setstate() {
      setState(() {
        _current_health_data =
            _hCheck_list[rapivetStatics.selected_check_index];
        print("callback  state");
      });
    }

    goback_to_main() {
      Navigator.pushReplacement(context,
          PageTransition(type: PageTransitionType.fade, child: HomePage()));
    }

    String _get_date_txt() {
      try {
        return _hCheck_date_strs[rapivetStatics.selected_check_index];
      } catch (e) {
        return ".";
      }
    }

    return WillPopScope(
      onWillPop: () async {
        goback_to_main();
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
                  child: Visibility(
                    visible: !_is_loading,
                    child: Column(
                      children: [
                        Padding(padding: new EdgeInsets.all(42)),
                        Material(
                          child: InkWell(
                            onTap: () {
                              print('click');
                              Result_subFuncs().show_dialog_date(
                                  context,
                                  _hCheck_date_strs,
                                  callback_setstate,
                                  rapivetStatics.selected_check_index,
                                  s_width);
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(18),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      blurRadius: 6,
                                      spreadRadius: 3,
                                      color: Colors.grey.withOpacity(0.188),
                                    )
                                  ]),
                              width: s_width * 0.8,
                              height: 40,
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Padding(
                                        padding: new EdgeInsets.fromLTRB(
                                            20, 0, 0, 0)),
                                    Text(
                                      "*  ",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14),
                                    ),
                                    Padding(
                                        padding: new EdgeInsets.fromLTRB(
                                            20, 0, 0, 0)),
                                    Text(
                                      _get_date_txt(),
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14),
                                    ),
                                    Padding(
                                        padding: new EdgeInsets.fromLTRB(
                                            15, 0, 0, 0)),
                                    //Expanded(flex: 1, child: Container(color: Colors.red,)),
                                    OutlinedButton(
                                      style: OutlinedButton.styleFrom(
                                        side: BorderSide(
                                            color: Colors.white, width: 0),
                                      ),
                                      //onPressed: () {},
                                      child: Opacity(
                                        opacity: 0.75,
                                        child: Container(
                                            height: 18,
                                            child: Image.asset(
                                                'assets/updown_arrows.png')),
                                      ),
                                    ),
                                    Padding(
                                        padding: new EdgeInsets.fromLTRB(
                                            1, 0, 0, 0)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        Padding(padding: new EdgeInsets.all(5)),
                        Result_subFuncs().get_current_checkUI(
                            context, s_width, _current_health_data),
                        Padding(padding: new EdgeInsets.all(5)),
                        Container(
                            width: s_width,
                            child: Image.network(
                              ad_img_url,
                              fit: BoxFit.fitWidth,
                            )),
                        Padding(padding: new EdgeInsets.all(48)),
                      ],
                    ),
                  ),
                ),
                get_upbar(() {}, false, "RESULTADO", in_width: s_width,
                    callback_goBack: () {
                  goback_to_main();
                }),
                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    get_temp_downbar(context, callback_setstate,
                        DOWN_BAR_STATUS.RESULT, s_width),
                    //   Padding(padding: new EdgeInsets.all(10)),
                  ],
                ),
                get_overlay_btns(context, callback_setstate, s_width, s_height),
                show_loading(_is_loading, s_height, s_width, this),
              ],
            )),
          )),
    );
  }
}
