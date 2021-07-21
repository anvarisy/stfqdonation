
import 'package:flutter/material.dart';

class FullscreenWidget extends StatelessWidget {

  final Widget fullscreenWidget;
  final bool withInteractiveViewer;

  const FullscreenWidget(this.fullscreenWidget, {Key key, this.withInteractiveViewer=true}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          color: Colors.black,
          alignment: Alignment.center,
          child: withInteractiveViewer
              ? InteractiveViewer(
            child: fullscreenWidget,)
              : fullscreenWidget
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: AppBar(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            toolbarHeight: kToolbarHeight,
          ),
        ),
      ],
    );
  }
}
