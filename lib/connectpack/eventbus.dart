

import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:event_bus/event_bus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:newpro/otherwidget/wait_dialog.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'connect_api.dart';

EventBus eventBus=new EventBus();

class Player{
  static var audioPlayer=AudioPlayer()
  ..onPlayerStateChanged.listen((state){
    if(state==AudioPlayerState.PAUSED){
      print("暂停了");
    }
    if(state==AudioPlayerState.COMPLETED){
      print("放完一首");
      nextMusic();
    }
  });
  static playMusic()async{
    try{
      if(publicData.publicMusicMessage[3]!="null"){
        int res=await audioPlayer.play(publicData.publicMusicMessage[3],isLocal: true);
        if(res==1){
          print("播放:${publicData.publicMusicMessage[3]}");

          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setStringList("finalMessage",publicData.publicMusicMessage);
        }else{
          print(res.toString());
        }
      }
    }catch(e){
      print(e.toString());
      loadMusic(publicData.listMes[0]);
    }

  }
  static pauseMusic(){
    audioPlayer.pause();
  }
  static nextMusic(){
    //针对上一个放完/切掉的曲目
    if(publicData.publicMusicMessage[0]!="null"&&(publicData.playedMusic.length==0||publicData.playedMusic.last!=publicData.publicMusicMessage)){
      publicData.playedMusic.add(publicData.publicMusicMessage);//增加播放记录,单曲循环不算
    }
    switch (publicData.finalPlaymode){
      case "列表循环"://列表循环
        int index=0;
          for(;index<publicData.listMes.length;index++)
            if(publicData.publicMusicMessage[0]==publicData.listMes[index][0])
              break;
        if(index==publicData.listMes.length-1||index==publicData.listMes.length)//如果这首歌被删了或者是null
          index=-1;
        loadMusic(publicData.listMes[index+1]);
        break;
      case "随机播放"://随机模式
        Random random=new Random();
        int index=random.nextInt(publicData.listMes.length);//从0到length-1
        loadMusic(publicData.listMes[index]);
        break;
      case "单曲循环"://单曲循环
        playMusic();
    }
  }
  static preMusic(){
    if(publicData.playedMusic.length==0){
      switch (publicData.finalPlaymode){
        case "列表循环"://列表循环
          int index=0;
          for(;index<publicData.listMes.length;index++)
            if(publicData.publicMusicMessage[0]==publicData.listMes[index][0])
              break;
          if(index==0||index==publicData.listMes.length)
            index=publicData.listMes.length;
          loadMusic(publicData.listMes[index-1]);
          Fluttertoast.showToast(msg: "没有前一首了哦，列表前一首");
          break;
        case "随机播放"://随机模式
          Random random=new Random();
          int index=random.nextInt(publicData.listMes.length);//从0到length-1
          loadMusic(publicData.listMes[index]);
          Fluttertoast.showToast(msg: "没有前一首了哦，随机播放");
          break;
        case "单曲循环"://单曲循环
          playMusic();
          Fluttertoast.showToast(msg: "没有前一首了哦，单曲循环");
      }
    }else{
      loadMusic(publicData.playedMusic.last);//现在在放的歌曲将不被保存，返回到上一个
      publicData.playedMusic.removeLast();
    }
  }
  static loadMusic(List<String> musicMessage){
    if(musicMessage[3]=="null"||musicMessage[3]==null){//发现未下载
      showWaitDialog(builder: (context){//加载等待
        ConnectAPI.connectAPI.downLoadSong(musicMessage[0],musicMessage[1]).then((downPath){
          publicData.navigatorKey.currentState.pop();//结束时弹出锁屏
          ConnectAPI.connectAPI.saveDownloadPath(musicMessage[0],downPath);//保存路径
          musicMessage[3]=downPath;
          eventBus.fire(ChangeSongEvent(musicMessage));
        });
        return AlertDialog(
          title: Text("正在下载${musicMessage[1]}"),
        );
      });
    }else{
      eventBus.fire(ChangeSongEvent(musicMessage));
    }
  }
}


class publicData{
  static MaterialLocalizations materialLocalizations;//和下一个一起用于dialog随处弹出
  static GlobalKey<NavigatorState> navigatorKey=GlobalKey();
  static List<String> publicMusicMessage;//ID,MUSICNAME,ARTIST,PATH
  static List<List<String>> playedMusic=new List();//本次运行的播放历史，不持续化保存，用来进行preMusic
  static List<List<String>> listMes;//歌单内歌曲信息
  static String finalPlaymode;//播放模式信息
  static String finalListName;//歌单明
  static init()async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    publicMusicMessage=prefs.getStringList("finalMessage");
    finalPlaymode=prefs.getString("finalPlaymode");
    finalListName=prefs.getString("finalListName");
    if(finalPlaymode==null){
      finalPlaymode="列表循环";
      prefs.setString("finalPlaymode",finalPlaymode);
    }
    if(finalListName==null){
      finalListName="null";
      prefs.setString("finalListName",finalListName);
    }
    if(publicMusicMessage==null){
      publicMusicMessage=["null","null","null","null"];
      prefs.setStringList("finalMessage",publicMusicMessage);
    }
  }
  static String changePlaymode(){//更换歌单时
    String newPlaymode;
    switch(finalPlaymode){
      case "列表循环":
        newPlaymode="随机播放";
        break;
      case "随机播放":
        newPlaymode="单曲循环";
        break;
      case "单曲循环":
        newPlaymode="列表循环";
        break;
    }
    finalPlaymode=newPlaymode;
    SharedPreferences.getInstance().then((prefs){
      prefs.setString("finalPlaymode",finalPlaymode);
    });
    Fluttertoast.showToast(msg: newPlaymode);
    return newPlaymode;
  }
  static void changeList(String songListName,List<List<String>> songList)async{//更换歌单时
    if(songListName=="我喜欢的")songListName="MyFavouriteMusic";
    if(songListName!=finalListName){
      finalListName=songListName;
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString("finalListName",finalListName);
      listMes=songList;
    }
  }
}

class ChangeSongEvent{

  List<String> musicMessage;//ID,MUSICNAME,ARTIST,PATH
  ChangeSongEvent(this.musicMessage){//该事件发生一次，会有多个实例监听，所以播放代码只在这里运行一次
    publicData.publicMusicMessage=musicMessage;//更新正在播放的曲目
    Player.playMusic();
  }
}
class AddSingListEvent{
  String listName;
  AddSingListEvent(this.listName);
}
class DelSingListEvent{
  String listName;
  DelSingListEvent(this.listName);
}