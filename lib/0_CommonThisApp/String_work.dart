import 'dart:core';

class String_work {
  List<String> get_divided_strs(String str, String indicator) {

    List<String> outlist = [];

    if (str.indexOf(indicator) == -1){
      outlist.add(str);
      return outlist;
    }

    str = str.trim();

    while (true) {
      int index = str.indexOf(indicator);

      if (index == -1) {
        outlist.add(str);
        break;
      }

      String value = str.substring(0, index);

      outlist.add(value);

      str = str.substring(index + 1);
      str = str.trim();
    }

    return outlist;
  }
}
