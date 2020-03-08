import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../songlistpage/songlist_page.dart';
import '../connectpack/connect_api.dart';
import '../connectpack/eventbus.dart';

class Top10 extends StatelessWidget {
  double width;
  Top10(this.width);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(10, 10, 10,10),
      child: RawMaterialButton(
        child: Container(
          height: 95,
          width: (this.width-30)/2,
          child: WithIconText(icons:Icons.arrow_drop_up,string:"Top10播放",size: 20,),
          decoration: BoxDecoration(
              color: Color.fromARGB(100, 255, 255,102),
              borderRadius: BorderRadius.all(Radius.circular(30))
          ),
        ),
        onPressed: (){
        },
      ),
    );
  }
}
class Last10 extends StatelessWidget {
  double width;
  Last10(this.width);
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.fromLTRB(10, 0, 10,10),
        child: RawMaterialButton(
          child:Container(
            height: 95,
            width: (this.width-30)/2,
            child: WithIconText(icons:Icons.arrow_drop_down,string:"Last10播放",size: 20,),
            decoration: BoxDecoration(
                color: Color.fromARGB(100, 205, 255,102),
                borderRadius: BorderRadius.all(Radius.circular(30))
            ),
          ),
        )
    );
  }
}
class NormalSingList extends StatelessWidget {//自定义歌单
  String string;
  NormalSingList(this.string);
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.fromLTRB(10, 0, 0, 5),
        child:RawMaterialButton(
          child: Container(
            height: 120,
            width: 120,
            child: Center(
                child:Text(string,style: TextStyle(fontSize: 20),)
            ),
            decoration: BoxDecoration(
                color: Color.fromARGB(100, 238, 154,0),
                borderRadius: BorderRadius.all(Radius.circular(30))
            ),
          ),
          onPressed: (){
            ConnectAPI.connectAPI.getListSongs(string).then((res){//ID,MUSICNAME,ARTIST,PATH
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context)=>SongListPage(string,res)
              ));
            });
          },
          onLongPress: (){//长按删除该歌单
            showDialog(context: context,builder: (BuildContext context){
              return AlertDialog(
                title:Text("确认"),
                content: Text("确认要删除该歌单吗？"),
                actions: <Widget>[
                  FlatButton(
                      onPressed: () { Navigator.of(context).pop();},
                      child: Text("取消")
                  ),
                  FlatButton(
                      onPressed: () {
                        eventBus.fire(DelSingListEvent(string));
                        Navigator.of(context).pop();
                      },
                      child: Text("确认")
                  ),
                ],
              );
            });
          },
        )
    );;
  }
}
class AddSing extends StatefulWidget {//添加列表按钮
  @override
  _AddSingState createState() => _AddSingState();
}

class _AddSingState extends State<AddSing> {
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.fromLTRB(10, 0, 0, 5),
        child:RawMaterialButton(
          child: Container(
            height: 120,
            width: 120,
            child: Center(
              child:Icon(Icons.add,size:30),
            ),
            decoration: BoxDecoration(
                color: Color.fromARGB(100, 238, 154,0),
                borderRadius: BorderRadius.all(Radius.circular(30))
            ),
          ),
          onPressed: (){//新建一个列表，
            showDialog(context: context,builder: (BuildContext context){//弹出窗口
              final _controller = TextEditingController();//文字控制器
              return AlertDialog(//弹出窗口
                title: Text("新建歌单"),
                content: TextField(
                  maxLength: 20,
                  controller: _controller,
                ),
                actions: <Widget>[//按钮
                  FlatButton(
                      onPressed: () { Navigator.of(context).pop();},
                      child: Text("取消")
                  ),
                  RaisedButton(
                    color: Colors.blue,
                    onPressed: () {//确认添加
                      eventBus.fire(AddSingListEvent(_controller.text));
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      "确定",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],

              );
            });
          },
        )
    );;
  }
}


class ILkie extends StatelessWidget {
  double width;
  ILkie(this.width);
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.fromLTRB(10, 10, 0,10),
        child: RawMaterialButton(
          child:Container(
            height: 200,
            width: (this.width-30)/2,
            child: WithIconText(icons:Icons.favorite,string:"我喜欢的",size:26,iconColor:Colors.red),
            decoration: BoxDecoration(
                color: Color.fromARGB(100, 102, 205,255),
                borderRadius: BorderRadius.all(Radius.circular(30))
            ),
          ),
          onPressed: (){
            ConnectAPI.connectAPI.getListSongs("MyFavouriteMusic").then((res){//ID,MUSICNAME,ARTIST,PATH
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context)=>SongListPage("我喜欢的",res)
              ));
            });
          },
        )
    );
  }
}
class WithIconText extends StatelessWidget {//带文字和图标的按钮
  IconData icons;
  String string;
  double size;
  Color iconColor;
  WithIconText({this.icons,this.string,this.size=16,this.iconColor=Colors.black});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(child: Container(),),
        Icon(icons,color: iconColor,size: size+3,),
        Text(string,style: TextStyle(fontSize: size,fontWeight:FontWeight.bold,color: Color.fromARGB(160, 0, 0, 0)),),
        Expanded(child: Container(),),
      ],
    );
  }
}
