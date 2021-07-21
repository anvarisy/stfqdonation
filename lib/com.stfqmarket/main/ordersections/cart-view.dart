import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:qbsdonation/com.stfqmarket/helper/constant.dart';
import 'package:qbsdonation/com.stfqmarket/helper/saveddata.dart';
import 'package:qbsdonation/com.stfqmarket/helper/sessionmanager.dart';
import 'package:qbsdonation/com.stfqmarket/main/ordersections/payment-bottomsheet.dart';
import 'package:qbsdonation/com.stfqmarket/main/ordersections/product-view.dart';
import 'package:qbsdonation/com.stfqmarket/objects/cart.dart';
import 'dart:convert';
import 'package:qbsdonation/models/dafq.dart';
import 'package:qbsdonation/screens/detail_screen.dart';

class CartView extends StatefulWidget {
  final user_profil profile;
  final List<Cart> carts;
  final int status;
  final void Function(int count) updateCartCount;
  final void Function() reloadPaymentCart;
  final void Function(String orderId) deleteCart;

  const CartView({Key key,
    @required this.profile, @required this.carts, this.status=0,
    this.updateCartCount, this.reloadPaymentCart, this.deleteCart
  }) : super(key: key);

  @override
  _CartViewState createState() => _CartViewState();
}

class _CartViewState extends State<CartView> with SingleTickerProviderStateMixin {
  static const STATUS_CHECKOUT = 0;
  static const STATUS_PAYMENT = 1;

  final Map<String, GlobalKey<AnimatedListState>> _productListKeys = Map();

  TabController _tabController;
  int _tabIndex = 0;

  Future<void> _doCheckout(Cart cart) async {
    var marketCol = Firestore.instance.collection('stfq-market');

    final DateTime dateNow = DateTime.now();
    final String dateFormat = '${dateNow.day}/${dateNow.month}/${dateNow.year}';

    Map<String, dynamic> postData = {
      "order_id": cart.orderId,
      "total": cart.multipliedTotal,
      "date_update": dateFormat,
      "tenant_id": cart.tenantId,
      "tenant_name": cart.tenantName,
      "tenant_city_code": cart.tenantCityCode,
      "status": Constant.orderStatus.pendingPayment,
      "user": {
        "uid": widget.profile.uid.toString(),
        "fullname": widget.profile.name.toString(),
        "email": widget.profile.email.toString(),
      },
      "details": [
        for (final detail in cart.details) {
          "product_id": detail.productId,
          "count_product": detail.countProduct,
          "total": detail.multipliedTotal,
          "date_update": detail.dateUpdate,
          'product_name': detail.productName,
          'product_weight': detail.productWeight,
          'product_image': detail.productImage,
        },
      ],
    };

    return marketCol.document('Carts').collection('items').add(postData)
        .then((doc) =>
          marketCol.document('Carts').collection('items').document(doc.documentID).updateData({
            "order_id": 'mk-'+doc.documentID,})
        )
        .whenComplete(() async {
          int savedCarts = await SavedData.deleteSavedCart('${cart.tenantId}');
          widget.updateCartCount(savedCarts);
          widget.deleteCart(cart.orderId);
        }).catchError((e) {
          print(e);
          Scaffold.of(context).showSnackBar(
              SnackBar(content: Text('Gagal checkout. Periksa internet anda dan ulangi lagi.'))
          );
        });
  }

  Future<void> _doCancelOrder(BuildContext context, Cart cart) async {
    await Firestore.instance.collection('stfq-market').document('Carts').collection('items').document(cart.docId).delete()
        .whenComplete(() {
          widget.deleteCart(cart.orderId);
        }).catchError((e) {
          print(e);
          Scaffold.of(context).showSnackBar(
              SnackBar(content: Text('Gagal membatalkan order. Periksa internet anda dan ulangi lagi.'))
          );
        });
  }

  Future<void> _doPayment(Cart cart) async {
    num totalWeight = 0;
    for (CartDetail detail in cart.details) {
      totalWeight += detail.productWeight;
    }

    showModalBottomSheet<void>(
      context: context,
      builder: (_) {
        return PaymentBottomSheet(
          cartContext: context,
          totalWeight: totalWeight,
          cart: cart,
          cancelOrder: _doCancelOrder,
        );
      },
    );
  }

  _updateTotal(String cartOrderId, int detailI, int count) {
    setState(() => widget.carts.singleWhere((element) => element.orderId == cartOrderId).details[detailI].countProduct = count);
  }

  Future<void> _deleteProduct(String cartOrderId, int detailI) async {
    Cart cart = widget.carts.singleWhere((element) => element.orderId == cartOrderId);
    CartDetail detail = cart.details[detailI];

    setState(() {
      cart.details.removeAt(detailI);

      _productListKeys[cartOrderId].currentState.removeItem(
        detailI,
            (context, animation) => FadeTransition(
              opacity: CurvedAnimation(parent: animation, curve: Interval(0.5, 1.0)),
              child: SizeTransition(
                sizeFactor: CurvedAnimation(parent: animation, curve: Interval(0.0, 1.0)),
                axisAlignment: 0.0,
                child: ProductView(
                  key: ValueKey(detail.productId),
                  tenantId: cart.tenantId,
                  detail: detail,
                  detailIndex: detailI,
                ),
              ),
            ),
        duration: Duration(milliseconds: 700),
      );
    });

    if (cart.details.isEmpty) {
      widget.deleteCart(cart.orderId);
    }
  }

