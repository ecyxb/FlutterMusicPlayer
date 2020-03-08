import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:newpro/connectpack/eventbus.dart';
import 'loadpage/load_page.dart';
void main() {
//  SystemChrome.setPreferredOrientations([
//    DeviceOrientation.portraitUp,
//    DeviceOrientation.portraitDown
//  ]);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {


    return MaterialApp(
      theme: ThemeData(
        primaryColor: Color.fromARGB(255, 248, 142, 162),
      ),
      home: SplashScreen(),
      navigatorKey: publicData.navigatorKey,//用老无context加载页面，用于waitdialog
    );
  }
}

