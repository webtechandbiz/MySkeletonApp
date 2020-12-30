import 'dart:convert';
import 'package:http/http.dart';

//# WpLogin
Future<WpLogin> doLogin(String url, String _username, String _password) async {
  Map<String, String> headers = {"Content-type": "application/json; charset=UTF-8"};
  String json = '{"usernamedolifrives": "${_username}", "passwordwrochophag": "${_password}"}';
  Response response = await post(url, headers: headers, body: json);
  int statusCode = response.statusCode;
  String body = response.body;
  if (response.statusCode == 200) {
    return WpLogin.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Login failed.');
  }
}

class WpLogin {
  final bool success;
  final String message;
  final int user_id;
  final String authenticationToken;

  WpLogin({this.success, this.message, this.user_id, this.authenticationToken});

  factory WpLogin.fromJson(Map<String, dynamic> json) {
    return WpLogin(
        success: json['success'],
        message: json['message'],
        user_id: json['user_id'],
        authenticationToken: json['authenticationToken']
    );
  }
}
