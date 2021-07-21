import 'package:flutter/material.dart';
import 'package:qbsdonation/com.stfqmarket/helper/http-bookmark.dart';
import 'package:qbsdonation/com.stfqmarket/helper/saveddata.dart';
import 'package:qbsdonation/com.stfqmarket/helper/sessionmanager.dart';
import 'package:qbsdonation/com.stfqmarket/pages/product-detail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:qbsdonation/com.stfqmarket/objects/product.dart';

class ProductItemView extends StatefulWidget {
  final Product product;
  final FontWeight titleFontWeight;
  final double aspectRatio, buttonSize;
  final bool buttonShrink, buttonAttachedToBottom;
  final void Function(int count) newProductCountAction;
  final void Function(int page) changeRootPage;

  ProductItemView({Key key, @required this.product,
    @required this.newProductCountAction, @required this.changeRootPage,
    this.aspectRatio=9.0/16.0,
    this.buttonSize=30.0,
    this.titleFontWeight=FontWeight.bold,
    this.buttonShrink=false,
    this.buttonAttachedToBottom=false,
  }) : super(key: key);

  @override
  _ProductItemViewState createState() => _ProductItemViewState();
}

class _ProductItemViewState extends State<ProductItemView> {
  final Duration _duration = Duration(milliseconds: 300);

  int _count = 0;
  bool _isBookmark = false;

  _loadCount() async {
    int productCount = await SavedData.getProductCount(widget.product.id);
    setState(() {
      _count = productCount;
    });
  }

  _loadBookmark() async {
    final pref = await SharedPreferences.getInstance();
    final isBookmark = pref.getBool(SavedData.BookmarkedProductList + '-${widget.product.id}') ?? false;

    if (isBookmark) setState(() => _isBookmark = true);
  }

  _incrementCount() async {
    setState(() {
      _count++;
    });
    widget.product.count = _count;
    int productsCountInCart = await SavedData.putProductToCart(widget.product);
    if (widget.newProductCountAction != null)
      widget.newProductCountAction(productsCountInCart);
  }

  _decrementCount(id, tenantId) async {
    setState(() {
      _count--;
    });
    widget.product.count = _count;
    int productsCountInCart = await SavedData.putProductToCart(widget.product);
    if (widget.newProductCountAction != null)
      widget.newProductCountAction(productsCountInCart);
  }

