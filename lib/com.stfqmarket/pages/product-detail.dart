
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:qbsdonation/com.stfqmarket/components/bottomnavbar.dart';
import 'package:qbsdonation/com.stfqmarket/components/carousel.dart';
import 'package:qbsdonation/com.stfqmarket/components/expansiontile.dart';
import 'package:qbsdonation/com.stfqmarket/helper/saveddata.dart';
import 'package:qbsdonation/com.stfqmarket/helper/workaround.dart';
import 'package:qbsdonation/com.stfqmarket/objects/halaldetail.dart';
import 'package:qbsdonation/com.stfqmarket/objects/product.dart';
import 'package:qbsdonation/com.stfqmarket/pages/fullscreen-widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class STFQMarketProductPage extends StatefulWidget {
  STFQMarketProductPage({Key key, this.product}) : super(key: key);

  final Product product;

  @override
  _STFQMarketProductPageState createState() => _STFQMarketProductPageState();
}

class _STFQMarketProductPageState extends State<STFQMarketProductPage> {
  final GlobalKey<DefaultBottomNavigationBarState> _bottomNavKey = GlobalKey();

  Product _product;
  int _productsCountInCart = 0;
  int _count = -1;

  _loadCount() async {
    _product = widget.product;
    _count = _product.count;

    final pref = await SharedPreferences.getInstance();
    final savedCarts = SavedData.getSavedCarts(pref);
    setState(() {
      _productsCountInCart = savedCarts.length;
    });
  }

  _incrementCount(id, tenantId) async {
    setState(() {
      _count++;
    });
    _product.count = _count;
    _productsCountInCart = await SavedData.putProductToCart(_product);
    _bottomNavKey.currentState.updateProductCount(_productsCountInCart);
  }

  _decrementCount(id, tenantId) async {
    setState(() {
      _count--;
    });
    _product.count = _count;
    _productsCountInCart = await SavedData.putProductToCart(_product);
    _bottomNavKey.currentState.updateProductCount(_productsCountInCart);
  }

  _changePage(int index) {
    Navigator.of(context).pop({
      'page': index,
      'thisProductCount': _count,
      'productsCount': _productsCountInCart,
    });
  }

  _showFullscreenImage(String image) {
    MaterialPageRoute route = MaterialPageRoute(
      builder: (c) => FullscreenWidget(
        Image.network(
          image,
          fit: BoxFit.contain,
        ),
      )
    );
    Navigator.push(context, route);
  }

  @override
  void initState() {
    _loadCount();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _changePage(0);
        return false;
      },
      child: SafeArea(
        child: Scaffold(
          bottomNavigationBar: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Card(
                margin: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                ),
                color: Colors.transparent,
                elevation: 0.0,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${widget.product.formattedPrice}',
                            textAlign: TextAlign.start,
                            style: TextStyle(
                              color: Theme.of(context).accentColor,
                              fontSize: 20.0,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 4.0,),
                          Text(
                            'Harga per produk',
                            textAlign: TextAlign.start,
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12.0,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: 28.0,
                            height: 28.0,
                            child: OutlineButton(
                              child: Icon(Icons.remove, size: 18, color: Colors.black,),
                              padding: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                              onPressed: () {
                                if (_count >= 1)
                                  _decrementCount(widget.product.id, widget.product.tenantId);
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4.0),
                            child: Container(
                              width: 30.0,
                              child: Text(
                                '$_count',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          Container(
                            width: 28.0,
                            height: 28.0,
                            child: RaisedButton(
                              child: Icon(Icons.add, size: 18, color: Colors.white,),
                              elevation: 0,
                              padding: EdgeInsets.zero,
                              color: Theme.of(context).accentColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                              onPressed: () => _incrementCount(widget.product.id, widget.product.tenantId),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              DefaultBottomNavigationBar(
                key: _bottomNavKey,
                changePage: _changePage,
                noneSelected: true,
              ),
            ],
          ),
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                title: Text('Detail Produk'),
                pinned: true,
                stretch: true,
                stretchTriggerOffset: 80.0,
                expandedHeight: 250.0,
                flexibleSpace: FlexibleSpaceBar(
                  background: Hero(
                    tag: 'hero-product-image-${widget.product.id}',
                    child: Carousel(
                      itemBuilder: (_, i) {
                        var image = i == 0
                            ? widget.product.image
                            : widget.product.imageCollections[i-1];

                        return GestureDetector(
                          onTap: () => _showFullscreenImage(image),
                          child: Image.network(
                            image,
                            fit: BoxFit.cover,
                          ),
                        );
                      },
                      itemsLength: 1 +
                          // if imageCollections is empty
                          ( widget.product.imageCollections[0].isEmpty
                              ? 0
                              : widget.product.imageCollections.length
                      ),
                      viewportFraction: 1.0,
                      imageAspectRatio: 12.0/9.0,
                      showDotsIndicator: true,
                    ),
                  ),
                ),
              ),
              SliverFillRemaining(
                hasScrollBody: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      color: Colors.white,
                      padding: EdgeInsets.only(top: 24.0, bottom: 8.0, left: 14.0, right: 14.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${widget.product.name}',
                            style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 4.0,),
                          Text(
                            '${widget.product.categories.map((e) => e.name).toString().replaceAll('(', '').replaceAll(')', '')}',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 16.0,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Container(
                        color: Colors.white,
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          (widget.product.desc == null || widget.product.desc.isEmpty)
                              ? 'Produk ini tidak memiliki deskripsi.'
                              : widget.product.desc,
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
