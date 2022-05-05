import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as phttp;
import 'package:swork_raon/common/rapivetStatics.dart';
import 'package:swork_raon/model/one_QA_data.dart';

class QA_read_subFuncs {
  get_question_partUI(double s_width, String txt, String date_txt) {
    return Container(
      alignment: Alignment.center,
      width: s_width * 0.9,
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
      child: Column(
        children: [
          Padding(padding: new EdgeInsets.all(10)),
          Container(
            width: s_width * 0.8,
            child: Text(
              txt,
              style: TextStyle(fontSize: 14.5, color: Colors.black54),
            ),
          ),
          Padding(padding: new EdgeInsets.all(15)),
          Container(
              width: s_width * 0.8,
              alignment: Alignment.bottomRight,
              child: Text(
                get_date_inFomat(date_txt),
                style: TextStyle(
                    fontSize: 12, color: Colors.grey.withOpacity(0.7)),
              )),
          Padding(padding: new EdgeInsets.all(8)),
        ],
      ),
    );
  }

  get_answer_partUI(double s_width, String txt, String date_txt) {
    return Container(
      alignment: Alignment.center,
      width: s_width * 0.9,
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
      child: Column(
        children: [
          Padding(padding: new EdgeInsets.all(7)),
          Row(
            children: [
              Padding(
                  padding: new EdgeInsets.fromLTRB(s_width * 0.04, 0, 0, 0)),
              Container(
                  width: 50,
                  child: Image.asset('assets/main_img/doctor_icon.png')),
            ],
          ),
          Padding(padding: new EdgeInsets.all(5)),
          Container(
            width: s_width * 0.8,
            child: Text(
              txt,
              style: TextStyle(fontSize: 14.5, color: Colors.black54),
            ),
          ),
          Padding(padding: new EdgeInsets.all(15)),
          Container(
              width: s_width * 0.8,
              alignment: Alignment.bottomRight,
              child: Text(
                get_date_inFomat(date_txt),
                // date_txt,
                style: TextStyle(
                    fontSize: 12, color: Colors.grey.withOpacity(0.7)),
              )),
          Padding(padding: new EdgeInsets.all(8)),
        ],
      ),
    );
  }

  String get_date_inFomat(String date_txt) {
    if (date_txt.trim() == "") return ".";

    return rapivetStatics.converTime_to_displlay(date_txt.trim(),
        in_format: "yyyy-MM-dd HH:mm:ss");
  }

  Future<List<one_QA_data>> get_QnA_fromServer(String token) async {
    var uri = Uri.parse(rapivetStatics.baseURL + "/qa/read/1/1000");

    var response = await phttp.get(
      uri,
      headers: {HttpHeaders.authorizationHeader: "Bearer " + token},
    );

    print("${response.headers}");
    print("${response.statusCode}");
    print("${response.body}");

    // create return data ==================================================
    try {
      var json_data = json.decode(response.body);
      String total_count_str = json_data["data"]["total_count"].toString();
      int total_count = int.parse(total_count_str);

      List<one_QA_data> qa_datas = [];

      for (int i = 0; i < total_count; i++) {
        one_QA_data this_qa_data = one_QA_data();

        this_qa_data.question =
            json_data["data"]["items"][i]["question"].toString();
        this_qa_data.answer =
            json_data["data"]["items"][i]["answer"].toString();
        this_qa_data.question_date =
            json_data["data"]["items"][i]["created_at"].toString();
        this_qa_data.answer_created_at =
            json_data["data"]["items"][i]["answer_created_at"].toString();

        qa_datas.add(this_qa_data);
      }

      return qa_datas;
    } catch (e) {
      return [];
    }
  }

  Future<bool> write_QnA_toServer(String token, String question) async {
    String url = rapivetStatics.baseURL + "/qa/write";
    var uri = Uri.parse(url);

    Map<String, String> headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      "Authorization": "Bearer " + token
    };

    Map data = {"question": question};

    var body = json.encode(data);
    var response = await phttp.post(uri, headers: headers, body: body);

    try {
      var json_data = json.decode(response.body);

      print("${response.headers}");
      print("${response.statusCode}");
      print("${response.body}");

      if (json_data["msg"].toString() == "success")
        return true;
      else
        return false;
    } catch (e) {}

    return false;
  }

  get_QnA_UIs(List<one_QA_data> qa_datalist, double s_width) {
    if (qa_datalist == [] || qa_datalist.length == 0) {
      return Container(
        height: 0.01,
      );
    }

    return Column(
      children: [
        for (int i = 0; i < qa_datalist.length; i++)
          Column(children: [
            QA_read_subFuncs().get_question_partUI(
                s_width, qa_datalist[i].question, qa_datalist[i].question_date),
            Padding(padding: new EdgeInsets.all(6)),
            Visibility(
                visible: (qa_datalist[i].answer.trim() != ""),
                child: QA_read_subFuncs().get_answer_partUI(
                    s_width,
                    qa_datalist[i].answer.trim(),
                    qa_datalist[i].answer_created_at)),
            Padding(padding: new EdgeInsets.all(9)),
          ]),
      ],
    );
  }
}
