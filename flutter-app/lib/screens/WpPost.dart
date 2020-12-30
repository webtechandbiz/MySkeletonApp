import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:http/http.dart';
import 'package:network_send_data_b/screens/UserPosts.dart';

class WpPost extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ScreenArguments args = ModalRoute.of(context).settings.arguments;
    final String authenticationToken = args.authenticationToken;
    final String WS_url_get_post  = args.WS_url_get_post;
    final int post_id = args.post_id;
    Future<WpSinglePost> _futureWpSinglePost = getWpPost(WS_url_get_post, authenticationToken, post_id);

    return
      Center(
        child: FutureBuilder<WpSinglePost>(
          future: _futureWpSinglePost,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              List data;
              data = snapshot.data.categories;

              return new Scaffold(
                appBar: AppBar(
                    title: Text("Wp post")
                ),
                body: Container(
                      child: new Center(
                        child: new Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            Html(
                              data: "<img src=""${snapshot.data.imgurl}"" />",
                            ),
                            Html(
                              data: "<h1>${snapshot.data.title}</h1>",
                            ),
                            Html(
                              data: "${snapshot.data.description}",
                            ),
                          ],
                        ),
                      ),
                    ),
                );

            } else if (snapshot.hasError) {
              return Text("ERROR: ${snapshot.error}");
            }

            return CircularProgressIndicator();
          },
        ),
      );
  }
}


//# WpPost
Future<WpSinglePost> getWpPost(String url, String authenticationToken, int post_id) async {
  Map<String, String> headers = {"Content-type": "application/json; charset=UTF-8"};
  String json = '{"authenticationToken": "${authenticationToken}", "post_id": "${post_id}"}';
  Response response = await post(url, headers: headers, body: json);
  int statusCode = response.statusCode;
  String body = response.body;

  if (response.statusCode == 200) {
    return WpSinglePost.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('authenticationToken failed.');
  }
}

class WpSinglePost {
  final bool success;
  final String message;
  final int post_id;
  final String authenticationToken;
  final List categories;
  final String title;
  final String description;
  final String imgurl;

  WpSinglePost({
    this.success, this.message, this.post_id, this.authenticationToken, this.categories,
    this.title, this.description, this.imgurl});

  factory WpSinglePost.fromJson(Map<String, dynamic> json) {
    return WpSinglePost(
        success: json['success'],
        message: json['message'],
        post_id: json['post_id'],
        authenticationToken: json['authenticationToken'],
        categories: json['categories'],

        title: json['title'],
        description: json['description'],
        imgurl: (json['imgurl'] != null ? json['imgurl'] : '')
    );
  }
}
