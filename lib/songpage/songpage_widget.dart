import 'dart:async';
import 'dart:developer';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:newpro/connectpack/eventbus.dart';
import 'package:newpro/otherwidget/circile_button.dart';
class SongImgContainer extends StatefulWidget {//显示音乐图标的Box，以后可能显示歌词
  @override
  _SongImgContainerState createState() => _SongImgContainerState();
}

class _SongImgContainerState extends State<SongImgContainer> {
  @override
  Widget build(BuildContext context) {
    return Container(
        height: 240,
        width: 240,
        color: Colors.white60,
        padding: EdgeInsets.all(20),
        margin:EdgeInsets.fromLTRB(0, 60, 0, 45),
        child: Container(
          height: 160,
          width: 160,
          color: Colors.white60,
          child: Icon(Icons.music_note,size:70),
        ),
    );
  }
}

class MusicSlider extends StatefulWidget {//滑动条
  double sliderValue;
  MusicSlider({@required this.sliderValue});
  @override
  _MusicSliderState createState() => _MusicSliderState();
}

class _MusicSliderState extends State<MusicSlider> {
  Duration duration;
  Duration position;
  StreamSubscription listenDurate;
  StreamSubscription listenPos;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    listenDurate=Player.audioPlayer
    .onDurationChanged.listen((duration){
      setState(() {
        this.duration = duration;
        if (position != null) {
          widget.sliderValue = (position.inSeconds / duration.inSeconds)*100;
        }
      });
    });
    listenPos=Player.audioPlayer
    .onAudioPositionChanged.listen((position){
      setState(() {
        this.position = position;
        if (duration != null) {
          widget.sliderValue = (position.inSeconds / duration.inSeconds)*100;
        };
      });
    });
  }
  @override
  void dispose() {
    //取消监听;
    listenDurate.cancel();
    listenPos.cancel();
    // TODO: implement dispose
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Slider(
      onChanged: (newValue){
        print(newValue);
        setState(() {
            widget.sliderValue = newValue;
        });
        if (duration != null) {
          int seconds = (duration.inSeconds * newValue/100).round();
          print("audioPlayer.seek: $seconds");
          Player.audioPlayer.seek(new Duration(seconds: seconds));
        }
      },
      value: widget.sliderValue,
      min: 0,
      max:100,
      divisions: 100,
      activeColor: Color.fromARGB(160, 0, 0, 0),
      inactiveColor: Colors.grey,
    );
  }
}

class UsefulController extends StatefulWidget {//一些按钮
  @override
  _UsefulControllerState createState() => _UsefulControllerState();
}

class _UsefulControllerState extends State<UsefulController> {
  static var playmodeIcons={
    "列表循环":Icon(Icons.repeat,size:40,color:Color.fromARGB(180, 0, 0, 0)),//列表循环
    "随机播放":Icon(Icons.shuffle,size:40,color:Color.fromARGB(180, 0, 0, 0)),//随机播放
    "单曲循环":Icon(Icons.loop,size:40,color:Color.fromARGB(180, 0, 0, 0))//单曲循环
  };
  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        IconButton(//播放模式切换
          icon: playmodeIcons[publicData.finalPlaymode],
          onPressed: (){
            setState(() {
              publicData.changePlaymode();
            });
          },
        ),
      ],
    );
  }
}


class BottomMusicController extends StatefulWidget {//音乐控制按钮
  @override
  _BottomMusicControllerState createState() => _BottomMusicControllerState();
}

class _BottomMusicControllerState extends State<BottomMusicController> {

  var _songButtonController;
  static IconData playIcon=Icons.play_circle_outline;
  static IconData pauseIcon=Icons.pause_circle_outline;
  IconData playOrPauseIcon;

  @override
  void initState() {
    _songButtonController=Player.audioPlayer.onPlayerStateChanged.listen((state){
      if(state==AudioPlayerState.PAUSED){
        setState(() {
          playOrPauseIcon=playIcon;
        });
      }else if(state==AudioPlayerState.PLAYING){
        setState(() {
          playOrPauseIcon=pauseIcon;
        });
      }
    });
    var state=Player.audioPlayer.state;
    if(state==AudioPlayerState.PAUSED||state==AudioPlayerState.STOPPED||state==null){
      playOrPauseIcon=playIcon;
    }else{
      playOrPauseIcon=pauseIcon;
    }
    // TODO: implement initState
    super.initState();
  }
  @override
  void dispose() {
    _songButtonController.cancel();
    // TODO: implement dispose
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Expanded(
          child:UnconstrainedBox(
            child:CircleButton(
              iconData: Icons.skip_previous,
              iconSize: 45,
              iconColor: Color.fromARGB(180, 0, 0, 0),
              iconOntapColor: Color.fromARGB(120, 0, 0, 0),
              onTap: (){
                Player.preMusic();
              },
            )
          ),
        ),
        Expanded(
          child:UnconstrainedBox(
            child:CircleButton(
              iconData:playOrPauseIcon,
              iconSize: 60,
              iconColor: Color.fromARGB(180, 0, 0, 0),
              iconOntapColor: Color.fromARGB(120, 0, 0, 0),
              onTap: (){
                if(playOrPauseIcon==playIcon&&publicData.publicMusicMessage[0]!="null"){
                  Player.playMusic();
                }else{
                  Player.pauseMusic();
                }
              },
            )
          ),
        ),
        Expanded(
          child:UnconstrainedBox(
            child:CircleButton(
              iconData: Icons.skip_next,
              iconSize: 45,
              iconColor: Color.fromARGB(180, 0, 0, 0),
              iconOntapColor: Color.fromARGB(120, 0, 0, 0),
              onTap: (){
                Player.nextMusic();
              },
            )
          ),
        ),
      ],
    );
  }
}




