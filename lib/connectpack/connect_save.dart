
import 'dart:io';

import 'package:newpro/connectpack/eventbus.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
class ConnectSave{
  static Database MusicDatabase;

  //初始化数据库
  static init() async {
    var databasePath = await getDatabasesPath();
    String path =join(databasePath, 'Music.db');
    MusicDatabase= await openDatabase(path, version: 1,
      onCreate: (Database db, int version) async {
      //新建数据库时新建一张总表名为MusicList
      await db.execute(
      'CREATE TABLE MusicList (ID INTEGER PRIMARY KEY, MusicName TEXT, Artist TEXT, Path TEXT, Times INTEGER,MyFavouriteMusic INTEGER NOT NULL DEFAULT 1)');
    });
  }
  static Future<List<String>> getTables() async{//查找本地的自定义列表，和最后一次播放信息
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> tables=prefs.getStringList("MusicTables");
    if(tables==null){
      tables=new List();
      prefs.setStringList("MusicTables",tables);
    }
    return tables;
  }
  static Future<Set<String>> questIDs () async{//请求所有歌曲ID，用来初始化和服务器比较,
    if(MusicDatabase==null) await init();
    List<Map<String,dynamic>> songLists=await MusicDatabase.rawQuery("select ID from MusicList");
    Set<String> IDList=new Set();
    songLists.forEach((Map m){
      try {
        IDList.add(m['ID'].toString());
      }catch(e){print("wdnmd"+e.toString());};
    });
//    MusicDatabase.close();
//    MusicDatabase=null;
    return IDList;
  }
  static addSongs(List<List<String>> songsMessage,List<String> tables)async{//从服务器获得的新增的歌曲的信息录入本地数据库
    if(MusicDatabase==null) await init();
    String path="null";//默认先不下载歌曲
    String sql="INSERT INTO MusicList(ID,MusicName,Artist,Path,Times,MyFavouriteMusic";
    for(var table in tables) {
      sql+=','+table;
    }
    sql+=") VALUES ";
    int total=0;
    for(var message in songsMessage){
      sql+="(${message[0]},'${message[1]}','${message[2]}',$path,0,${message[3]}";
      total++;
      for(int i=4;i<message.length;i++){//其他列表的数据添加
        sql+=","+"${message[i]}";
      }
      if(total==songsMessage.length)sql+=');';
      else sql+='),';
    }
    MusicDatabase.rawInsert(sql);
//    MusicDatabase.close();
//    MusicDatabase=null;
  }
  static Future<List<List<String>>> getListSongs(String songListName)async {//获取一个歌单所有歌曲的 ID,MUSICNAME,ARTIST,PATH
    if(MusicDatabase==null) await init();
    List<Map<String,dynamic>> songLists=await MusicDatabase.rawQuery("select ID,MusicName,Artist,Path from MusicList where $songListName=1");
    List<List<String>> list=new List();
    songLists.forEach((Map m){
      list.add([m['ID'].toString(),m['MusicName'],m['Artist'],m['Path']]);//ID,MUSICNAME,ARTIST,PATH
    });

//    MusicDatabase.close();
//    MusicDatabase=null;
    return list;
  }
  static Future checkSongList(String listName)async{//只检查列表名是否合法,并更新shared
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> tables=prefs.getStringList("MusicTables");
    String lowerName=listName.toLowerCase();//用小字母进行查重，防止字段冲突
    for(String savedString in tables){
      if(savedString.toLowerCase()==lowerName){
        return 1;//和已有列表冲突
      }
    }
    if(lowerName=="id"||lowerName=="musicname"||lowerName=="artist"||lowerName=="path"||lowerName=="times"||lowerName=="data"||lowerName=="myfavouritemusic")
      return -1;//和系统字段冲突

    tables.add(listName);

    prefs.setStringList("MusicTables",tables);//shared快速添加
    return 0;//允许添加
  }

  static void addSongList(String listName)async{//更新本地数据库操作较为耗时
    if(MusicDatabase==null ) await init();//数据库添加
    var sql="alter table MusicList add $listName INTEGER not Null DEFAULT 0;";
    MusicDatabase.execute(sql);
//    MusicDatabase.close();
//    MusicDatabase=null;
  }
  static void delSongListForShared(String listName)async{
    SharedPreferences prefs = await SharedPreferences.getInstance();//shared更新
    List<String> tables=prefs.getStringList("MusicTables");
    tables.remove(listName);
    prefs.setStringList("MusicTables", tables);
  }
  static void delSongListForDataBase(String listName)async{//从本地删除该歌单的所有信息，该歌单必定是存在的（通过add添加
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> tables=prefs.getStringList("MusicTables");//这时shared已经更新完成，没有待删除的List
    if(MusicDatabase==null ) await init();//数据库删除
    var sql="create table MusicList_Copy as select ID,MusicName,Artist,Path,Times,MyFavouriteMusic";
    for(int i=0;i<tables.length;i++)
      sql+=',${tables[i]}';
    sql+=" from MusicList";
    MusicDatabase.execute(sql);
    sql="drop table if exists MusicList";//删除原表
    MusicDatabase.execute(sql);
    sql="alter table MusicList_Copy rename to MusicList";
    MusicDatabase.execute(sql);
//    MusicDatabase.close();
//    MusicDatabase=null;
  }
  static Future<String> loadSongPath(String musicID)async{//从本地数据库中加载路径
    if(MusicDatabase==null) await init();
    List<Map<String,dynamic>> musics=await MusicDatabase.rawQuery("select Path from MusicList where ID=$musicID");
    return musics[0]["Path"].toString();

  }
  static void saveDownloadPath(String musicID,String downPath)async{
    if(MusicDatabase==null) await init();
    MusicDatabase.update('MusicList', {'Path': downPath},where: 'ID=?',whereArgs: [musicID]);
  }


  static deleteSongs(Set<String> IDs) async{
    IDs.forEach((id){
      String sql="Select Path From MusicList where ID=$id";
      MusicDatabase.rawQuery(sql).then((res){
        Map<String,String> pathMap=res[0];
        File file=new File(pathMap['Path']);
        file.exists().then((isExists){
          if(isExists) file.delete();
        });
      });
      sql="Delete From MusicList where ID=$id";
      MusicDatabase.rawDelete(sql);
    });
  }

}
