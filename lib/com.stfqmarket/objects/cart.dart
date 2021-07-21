import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class Cart {
  String docId, orderId, dateUpdate;
  final String tenantId, tenantName, status, tenantCityCode, resiOrder;
  final CartUser user;
  final List<CartDetail> details;

  num get total {
    num total = 0;
    for (var detail in details) {
      total += (detail.productPrice);
    }
    return total;
  }

  String get formattedTotal => NumberFormat.currency(locale: "id-ID").format(total);

  num get multipliedTotal {
    num total = 0;
    for (var detail in details) {
      total += (detail.productPrice*detail.countProduct);
    }
    return total;
  }

  String get formattedMultipliedTotal => NumberFormat.currency(locale: "id-ID").format(multipliedTotal);

  Cart(this.docId, this.orderId, this.tenantName, this.dateUpdate, this.status, this.tenantId, this.tenantCityCode, this.resiOrder, this.user, this.details);

  @override
  int get hashCode => orderId.hashCode;

  /// NOTE: This object is equal if their orderId is equal
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    return other is Cart
        && other.orderId == orderId;
  }

  static Cart toCart(DocumentSnapshot e) {
    var user = e.data['user'];

    return Cart(
        e.documentID, e.data['order_id'],
        e.data['tenant_name'], e.data['date_update'], e.data['status'], e.data['tenant_id'], e.data['tenant_city_code'].toString(),
        e.data['resi_order'] ?? null,
        CartUser(user['uid'], user['fullname'], user['email']),
        e.data['details'].map<CartDetail>((c) => CartDetail(
          c['product_name'], c['date_update'], c['product_image'],
          c['product_id'], c['total'], c['count_product'], c['product_weight']
        )).toList()
    );
  }

  static List<Cart> toList(List<DocumentSnapshot> items) {
    List<Cart> carts = List();
    for (var item in items) {
      Cart cart = toCart(item);
      carts.add(cart);
    }
    return carts;
  }
}

class CartUser {
  final String uid, name, email;

  CartUser(this.uid, this.name, this.email);
}

class CartDetail {
  final String productId, productName, dateUpdate, productImage;
  final num productPrice, productWeight;

  int countProduct;

  num get total => (productPrice);

  String get formattedTotal => NumberFormat.currency(locale: "id-ID").format(total);

  num get multipliedTotal => (productPrice*countProduct);

  String get formattedMultipliedTotal => NumberFormat.currency(locale: "id-ID").format(multipliedTotal);

  CartDetail(this.productName, this.dateUpdate, this.productImage, this.productId, this.productPrice, this.countProduct, this.productWeight);

  @override
  int get hashCode => productId.hashCode;

  /// NOTE: This object is equal if their productId is equal
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    return other is CartDetail
        && other.productId == productId;
  }
}