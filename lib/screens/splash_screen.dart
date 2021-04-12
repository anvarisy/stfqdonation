
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stfqdonation/helpers/function.dart';
import 'package:stfqdonation/screens/menu_screen.dart';

class splash_screen extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _splash_screen();
  }

}

class _splash_screen extends State<splash_screen>{
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      body: Center(
        child: Text('STFQ DONATION',style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold
        ),),
      ),
    );
  }

  @override
  void initState() {
    User user = FirebaseAuth.instance.currentUser!;
    
  }
}