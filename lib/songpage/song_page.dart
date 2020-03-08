

import 'package:flutter/material.dart';

import '../connectpack/eventbus.dart';
import '../otherwidget/blur_filter.dart';
import '../otherwidget/comback_iconbutton.dart';
import '../otherwidget/myappbar.dart';
import '../songpage/songpage_widget.dart';

class SongPage extends StatefulWidget {
  String songname;
  String songID;
  double initSliderValue;
  SongPage({this.initSliderValue=0});
  @override
  _SongPageState createState() => _SongPageState();
}

class _SongPageState extends State<SongPage> {
  var _songnameChangeEvent;
  @override
  void initState() {
    _songnameChangeEvent=eventBus.on<ChangeSongEvent>().listen((onData){
      setState(() {});
    });
    // TODO: implement initState
    super.initState();
  }
  @override
  void dispose() {
    _songnameChangeEvent.cancel();
    // TODO: implement dispose
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar:MyAppBar(title:publicData.publicMusicMessage[1],iconButton: ComebackIconButton(context),),
      body: Stack(
        children: <Widget>[
          ConstrainedBox(//高斯模糊1
            constraints: BoxConstraints.expand(),
            child: Image.asset("img/mainpage_bg.jpg"),
          ),
          BlurFilter(),//高斯模糊2
          Column(
            children: <Widget>[
              SongImgContainer(),
              Flexible(
                child:Container(
                  height: 50,
                  child: Text(
                    publicData.publicMusicMessage[1],
                    style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color:Color.fromARGB(180, 0, 0, 0)
                    ),
                  ),
                )
              ),
              Flexible(
                child: Container(
                  child: Text(
                    publicData.publicMusicMessage[2],
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                  height: 40,
                )
              ),



              UsefulController(),
              MusicSlider(sliderValue: widget.initSliderValue,),
              BottomMusicController()
            ],
          )
        ],
      ),
    );
  }
}
