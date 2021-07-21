import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qbsdonation/components/dashboard/dashboard_carousel.dart';
import 'package:qbsdonation/components/dashboard/dashboard_list.dart';
import 'package:qbsdonation/components/dashboard/search_bar.dart';
import 'package:qbsdonation/components/dialog.dart';
import 'package:qbsdonation/models/dafq.dart';
import 'package:qbsdonation/screens/mission_screen.dart';
import 'package:qbsdonation/utils/colors.dart';
import 'package:qbsdonation/utils/constants.dart';
import 'package:qbsdonation/utils/widgets.dart';
import 'package:qbsdonation/utils/widgets.dart';

class dashboard_screen extends StatefulWidget {
  final user_profil profil;

  dashboard_screen({this.profil});

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return dashboard();
  }
}

class dashboard extends State<dashboard_screen> {

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    // TODO: implement build
    return Scaffold(
      body: SingleChildScrollView(
        physics: ScrollPhysics(),
        child: Container(
          padding: EdgeInsets.only(top: 36.0),
          decoration: backgroundDecor(),
          child: Column(
            children: <Widget>[
              // Saldo(
              //   profil: widget.profil,
              // ),
              // SizedBox(height: 16),
              dashboard_carousel(),
              SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.only(left: 12, right: 12, bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    text('Lihat Misi Kami',
                        textColor: t2TextColorPrimary,
                        fontSize: textSizeNormal,
                        fontFamily: fontBold),
                    InkWell(
                      onTap: () => {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => mission_screen(
                              profil: widget.profil,
                            )))
                      },
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                                text: 'Lainnya',
                                style: TextStyle(
                                    fontSize: textSizeMedium,
                                    fontFamily: fontMedium,
                                    color: t10_textColorSecondary)),
                            WidgetSpan(
                              child: Padding(
                                padding: EdgeInsets.only(left: 0),
                                child: Icon(
                                  Icons.keyboard_arrow_right,
                                  color: t10_textColorPrimary,
                                  size: 18,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
              dashboard_list(
                profil: widget.profil,
              )
            ],
          ),
        )
      ),
    );
  }
}

class Saldo extends StatelessWidget {
  final user_profil profil;
  double saldo;
  Saldo({this.profil});


  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Container(
          decoration: boxDecoration(radius: 10, showShadow: true),
          child: Stack(
            children: <Widget>[
              Container(
                // padding: EdgeInsets.all(16),
                child: Column(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        ClipRRect(
                          child: Image.asset(
                            'assets/images/icon.png',
                            width: width / 5.5,
                            height: width / 6,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.only(left: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    text('Dompet Anda',
                                        textColor: t1TextColorPrimary,
                                        fontFamily: fontBold,
                                        fontSize: textSizeNormal,
                                        maxLine: 2),
                                   InkWell(
                                     onTap: ()=>{
                                        showDialog(context: context, builder: (BuildContext context)=>CustomDialog_II(profil: profil))
                                     },
                                     child:  Icon(Icons.add),
                                   )
                                  ],
                                ),
                                BuildSaldo(context)
                              ],
                            ),
                          ),
                        )
                      ],
                      mainAxisAlignment: MainAxisAlignment.start,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ));
  }

  Widget BuildSaldo(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream:
          Firestore.instance.collection('s-transactions').where('p_uid',isEqualTo: profil.uid).where('mis_id', isEqualTo: '12345678').snapshots(),
      builder: (context, snapshot) {
        return !snapshot.hasData
            ? text(money.moneyCurrency('0'),
                fontSize: textSizeLargeMedium,
                textColor: t1TextColorPrimary,
                fontFamily: fontMedium)
            : _Saldo(context, snapshot.data.documents);
      },
    );
  }

  Widget _Saldo(BuildContext context, List<DocumentSnapshot> snapshot) {
    double debit = 0;
    double credit = 0;
    double saldo = 0;
   if(snapshot.length<1){
     saldo = 0;
   }else{
      for (DocumentSnapshot element in snapshot){
          if(element['mis_name']=='Debit'){
            debit += double.parse(element['gross_amount']);
          }else{
            credit += double.parse(element['gross_amount']);
          }
      }
     saldo = debit - credit;
   }

    return text(money.moneyCurrency(saldo.toString()),
        fontSize: textSizeLargeMedium,
        textColor: t1TextColorPrimary,
        fontFamily: fontMedium);
  }
}
