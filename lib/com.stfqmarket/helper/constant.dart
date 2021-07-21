
import 'package:flutter/material.dart';

class Constant {
  static OrderStatus orderStatus = const OrderStatus();

  static const ALPHABET = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz';
  static const MEDIA_URL_PREFIX = 'http://rest-netfarm.daf-q.id/media/';

  // AUTH STRING -> Base64(Midtrans Server Key + :)
  static const MIDTRANS_SERVER_KEY_AUTH_STRING = 'TWlkLXNlcnZlci1RZUFWM2hCN0pSaEFhVTRHT1RZX254Q046';
  static const RAJAONGKIR_API_KEY = 'ecfde67e573b6df12b030ae88c16b907';
  static const ANDROID_KEY = '';
}

class OrderStatus {
  const OrderStatus();
  String get pendingCheckout => 'Pending Checkout';
  String get pendingPayment => 'Pending Payment';
  String get onShipping => 'On Shipping';
  String get completed => 'Completed';
  String get failed => 'Failed';
  String get canceled => 'Canceled';
}