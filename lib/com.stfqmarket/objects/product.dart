import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:qbsdonation/com.stfqmarket/objects/category.dart';

class Product {
  String id, tenantId, image, name, desc, date;
  num price, weight;
  List<String> imageCollections;
  List<Category> categories;

  int count = 0;

  Product.none();
  Product(this.id, this.tenantId, this.image, this.name, this.desc, this.date, this.price, this.weight, this.imageCollections, this.categories);

  String get formattedPrice => NumberFormat.currency(locale: "id-ID").format(price);

  static Product toProduct(DocumentSnapshot item) {
    return Product(
        item.documentID, item.data['tenant_id'],
        item.data['product_image'], item.data['product_name'], item.data['product_detail'], item.data['product_date'], num.tryParse(item.data['product_price']) ?? 0, num.tryParse(item.data['product_weight']) ?? 0,
        item.data['image_collections'].map<String>((i) => i.toString()).toList(),
        item.data['categories'].map<Category>((c) => Category(c['category_id'], c['category_name'])).toList()
    );
  }

  static List<Product> toList(List<DocumentSnapshot> items) {
    return items.map<Product>((e) => toProduct(e)).toList();
  }
}