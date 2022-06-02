import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:swork_raon/common/rapivet_statics.dart';
import 'package:swork_raon/model/one_health_check.dart';
import 'package:swork_raon/rapivet/10_Result_plus.dart';

class ResultPlus_subFuncs {
  // 화면에 보이는대로
  List<String> _titles = [
    "Cetonas", // keton 케톤 stick 0
    "Glicose", // glucose 포도당   stick 1
    "Leucócitos", //  leukocyte 백혈구 stick 5
    "Nitrito", // nitrite 아질산염  stick 4
    "Sangue", // blood 잠혈  stick 3
    "pH", //ph 산 stick 6
    "Proteínas", // proteinuria 단백질   stick 2,
    "d"
  ];

  // title 과 대응되어야함.
  List<RESULT_PLUS_MODE> _resultPlust_mode = [
    RESULT_PLUS_MODE.KETON,
    RESULT_PLUS_MODE.GLUCOSE,
    RESULT_PLUS_MODE.LEUKOZYTEN,
    RESULT_PLUS_MODE.NITRITE,
    RESULT_PLUS_MODE.BLOOD,
    RESULT_PLUS_MODE.PH,
    RESULT_PLUS_MODE.PROTEIN,
    RESULT_PLUS_MODE.NOTHING
  ];

  String _get_dialogTitle() {
    if (RapivetStatics.selectedResultPlusMode == RESULT_PLUS_MODE.KETON) {
      return "Cetonas";
    }
    if (RapivetStatics.selectedResultPlusMode == RESULT_PLUS_MODE.GLUCOSE) {
      return "Glicose";
    }
    if (RapivetStatics.selectedResultPlusMode == RESULT_PLUS_MODE.LEUKOZYTEN) {
      return "Leucócitos";
    }
    if (RapivetStatics.selectedResultPlusMode == RESULT_PLUS_MODE.NITRITE) {
      return "Nitrito";
    }
    if (RapivetStatics.selectedResultPlusMode == RESULT_PLUS_MODE.BLOOD) {
      return "Sangue";
    }
    if (RapivetStatics.selectedResultPlusMode == RESULT_PLUS_MODE.PH) {
      return "pH";
    }
    if (RapivetStatics.selectedResultPlusMode == RESULT_PLUS_MODE.PROTEIN) {
      return "Proteínas";
    }
  }

