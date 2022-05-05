import 'dart:math';

class AntiCacheURL {
  String URLAntiCacheRandomizer(String url) {
    String r = "";

    Random random = new Random();
    int randomNumber = 1000000 + random.nextInt(7000000);
    r += randomNumber.toString();
    randomNumber = 1000000 + random.nextInt(7000000);
    r += randomNumber.toString();

    String result = url + "?p=" + r;
    return result;
  }
}
