import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:qbsdonation/com.stfqmarket/helper/workaround.dart';
import 'package:qbsdonation/com.stfqmarket/item-view/product.dart';
import 'package:qbsdonation/com.stfqmarket/main/homesections/root.dart';
import 'package:qbsdonation/com.stfqmarket/objects/category.dart';
import 'package:qbsdonation/com.stfqmarket/objects/product.dart';
import 'package:http/http.dart' as http;

class ProductsGrid extends StatefulWidget {
  static const String routeName = '/product-grid';

  final void Function(int count) rootAction;
  final void Function(int page) changeRootPage;
  final String searchQuery;

  const ProductsGrid({Key key,
    @required this.rootAction, @required this.changeRootPage, this.searchQuery
  }) : super(key: key);

  @override
  _ProductsGridState createState() => _ProductsGridState();
}

class _ProductsGridState extends State<ProductsGrid> {
  static const SORT_TERBARU = 0;
  static const SORT_FAVORITE = 1;
  static const SORT_PALING_LAKU = 2;
  static const SORT_PALING_MURAH = 3;
  static const SORT_PALING_MAHAL = 4;

  static const _fetchProductsLimit = 9;

  ScrollController _scrollController;

  bool _fetchDataFailed = false;
  bool _noProduct = false;

  String _nextUrl;

  String _searchValue = '';
  Timer _searchDelay;

  int _categoryValue = -1;
  int _sortValue = SORT_TERBARU;

  int _productsCount = -1;

  final List<Product> _productsList = List();
  Future<List<Category>> _futureCategories;

  Future<List<Category>> _fetchCategories() async {
    final response = await http.get(WorkAround.httpUrl('http://rest-netfarm.daf-q.id/category/'));

    if ([200, 201].contains(response.statusCode)) {
      return Category.toList(json.decode(response.body));
    }
    else {
      throw Exception('Failed to load');
    }
  }

  bool _isRefreshing = false;
  bool _allLoaded = false;
  void _fetchProducts({bool refresh=false}) async {
    if (refresh) {
      setState(() {
        _fetchDataFailed = false;
        _noProduct = false;
        _allLoaded = false;
        _productsList.clear();
      });

      _nextUrl = (_categoryValue == -1)
          ? 'http://rest-netfarm.daf-q.id/product/?limit=$_fetchProductsLimit&search=$_searchValue'
          : 'http://rest-netfarm.daf-q.id/product/?cid=$_categoryValue&limit=$_fetchProductsLimit&search=$_searchValue';

      switch (_sortValue) {
        case SORT_TERBARU:
          _nextUrl += '&ordering=-product_date';
          break;
        case SORT_FAVORITE:
          //
          break;
        case SORT_PALING_LAKU:
          _nextUrl = 'http://rest-netfarm.daf-q.id/laris/?cid=$_categoryValue&limit=$_fetchProductsLimit&search=$_searchValue';
          break;
        case SORT_PALING_MURAH:
          _nextUrl += '&ordering=+product_price';
          break;
        case SORT_PALING_MAHAL:
          _nextUrl += '&ordering=-product_price';
          break;
      }
    }

    if (_nextUrl == null) return;
    final response = await http.get(WorkAround.httpUrl(_nextUrl));

    if ([200, 201].contains(response.statusCode)) {
      var responseData = json.decode(response.body);

      if (responseData['count'] == 0) {
        setState(() => _noProduct = true);
      }
      else {
        _nextUrl = responseData['next'];

        if (_nextUrl == null) {
          _allLoaded = true;
        }

        final result = Product.toList(responseData['results']);
        setState(() => _productsList.addAll(result));
      }
    }
    else {
      setState(() => _fetchDataFailed = true);
      throw Exception('Failed to load');
    }

    _isRefreshing = false;
  }

  _setProductCount(int count) {
    setState(() => _productsCount = count);
    widget.rootAction(_productsCount);
  }

  @override
  void initState() {
    /*_scrollController = ScrollController(initialScrollOffset: 8.0)
      ..addListener(() {
        if (_scrollController.offset >= _scrollController.position.maxScrollExtent
        && !_scrollController.position.outOfRange)
          if (!_isRefreshing) {
            _isRefreshing = true;
            _fetchProducts();
          }
      });
    _futureCategories = _fetchCategories();
    _fetchProducts(refresh: true);*/
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Semua Produk',
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w300,),),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(4.0),
          child: FutureBuilder<QuerySnapshot>(
            future: widget.searchQuery.isNotEmpty 
                ? Firestore.instance.collection('stfq-market').document('Products').collection('items').orderBy('product_name')
                .where('product_query', arrayContains: widget.searchQuery).getDocuments()
                //.where('product_name', isGreaterThanOrEqualTo: widget.searchQuery).where('product_name', isLessThanOrEqualTo: widget.searchQuery+ '\uf8ff').getDocuments()
                : Firestore.instance.collection('stfq-market').document('Products').collection('items').orderBy('product_name')
                .getDocuments(),
            builder: (_, snapshot) {
              if (snapshot.hasData) {
                var data = Product.toList(snapshot.data.documents);

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, childAspectRatio: 9.0/16.0),
                  itemCount: data.length,
                  itemBuilder: (_, i) => ProductItemView(
                    key: Key('${data[i].id}'),
                    product: data[i],
                    buttonSize: 28.0,
                    titleFontWeight: FontWeight.w400,
                    buttonShrink: true,
                    buttonAttachedToBottom: true,
                    newProductCountAction: _setProductCount,
                    changeRootPage: widget.changeRootPage,
                  ),
                );
              }
              else if (snapshot.hasError) {
                print(snapshot.error);
                return const Center(child: Text('Terjadi masalah'),);
              }

              return const Center(child: CircularProgressIndicator(),);
              },
          ),
        ),
      ],
    );
  }
}
