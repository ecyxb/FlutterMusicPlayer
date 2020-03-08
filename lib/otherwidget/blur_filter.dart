import 'dart:ui';

import 'package:flutter/material.dart';

class BlurFilter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX:5.0,sigmaY: 5.0),
          child: Opacity(
            opacity: 0.3,//
            child: Container(
              height: 700.0,width: 500.0,
              decoration: BoxDecoration(color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}