  @override
  void initState() {
    setState(() {
      _count = widget.product.count;
    });
    _loadCount();
    _loadBookmark();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final Product data = widget.product;
    bool isCount = _count > 0;

    return GestureDetector(
      onTap: () async {
        data.count = _count;
        final resultPage = await Navigator.push(
          context, MaterialPageRoute(builder: (_) => STFQMarketProductPage(product: data)),
        ) as Map<String, int>;
        setState(() => _count = resultPage['thisProductCount']);
        widget.newProductCountAction(resultPage['productsCount']);
        widget.changeRootPage(resultPage['page']);
      },
      child: AspectRatio(
        aspectRatio: widget.aspectRatio,
        child: Card(
          clipBehavior: Clip.hardEdge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6.0),
          ),
          color: Theme.of(context).cardColor,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Stack(
                children: [
                  AspectRatio(
                    aspectRatio: 1,
                    child: Hero(
                      tag: 'hero-product-image-${data.id}',
                      child: Image.network(
                        data.image,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  /*Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      icon: Icon(
                        _isBookmark
                            ? Icons.bookmark
                            : Icons.bookmark_border,
                        color: Colors.white,
                      ),
                      onPressed: () async {
                        if (await SessionManager.loginState) {
                          final sessionData = await SessionManager.sessionData;

                          if (_isBookmark) {
                            final isSuccess = await Bookmark.delBookmark(sessionData.email, data.id);
                            if (isSuccess) {
                              setState(() => _isBookmark = false);
                            }
                            setState(() => _isBookmark = false);
                          }
                          else {
                            final isSuccess = await Bookmark.addBookmark(sessionData.email, data.id);
                            if (isSuccess) {
                              setState(() => _isBookmark = true);
                            }
                            else Scaffold.of(context)
                                .showSnackBar(SnackBar(content: Text('Gagal memfavoritkan produk. Cek internet anda.')));
                          }
                        }
                        else {
                          Scaffold.of(context)
                              .showSnackBar(SnackBar(content: Text('Tidak bisa memfavoritkan produk sebelum login.')));
                        }
                      },
                    ),
                  ),*/
                ],
              ),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0),
                      child: Text(
                        data.name,
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          fontWeight: widget.titleFontWeight,),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                      child: FittedBox(
                        child: Text(
                          data.formattedPrice,
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            color: Colors.deepOrange,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: widget.buttonAttachedToBottom
                          ? EdgeInsets.zero
                          : EdgeInsets.only(bottom: 8.0, left: 8.0, right: 8.0),
                      child: widget.buttonAttachedToBottom
                          ? Container(
                            padding: isCount ? EdgeInsets.only(bottom: 4.0, left: 4.0, right: 4.0) : EdgeInsets.zero,
                            child: _buildButton(data, isCount, context)
                          )
                          : _buildButton(data, isCount, context),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Stack _buildButton(Product data, bool isCount, BuildContext context) {
    return Stack(
      children: [
        Align(
          alignment: Alignment.topLeft,
          child: Container(
            height: widget.buttonShrink
                ? isCount
                  ? widget.buttonSize - 8.0
                  : widget.buttonSize
                : widget.buttonSize,
            child: Row(
              children: [
                Container(
                  width: widget.buttonSize,
                  child: OutlineButton(
                    shape: widget.buttonAttachedToBottom
                        ? isCount
                          ? null
                          : RoundedRectangleBorder()
                        : null,
                    child: Icon(Icons.remove, size: 18, color: Colors.black,),
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      if (_count != 0)
                        _decrementCount(data.id, data.tenantId);
                    }
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 4.0),
                    child: OutlineButton(
                      shape: widget.buttonAttachedToBottom
                          ? isCount
                            ? null
                            : RoundedRectangleBorder()
                          : null,
                      padding: EdgeInsets.zero,
                      child: Text('$_count', softWrap: false,),
                      onPressed: () {},
                    ),
                  ),
                ),
                Container(width: widget.buttonSize,),
              ],
            ),
          ),
        ),
        Align(
          alignment: Alignment.topRight,
          child: AnimatedContainer(
            curve: Curves.easeOut,
            duration: _duration,
            width: isCount ? widget.buttonSize : 200.0,
            height: widget.buttonShrink
                ? isCount
                ? widget.buttonSize - 8.0
                    : widget.buttonSize
                    : widget.buttonSize,
            child: RaisedButton(
              shape: widget.buttonAttachedToBottom
                  ? isCount
                    ? null
                    : RoundedRectangleBorder()
                  : null,
              elevation: 0,
              padding: EdgeInsets.zero,
              color: Theme.of(context).primaryColor,
              onPressed: () => _incrementCount(),
              child: Container(
                width: 90.0,
                height: widget.buttonShrink
                    ? isCount
                      ? widget.buttonSize - 8.0
                      : widget.buttonSize
                    : widget.buttonSize,
                alignment: Alignment.center,
                child: ListView(
                  physics: NeverScrollableScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  children: [
                    Container(
                        width: widget.buttonSize,
                        height: widget.buttonShrink
                            ? isCount
                              ? widget.buttonSize - 8.0
                              : widget.buttonSize
                            : widget.buttonSize,
                        child: Icon(isCount ? Icons.add : Icons.shopping_cart, size: 18, color: Colors.white,)
                    ),
                    Container(
                      height: widget.buttonShrink
                          ? isCount
                            ? widget.buttonSize - 8.0
                            : widget.buttonSize
                          : widget.buttonSize,
                      alignment: Alignment.center,
                      child: Text(' Tambah',
                        softWrap: false,
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}