
import 'dart:math';

import 'package:qbsdonation/com.stfqmarket/helper/constant.dart';

class Generator {
  String generateRandomId() {
    Random random = Random();
    DateTime dateNow = DateTime.now();

    String id = '${dateNow.millisecondsSinceEpoch}';
    if (id.length > 14) {
      id = id.substring(0, 15);
    }
    for (var i = 0; i < id.length; ++i) {
      if (i%2 == 0 && id[i] != ' ') continue;

      int rand = random.nextInt(Constant.ALPHABET.length);
      id = id.replaceRange(i, i+1, Constant.ALPHABET[rand]);
    }

    return id;
  }
}