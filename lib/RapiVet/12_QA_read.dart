import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:page_transition/page_transition.dart';
import 'package:swork_raon/common/rapivetStatics.dart';
import 'package:swork_raon/model/one_QA_data.dart';
import 'package:swork_raon/rapivet/11_QA_write.dart';
import 'package:swork_raon/rapivet/scene_sub_functions/12_2_QA_read_subFuncs.dart';

import '5_Main.dart';
import 'scene_sub_functions/common_ui.dart';

bool _is_showing_questionArea = false;
bool _is_loading = false;
List<one_QA_data> _qa_datas_list = [];

class QA_read extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _QA_read_home();
}

class _QA_read_home extends State<StatefulWidget>
    with TickerProviderStateMixin {
  @override
  void initState() {
    _is_showing_questionArea = false;
    _is_loading = false;
    _get_QnAs_fromServer();
    super.initState();
  }

  _get_QnAs_fromServer() async {
    setState(() {
      _is_loading = true;
    });

    _qa_datas_list =
        await QA_read_subFuncs().get_QnA_fromServer(rapivetStatics.token);

    if (_qa_datas_list == [] || _qa_datas_list.length == 0) {
      _is_showing_questionArea = false;
    } else {
      _is_showing_questionArea = true;
    }

    setState(() {
      _is_loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    double s_width = MediaQuery.of(context).size.width;
    double s_height = MediaQuery.of(context).size.height;

    goback_to_main() {
      Navigator.pushReplacement(context,
          PageTransition(type: PageTransitionType.fade, child: Main_scene()));
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
                  child: Stack(children: [
                SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  scrollDirection: Axis.vertical,
                  child: Container(
                    width: s_width,
                    //color: Colors.redAccent,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(padding: new EdgeInsets.all(40)),
                        Container(
                          alignment: Alignment.center,
                          width: s_width * 0.9,
                          height: 70,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.all(
                                Radius.circular(8),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  blurRadius: 0,
                                  spreadRadius: 0.5,
                                  // offset: Offset(0, 2),
                                  color: Colors.grey.withOpacity(0.188),
                                )
                              ]),
                          child: Container(
                            width: s_width * 0.8,
                            child: Text(
                              "Você tem alguma dúvida ou quer deixar uma opinião?",
                              style: TextStyle(fontSize: 15.5),
                            ),
                          ),
                        ),
                        Padding(padding: new EdgeInsets.all(13)),
                        get_one_btn(
                            s_width * 0.9, rapivetStatics.app_blue, "Escreva",
                            () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      QA_write()));
                        }, in_height: 55),
                        Padding(padding: new EdgeInsets.all(12)),
                        Container(
                          height: 12,
                          color: Colors.grey.withOpacity(0.1),
                        ),
                        Padding(padding: new EdgeInsets.all(12)),
                        QA_read_subFuncs().get_QnA_UIs(_qa_datas_list, s_width),
                        Padding(padding: new EdgeInsets.all(50)),
                      ],
                    ),
                  ),
                ),
                get_upbar(() {}, false, "Q&A",
                    in_width: s_width, callback_goBack: goback_to_main),
                show_loading(_is_loading, s_height, s_width, this),
              ])))),
    );
  }
}
