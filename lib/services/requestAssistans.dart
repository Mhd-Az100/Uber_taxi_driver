import 'dart:convert';

import 'package:http/http.dart' as http;

class RequestAssistant {
  static Future<dynamic> getRequsest(String url) async {
    http.Response res = await http.get(Uri.parse(url));
    try {
      if (res.statusCode == 200) {
        String body = res.body;
        var data = jsonDecode(body);
        return data as Map<String, dynamic>;
      } else {
        return "failed";
      }
    } catch (e) {
      return "failed";
    }
  }
}
