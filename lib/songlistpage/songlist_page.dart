import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:newpro/connectpack/eventbus.dart';
import '../otherwidget/blur_filter.dart';
import '../otherwidget/comback_iconbutton.dart';
import '../otherwidget/myappbar.dart';
import 'songlist_tile.dart';
import '../otherwidget/current_song.dart';

class SongListPage extends StatefulWidget {
  String songListName="";
  List<List<String>> songList=new List();//ID,MUSICNAME,ARTIST,PATH
  SongListPage(this.songListName,this.songList){
    publicData.changeList(this.songListName,this.songList);//打开列表时虽然不会换歌曲，但歌单已经更换好了，如果是单曲循环不受影响
  }
  @override
  _SongListPageState createState() => _SongListPageState();
}

class _SongListPageState extends State<SongListPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:MyAppBar(
        title:widget.songListName,
        iconButton: IconButton(
          icon: ComebackIconButton(context),
        ),
      ),
      body: Column(//除了appbar的垂直布局
        children:[
          Expanded(//下部分current定义死高度，歌单部分用Expanded适应
            child:Stack(//设置带高斯模糊的ListView，用Stack
              children:[
                ConstrainedBox(//高斯模糊1
                  constraints: BoxConstraints.expand(),
                  child: Image.asset("img/mainpage_bg.jpg"),
                ),
                BlurFilter(),//高斯模糊2
                ListView.builder(
                  itemBuilder: (context, index){
                    return MuiscTile(musicMessage:widget.songList[index],index:index ,);
                  },
                  itemCount: widget.songList.length,
                ),
              ]
            ),
          ),
          CurrentSong(MediaQuery.of(context).size.width)
        ]
      )
    );
  }
}



