import 'package:newpro/connectpack/eventbus.dart';

import 'connect_save.dart';
import 'connect_service.dart';
class ConnectAPI{
  final ConnectService service=new ConnectService();
  final ConnectSave save=new ConnectSave();
  static final ConnectAPI connectAPI=new ConnectAPI();
  Future CheckMusicList() async{//算是初始化所有歌曲以及加载最后一次运行信息
    List<String> tables= await ConnectSave.getTables();//自定义的列表
    Set<String> serviceSet;
    Set<String> saveSet;
    ConnectService.questIDs().then((res1){
      serviceSet=res1;
      ConnectSave.questIDs().then((res2){
        saveSet=res2;
        Set<String> sameSet=serviceSet.intersection(saveSet);//求交集
        serviceSet.removeAll(sameSet);//数据库新增的歌曲
        if(serviceSet.length!=0){
          ConnectService.getSongsMessage(serviceSet,tables).then((res3) {
            ConnectSave.addSongs(res3, tables);
          });
        }
      });
    }).whenComplete(()async {
      await publicData.init();//加载最后一次信息
      if(publicData.finalListName!="null"){//若上次已经使用过某一歌单了，从该歌单加载
//        var songListName=publicData.finalListName;
//        songListName=songListName=="我喜欢的"?"MyFavouriteMusic":songListName;
        publicData.listMes=await getListSongs(publicData.finalListName);
      }
    });
    return tables;
  }
  Future addSongList(String listName) async{
    return ConnectSave.checkSongList(listName).then((res){//本地判断是否可以添加，若可以则进行添加
      if(res==0){//如果允许添加
        ConnectService.addSongList(listName);//服务器添加
        ConnectSave.addSongList(listName);//本地数据库添加
      }
      return res;
    });
  }
  void deleteSongListForShared(String listName) async{//针对shared删除，响应快
    ConnectSave.delSongListForShared(listName);
  }
  void deleteSongListForDataBase(String listName) async{//针对数据库的删除，因为sqlite不能直接drop一个字段
    ConnectService.delSongList(listName);//服务器删除
    ConnectSave.delSongListForDataBase(listName);//本地删除
  }
  Future<List<List<String>>> getListSongs (String songListName) async{//加载列表所有歌曲信息，只从本地加载
    return ConnectSave.getListSongs(songListName)??[];
  }
  Future<String> loadSongPath(String musicID)async{//从本地加载路径
    return ConnectSave.loadSongPath(musicID);
  }
  Future<String> downLoadSong(String musicID,String musicName)async{
    return ConnectService.questSong(musicID, musicName);
  }
  void saveDownloadPath(String musicID,String downPath){
    ConnectSave.saveDownloadPath(musicID,downPath);
  }


}