import 'dart:convert';

import 'package:qbsdonation/com.stfqmarket/objects/product.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SavedData {
  /// {
  ///   tenantId: [
  ///     {id: 1, count: 2},
  ///     {id: 2, count: 3},
  ///   ]
  /// }
  static const String SavedCartList = 'list:saved_cart';

  /// ['id'] ? ['1', '2']
  static const String BookmarkedProductList = 'list:product_bookmark'; // ? -$id

  /// {
  ///     "first_name": "TESTER",
  ///     "last_name": "MIDTRANSER",
  ///     "email": "test@midtrans.com",
  ///     "phone": "081 2233 44-55",
  ///     "address": "Sudirman",
  ///     "city": "Jakarta",
  ///     "postal_code": "12190",
  ///     "country_code": "IDN"
  /// }
  static const String SavedAddress = 'dynamic:saved_address';

  /// {
  ///   "{orderId}": "gojek://gopay/merchanttransfer"
  /// }
  static const String SavedPaymentUrl = 'dynamic:payment_url';

  static Map<String, dynamic> getSavedCarts(SharedPreferences pref) {
    var decodedCarts = jsonDecode(pref.getString(SavedCartList) ?? '{}');
    return decodedCarts;
  }

  static void setSavedCarts(SharedPreferences pref, Map<String, dynamic> carts) {
    var encodedCarts = jsonEncode(carts);
    pref.setString(SavedCartList, encodedCarts);
  }

  /// return cart length
  static Future<int> deleteSavedCart(String tenantId) async {
    final pref = await SharedPreferences.getInstance();

    final carts = getSavedCarts(pref);
    carts.remove(tenantId);
    setSavedCarts(pref, carts);

    return carts.length;
  }

  /// return cart length
  static Future<int> putProductToCart(Product product) async {
    final pref = await SharedPreferences.getInstance();

    final carts = getSavedCarts(pref);
    final List products = carts['${product.tenantId}'] ?? List();

    var pIndex = products.indexWhere((element) => element['id'] == product.id);
    if (pIndex != -1) {
      products.removeAt(pIndex);
    }

    if (product.count > 0) {
      products.add({
        'id': product.id,
        'count': product.count
      });
    }

    if (products.isEmpty) {
      carts.remove('${product.tenantId}');
    } else {
      carts['${product.tenantId}'] = products;
    }
    setSavedCarts(pref, carts);
    return carts.length;
  }

  static Future<int> getProductCount(String id) async {
    final pref = await SharedPreferences.getInstance();

    final carts = getSavedCarts(pref);
    var count = 0;
    carts.values.forEach((element) {
      if (element != null) (element as List).forEach((element2) {
        if (element2['id'] == id) {
          count = element2['count'];
        }
      });
    });

    return count;
  }

  static Future<void> updateBookmarkedProductList(int id, bool setBookmark) async {
    final pref = await SharedPreferences.getInstance();

    List<int> bookmarkedProductList = pref.getStringList(BookmarkedProductList)
        .map<int>((e) => int.tryParse(e) ?? 0).toList() ?? List();

    if (setBookmark) {
      pref.setBool(BookmarkedProductList+'-$id', setBookmark);
      if (!bookmarkedProductList.contains(id))
        bookmarkedProductList.add(id);
    }
    else {
      pref.remove(BookmarkedProductList+'-$id');
      if (bookmarkedProductList.contains(id))
        bookmarkedProductList.remove(id);
    }
    pref.setStringList(BookmarkedProductList,
        bookmarkedProductList.map<String>((e) => e.toString()).toList()
    );
  }

  static dynamic getSavedAddress(SharedPreferences pref) {
    return pref.getString(SavedAddress) != null
        ? jsonDecode(pref.getString(SavedAddress))
        : null;
  }

  static void setSavedAddress(SharedPreferences pref, dynamic address) {
    var encodedAddress = jsonEncode(address);
    pref.setString(SavedAddress, encodedAddress);
  }

  static dynamic getSavedPaymentUrl(SharedPreferences pref) {
    return pref.getString(SavedPaymentUrl) != null
        ? jsonDecode(pref.getString(SavedPaymentUrl))
        : {};
  }

  static void setSavedPaymentUrl(SharedPreferences pref, dynamic paymentUrl) {
    var encodedPaymentUrl = jsonEncode(paymentUrl);
    pref.setString(SavedPaymentUrl, encodedPaymentUrl);
  }
}