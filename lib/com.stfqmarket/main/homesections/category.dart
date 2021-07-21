import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:qbsdonation/com.stfqmarket/objects/category.dart';

class MainPageCategorySection extends StatefulWidget {
  @override
  _MainPageCategorySectionState createState() => _MainPageCategorySectionState();
}

class _MainPageCategorySectionState extends State<MainPageCategorySection> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Semua Kategori',
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w300,),),
            ],
          ),
        ),
        Container(
          height: 120.0,
          padding: EdgeInsets.symmetric(horizontal: 4.0),
          child: FutureBuilder<QuerySnapshot>(
            future: Firestore.instance.collection('stfq-market').document('Categories').collection('items').getDocuments(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                var data = Category.toList(snapshot.data.documents);

                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: data.length,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (_, i) {
                    return Container(
                      width: 80.0,
                      padding: EdgeInsets.symmetric(horizontal: 2.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Card(
                            clipBehavior: Clip.hardEdge,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6.0),
                            ),
                            color: Theme.of(context).cardColor,
                            child: AspectRatio(
                              child: Image.network(
                                  data[i].image, fit: BoxFit.cover),
                              aspectRatio: 1,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              data[i].name,
                              textAlign: TextAlign.center,
                              softWrap: true,
                              style: TextStyle(
                                fontWeight: FontWeight.w300, fontSize: 13.0,),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              }
              else if (snapshot.hasError)
                return Center(
                  child: Text('Check your internet'),
                );
              return Center(
                child: CircularProgressIndicator(),
              );
            }
          ),
        ),
      ],
    );
  }
}
