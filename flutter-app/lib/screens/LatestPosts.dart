import 'package:flutter/material.dart';
import '../main.dart';
import 'UserPosts.dart';

class LatestPosts extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final UserPostsArguments args = ModalRoute.of(context).settings.arguments;
    final String authenticationToken = args.authenticationToken;
    final String WS_url_get_userposts = args.WS_url_get_userposts;

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
                    title: Text("Latest posts")
                ),
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
                                child: new Text(data[index]['title']),
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