  String _get_dialogContent() {
    if (RapivetStatics.selectedResultPlusMode == RESULT_PLUS_MODE.KETON) {
      //return "Em condições normais, a urina da maioria dos animais domésticos é livre de cetonas. Concentrações detectáveis de cetona podem ser originadas por situações fisiológicas como stress, exercício físico intenso e gestação.";
      return "As cetonas são uma substância química produzida pelo corpo quando este não é capaz de usar a glicose como fonte de energia, e passa a utilizar a gordura. \n\nPROVÁVEIS CAUSAS: Anorexia; Dietas pobres em carboidratos e rico em gorduras; Estresse; Exercícios intenso; Gestação. ";
    }
    if (RapivetStatics.selectedResultPlusMode == RESULT_PLUS_MODE.GLUCOSE) {
      // return "A presença de glicose na urina significa que a concentração excedeu o limiar renal. A medição é usada no diagnóstico e tratamento de desordens do metabolismo de carboidratos, incluindo Diabetes Mellitus, hiperglicemia e distúrbios hereditários. Normalmente não se detecta em animais saudáveis, embora pequenas quantidades possam ser secretadas por um rim não doente. Reações falso positivas podem ser produzidas por resíduos de produtos de limpeza contendo peróxido.";
      return "A glicose é uma das principais fontes de energia que o corpo do animal utiliza. Frequentemente, é possível detectar a glicose na urina dos cachorros com menos de 8 semanas de vida.\n\nPROVÁVEIS CAUSAS: Ingestão excessiva de carboidratos; Estresse.";
    }
    if (RapivetStatics.selectedResultPlusMode == RESULT_PLUS_MODE.LEUKOZYTEN) {
      //return "Leucócitos são indicações de doença inflamatórias renais ou do trato urinário. Urinas de animais saudáveis não contém leucócitos. Resultados falso-positivos podem ser causados por contaminação por secreções vaginais ou esmegma.";
      return "Geralmente as urinas dos pets saudáveis não contém leucócitos. A presença de leucócitos na urina indica inflamações renais ou infecções do sistema urinário. O número de leucócitos pode variar conforme a ação imunológica do corpo.\n\nPROVÁVEIS CAUSAS: Ambiente anti-higiênico.";
    }
    if (RapivetStatics.selectedResultPlusMode == RESULT_PLUS_MODE.NITRITE) {
      // return "O teste normalmente é negativo para animais sadios. Resultados negativos não excluem uma bacteriúria relevante. Antes do teste, deve diminuir a ingestão de líquidos, e descontinuar o uso de antibióticos e vitamina C. Um resultado negativo pode ocorrer devido às seguintes razões: bactérias que não apresentam nitrato redutase, dietas com baixos níveis de nitrato(animais carnívoros), aumento da diurese, altas concentrações de ácido ascórbico, ou incubação insuficiente da urina na bexiga.";
      return "O nitrito é produzido a partir dos nitratos naturais da urina pelas bactérias formadoras de nitrito. A identificação do nitrito é usada no diagnóstico de infecções do trato urinário. As bactérias formadoras de nitrito são: Escherichia coli, Staphylococcus aureus e Pseudomonas auruginosa. Elas possuem enzimas que reduzem o nitrato a nitrito. A infecção do trato urinário é detectado quando o nitrito está presente na urina. A maioria dos pets saudáveis não apresentam nitritos nas urinas. Para os que apresentam, é recomendável diminuir a ingestão de líquidos e interromper o uso de antibióticos e vitamina C (cerca de 3dias). \n\nPROVÁVEIS CAUSAS: Ambiente anti-higiênico; Ingestão excessiva de petiscos contendo alta quantidade de nitrito.";
    }
    if (RapivetStatics.selectedResultPlusMode == RESULT_PLUS_MODE.BLOOD) {
      //return "Reações falso positivas podem ser causadas por resíduos de produtos de limpeza, formalina ou atividade de oxidases microbianas oriundas de infecções do trato urinário. O significado de um resultado positivo varia de animal para animal. Para estabelecer um diagnóstico individual, é indispensável levar em consideração o quadro clínico do animal. O teste é normalmente negativo para animais saudáveis.";
      return "Indica níveis de sangue ocultos na urina. O sangue pode estar presente na urina em forma de glóbulos vermelhos(hematúria), hemoglobina(hemoglobinúria) ou mioglobina(pigmentúria muscular) livres.\n\nPROVÁVEIS CAUSAS: Exercícios físicos excessivo ou caminhada antes de fazer o teste; Ingestão excessiva de carnes, peixes(vermelhos), vegatais cru e frutas.";
    }
    if (RapivetStatics.selectedResultPlusMode == RESULT_PLUS_MODE.PH) {
      //return "A estimativa do pH é usada para avaliar a acidez ou a alcalinidade da urina dos animais sendo útil também no acompanhamento da urolitíase. Essas características podem estar relacionadas a vários distúrbios renais e metabólicos. O pH urinário dos animais está diretamente relacionado à nutrição.";
      return "A estimativa do pH pode variar com o tempo da digestão, tempo de armazenamento da urina, infecção bacteriana e com o equilíbrio do ácido-básico do corpo. O pH normal da urina é de 6.0~7.0. Geralmente o pH dos herbívoros(alcalino) é mais alto do que o pH dos carnívoros(ácido). \n\nPROVÁVEIS CAUSAS: Ingestão excessiva de carne; Vegetariano; Ingestão excessiva de petiscos contendo alta quantidade de grãos e amido.";
    }
    if (RapivetStatics.selectedResultPlusMode == RESULT_PLUS_MODE.PROTEIN) {
      // return "A identificação da proteína urinária é usada no diagnóstico e tratamento de infecções do trato urinário (geralmente acompanhada por hematúria, pH alcalino e reação positiva para nitrito) e afecções renais. O teste é normalmente negativo para a maioria dos animais domésticos, mas saudáveis podem apresentar traços de proteína na urina.";
      return "Chamamos de proteinúria quando uma grande quantidade de proteínas é filtrada pelos rins e excretada na urina. Para a maioria dos pets saudáveis as proteínas são retidas no corpo, apresentando poucas ou não apresentando proteínas na urina. \n\nPROVÁVEIS CAUSAS: Exercícios físicos excessivo ou caminhada antes de fazer o teste; Ingestão excessiva de alimentos ricos em proteínas, como carne.";
    }
  }

