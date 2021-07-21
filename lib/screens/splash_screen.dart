import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qbsdonation/models/dafq.dart';
import 'package:qbsdonation/response/success_payout.dart';
import 'package:qbsdonation/screens/menu_screen.dart';
import 'package:qbsdonation/screens/walkthrough_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';



class splash_screen extends StatefulWidget {
  final status;

  const splash_screen({Key key, this.status}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return Splash();
  }
}

class Splash extends State<splash_screen> {
  user_profil profil = user_profil();
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Image(
          image: AssetImage('assets/images/dafq.png'),
          height: 250,
          width: 250,
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    FirebaseAuth.instance
        .currentUser()
        .then((currentUser) => {
      if (currentUser == null){
        transition(walkthrough_screen())
      }
      else
        {
          Firestore.instance
              .collection("User")
              .document(currentUser.uid)
              .get()
              .then((DocumentSnapshot result) =>

         {
           if(widget.status==null){
             profil.uid = currentUser.uid,
             profil.name = result["full_name"],
             profil.mobile = result['phone'],
             profil.email = result['email'],
             Navigator.pushReplacement(
                 context,
                 MaterialPageRoute(
                     builder: (context) => menu_screen(
                       profil: profil,
                     )))
           }else{
             profil.uid = currentUser.uid,
             profil.name = result["full_name"],
             profil.mobile = result['phone'],
             profil.email = result['email'],
             Navigator.pushReplacement(
                 context,
                 MaterialPageRoute(
                     builder: (context) => success_payout(
                       profil: profil,
                     )))
           }

         }).catchError((err)=>print(err)

          )}
    })
        .catchError((err) => print(err));

  }


  void transition(Widget widget){
    Navigator.of(context)
        .pushReplacement(MaterialPageRoute(builder: (context) => widget));
  }
  
}
