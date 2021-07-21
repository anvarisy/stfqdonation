
class HalalDetail {
  final int id, productId;
  final String halalInstitution, halalNumber, dateAccepted, dateExpired;

  HalalDetail(this.id, this.productId, this.halalInstitution, this.halalNumber, this.dateAccepted, this.dateExpired);

  static List<HalalDetail> toList(List<dynamic> json) {
    return json.map((e) => HalalDetail(
        e['id'], e['product_id'], e['halal'], e['no_halal'],
        e['date_accepted'], e['date_expired'])).toList();
  }
}