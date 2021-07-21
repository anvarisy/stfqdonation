import 'package:flutter/material.dart';

class DotsIndicator extends AnimatedWidget {
  DotsIndicator({
    this.controller,
    this.itemCount,
    this.onPageSelected,
    this.inactiveColor=Colors.grey,
    this.activeColor=Colors.white,
  }) : super(listenable: controller);

  /// The PageController that this DotsIndicator is representing.
  final PageController controller;

  /// The number of items managed by the PageController
  final int itemCount;

  /// Called when a dot is tapped
  final ValueChanged<int> onPageSelected;

  /// The color of the inactive dots.
  ///
  /// Defaults to `Colors.grey`.
  final Color inactiveColor;

  /// The color of the active dot.
  ///
  /// Defaults to `Colors.white`.
  final Color activeColor;

  // The base size of the dots
  static const double _kDotSize = 9.0;

  // The distance between the center of each dot
  static const double _kDotSpacing = 20.0;

  Widget _buildDot(int index) {
    bool isSelected = (controller.page ?? controller.initialPage) == index;
    return new Container(
      width: _kDotSpacing,
      child: new Center(
        child: new Material(
          color: isSelected ? activeColor : inactiveColor,
          type: MaterialType.circle,
          child: new Container(
            width: _kDotSize,
            height: _kDotSize,
            child: new InkWell(
              onTap: () => onPageSelected(index),
            ),
          ),
        ),
      ),
    );
  }

  Widget build(BuildContext context) {
    return new Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: new List<Widget>.generate(itemCount, _buildDot),
    );
  }
}