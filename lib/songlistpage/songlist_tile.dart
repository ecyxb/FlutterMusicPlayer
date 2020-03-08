import 'package:flutter/material.dart';
import '../connectpack/connect_api.dart';
import '../connectpack/eventbus.dart';

class MuiscTile extends StatefulWidget {
  int index;
  List<String> musicMessage;//ID,MUSICNAME,ARTIST,PATH
  MuiscTile({this.musicMessage,this.index});
  @override
  _MuiscTileState createState() => _MuiscTileState();
}

class _MuiscTileState extends State<MuiscTile> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child:ListTile(
        leading: Padding(
          child:Text((widget.index+1).toString()),
          padding: EdgeInsets.fromLTRB(10, 10, 0, 0),
        ),
        title: Text(widget.musicMessage[1]),
        subtitle: Text(widget.musicMessage[2]),
        onTap: (){
          //这个不会调用nextMusic所以需要进行一次入队列
          if(publicData.playedMusic.length==0||widget.musicMessage!=publicData.publicMusicMessage)
            publicData.playedMusic.add(publicData.publicMusicMessage);//增加播放记录,单曲循环不算
          Player.loadMusic(widget.musicMessage);
        },
      ),
      decoration: BoxDecoration(

          border: Border(bottom: BorderSide(color:Color.fromARGB(50, 100, 100, 255),width:1))
      ),
    );
  }
}
