import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:qbsdonation/com.stfqmarket/components/carousel.dart';
import 'package:http/http.dart' as http;
import 'package:qbsdonation/com.stfqmarket/helper/workaround.dart';
import 'package:url_launcher/url_launcher.dart';

class Promo {
  final String dateStart, dateEnd, name, imageUrl, url;
  final int tenantId, position;

  Promo(this.dateStart, this.dateEnd, this.name, this.imageUrl, this.url, this.tenantId, this.position);
  
  static List<Promo> toList(List<dynamic> json) {
    return json.map((e) => Promo(e['date_start'], e['date_end'], e['name'], e['image'], e['url'], e['tenant_id'], e['position'])).toList();
  }
}

class MainPagePromoSection extends StatefulWidget {
  final double height;

  const MainPagePromoSection({Key key, @required this.height}) : super(key: key);

  @override
  _MainPagePromoSectionState createState() => _MainPagePromoSectionState();
}

class _MainPagePromoSectionState extends State<MainPagePromoSection> {
  final imageWidthRatio = 40.0;
  final imageHeightRatio = 12.0;

  Future<List<Promo>> _futureData;

  Future<List<Promo>> _fetchData() async {
    final response = await http.get(WorkAround.httpUrl('http://rest-netfarm.daf-q.id/promo/'));

    if ([200, 201].contains(response.statusCode)) {
      return Promo.toList(json.decode(response.body));
    }
    else {
      throw Exception('Failed to load');
    }
  }

  @override
  void initState() {
    super.initState();
    _futureData = _fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: kToolbarHeight),
      child: Stack(
        children: [
          Container(
            child: Column(
              children: [
                Expanded(flex: 1, child: Container(color: Theme.of(context).primaryColor,)),
                Expanded(flex: 1, child: Container(color: Theme.of(context).scaffoldBackgroundColor,)),
              ],
            ),
          ),
          Container(
            height: widget.height,
            alignment: Alignment.center,
            child: FutureBuilder<List<Promo>>(
              future: _futureData,
              builder: (_, snapshot) {
                if (snapshot.hasData) {
                  var data = snapshot.data;

                  return Carousel(
                    itemBuilder: (_, i) {
                      return GestureDetector(
                        onTap: () async {
                          final url = Uri.decodeFull(data[i].url);
                          if (await canLaunch(url))
                            await launch(url);
                          else throw('Could not launch $url');
                        },
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.0),
                          child: Image.network(
                            data[i].imageUrl,
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    },
                    itemsLength: data.length,
                    imageAspectRatio: imageWidthRatio / imageHeightRatio,
                  );
                }
                return Container();
              },
            ),
          ),
        ],
      ),
    );
  }
}