  Future<bool> _showDialog(String title, String message) async {
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(message),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text('Tidak'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: Text('Ya'),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );
  }

  BuildContext _loadingDialogContext;
  Future<void> _showLoadingDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        _loadingDialogContext = context;
        return AlertDialog(
          content: SingleChildScrollView(
            child: Column(
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 12.0,),
                Text('Mohon Tunggu...'),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void initState() {
    _tabController = TabController(
      initialIndex: _tabIndex,
      length: widget.carts.length,
      vsync: this,
    );
    for (final cart in widget.carts) {
      _productListKeys[cart.orderId] = GlobalKey();
    }
    super.initState();
  }


  @override
  void dispose() {
    if (_tabController != null) _tabController.dispose();
    super.dispose();
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
            isScrollable: true,
            onTap: (i) {
              _tabIndex = i;
            },
            tabs: [
              for (final cart in widget.carts) Tab(
                text: cart.tenantName,
              ),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            physics: NeverScrollableScrollPhysics(),
            controller: _tabController,
            children: [
              for (final cart in widget.carts) Column(
                children: [
                  Expanded(
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      fit: StackFit.expand,
                      children: [
                        ListView(
                          children: [
                            Container(
                              height: 80.0,
                              padding: EdgeInsets.all(8.0),
                              margin: EdgeInsets.zero,
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.info,
                                        color: Theme.of(context).accentColor,
                                        size: 16.0,
                                      ),
                                      Text(
                                        '',
                                        style: TextStyle(
                                          fontSize: 18.0,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(width: 3.0,),
                                  Expanded(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                      children: [
                                        Text(
                                          'Selesaikan Belanja di ${cart.tenantName}',
                                          textAlign: TextAlign.start,
                                          style: TextStyle(
                                            fontSize: 16.0,
                                            fontWeight: FontWeight.w300,
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              '${cart.details.length} Produk',
                                              textAlign: TextAlign.start,
                                              style: TextStyle(
                                                color: Theme.of(context).accentColor,
                                                fontSize: 16.0,
                                                fontWeight: FontWeight.w300,
                                              ),
                                            ),
                                            Text(
                                              ' dikeranjang belanjaan',
                                              textAlign: TextAlign.start,
                                              style: TextStyle(
                                                color: Colors.grey,
                                                fontSize: 16.0,
                                                fontWeight: FontWeight.w300,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            AnimatedList(
                              key: _productListKeys[cart.orderId],
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              padding: EdgeInsets.zero,
                              initialItemCount: cart.details.length,
                              itemBuilder: (_, i, anim) {
                                String key = '$i${cart.orderId}${cart.details[i].productId}';
                                return FadeTransition(
                                  opacity: anim,
                                  child: ProductView(
                                    key: Key(key),
                                    status: widget.status,
                                    tenantId: cart.tenantId,
                                    detail: cart.details[i],
                                    cartOrderId: cart.orderId,
                                    detailIndex: i,
                                    updateViewTotal: _updateTotal,
                                    updateCartCount: widget.updateCartCount,
                                    deleteProductAction: _deleteProduct,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        if (widget.status == STATUS_PAYMENT) Positioned(
                          right: 16.0, bottom: 0.0,
                          child: Container(
                            width: 80.0, height: 30.0,
                            child: RaisedButton.icon(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(topLeft: Radius.circular(8.0), topRight: Radius.circular(8.0)),
                              ),
                              elevation: 0,
                              padding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 0.0),
                              color: Colors.redAccent,
                              icon: Icon(
                                Icons.cancel,
                                color: Colors.white,
                                size: 13.0,
                              ),
                              label: Text(
                                'Cancel',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              onPressed: () async {
                                bool isCancel = await _showDialog('Hapus Order', 'Apa anda yakin ingin membatalkan order di ${cart.tenantName}?');

                                if (isCancel) {
                                  _showLoadingDialog();
                                  await _doCancelOrder(context, cart);
                                  Navigator.of(_loadingDialogContext).pop();
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Card(
                    margin: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                    color: Theme.of(context).cardColor,
                    elevation: 8.0,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Total',
                                  textAlign: TextAlign.start,
                                  style: TextStyle(
                                    fontSize: 12.0,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(height: 4.0,),
                                Text(
                                  widget.status == STATUS_CHECKOUT ? cart.formattedMultipliedTotal : cart.formattedTotal,
                                  textAlign: TextAlign.start,
                                  style: TextStyle(
                                    color: Theme.of(context).accentColor,
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.end, //CrossAxisAlignment.stretch,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                RaisedButton.icon(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15.0),
                                  ),
                                  elevation: 0,
                                  padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                                  color: Theme.of(context).accentColor,
                                  icon: Icon(
                                    widget.status == 0 ? Icons.shopping_bag : Icons.payment,
                                    color: Colors.white,
                                  ),
                                  label: Text(
                                    widget.status == STATUS_CHECKOUT ? 'Checkout' : 'Pay',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  onPressed: () async {
                                    if (widget.status == STATUS_CHECKOUT) {
                                      bool isAgree = await _showDialog('Konfirmasi Checkout', 'Apa anda yakin ingin checkout di ${cart.tenantName}?');

                                      if (isAgree) {
                                        _showLoadingDialog();
                                        await _doCheckout(cart);
                                        Navigator.of(_loadingDialogContext).pop();
                                      }
                                    }
                                    else if (widget.status == STATUS_PAYMENT) {
                                      await _doPayment(cart);
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
