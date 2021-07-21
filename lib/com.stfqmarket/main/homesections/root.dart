import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:qbsdonation/com.stfqmarket/main/homesections/allsections.dart';

class MainPageHomeRoot extends StatefulWidget {
  const MainPageHomeRoot({Key key, @required this.rootAction, @required this.changeRootPage}) : super(key: key);

  final void Function(int count) rootAction;
  final void Function(int page) changeRootPage;

  @override
  _MainPageHomeRootState createState() => _MainPageHomeRootState();
}

class _MainPageHomeRootState extends State<MainPageHomeRoot> {

  String searchQuery = '';

  void updateSearchQuery(String query) {
    setState(() {
      searchQuery = query;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          titleSpacing: 0.0,
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          title: MainPageSearchTextField(updateSearchQuery),
          toolbarHeight: kToolbarHeight + 32.0,
          floating: true,
          snap: true,
          automaticallyImplyLeading: false,
        ),
        SliverPadding(
          padding: EdgeInsets.only(bottom: 12.0),
          sliver: SliverList(
            delegate: SliverChildListDelegate.fixed([
              MainPageCategorySection(),
              ProductsGrid(rootAction: widget.rootAction, changeRootPage: widget.changeRootPage, searchQuery: searchQuery),
            ]),
          ),
        ),
      ],
    );
  }
}
