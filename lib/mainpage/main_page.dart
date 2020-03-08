import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:newpro/connectpack/connect_api.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../connectpack/eventbus.dart';
import '../otherwidget/myappbar.dart';
import '../otherwidget/current_song.dart';
import 'songlists_widget.dart';
class MainScaffold extends StatelessWidget {
  final List<String> songLists;
  MainScaffold(this.songLists);
  @override
  Widget build(BuildContext context) {
    double useableWidth=MediaQuery.of(context).size.width;
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: MyAppBar(title:"我的音乐"),
      body:Container(//主要页面
        child:Column(
          children: <Widget>[
            WhiteSpace(),
            MainContent(useableWidth,songLists),//各种歌单
            CurrentSong(useableWidth)
          ],
        ),
        decoration: BoxDecoration(
            image:DecorationImage(
                image: AssetImage("img/mainpage_bg.jpg"),
                fit: BoxFit.cover
            )
        ),
      ) ,
    );
  }
}

class WhiteSpace extends StatelessWidget {//占据空白
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child:Container(color:Colors.white24,)
    );
  }
}

class MainContent extends StatefulWidget {//歌单存放
  final double _width;
  List<String> songLists=[];
  MainContent(this._width,this.songLists);
  @override
  _MainContentState createState() => _MainContentState();

}

class _MainContentState extends State<MainContent> {

  static var _addSingListEvent;//订阅是否增加歌单
  static var _delSingListEvent;//订阅是否删除歌单
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _delSingListEvent=eventBus.on<DelSingListEvent>().listen((onData){//删除事件
      setState(() {
        ConnectAPI.connectAPI.deleteSongListForShared(onData.listName);
        print("widgetlist="+widget.songLists.toString());
      });
      ConnectAPI.connectAPI.deleteSongListForDataBase(onData.listName);
    });
    _addSingListEvent=eventBus.on<AddSingListEvent>().listen((onData){//增加事件
      ConnectAPI.connectAPI.addSongList(onData.listName).then((res){//必须先确认是否能够增加
        if(res==0){//如果后台确认可以添加，返回0
          setState(() {
            //这里不再减一次，因为似乎shared所产生的实例是指向同一个的，在save里的check已经增加了
            print("widgetlist="+widget.songLists.toString());
          });
        }else if(res==-1){//该名字和系统内置字段名重复
          Fluttertoast.showToast(
            msg: "该名称和系统冲突，请换一个名称",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.black54,
            textColor: Colors.white70,
            fontSize: 16
          );
        }else{
          Fluttertoast.showToast(
              msg: "已存在该歌单",
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.BOTTOM,
              backgroundColor: Colors.black54,
              textColor: Colors.white70,
              fontSize: 16
          );
        }
      });
    });
  }
  @override
  Widget build(BuildContext context) {
    publicData.materialLocalizations=Localizations.of<MaterialLocalizations>(context, MaterialLocalizations);//用于随处弹出一个dialog
    return Container(
      height: 360,
      width: widget._width,
      child: Column(//总的纵向布局
        children: <Widget>[
          Row(//上面一层，我喜欢，top10和last10
            children: <Widget>[
              ILkie(widget._width),//我喜欢
              Column(//top10和last10
                children:<Widget>[
                  Top10(widget._width),//top10
                  Last10(widget._width)//last10
                ]//top10和last10
              )
            ],
          ),
          Flexible(//自定义歌单
            child:ListView.builder(//自定义歌单定义方法
              itemBuilder: (context,index){
                if(index==widget.songLists.length){
                  return AddSing();//最后一个返回一个新建歌单按钮
                }
                return NormalSingList(widget.songLists[index]);
              },
              itemCount: widget.songLists.length+1,
              scrollDirection: Axis.horizontal,
            )
          )
        ],
      ),
      decoration: BoxDecoration(
        color: Colors.white70,
        borderRadius: BorderRadius.vertical(top:Radius.circular(20))
      ),
    );
  }
}










