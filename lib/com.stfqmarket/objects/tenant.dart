
import 'package:cloud_firestore/cloud_firestore.dart';

class Tenant {
  final String id, cityCode, image, name, owner, address, star, review, distance;

  Tenant(this.id, this.cityCode, this.image, this.name, this.owner, this.address, this.star, this.review, this.distance);

  static Tenant toTenant(DocumentSnapshot item) {
    return Tenant(item.documentID, item.data['tenant_city_code'], item.data['tenant_image'],
        item.data['tenant_name'], item.data['tenant_owner'], item.data['tenant_address'], '', '', '');
  }

  static List<Tenant> toList(List<DocumentSnapshot> items) {
    return items.map((e) => toTenant(e)).toList();
  }
}