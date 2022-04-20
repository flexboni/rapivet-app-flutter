import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class JToast {
  show_toast(String msg, bool is_short) {
    Fluttertoast.cancel();

    Fluttertoast.showToast(
        msg: msg,
        toastLength: (is_short)?Toast.LENGTH_SHORT:Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.black87.withOpacity(0.7),
        textColor: Colors.white,
        fontSize: 13.0);
  }
}
