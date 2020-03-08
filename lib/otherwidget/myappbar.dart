import 'package:flutter/material.dart';
class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  String title;
  IconButton iconButton;
  MyAppBar({this.title="",this.iconButton=null});
  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading:Padding(
        child:iconButton!=null?iconButton:CircleAvatar(//头像
          backgroundImage: AssetImage("img/main_head.jpg"),
        ),
        padding: EdgeInsets.only(bottom: 5),
      ),
      title: Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.clip,
        style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16
        ),
      ),
      centerTitle: true,
    );
  }

  @override
  // TODO: implement preferredSize
  Size get preferredSize => Size.fromHeight(60);
}
