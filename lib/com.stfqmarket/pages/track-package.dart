import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:qbsdonation/com.stfqmarket/helper/constant.dart';

class TrackPackagePage extends StatefulWidget {
  final String resi;
  final String kurir;

  TrackPackagePage({@required this.resi, @required this.kurir});

  @override
  _TrackPackagePageState createState() => _TrackPackagePageState();
}

class _TrackPackagePageState extends State<TrackPackagePage> {

  Future getOfflinePackageWaybill() async {
    return {
      "rajaongkir":{
        "query":{
          "waybill":"SOCAG00183235715",
          "courier":"jne"
        },
        "status":{
          "code":200,
          "description":"OK"
        },
        "result":{
          "delivered":true,
          "summary":{
            "courier_code":"jne",
            "courier_name":"Jalur Nugraha Ekakurir (JNE)",
            "waybill_number":"SOCAG00183235715",
            "service_code":"OKE",
            "waybill_date":"2015-03-03",
            "shipper_name":"IRMA F",
            "receiver_name":"RISKA VIVI",
            "origin":"WONOGIRI,KAB.WONOGIRI",
            "destination":"PALEMBANG",
            "status":"DELIVERED"
          },
          "details":{
            "waybill_number":"SOCAG00183235715",
            "waybill_date":"2015-03-03",
            "waybill_time":"13:23",
            "weight":"1",
            "origin":"WONOGIRI,KAB.WONOGIRI",
            "destination":"PALEMBANG",
            "shippper_name":"IRMA F",
            "shipper_address1":"WONOGIRI",
            "shipper_address2":null,
            "shipper_address3":null,
            "shipper_city":"WONOGIRI",
            "receiver_name":"RISKA VIVI",
            "receiver_address1":"PERUMAHAN BUKIT SEJAHTERA",
            "receiver_address2":"AF 05 RT 074\/022",
            "receiver_address3":"PALEMBANG",
            "receiver_city":"PALEMBANG"
          },
          "delivery_status":{
            "status":"DELIVERED",
            "pod_receiver":"RISKA",
            "pod_date":"2015-03-05",
            "pod_time":"13:22"
          },
          "manifest":[
            {
              "manifest_code":"1",
              "manifest_description":"Manifested",
              "manifest_date":"2015-03-04",
              "manifest_time":"03:41",
              "city_name":"SOLO"
            },
            {
              "manifest_code":"2",
              "manifest_description":"On Transit",
              "manifest_date":"2015-03-04",
              "manifest_time":"15:44",
              "city_name":"JAKARTA"
            },
            {
              "manifest_code":"3",
              "manifest_description":"Received On Destination",
              "manifest_date":"2015-03-05",
              "manifest_time":"08:57",
              "city_name":"PALEMBANG"
            }
          ]
        }
      }
    };
  }

  Future<dynamic> getPackageWaybill() async {
    var response = await http.post(
      'https://pro.rajaongkir.com/api/waybill',
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'key': Constant.RAJAONGKIR_API_KEY,
        //'android-key': Constant.ANDROID_KEY,
      },
      body: jsonEncode({
        'waybill': widget.resi,
        'courier': widget.kurir,
      }),
    );

    // if success
    if ([200, 201].contains(response.statusCode)) {
      return jsonDecode(response.body);
    }
    else return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lacak Paket'),
      ),
      body: FutureBuilder(
        future: getPackageWaybill(),
        builder: (_, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data == false) return Center(child: Text('Paket tidak ditemukan.'),);

            var result = snapshot.data['rajaongkir']['result'];
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: EdgeInsets.all(8.0),
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      //Text('delivered: ${result['delivered']}', textAlign: TextAlign.center,),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Text('${result['delivery_status']['status']}', textAlign: TextAlign.center,
                          style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 18.0, fontWeight: FontWeight.w600),),
                      ),
                      SizedBox(height: 8.0,),
                      Text('Waktu dan Tanggal: ${result['delivery_status']['pod_time']} ${result['delivery_status']['pod_date']}',),
                      Text('Penerima: ${result['delivery_status']['pod_receiver']}'),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: ListView(
                      children: [
                        Text('Manifest', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22.0),),
                        for (var manifest in result['manifest']) Card(
                          margin: EdgeInsets.symmetric(vertical: 6),
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Kode: ${manifest['manifest_code']}'),
                                    Text('${manifest['manifest_time']} ${manifest['manifest_date']}'),
                                  ],
                                ),
                                Text('${manifest['city_name']}'),
                                Text('${manifest['manifest_description']}'),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }
          if (snapshot.hasError) {
            return Center(child: Text('Terjadi masalah.'),);
          }
          return Center(child: CircularProgressIndicator(),);
        },
      ),
    );
  }
}
