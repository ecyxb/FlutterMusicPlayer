

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import '../connectpack/eventbus.dart';
import '../songpage/song_page.dart';

class CurrentSong extends StatefulWidget {//正在播放
  final double _width;
  CurrentSong(this._width);
  @override
  _CurrentSongState createState() => _CurrentSongState();
}

class _CurrentSongState extends State<CurrentSong> {
  var _songnameChangeEvent;
  var _songButtonController;
  static Icon playIcon=Icon(Icons.play_circle_outline,size: 35);
  static Icon pauseIcon=Icon(Icons.pause_circle_outline,size: 35);
  Icon playOrPauseIcon;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _songnameChangeEvent=eventBus.on<ChangeSongEvent>().listen((onData){
      setState(() {});
    });
    _songButtonController=Player.audioPlayer.onPlayerStateChanged.listen((state){
      if(state==AudioPlayerState.PAUSED){
        setState(() {
          playOrPauseIcon=playIcon;
        });
      }else if(state==AudioPlayerState.PLAYING){
        setState(() {
          print("开始播放");
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
  }
  @override
  void dispose() {
    // TODO: implement dispose
    _songnameChangeEvent.cancel();//防止内存溢出
    _songButtonController.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      width: widget._width,
      color: Colors.white,
      padding: EdgeInsets.only(left: 10),
      child: Row(
        children: <Widget>[
          Expanded(
            child: GestureDetector(
              child:Container(
                alignment: Alignment.centerLeft,
                color:Colors.white,//如果不设置颜色，空白的地方不会被响应
                child:Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(//歌曲名字
                      publicData.publicMusicMessage[1],
                      style: TextStyle(fontSize: 16),
                    ),
                    Text(//歌手
                      publicData.publicMusicMessage[2],
                      style: TextStyle(fontSize: 10,color: Colors.grey),
                    ),
                  ],
                )
              ),
              onTap: (){
                if(Player.audioPlayer.state!=null){
                  Player.audioPlayer.getDuration().then((resDuration){
                    Player.audioPlayer.getCurrentPosition().then((resPosition){
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context)=>SongPage(initSliderValue:resPosition/resDuration*100)
                      ));
                    });
                  });
                }else{
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context)=>SongPage()
                  ));
                }
              },
            ),
          ),
          IconButton(
            icon: Icon(Icons.skip_previous,size:25,),
            onPressed: (){
              Player.preMusic();
            },
          ),
          IconButton(
            icon:playOrPauseIcon,
            onPressed: (){
              if(playOrPauseIcon==playIcon&&publicData.publicMusicMessage[0]!="null"){
                Player.playMusic();
              }else{
                Player.pauseMusic();
              }
            },
          ),
          IconButton(//下一曲
            icon: Icon(Icons.skip_next,size: 25,),
            onPressed: (){
              Player.nextMusic();
            },
          )
        ],
      ),
    );
  }
}