import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void transition_replace(Widget widget, BuildContext context){
  Navigator.of(context)
      .pushReplacement(MaterialPageRoute(builder: (context) => widget));
}

void transition_push(Widget widget, BuildContext context){
  Navigator.of(context)
      .push(MaterialPageRoute(builder: (context) => widget));
}