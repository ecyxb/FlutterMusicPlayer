import 'package:flutter/material.dart';
import 'package:newpro/connectpack/eventbus.dart';
import '../connectpack/connect_api.dart';
import '../mainpage/main_page.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin{
  AnimationController _controller;
  Animation _animation;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controller=AnimationController(
        vsync: this,
        duration: Duration(seconds: 3)
    );
    _animation=Tween(begin: 0.0,end: 1.0).animate(_controller);

    ConnectAPI connectAPI=ConnectAPI.connectAPI;
    connectAPI.CheckMusicList().then((res){
      _animation.addStatusListener((status){
        if(status==AnimationStatus.completed){
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                  builder:(context)=>MainScaffold(res)
              ),
                  (route)=>route==null
          );
        }
      });
      _controller.forward();//播放
    });

  }
  @override
  void dispose() {
    // TODO: implement dispose
    _controller.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: Image.asset("img/mainpage_bg.jpg",scale: 2.0,fit: BoxFit.cover,),
    );
  }
}



