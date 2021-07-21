import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:qbsdonation/com.stfqmarket/components/dotsindicator.dart';

typedef OnCurrentItemChangedCallback = void Function(int currentItem);

class Carousel extends StatefulWidget {
  final IndexedWidgetBuilder itemBuilder;
  final double viewportFraction, imageAspectRatio, imageHeight;
  final int itemsLength;
  final bool showDotsIndicator, heightAsSize;

  const Carousel({Key key,
    @required this.itemBuilder,
    this.imageAspectRatio=16.0/9.0,
    this.imageHeight=100.0, this.heightAsSize=false,
    this.itemsLength,
    this.viewportFraction=0.85,
    this.showDotsIndicator=false,
  });

  @override
  _CarouselState createState() => _CarouselState();
}

class _CarouselState extends State<Carousel> {
  PageController _controller;
  int _currentPage;

  PageView buildPageView() {
    return PageView.builder(
      onPageChanged: (value) {
        setState(() {
          _currentPage = value;
        });
      },
      itemCount: widget.itemsLength,
      controller: _controller,
      itemBuilder: (context, index) => AnimatedBuilder(
        animation: _controller,
        child: widget.itemBuilder(context, index),
        builder: (context, child) {
          return child;
        },
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _currentPage = 0;
    _controller = PageController(
      viewportFraction: widget.viewportFraction,
      initialPage: _currentPage,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(context) {
    return widget.showDotsIndicator
        ? Stack(
            fit: StackFit.expand,
            children: [
              widget.heightAsSize
                  ? Container(
                height: widget.imageHeight,
                child: buildPageView(),
              )
                  : AspectRatio(
                aspectRatio: widget.imageAspectRatio,
                child: buildPageView(),
              ),
              Positioned(
                bottom: 24.0, left: 0, right: 0,
                child: DotsIndicator(
                  controller: _controller,
                  itemCount: widget.itemsLength,
                  onPageSelected: (page) => _controller.animateToPage(page,
                      duration: Duration(milliseconds: 400), curve: Curves.easeOut),
                  activeColor: Theme.of(context).accentColor,
                  inactiveColor: Theme.of(context).accentColor.withOpacity(0.5),
                ),
              ),
            ],
          )
        : widget.heightAsSize
          ? Container(
              //height: widget.imageHeight,
              child: buildPageView(),
            )
          : AspectRatio(
              aspectRatio: widget.imageAspectRatio,
              child: buildPageView(),
            );
  }
}