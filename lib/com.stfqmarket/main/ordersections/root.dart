import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qbsdonation/com.stfqmarket/helper/constant.dart';
import 'package:qbsdonation/com.stfqmarket/helper/generator.dart';
import 'package:qbsdonation/com.stfqmarket/helper/sessionmanager.dart';
import 'package:qbsdonation/com.stfqmarket/helper/saveddata.dart';
import 'package:qbsdonation/com.stfqmarket/helper/workaround.dart';
import 'package:qbsdonation/com.stfqmarket/main/ordersections/cart-view.dart';
import 'package:qbsdonation/com.stfqmarket/pages/order-history.dart';
import 'package:qbsdonation/com.stfqmarket/viewmodel/cartview-viewmodel.dart';
import 'package:qbsdonation/models/dafq.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:qbsdonation/com.stfqmarket/objects/tenant.dart';
import 'package:qbsdonation/com.stfqmarket/objects/product.dart';
import 'package:qbsdonation/com.stfqmarket/objects/cart.dart';
import 'package:stacked/stacked.dart';

class MainPageOrderRoot extends StatefulWidget {
  final void Function(int count) rootAction;
  final void Function(int index) changeRootPage;
  final user_profil profile;

  const MainPageOrderRoot({Key key, this.rootAction, this.changeRootPage, this.profile}) : super(key: key);

  @override
  _MainPageOrderRootState createState() => _MainPageOrderRootState();
}

class _MainPageOrderRootState extends State<MainPageOrderRoot> with TickerProviderStateMixin {
  TabController _tabController;
  int _tabIndex = 0;

  AnimationController _loadingController;
  Animation<double> _loadingCurve;

  String userId;


  @override
  void initState() {
    _loadingController = AnimationController(vsync: this, duration: Duration(milliseconds: 150));
    _loadingCurve = CurvedAnimation(
      parent: _loadingController,
      curve: Curves.easeOut,
    );
    _tabController = TabController(
      initialIndex: _tabIndex,
      length: 3,
      vsync: this,
    );
    userId = widget.profile.uid.toString();

    super.initState();
  }

  @override
  void dispose() {
    if (_loadingController != null) _loadingController.dispose();
    if (_tabController != null) _tabController.dispose();
    super.dispose();
  }

  Widget _tabBarViewContent() {
    switch (_tabIndex) {
      case 1:
        return ViewModelBuilder<CartViewViewModel>.reactive(
          key: Key('1'),
          createNewModelOnInsert: true,
          viewModelBuilder: () => CartViewViewModel(),
          onModelReady: (model) => model.loadPayment(userId),
          builder: (_, model, child) {
            if (model.carts != null && model.carts.isNotEmpty) {
              return CartView(
                key: Key('cv${model.carts.length}'),
                profile: widget.profile,
                carts: model.carts,
                status: _tabIndex,
                updateCartCount: widget.rootAction,
                deleteCart: model.deleteCart,
              );
            } else if (model.carts != null && model.carts.isEmpty) {
              return Center(child: Text('Belum ada keranjang yang sudah di periksa.', textAlign: TextAlign.center,),);
            }

            return Center(
              child: Container(
                width: 100.0,
                height: 100.0,
                child: CircularProgressIndicator(),
              ),
            );
          },
        );
        break;
      case 2:
        return ViewModelBuilder<CartViewViewModel>.reactive(
          key: Key('2'),
          createNewModelOnInsert: true,
          viewModelBuilder: () => CartViewViewModel(),
          onModelReady: (model) => model.loadPostPayment(userId),
          builder: (_, model, child) {
            if (model.carts != null && model.carts.isNotEmpty) {
              return OrderHistory(model.carts);
            } else if (model.carts != null && model.carts.isEmpty) {
              return Center(child: Text('Belum ada keranjang yang sudah di bayar.', textAlign: TextAlign.center,),);
            }

            return Center(
              child: Container(
                width: 100.0,
                height: 100.0,
                child: CircularProgressIndicator(),
              ),
            );
          },
        );
        break;
      case 0:
      default:
        return ViewModelBuilder<CartViewViewModel>.reactive(
          key: Key('0'),
          createNewModelOnInsert: true,
          viewModelBuilder: () => CartViewViewModel(),
          onModelReady: (model) => model.loadCheckout(widget.profile),
          builder: (_, model, child) {
            if (model.carts != null && model.carts.isNotEmpty) return CartView(
              key: Key('cv${model.carts.length}'),
              profile: widget.profile,
              carts: model.carts,
              status: _tabIndex,
              updateCartCount: widget.rootAction,
              deleteCart: model.deleteCart,
            );
            else if (model.carts != null && model.carts.isEmpty) {
              return Center(child: Text('Tidak ada barang di keranjang. Segera belanja produk kami.', textAlign: TextAlign.center),);
            }

            return Center(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 40.0),
                height: 15.0,
                child: LinearProgressIndicator(value: model.progress(_loadingController, _loadingCurve)),
              ),
            );
          },
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          color: Colors.white,
          child: TabBar(
            labelColor: Colors.black,
            unselectedLabelColor: Colors.black54,
            controller: _tabController,
            isScrollable: false,
            onTap: (i) {
              setState(() {
                _tabIndex = i;
              });
            },
            tabs: [
              Tab(text: 'Periksa'),
              Tab(text: 'Bayar'),
              Tab(text: 'Paska-Bayar'),
            ],
          ),
        ),
        Expanded(
          child: _tabBarViewContent(),
        ),
      ],
    );
  }
}