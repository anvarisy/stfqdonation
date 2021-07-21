import 'dart:convert';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:qbsdonation/com.stfqmarket/helper/TempData.dart';
import 'package:qbsdonation/com.stfqmarket/helper/workaround.dart';
import 'package:qbsdonation/com.stfqmarket/main/homesections/root.dart';
import 'package:qbsdonation/com.stfqmarket/objects/product.dart';
import 'package:qbsdonation/com.stfqmarket/item-view/product.dart';

class MainPageRecommendedProductSection extends StatefulWidget {
  final void Function(int count) rootAction;
  final void Function(int page) changeRootPage;

  const MainPageRecommendedProductSection({Key key,
    @required this.rootAction,
    @required this.changeRootPage
  }) : super(key: key);

  @override
  _MainPageRecommendedProductSectionState createState() => _MainPageRecommendedProductSectionState();
}

class _MainPageRecommendedProductSectionState extends State<MainPageRecommendedProductSection> {
  Future<List<Product>> _futureData;

  Future<List<Product>> _fetchData() async {
    final response = await http.get(WorkAround.httpUrl('http://rest-netfarm.daf-q.id/product/?limit=10'));

    if ([200, 201].contains(response.statusCode)) {
      var data = json.decode(response.body)['results'];
      final productList = Product.toList(data);

      TempData.MainPageRecommendedProductSection.addAll(productList);
      return productList;
    }
    else {
      throw Exception('Failed to load');
    }
  }

  Future<List<Product>> _fetchTempData() async => TempData.MainPageRecommendedProductSection;

  @override
  void initState() {
    super.initState();

    if (TempData.MainPageRecommendedProductSection.isEmpty)
      _futureData = _fetchData();
    else _futureData = _fetchTempData();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Produk Pilihan',
                  style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w300,),),
                /*GestureDetector(
                  onTap: () => widget.changeHomeView(MainPageHomeRoot.HOME_PRODUCTS_GRID),
                  child: Text(
                    'View all >>',
                    style: TextStyle(fontSize: 16.0, color: Colors.deepOrange, fontWeight: FontWeight.w400),),
                )*/
              ],
            ),
          ),
          Container(
            height: 265.0,
            child: FutureBuilder<List<Product>>(
              future: _futureData,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  var data = snapshot.data;

                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: data.length,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (_, i) {
                      return ProductItemView(product: data[i], changeRootPage: widget.changeRootPage, newProductCountAction: widget.rootAction,);
                    },
                  );
                }
                else if (snapshot.hasError)
                  return Center(
                    child: Text('Check your internet.'),
                  );
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
            ),
          ),
        ],
      ),
    );
  }
}
