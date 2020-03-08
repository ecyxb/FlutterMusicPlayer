import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
class ConnectService{
  static Dio dio = Dio(); // 使用默认配置
  ConnectService(){
    dio.options.baseUrl = "http://49.233.171.101/musicAPI";
    dio.options.connectTimeout = 5000; //5s
    dio.options.receiveTimeout = 1000*60*10;
  }
  static Future<Set<String>> questIDs() async {//请求所有歌曲ID，用来初始化和本地比较
    Response response = await dio.get("/basicQuest.php",queryParameters: {"funname": "questAllSongs"});
    final responseJson = json.decode(response.data.toString());
    List<dynamic> resList = responseJson ;
    Set<String> allSongSet=new Set();
    for(int i=0;i<resList.length;i++){
      allSongSet.add(resList[i][0]);
    }
    return allSongSet;
  }


  static  Future<String> questSong(String musicID,String musicName)async{
    //存储位置初始化部分
    Directory documentsDir = await getExternalStorageDirectory();
    String Path=documentsDir.path+'/DownloadMusic';
    print(Path);
    final savedDir = Directory(Path);
    // 判断下载路径是否存在
    bool hasExisted = await savedDir.exists();
    // 不存在就新建路径
    if (!hasExisted) {
      savedDir.create();
    }
    Response response = await dio.download("/mp3Reader.php?musicID=$musicID",Path+"/$musicName.mp3");
    print(response.statusCode);
    return Path+"/$musicName.mp3";

  }
  static Future<List<List<String>>> getSongsMessage(Set<String> IDs,List<String> tables)async{//请求新增歌曲的除了mp3外所有信息
    String tableSQL="SELECT ID,MusicName,Artist,MyFavouriteMusic ";//这四个是常驻列
    tables.forEach((table){
      tableSQL+=","+table;//table是自定义列表
    });
    tableSQL+="FROM MusicList WHERE ID=";
    List<List<String>> songsMessage=new List();
    int total=0;
    for(String id in IDs){
      Response response = await dio.get("/basicQuest.php",queryParameters: {"funname": "getSongsMessage","SQL":tableSQL+"$id"});

      List<dynamic> res= json.decode(response.data);//[id,musicname,artist,MyFavouriteMusic,table1,table2....]
      List<String> temp=new List();
      for(int i=0;i<res[0].length;i++)
        temp.add(res[0][i]);
      songsMessage.add(temp);
      total++;
      if(total==IDs.length){return songsMessage;}
    }
  }
  static void addSongList(String listName) async{//更新服务器数据库
    dio.get("/basicQuest.php",queryParameters: {"funname": "addSongList","listName":listName});
  }
  static void delSongList(String listName) async{//更新服务器数据库
    dio.get("/basicQuest.php",queryParameters: {"funname": "delSongList","listName":listName});
  }

}