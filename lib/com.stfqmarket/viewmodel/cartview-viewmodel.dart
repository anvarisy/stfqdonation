
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:qbsdonation/com.stfqmarket/helper/constant.dart';
import 'package:qbsdonation/com.stfqmarket/helper/generator.dart';
import 'package:qbsdonation/com.stfqmarket/helper/saveddata.dart';
import 'package:qbsdonation/com.stfqmarket/objects/cart.dart';
import 'package:qbsdonation/com.stfqmarket/objects/product.dart';
import 'package:qbsdonation/com.stfqmarket/objects/tenant.dart';
import 'package:qbsdonation/models/dafq.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartViewViewModel extends ChangeNotifier {
  double _progress = 0;

  double progress(AnimationController controller, Animation<double> animation) {
    Tween<double> _loadingTween = Tween(
      begin: _progress,
      end: 1.0,
    );
    controller..value = 0..forward();
    return _loadingTween.evaluate(animation);
  }

  List<Cart> _carts;

  List<Cart> get carts => _carts;

  void loadCheckout(user_profil user) async {
    _carts = await _loadCheckoutCarts(user);
    notifyListeners();
  }
  
  void loadPayment(String userId) async {
    _carts = await _loadPaymentCarts(userId);
    notifyListeners();
  }

  void loadPostPayment(String userId) async {
    _carts = await _loadPostPaymentCarts(userId);
    notifyListeners();
  }
  
  void deleteCart(String orderId) {
    print(orderId);
    if (_carts != null) {
      _carts.removeWhere((element) => element.orderId == orderId);
      notifyListeners();
    }
  }

  Future<List<Cart>> _loadCheckoutCarts(user_profil profil) async {
    _progress = null;
    notifyListeners();

    final pref = await SharedPreferences.getInstance();
    final savedCarts = SavedData.getSavedCarts(pref);

    List<String> _savedTenantData = List();
    List<String> _savedProductData = List();
    savedCarts.keys.forEach((element) {
      _savedTenantData.add(element);
    });
    savedCarts.values.forEach((element) {
      if (element != null) (element as List).forEach((element2) {
        _savedProductData.add('${element2['id']}:${element2['count']}');
      });
    });

    var maxProgress = _savedTenantData.length + _savedProductData.length;
    // if no data
    if (maxProgress == 0) return List();
    else {
      var prog = 0;

      _progress = 0;
      notifyListeners();

      // tenant
      List<Tenant> tenants = List();
      for (final tenantId in _savedTenantData) {
        _progress = (++prog / maxProgress) * 1.0;
        notifyListeners();

        var item = await Firestore.instance.collection('stfq-market').document('Tenants').collection('items').document(tenantId).get();
        tenants.add(Tenant.toTenant(item));
      }

      // product
      Map<String, Product> products = Map();
      for (final product in _savedProductData) {
        _progress = (++prog / maxProgress) * 1.0;
        notifyListeners();

        final productId = product.split(':')[0];
        final productCount = int.tryParse(product.split(':')[1]) ?? 0;

        var item = await Firestore.instance.collection('stfq-market').document('Products').collection('items').document(productId).get();
        var docProduct = Product.toProduct(item);
        docProduct.count = productCount;
        products[item.documentID] = docProduct;
      }

      // cart
      List<Cart> carts = List();
      for (final tenant in tenants) {
        List<dynamic> savedProducts = savedCarts['${tenant.id}'];

        final DateTime dateNow = DateTime.now();
        final String dateFormat = '${dateNow.year}/${dateNow.month}/${dateNow.day}';

        List<Product> productsInTenant = savedProducts.map((e) => products['${e['id']}']).toList();
        List<CartDetail> details = productsInTenant.map((e) => CartDetail(e.name, e.date, e.image, e.id, e.price, e.count, e.weight)).toList();
        carts.add(
            Cart('', Generator().generateRandomId(), tenant.name,
                dateFormat, Constant.orderStatus.pendingCheckout, tenant.id, tenant.cityCode, null,
                CartUser(profil.uid, profil.name, profil.email), details));
      }

      return carts;
    }
  }
  
  Future<List<Cart>> _loadPaymentCarts(String userId) async {
    var documents = await Firestore.instance.collection('stfq-market').document('Carts').collection('items')
        .where('user.uid', isEqualTo: userId).where('status', isEqualTo: Constant.orderStatus.pendingPayment).getDocuments();

    List<Cart> carts = Cart.toList(documents.documents);
    return carts;
  }

  Future<List<Cart>> _loadPostPaymentCarts(String userId) async {
    var documents = await Firestore.instance.collection('stfq-market').document('Carts').collection('items')
        .where('user.uid', isEqualTo: userId).getDocuments();

    List<Cart> carts = Cart.toList(documents.documents);
    carts.removeWhere((element) => element.status == Constant.orderStatus.pendingPayment);
    return carts;
  }
}