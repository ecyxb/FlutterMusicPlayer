import 'package:flutter/material.dart';
class CircleButton extends StatefulWidget {
  @override
  _CircleButtonState createState() => _CircleButtonState();
  IconData iconData;
  double iconSize=16;
  Color iconColor=Colors.black;
  Color iconOntapColor=Colors.black;
  Color changeColor;
  Null Function() onTap=(){};
  CircleButton({
    @required this.iconData,
    this.iconSize,
    this.iconColor,
    this.iconOntapColor,
    this.onTap
  }){this.changeColor=this.iconColor;}
}

class _CircleButtonState extends State<CircleButton> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child:ClipOval(
        child:Container(
          child: Icon(widget.iconData,size: widget.iconSize,color: widget.changeColor),

        ),
      ),
      onTap: widget.onTap,
      onTapDown: (detail){
        setState(() {
          widget.changeColor=widget.iconOntapColor;
        });
      },
      onTapUp: (detail){
        setState(() {
          widget.changeColor=widget.iconColor;
        });
      },
    );
  }
}
