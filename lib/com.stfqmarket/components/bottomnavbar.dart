import 'package:flutter/material.dart';
import 'package:qbsdonation/com.stfqmarket/helper/saveddata.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DefaultBottomNavigationBar extends StatefulWidget {
  final void Function(int index) changePage;
  final bool noneSelected;

  const DefaultBottomNavigationBar({Key key, @required this.changePage, this.noneSelected=false}) : super(key: key);

  @override
  DefaultBottomNavigationBarState createState() => DefaultBottomNavigationBarState();
}

class DefaultBottomNavigationBarState extends State<DefaultBottomNavigationBar> {
  int _productCount = 0;
  int _bottomNavCurrentIndex = 0;

  changePage(int page) {
    setState(() => _bottomNavCurrentIndex = page);
    widget.changePage(page);
  }

  updateProductCount(int count) {
    setState(() => _productCount = count);
  }

  _loadProductCount() async {
    final pref = await SharedPreferences.getInstance();
    updateProductCount(SavedData.getSavedCarts(pref).length ?? 0);
  }

  @override
  void initState() {
    _loadProductCount();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      showUnselectedLabels: true,
      currentIndex: _bottomNavCurrentIndex,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: widget.noneSelected ? Colors.grey.withOpacity(0.38) : Colors.deepOrange,
      unselectedItemColor: Colors.grey.withOpacity(0.38),
      backgroundColor: Colors.white,
      elevation: 8.0,
      onTap: changePage,
      items: [
        BottomNavigationBarItem(
          icon: const Icon(Icons.home),
          label: 'Beranda',
        ),
        BottomNavigationBarItem(
          icon: Stack(
            children: [
              Icon(Icons.shopping_cart),
              Positioned(
                top: 0.0,
                right: 0.0,
                child: _productCount == 0
                    ? Container(
                  padding: EdgeInsets.all(1.0),
                  constraints: BoxConstraints(
                      minWidth: 12.0,
                      minHeight: 12.0
                  ),
                )
                    : Container(
                  padding: EdgeInsets.all(1.0),
                  constraints: BoxConstraints(
                      minWidth: 12.0,
                      minHeight: 12.0
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(6.0),
                  ),
                  child: Center(
                    child: Text(
                      '$_productCount',
                      style: TextStyle(
                        fontSize: 8.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          label: 'Keranjang',
        ),
      ],
    );
  }
}