  List<String> _suspect_disease_ketoen = [
    "Diabetes",
    "Cesose",
    //"Acúmulo de\nácido láctico",
    "Acidose láctica\n(Acidose)"
  ];
  List<String> _suspect_disease_glucose = [
    "Diabetes",
    //"Hiperglicemia\nestressante",
    "Hiperglicemia\nde Estresse",
    "Doença renal"
  ];
  List<String> _suspect_disease_protein = [
    "Insuficiência\nrenal",
    "Amiloidose\nglomerular",
    "Glomerulinofrite",
    "Infecção do\ntrato urinário",
    "nothing",
    "nothing"
  ];
  List<String> _suspect_disease_blood = [
    "Urolitíase",
    "Cistite",
    "Doença\nhemolítica",
    "Tumor do\ntrato urinário",
    "Infecção do\ntrato urinário",
    "Distúrbio de\ncoagulação do sangue"
  ];
  List<String> _suspect_disease_nitrite = [
    "Cistite",
    "Uretrite",
    "Pielonefrite"
  ];
  List<String> _suspect_disease_leukozyten = [
    "Cistite",
    "Pielonefrite",
    "Infecção do\ntrato urinário"
  ];
  List<String> _suspect_disease_ph = [
    "Urolitíase",
    "Infecção do\ntrato urinário",
    "Acidose\nmetabólica",
    "Acidose\ntubular renal",
    "Alcalose \nmetabólica",
    "nothing"
  ];

