import 'dart:convert';

import 'package:http/http.dart' as http;

class HttpRequestManager {
  static Future<String?> registerToAppServer({
    required String username,
    required String password,
  }) async {
    Map<String, String> params = {};
    params["userAccount"] = username;
    params["userPassword"] = password;

    var uri = Uri.https("a41.easemob.com", "/app/chat/user/register");

    var client = http.Client();

    var response = await client.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(params),
    );
    if (response.statusCode == 200) {
      return response.body;
    }

    return null;
  }

  static Future<String?> loginToAppServer({
    required String username,
    required String password,
  }) async {
    Map<String, String> params = {};
    params["userAccount"] = username;
    params["userPassword"] = password;

    var uri = Uri.https("a41.easemob.com", "/app/chat/user/login");

    var client = http.Client();

    var response = await client.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(params),
    );
    if (response.statusCode == 200) {
      return response.body;
    }
    return null;
  }
}
