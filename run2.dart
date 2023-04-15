import 'package:flutter/material.dart';
import 'package:first_app/main2.dart' as m2;

void main() {
  runApp(App());
}

class App extends StatefulWidget {
  @override
  AppState createState() => AppState();
}

class AppState extends State<App> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: m2.Login());
  }
}
