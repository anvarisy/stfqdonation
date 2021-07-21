import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:qbsdonation/com.stfqmarket/components/bottomnavbar.dart';
import 'package:qbsdonation/com.stfqmarket/main/homesections/root.dart';
import 'package:qbsdonation/com.stfqmarket/main/ordersections/root.dart';
import 'package:qbsdonation/com.stfqmarket/pages/product-detail.dart';
import 'package:qbsdonation/models/dafq.dart';

class STFQMarketMainPage extends StatefulWidget {
  static String routeName = '/market/main';

  final user_profil profil;
  STFQMarketMainPage(this.profil);

  @override
  _STFQMarketMainPageState createState() => _STFQMarketMainPageState();
}

class _STFQMarketMainPageState extends State<STFQMarketMainPage> {
  final GlobalKey<DefaultBottomNavigationBarState> _bottomNavKey = GlobalKey();

  final _pageController = PageController();
  final _pDuration = const Duration(milliseconds: 400);
  final _pCurve = Curves.ease;

  _changeRootPage(int page) {
    _bottomNavKey.currentState.changePage(page);
    _changePage(page);
  }

  _changePage(int index) {
    final int page = index ?? 0;
    _pageController.animateToPage(
      page,
      duration: _pDuration,
      curve: _pCurve,
    );
  }

  _updateProductCount(int count) => _bottomNavKey.currentState.updateProductCount(count);

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(context) {
    return SafeArea(
      child: Scaffold(
        bottomNavigationBar: DefaultBottomNavigationBar(key: _bottomNavKey, changePage: _changePage,),
        body: PageView(
          physics: NeverScrollableScrollPhysics(),
          controller: _pageController,
          children: [
            // HOME
            MainPageHomeRoot(rootAction: _updateProductCount, changeRootPage: _changeRootPage,),
            // ORDER
            MainPageOrderRoot(rootAction: _updateProductCount, changeRootPage: _changeRootPage, profile: widget.profil),
          ],
        ),
      ),
    );
  }
}