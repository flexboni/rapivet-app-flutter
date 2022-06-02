import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:page_transition/page_transition.dart';
import 'package:swork_raon/common/JToast.dart';
import 'package:swork_raon/rapivet/12_QA_read.dart';
import 'package:swork_raon/rapivet/scene_sub_functions/12_2_QA_read_subFuncs.dart';
import 'package:swork_raon/rapivet/scene_sub_functions/common_ui.dart';

import '../common/rapivet_statics.dart';

TextEditingController _question_txtedit_control;
bool _is_loading = false;

class QA_write extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _QA_write_home();
}

class _QA_write_home extends State<StatefulWidget>
    with TickerProviderStateMixin {
  @override
  void initState() {
    _is_loading = false;
    super.initState();
    _question_txtedit_control = TextEditingController();
    // _question_txtedit_control.text="a";
  }

  @override
  Widget build(BuildContext context) {
    double s_width = MediaQuery.of(context).size.width;
    double s_height = MediaQuery.of(context).size.height;

    callback_goto_QA_read() {
      Navigator.pushReplacement(context,
          PageTransition(type: PageTransitionType.fade, child: QA_read()));
    }

    onClick_write() async {
      if (_question_txtedit_control.text.trim() == "") {
        JToast().show_toast("Escreva a sua opinião ou a dúvida.", true);
        return;
      }

      setState(() {
        _is_loading = true;
      });

      bool result = await QA_read_subFuncs().write_QnA_toServer(
          RapivetStatics.token, _question_txtedit_control.text);

      if (result) {
        callback_goto_QA_read();
      }

      setState(() {
        _is_loading = false;
      });
    }

    return Scaffold(
      backgroundColor: RapivetStatics.appBG,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: SafeArea(
          child: Stack(
            children: [
              Container(
                child: SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  scrollDirection: Axis.vertical,
                  child: Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(padding: new EdgeInsets.all(42)),
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
                              "Perguntas & Respostas",
                              style: TextStyle(
                                  fontSize: 17,
                                  color: Colors.black.withOpacity(0.7)),
                            ),
                          ],
                        ),
                        Padding(padding: new EdgeInsets.all(15)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: s_width * 0.9,
                              alignment: Alignment.centerLeft,
                              child: TextFormField(
                                controller: _question_txtedit_control,
                                minLines: 10,
                                maxLines: 10,
                                keyboardType: TextInputType.multiline,
                                maxLength: 300,
                                style: TextStyle(
                                    fontSize: 14.5,
                                    color: Colors.black.withOpacity(0.6)),
                                decoration: InputDecoration(
                                  fillColor: Colors.white,
                                  filled: true,
                                  // labelStyle: TextStyle(fontSize: 10),
                                  // hoverColor: Colors.red,
                                  //  RapivetStatics.app_blue.withOpacity(0.1),
                                  hintText: 'Em breve retornaremos o contato.',
                                  hintStyle: TextStyle(
                                      color: Colors.grey.withOpacity(0.7),
                                      fontSize: 15),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(7.0),
                                    borderSide: BorderSide(
                                        color: RapivetStatics.normalUILineColor,
                                        width: 1.5),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: RapivetStatics.appBlue,
                                        width: 1.0),
                                    borderRadius: BorderRadius.circular(7.0),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Padding(padding: new EdgeInsets.all(15)),
                        get_one_btn(
                            s_width * 0.9, RapivetStatics.appBlue, "Cadastrar",
                            () {
                          onClick_write();
                        }, in_height: 55),
                      ],
                    ),
                  ),
                ),
              ),
              Container(
                width: s_width,
                //color: Colors.redAccent,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    get_upbar(() {}, false, "Q&A",
                        in_width: s_width,
                        callback_goBack: callback_goto_QA_read),
                  ],
                ),
              ),
              show_loading(_is_loading, s_height, s_width, this),
            ],
          ),
        ),
      ),
    );
  }
}
