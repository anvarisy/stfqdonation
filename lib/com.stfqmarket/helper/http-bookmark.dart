import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:qbsdonation/com.stfqmarket/helper/sessionmanager.dart';

class Bookmark {
  static Future<bool> addBookmark(String userId, String productId) async {
    final sessionData = await SessionManager.sessionData;
    final response = await http.post(
      'http://rest-netfarm.daf-q.id/add-bookmark/',
      headers: <String, String>{
        'Authorization': 'Token ${sessionData.token}',
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        'user_id': userId,
        'product_id': productId,
      }),
    );

    if ([200, 201].contains(response.statusCode)) {
      var data = json.decode(response.body);
      print(data);

      return true;
    }
    return false;
  }

  static Future<bool> delBookmark(int idb) async {
    final sessionData = await SessionManager.sessionData;
    final response = await http.post(
      'http://rest-netfarm.daf-q.id/del-bookmark/',
      headers: <String, String>{
        'Authorization': 'Token ${sessionData.token}',
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        'idb': idb,
      }),
    );

    if ([200, 201].contains(response.statusCode)) {
      var data = json.decode(response.body);
      print(data);

      return true;
    }
    return false;
  }
}