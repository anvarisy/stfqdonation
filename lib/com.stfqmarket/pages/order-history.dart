
import 'package:flutter/material.dart';
import 'package:qbsdonation/com.stfqmarket/components/expansiontile.dart';
import 'package:qbsdonation/com.stfqmarket/helper/constant.dart';
import 'package:qbsdonation/com.stfqmarket/objects/cart.dart';
import 'package:qbsdonation/com.stfqmarket/pages/track-package.dart';

class OrderHistory extends StatefulWidget {
  final List<Cart> carts;

  OrderHistory(this.carts);

  @override
  _OrderHistoryState createState() => _OrderHistoryState();
}

class _OrderHistoryState extends State<OrderHistory> {
  Color _getStatusColor(String status) {
    if (status == Constant.orderStatus.onShipping) {
      return Colors.blue;
    } else if (status == Constant.orderStatus.completed) {
      return Colors.green;
    } else if (status == Constant.orderStatus.failed) {
      return Colors.red;
    } else if (status == Constant.orderStatus.canceled) {
      return Colors.yellow[600];
    }
    return Colors.black;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(8.0),
      children: [
        for (var cart in widget.carts)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        cart.dateUpdate,
                        style:
                            TextStyle(color: Colors.blueGrey, fontSize: 12.0),
                      ),
                      Text(
                        cart.status,
                        style: TextStyle(
                            color: _getStatusColor(cart.status),
                            fontSize: 12.0,
                            fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 8.0,
                  ),
                  Text(
                    cart.tenantName,
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: 4.0,
                  ),
                  Text(
                    cart.formattedTotal,
                    style: TextStyle(
                      color: Theme.of(context).accentColor,
                    ),
                  ),
                  SizedBox(
                    height: 8.0,
                  ),
                  CustomExpansionTile(
                    title: Text(
                      'Barang Belanjaan',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16.0,
                      ),
                    ),
                    expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (var detail in cart.details)
                        Container(
                          height: 91.0,
                          child: Column(
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    AspectRatio(
                                      aspectRatio: 1,
                                      child: Image.network(
                                        detail.productImage.contains('http')
                                            ? detail.productImage
                                            : '${Constant.MEDIA_URL_PREFIX}${detail.productImage}',
                                      ),
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8.0),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          mainAxisSize: MainAxisSize.max,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '${detail.productName}',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              'Jumlah: ${detail.countProduct}',
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.w300,
                                              ),
                                            ),
                                            Text(
                                              '${detail.formattedTotal}',
                                              style: TextStyle(
                                                color: Theme.of(context)
                                                    .accentColor,
                                                fontWeight: FontWeight.w300,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Divider(
                                height: 1.0,
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  if (cart.resiOrder != null) Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => TrackPackagePage(resi: cart.resiOrder, kurir: 'jne',))
                        );
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Icon(Icons.my_location, color: Colors.blue,),
                          SizedBox(width: 8.0,),
                          Text('Lacak Paket', style: TextStyle(color: Colors.blue),),
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
}
