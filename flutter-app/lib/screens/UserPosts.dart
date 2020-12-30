import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import '../main.dart';
import 'WpPost.dart';

class UserPosts extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final UserPostsArguments args = ModalRoute.of(context).settings.arguments;
    final String authenticationToken = args.authenticationToken;
    final String WS_url_get_userposts = args.WS_url_get_userposts;
    final String WS_url_get_post  = args.WS_url_get_post;

    Future<WpUserPost> _futureWpUserPost = getUserPost(WS_url_get_userposts, authenticationToken);

    return
      Center(
        child: FutureBuilder<WpUserPost>(
          future: _futureWpUserPost,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              List data;
              data = snapshot.data.usersposts;

              return new Scaffold(
                appBar: AppBar(
                    title: Text("Published by the logged user")
                ),
                //# Reference: api.flutter.dev/flutter/widgets/ListView-class.html
                body: new ListView.builder(
                  itemCount: data == null ? 0 : data.length,
                  itemBuilder: (BuildContext context, int index){
                    return new Container(
                      child: new Center(
                        child: new Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            new Card(
                              child: new Container(
                                child:
                                ElevatedButton(
                                  child: Text(data[index]['title']),
                                  onPressed: () {
                                    print(data[index]['_ID']);
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => WpPost(),
                                        settings: RouteSettings(
                                          arguments: ScreenArguments(
                                            WS_url_get_post,
                                            authenticationToken,
                                            data[index]['_ID'],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                padding: EdgeInsets.all(20),
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  },
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


//# WpUserPost
Future<WpUserPost> getUserPost(String url, String authenticationToken) async {
  Map<String, String> headers = {"Content-type": "application/json; charset=UTF-8"};
  String json = '{"authenticationToken": "${authenticationToken}"}';
  Response response = await post(url, headers: headers, body: json);
  int statusCode = response.statusCode;
  String body = response.body;
  print('getUserPost');
  print(body);
  if (response.statusCode == 200) {
    return WpUserPost.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('authenticationToken failed.');
  }
}

class WpUserPost {
  final bool success;
  final String message;
  final int user_id;
  final String authenticationToken;
  final List usersposts;

  WpUserPost({this.success, this.message, this.user_id, this.authenticationToken, this.usersposts});

  factory WpUserPost.fromJson(Map<String, dynamic> json) {
    return WpUserPost(
        success: json['success'],
        message: json['message'],
        user_id: json['user_id'],
        authenticationToken: json['authenticationToken'],
        usersposts: json['usersposts']
    );
  }
}

//# Reference: https://flutter.dev/docs/cookbook/navigation/navigate-with-arguments
class ScreenArguments {
  final String WS_url_get_post;
  final String authenticationToken;
  final int post_id;

  ScreenArguments(this.WS_url_get_post, this.authenticationToken, this.post_id);
}