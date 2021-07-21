
import 'package:cloud_firestore/cloud_firestore.dart';

class Category {
  final String id, image, name;

  Category(this.id, this.name, {this.image});

  static List<Category> toList(List<DocumentSnapshot> items) {
    return items.map<Category>((e) => Category(e.documentID, e.data['category_name'],
        image: e.data['category_image'])).toList();
  }
}