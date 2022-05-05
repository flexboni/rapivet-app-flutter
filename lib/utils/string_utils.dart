import 'dart:core';

class StringUtils {
  List<String> getSeparatedValues(String value, String letter) {
    List<String> outList = [];

    if (value.indexOf(letter) == -1) {
      outList.add(value);
      return outList;
    }

    value = value.trim();

    while (true) {
      int index = value.indexOf(letter);
      if (index == -1) {
        outList.add(value);
        break;
      }

      outList.add(value.substring(0, index));

      value = value.substring(index + 1);
      value = value.trim();
    }

    return outList;
  }
}
