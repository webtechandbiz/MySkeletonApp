import 'dart:async';
import 'package:flutter/material.dart';
import 'package:network_send_data_b/screens/UserPosts.dart';
import 'package:network_send_data_b/screens/LatestPosts.dart';
import 'package:network_send_data_b/screens/WpLogin.dart';

void main() {

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  MyApp({Key key}) : super(key: key);

  @override
  _MyAppState createState() {
    return _MyAppState();
  }
}

class _MyAppState extends State<MyApp> {
  final TextEditingController _cntrl_name = TextEditingController(text: "");
  final TextEditingController _cntrl_psw = TextEditingController(text: "");

  final String WS_url_login = '<YOUR_DOMAIN>/wp-json/remote-login-vojocheruh/login-lutanithet';
  final String WS_url_get_userposts = '<YOUR_DOMAIN>/wp-json/remote-login-vojocheruh/fetch-user-personal-posts-lutanithet';
  final String WS_url_get_post = '<YOUR_DOMAIN>/wp-json/remote-login-vojocheruh/get-wp-post-lutanithet';

  Future<WpLogin> _futureWpLogin;
  Future<WpUserPost> _futureWpUserPost;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Login'),
        ),
        body: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.all(8.0),
          child: (_futureWpLogin == null) ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextField(
                controller: _cntrl_name,
                decoration: InputDecoration(hintText: 'Enter Email'),
              ),
              TextField(
                controller: _cntrl_psw,
                decoration: InputDecoration(hintText: 'Enter Password'),
              ),
              ElevatedButton(
                child: Text('Login to WP'),
                onPressed: () {
                  setState(() {
                    _futureWpLogin = doLogin(WS_url_login, _cntrl_name.text, _cntrl_psw.text);
                  });
                },
              ),
            ],
          )
          : FutureBuilder<WpLogin>(
            future: _futureWpLogin,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Scaffold(
                    body: Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.all(8.0),
                        child:
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text((_futureWpUserPost != null) ? '_futureWpUserPost' : snapshot.data.message),
                            ElevatedButton(
                              child: Text('Get user\'s posts from WP'),
                              onPressed: () {
                                setState(() {
                                  //# Reference: https://flutter.dev/docs/cookbook/navigation/passing-data
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => UserPosts(),
                                      settings: RouteSettings(
                                        arguments: UserPostsArguments(
                                          snapshot.data.authenticationToken,
                                          WS_url_get_userposts,
                                          WS_url_get_post
                                        ),
                                      ),
                                    ),
                                  );
                                });
                              },
                            ),
                            //# Latest posts
                            ElevatedButton(
                              child: Text('Get latest posts from WP'),
                              onPressed: () {
                                setState(() {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => LatestPosts(),
                                      settings: RouteSettings(
                                        arguments: UserPostsArguments(
                                            snapshot.data.authenticationToken,
                                            WS_url_get_userposts,
                                            WS_url_get_post
                                        ),
                                      )
                                    ),
                                  );
                                });
                              },
                            ),
                          ],
                        )
                    )
                );

              } else if (snapshot.hasError) {
                return Text("${snapshot.error}");
              }

              return CircularProgressIndicator();
            },
          ),
        ),
      ),
    );
  }
}

//# Reference: https://flutter.dev/docs/cookbook/navigation/navigate-with-arguments
class UserPostsArguments {
  final String authenticationToken;
  final String WS_url_get_userposts;
  final String WS_url_get_post;

  UserPostsArguments(this.authenticationToken, this.WS_url_get_userposts, this.WS_url_get_post);
}
