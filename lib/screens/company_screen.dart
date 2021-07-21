import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html/html_parser.dart';
import 'package:flutter_html/style.dart';
import 'package:qbsdonation/components/dashboard/dashboard_appbar.dart';
import 'package:qbsdonation/components/profil/fab_socialmedia.dart';
import 'package:qbsdonation/models/dafq.dart';
import 'package:qbsdonation/screens/grid_photo.dart';
import 'package:qbsdonation/screens/image_all_screen.dart';
import 'package:qbsdonation/utils/colors.dart';
import 'package:qbsdonation/utils/constants.dart';
import 'package:qbsdonation/utils/widgets.dart';


class company_screen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return company();
  }
}

class company extends State<company_screen> {
  int position;

  var items = [];

  Widget mInfo(int position) {
    return Container(
      margin: EdgeInsets.all(spacing_standard_new),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
        Html(
          data: """
            <div>
                ${items[position]}
            </div>
      """,
        style: {
                "div":Style(
                  textAlign: TextAlign.justify,
                  color: Color(0xFF130925),
                  fontSize: FontSize(16.0),
                  letterSpacing: 0.25
                ),
        },
        //Optional parameters:
      ),
          SizedBox(
            height: spacing_standard_new,
          ),
          Divider(
            height: 1,
            color: t10_view_color,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      // floatingActionButton: fab_socialmedia(),
      body: BuildCompany(context),

    );
  }

  @override
  void initState() {
    super.initState();
    position = 0;
  }
  
  Widget BuildCompany(BuildContext context){
   return StreamBuilder<QuerySnapshot>(
       stream: Firestore.instance.collection('Profil').snapshots(),
       builder: (context, snapshot) {
         return !snapshot.hasData
             ? Text('-')
             : _Company(context, snapshot.data.documents);
       },);
  }

  Widget _Company(BuildContext context, List<DocumentSnapshot> snapshot){
    String misi = '<ol>';
    var width = MediaQuery.of(context).size.width;
    company_ c = company_();
    for (DocumentSnapshot element in snapshot){
        c.detail = element['profil_detail'];
        c.photos = element['photo_collection'];
        c.visi = element['profil_vision'];
        c.missions = element['profil_mission'];
    }
    for (String item in c.missions){
      misi+='<li>'+'${item}'+'</br>'+'</li>';
    }
    misi+='</ol>';
       items.add(c.detail);
       items.add(c.visi);
       items.add(misi);

    return SafeArea(
      child: Column(
        children: <Widget>[
          // TopBar('Profile',bgColor: p_11.withOpacity(0.87),),
          Expanded(
            child: SingleChildScrollView(
              child: Container(
                decoration: backgroundDecor(),
                child: Column(
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.all(spacing_standard_new),
                      child: Column(
                        children: <Widget>[
                          Image.asset(
                            'assets/images/dafq.png',
                            width: width,
                            height: width * 0.4,
                            fit: BoxFit.fill,
                          ),
                          SizedBox(
                            height: spacing_standard_new,
                          ),
                        ],
                      ),
                    ),
                    DefaultTabController(
                      child: TabBar(
                        onTap: (i) {
                          setState(() {
                            position = i;
                          });
                        },
                        unselectedLabelColor: t10_textColorSecondary,
                        indicatorColor: t10_colorPrimary,
                        labelColor: t10_colorPrimary,
                        tabs: <Widget>[
                          Tab(
                            //padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                            child: FittedBox(
                              child: text_normal(
                                'Tentang DAFQ',
                              ),
                            ),
                          ),
                          Tab(
                            //padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                            child: FittedBox(
                              child: text_normal(
                                'Visi DAFQ',
                              ),
                            ),
                          ),
                          Tab(
                            //padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                            child: FittedBox(
                              child: text_normal(
                                'Misi DAFQ',
                              ),
                            ),
                          ),
                        ],
                      ),
                      length: 3,
                    ),
                    mInfo(position),
                    Container(
                      margin: EdgeInsets.all(spacing_standard_new),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              text_normal('Koleksi Photo', fontFamily: fontMedium, fontSize: textSizeLargeMedium),
                              InkWell(
                                onTap: ()=>{
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context)=>image_all_screen(images: c.photos,)
                                  ))
                                },
                                child:  RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(text: 'Lainnya', style: TextStyle(fontSize: textSizeMedium, fontFamily: fontMedium, color: t10_textColorSecondary)),
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
                          SizedBox(
                            height: spacing_standard_new,
                          ),
                          grid_photo(images: c.photos,max: c.photos.length<=6? c.photos.length:6,)
                        ],
                      ),
                    ),

                  ],
                ),
              )
            ),
          )
        ],
      ),
    );
  }
}