  get_result_btns(double s_width, VoidCallback Callback_setState) {
    return Column(
      children: [
        for (int i = 0; i < 2; i++)
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (int j = 0; j < 4; j++)
                    Row(
                      children: [
                        Visibility(
                          visible: (i * 4 + j != 7) ? true : false,
                          child: _get_one_category_btn(
                            _resultPlust_mode[i * 4 + j],
                            s_width * 0.21,
                            Colors.white,
                            _titles[i * 4 + j],
                            Callback_setState,
                            font_size: 10,
                          ),
                        ),
                        Visibility(
                          visible: (i * 4 + j == 7) ? true : false,
                          child: Container(
                            width: s_width * 0.21,
                          ),
                        ),
                        Padding(
                            padding: (j == 3)
                                ? new EdgeInsets.all(0.001)
                                : new EdgeInsets.fromLTRB(
                                    0, 0, s_width * 0.02, 0))
                      ],
                    ),
                ],
              ),
              Padding(padding: new EdgeInsets.all(3.88))
            ],
          ),
      ],
    );
  }

  get_graphTable(BuildContext context, double s_width,
      List<OneHealthCheck> hcheck_data_list) {
    double result_talbe_width = s_width * 0.5;
    double result_talbe_height = 33;

    try {
      return Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              children: [
                Container(
                  width: s_width,
                  child: Column(
                    children: [
                      Padding(padding: new EdgeInsets.all(8)),
                      Container(
                        width: s_width * 0.9,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.all(
                              Radius.circular(8),
                            ),
                            boxShadow: [
                              BoxShadow(
                                blurRadius: 1,
                                spreadRadius: 2,
                                offset: Offset(0, 2),
                                color: Colors.grey.withOpacity(0.188),
                              )
                            ]),
                        child: Column(
                          children: [
                            Padding(padding: new EdgeInsets.all(20)),
                            // Text("Estatísiticas",
                            //     style: TextStyle(
                            //         fontWeight: FontWeight.bold,
                            //         fontSize: 11,
                            //         color: Colors.black54)),
                            // Padding(padding: new EdgeInsets.all(10)),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: s_width * 0.18,
                                      child: Image.asset(
                                          "assets/result_plus/normal_guide.png"),
                                    ),
                                    Padding(
                                        padding: new EdgeInsets.fromLTRB(
                                            0, 0, 0, 10)),
                                    _get_bar_graph(
                                        s_width,
                                        hcheck_data_list[
                                            hcheck_data_list.length - 1]),
                                  ],
                                ),
                                // get_one_temp_resultTable(
                                //     result_talbe_width, result_talbe_height),
                                Padding(
                                    padding: new EdgeInsets.fromLTRB(
                                        s_width * 0.08, 0, 0, 0)),
                                Container(
                                    width: s_width * 0.15,
                                    child: Image.asset(
                                      _is_normal(hcheck_data_list[
                                              hcheck_data_list.length - 1])
                                          ? "assets/result_plus/normal_mark.png"
                                          : "assets/result_plus/suspect_mark.png",
                                      fit: BoxFit.fitWidth,
                                    )),
                                Padding(
                                    padding: new EdgeInsets.fromLTRB(
                                        s_width * 0.02, 0, 0, 0)),
                              ],
                            ),
                            Padding(padding: new EdgeInsets.all(12)),
                            Stack(
                              children: [
                                Container(
                                    child: SizedBox(
                                        width: s_width * 0.7,
                                        height: s_width * 0.21,
                                        child: Image.asset(
                                          "assets/result_plus/grid.png",
                                          fit: BoxFit.fill,
                                        ))),
                                Container(
                                    child: SizedBox(
                                        width: s_width * 0.7,
                                        height: s_width * 0.21,
                                        child: LineChart(
                                            _make_mainChart(hcheck_data_list),
                                            swapAnimationDuration:
                                                Duration(seconds: 1)))),
                              ],
                            ),
                            Padding(padding: new EdgeInsets.all(10)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: s_width,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Material(
                        child: InkWell(
                          onTap: () {
                            show_detail(context);
                          },
                          child: Container(
                              width: s_width * 0.48,
                              height: 35,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(18),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      blurRadius: 5,
                                      spreadRadius: 2,
                                      offset: Offset(0, 3),
                                      color: Colors.grey.withOpacity(0.288),
                                    )
                                  ]),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Padding(
                                      padding:
                                          new EdgeInsets.fromLTRB(0, 0, 15, 0)),
                                  Text(
                                    _get_current_title(),
                                    style: TextStyle(fontSize: 16.5),
                                  ),
                                  Padding(
                                      padding:
                                          new EdgeInsets.fromLTRB(0, 0, 15, 0)),
                                  Icon(
                                    Icons.help,
                                    color: Colors.black.withOpacity(0.78),
                                  )
                                ],
                              )),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    } catch (e) {
      return Container();
    }
  }

  get_dieases_btns(double s_width) {
    List<String> DieasesList = _get_suspect_dieasesList();
    int lineCount = 1;
    if (DieasesList.length >= 4) lineCount = 2;

    return Column(
      children: [
        for (int i = 0; i < lineCount; i++)
          Column(
            children: [
              Row(
                children: [
                  Padding(
                      padding:
                          new EdgeInsets.fromLTRB(0, 0, s_width * 0.05, 0)),
                  for (int j = 0; j < 3; j++)
                    Row(
                      children: [
                        Visibility(
                            visible: DieasesList[i * 3 + j] != "nothing",
                            child: _get_one_dieases_btn(s_width * 0.27,
                                Colors.white, DieasesList[i * 3 + j], () {},
                                font_size: 10)),
                        Padding(
                            padding: new EdgeInsets.fromLTRB(
                                0, 0, (j <= 3) ? s_width * 0.04 : 0, 0))
                      ],
                    ),
                ],
              ),
              Padding(padding: new EdgeInsets.fromLTRB(0, 0, 0, 9)),
            ],
          ),
      ],
    );
  }

  void show_detail(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: new Text(
            _get_dialogTitle(),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.normal,
            ),
            textAlign: TextAlign.center,
          ),
          content: new Text(
            _get_dialogContent(),
            style: TextStyle(fontSize: 11.38, color: Colors.black54),
          ),
          actions: <Widget>[
            new FlatButton(
              child: new Text(
                "OK",
                style: TextStyle(color: Colors.black87),
              ),
              onPressed: () {
                Navigator.pop(context);
                FocusScope.of(context).unfocus();
              },
            ),
          ],
        );
      },
    );
  }

  // etc =======================================================================

  _get_bar_graph(double s_width, one_health_check this_healthcheck_data) {
    // server data --> local
    int current_index = _get_current_value(this_healthcheck_data);
    int total_count = _get_graph_maxY() + 1;

    // String mark_fileName = (is_normal)
    //     ? "assets/result_plus/bar_normal_mark.png"
    //     : "assets/result_plus/bar_suspect_mark.png";

    String mark_fileName = _is_normal(this_healthcheck_data)
        ? "assets/result_plus/bar_normal_mark.png"
        : "assets/result_plus/bar_suspect_mark.png";

    double bar_width = s_width * 0.55;
    double bar_height = bar_width / 4.5; // as image size

    double mark_width = bar_width / 18;

    double one_area_width = bar_width / total_count;
    double mark_left_padding =
        (one_area_width - mark_width) / 2 + one_area_width * current_index;

    return Stack(
      children: [
        Container(
          width: bar_width,
          height: bar_height, // as image size
          child: Image.asset(_get_bar_fileName()),
        ),
        Row(
          children: [
            Padding(
                padding: new EdgeInsets.fromLTRB(mark_left_padding, 0, 0, 0)),
            Container(
              width: mark_width,
              height: bar_height * 0.7,
              child: Image.asset(mark_fileName),
            ),
          ],
        ),
      ],
    );
  }

  String _get_bar_fileName() {
    String parentPath = "assets/result_plus/bar_";

    if (RapivetStatics.selectedResultPlusMode == RESULT_PLUS_MODE.KETON) {
      return parentPath + 'keton.png';
    }

    if (RapivetStatics.selectedResultPlusMode == RESULT_PLUS_MODE.GLUCOSE) {
      return parentPath + 'glucose.png';
    }

    if (RapivetStatics.selectedResultPlusMode == RESULT_PLUS_MODE.PROTEIN) {
      return parentPath + 'protein.png';
    }

    if (RapivetStatics.selectedResultPlusMode == RESULT_PLUS_MODE.BLOOD) {
      return parentPath + 'blood.png';
    }

    if (RapivetStatics.selectedResultPlusMode == RESULT_PLUS_MODE.NITRITE) {
      return parentPath + 'nitrite.png';
    }

    if (RapivetStatics.selectedResultPlusMode == RESULT_PLUS_MODE.LEUKOZYTEN) {
      return parentPath + 'leukozyten.png';
    }

    if (RapivetStatics.selectedResultPlusMode == RESULT_PLUS_MODE.PH) {
      return parentPath + 'ph.png';
    }
  }

  bool _is_normal(one_health_check this_healthCheck_data) {
    return this_healthCheck_data
        .isNormal(RapivetStatics.selectedResultPlusMode);
  }

  List<String> _get_suspect_dieasesList() {
    if (RapivetStatics.selectedResultPlusMode == RESULT_PLUS_MODE.KETON) {
      return _suspect_disease_ketoen;
    }

    if (RapivetStatics.selectedResultPlusMode == RESULT_PLUS_MODE.GLUCOSE) {
      return _suspect_disease_glucose;
    }

    if (RapivetStatics.selectedResultPlusMode == RESULT_PLUS_MODE.PROTEIN) {
      return _suspect_disease_protein;
    }

    if (RapivetStatics.selectedResultPlusMode == RESULT_PLUS_MODE.BLOOD) {
      return _suspect_disease_blood;
    }

    if (RapivetStatics.selectedResultPlusMode == RESULT_PLUS_MODE.NITRITE) {
      return _suspect_disease_nitrite;
    }

    if (RapivetStatics.selectedResultPlusMode == RESULT_PLUS_MODE.LEUKOZYTEN) {
      return _suspect_disease_leukozyten;
    }

    if (RapivetStatics.selectedResultPlusMode == RESULT_PLUS_MODE.PH) {
      return _suspect_disease_ph;
    }
  }

  String _get_current_title() {
    for (int i = 0; i < _resultPlust_mode.length; i++) {
      if (_resultPlust_mode[i] == RapivetStatics.selectedResultPlusMode) {
        return _titles[i];
      }
    }

    return "nothing";
  }

  Widget _get_one_category_btn(
      RESULT_PLUS_MODE in_result_plus_mode,
      double in_width,
      Color bgcolor,
      String text,
      VoidCallback Callback_setState,
      {double in_height = 37.88,
      double font_size = 18.88}) {
    return Container(
      height: in_height,
      width: in_width,
      child: OutlinedButton(
          style: OutlinedButton.styleFrom(
            shape: new RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(30.0)),
            tapTargetSize: MaterialTapTargetSize.padded,
            backgroundColor:
                (in_result_plus_mode == RapivetStatics.selectedResultPlusMode)
                    ? RapivetStatics.appBlue.withOpacity(0.88)
                    : bgcolor,
          ),
          onPressed: () {
            if (in_result_plus_mode == RapivetStatics.selectedResultPlusMode)
              return;

            RapivetStatics.selectedResultPlusMode = in_result_plus_mode;

            Callback_setState();
          },
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              text,
              style: TextStyle(
                fontFamily: 'Noto',
                color: (in_result_plus_mode ==
                        RapivetStatics.selectedResultPlusMode)
                    ? Colors.white
                    : Colors.black,
                fontSize: font_size,
              ),
              maxLines: 1,
              overflow: TextOverflow.visible,
            ),
          )),
    );
  }

  Widget _get_one_dieases_btn(double in_width, Color bgcolor, String text,
      VoidCallback Callback_setState,
      {double in_height = 40.88, double font_size = 18.88}) {
    return Container(
      height: in_height,
      width: in_width,
      child: OutlinedButton(
          style: OutlinedButton.styleFrom(
            shape: new RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(10.0)),
            tapTargetSize: MaterialTapTargetSize.padded,
            backgroundColor: bgcolor,
          ),
          //onPressed: () {},
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Noto',
                color: Colors.black.withOpacity(0.5),
                fontSize: font_size,
              ),
              maxLines: 2,
              overflow: TextOverflow.visible,
            ),
          )),
    );
  }

  // graph area =================================================================

  //https://velog.io/@adbr/flutter-line-chart%EA%BA%BD%EC%9D%80%EC%84%A0-%EA%B7%B8%EB%9E%98%ED%94%84-%EA%B5%AC%ED%98%84%ED%95%98%EA%B8%B02-flutter-flchart-example#%EC%82%AC%EC%9A%A9%ED%95%9C-%EB%9D%BC%EC%9D%B4%EB%B8%8C%EB%9F%AC%EB%A6%AC
  LineChartData _mainChart() {
    int max_y = _get_graph_maxY();

    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: Color(0x00000000),
            strokeWidth: 0,
          );
        },
        getDrawingVerticalLine: (value) {
          return FlLine(
            color: Color(0xff37434d),
            strokeWidth: 0,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: false,
        bottomTitles: SideTitles(
          showTitles: true,
          reservedSize: 22,
          textStyle: const TextStyle(
              color: Color(0xff68737d),
              fontWeight: FontWeight.bold,
              fontSize: 16),
          getTitles: (value) {
            print('bottomTitles $value');
            switch (value.toInt()) {
            }
            return '';
          },
          margin: 8,
        ),
        leftTitles: SideTitles(
          showTitles: false,
          textStyle: const TextStyle(
            color: Color(0xff67727d),
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
          getTitles: (value) {
            print('leftTitles $value');
            switch (value.toInt()) {
            }
            return '';
          },
          reservedSize: 15,
          margin: 12,
        ),
      ),
      borderData: FlBorderData(
          show: false,
          border: Border.all(color: const Color(0xff37434d), width: 1)),
      minX: 0,
      maxX: 7,
      minY: -1,
      maxY: max_y.toDouble() + 1,
      lineBarsData: [
        LineChartBarData(
          spots: [
            FlSpot(0, Random().nextInt(max_y).toDouble()),
            FlSpot(1, Random().nextInt(max_y).toDouble()),
            FlSpot(2, Random().nextInt(max_y).toDouble()),
            FlSpot(3, Random().nextInt(max_y).toDouble()),
            FlSpot(4, Random().nextInt(max_y).toDouble()),
            FlSpot(5, Random().nextInt(max_y).toDouble()),
            FlSpot(6, Random().nextInt(max_y).toDouble()),
            FlSpot(7, Random().nextInt(max_y).toDouble()),
            // FlSpot(6, 4),
          ],
          isCurved: true,
          colors: _gradientColors,
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: false,
          ),
          belowBarData: BarAreaData(
            show: false,
            colors:
                _gradientColors.map((color) => color.withOpacity(0.3)).toList(),
          ),
        ),
      ],
    );
  }

  LineChartData _make_mainChart(List<OneHealthCheck> hcheck_data_list) {
    int min_y = -1; // grid 안에 그래프 보일 수 있게.
    int max_y = _get_graph_maxY();

    int min_x = 0;
    int max_x = hcheck_data_list.length - 1;

    if (max_x >= 10) max_x = 9;
    if (max_x == 0) max_x = 1;

    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: Color(0x00000000),
            strokeWidth: 0,
          );
        },
        getDrawingVerticalLine: (value) {
          return FlLine(
            color: Color(0xff37434d),
            strokeWidth: 0,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: false,
        bottomTitles: SideTitles(
          showTitles: true,
          reservedSize: 22,
          textStyle: const TextStyle(
              color: Color(0xff68737d),
              fontWeight: FontWeight.bold,
              fontSize: 16),
          getTitles: (value) {
            print('bottomTitles $value');
            switch (value.toInt()) {
            }
            return '';
          },
          margin: 8,
        ),
        leftTitles: SideTitles(
          showTitles: false,
          textStyle: const TextStyle(
            color: Color(0xff67727d),
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
          getTitles: (value) {
            print('leftTitles $value');
            switch (value.toInt()) {
            }
            return '';
          },
          reservedSize: 15,
          margin: 12,
        ),
      ),
      borderData: FlBorderData(
          show: false,
          border: Border.all(color: const Color(0xff37434d), width: 1)),
      minX: min_x.toDouble(),
      maxX: max_x.toDouble(),
      minY: min_y.toDouble(),
      maxY: max_y.toDouble() + 1,
      lineBarsData: [
        LineChartBarData(
          spots: _get_FlSpot_datas(hcheck_data_list),
          isCurved: true,
          colors: _gradientColors,
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: false,
          ),
          belowBarData: BarAreaData(
            show: false,
            colors:
                _gradientColors.map((color) => color.withOpacity(0.3)).toList(),
          ),
        ),
      ],
    );
  }

  List<Color> _gradientColors = [
    const Color(0xff6e91bb),
    const Color(0xff6e91bb),
    // const Color(0xff02d39a),
  ];

  int _get_graph_maxY() {
    if (RapivetStatics.selectedResultPlusMode == RESULT_PLUS_MODE.KETON) {
      return 4;
    }

    if (RapivetStatics.selectedResultPlusMode == RESULT_PLUS_MODE.GLUCOSE) {
      return 5;
    }

    if (RapivetStatics.selectedResultPlusMode == RESULT_PLUS_MODE.PROTEIN) {
      return 4;
    }

    if (RapivetStatics.selectedResultPlusMode == RESULT_PLUS_MODE.BLOOD) {
      return 6;
    }

    if (RapivetStatics.selectedResultPlusMode == RESULT_PLUS_MODE.NITRITE) {
      return 2;
    }

    if (RapivetStatics.selectedResultPlusMode == RESULT_PLUS_MODE.LEUKOZYTEN) {
      return 3;
    }

    if (RapivetStatics.selectedResultPlusMode == RESULT_PLUS_MODE.PH) {
      return 5;
    }
  }

  int _get_current_value(one_health_check this_healthcheck_data) {
    if (RapivetStatics.selectedResultPlusMode == RESULT_PLUS_MODE.KETON) {
      return this_healthcheck_data.ketone;
    }

    if (RapivetStatics.selectedResultPlusMode == RESULT_PLUS_MODE.GLUCOSE) {
      return this_healthcheck_data.glucose;
    }

    if (RapivetStatics.selectedResultPlusMode == RESULT_PLUS_MODE.PROTEIN) {
      return this_healthcheck_data.proteinuria;
    }

    if (RapivetStatics.selectedResultPlusMode == RESULT_PLUS_MODE.BLOOD) {
      return this_healthcheck_data.blood;
    }

    if (RapivetStatics.selectedResultPlusMode == RESULT_PLUS_MODE.NITRITE) {
      return this_healthcheck_data.nitrite;
    }

    if (RapivetStatics.selectedResultPlusMode == RESULT_PLUS_MODE.LEUKOZYTEN) {
      return this_healthcheck_data.leukocyte;
    }

    if (RapivetStatics.selectedResultPlusMode == RESULT_PLUS_MODE.PH) {
      return this_healthcheck_data.ph;
    }
  }

  List<FlSpot> _get_FlSpot_datas(List<OneHealthCheck> hcheck_data_list) {
    List<int> int_datas = [];

    if (RapivetStatics.selectedResultPlusMode == RESULT_PLUS_MODE.KETON) {
      for (int i = 0; i < hcheck_data_list.length; i++) {
        int_datas.add(hcheck_data_list[i].ketone);
      }
    }
    if (RapivetStatics.selectedResultPlusMode == RESULT_PLUS_MODE.GLUCOSE) {
      for (int i = 0; i < hcheck_data_list.length; i++) {
        int_datas.add(hcheck_data_list[i].glucose);
      }
    }
    if (RapivetStatics.selectedResultPlusMode == RESULT_PLUS_MODE.PROTEIN) {
      for (int i = 0; i < hcheck_data_list.length; i++) {
        int_datas.add(hcheck_data_list[i].proteinuria);
      }
    }
    if (RapivetStatics.selectedResultPlusMode == RESULT_PLUS_MODE.BLOOD) {
      for (int i = 0; i < hcheck_data_list.length; i++) {
        int_datas.add(hcheck_data_list[i].blood);
      }
    }
    if (RapivetStatics.selectedResultPlusMode == RESULT_PLUS_MODE.NITRITE) {
      for (int i = 0; i < hcheck_data_list.length; i++) {
        int_datas.add(hcheck_data_list[i].nitrite);
      }
    }
    if (RapivetStatics.selectedResultPlusMode == RESULT_PLUS_MODE.LEUKOZYTEN) {
      for (int i = 0; i < hcheck_data_list.length; i++) {
        int_datas.add(hcheck_data_list[i].leukocyte);
      }
    }
    if (RapivetStatics.selectedResultPlusMode == RESULT_PLUS_MODE.PH) {
      for (int i = 0; i < hcheck_data_list.length; i++) {
        int_datas.add(hcheck_data_list[i].ph);
      }
    }

    // max data 갯수 10개
    if (int_datas.length > 10) {
      List<int> new_datas = [];

      for (int i = 0; i < 10; i++) {
        new_datas.add(int_datas[int_datas.length - 10 + i]);
      }
      int_datas = new_datas;
    }

    // 데이터가 하나만 있을 수 없으므로
    if (int_datas.length == 1) {
      int_datas.add(int_datas[0]);
    }

    List<FlSpot> spot_lists = [];

    for (int i = 0; i < int_datas.length; i++) {
      FlSpot this_spot = FlSpot(i.toDouble(), int_datas[i].toDouble());
      spot_lists.add(this_spot);
    }

    return spot_lists;
  }
}
