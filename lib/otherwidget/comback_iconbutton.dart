import 'package:flutter/material.dart';
class ComebackIconButton extends IconButton{
  BuildContext context;
  ComebackIconButton(this.context):super(icon:Icon(Icons.arrow_back,color: Colors.white,));
  @override
  // TODO: implement onPressed
  get onPressed => (){
    Navigator.of(context).pop();
  };
}