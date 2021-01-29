# MySkeletonApp
A skeleton app in Dart to connect a mobile phone to a WordPress website: Login and fetch posts.
View post_title, post_description and thumbnail image of the selected post.


# Dependencies
- https://pub.dev/packages/http
- https://pub.dev/packages/flutter_html
  
  Add the following lines after "cupertino_icons" in pubspec.yaml
  
  http: ^0.12.2
  flutter_html: ^1.1.1
  url_launcher: ^5.7.10
  

# TODO
- Check every used variable before use them (!= null)
- Obscure password field
- Labels localization
- Save the login username/password
- Fetch WooCommerce orders (if there are any)
