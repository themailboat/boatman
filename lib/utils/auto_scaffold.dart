import 'package:flutter/material.dart';

class AutoScaffold extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget? drawer;
  final Widget? body;
  final Widget? floatingActionButton;

  const AutoScaffold(
      {Key? key,
      this.appBar,
      this.drawer,
      this.body,
      this.floatingActionButton})
      : super(key: key);

  int chooseBodyPanelFlex(double width) {
    if (width <= 720) {
      return 2;
    } else if (width <= 960) {
      return 2;
    } else if (width <= 1280) {
      return 3;
    } else {
      return 5;
    }
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    if (media.width >= 600) {
      return Row(
        children: [
          if (drawer != null) Flexible(child: drawer!),
          Flexible(
              flex: 0,
              child: const VerticalDivider(
                width: 0.1,
              )),
          Expanded(
            flex: chooseBodyPanelFlex(media.width),
            child: Scaffold(
              appBar: appBar,
              body: body,
              floatingActionButton: floatingActionButton,
            ),
          )
        ],
      );
    } else {
      return Scaffold(
        drawer: drawer,
        appBar: appBar,
        body: body,
        floatingActionButton: floatingActionButton,
      );
    }
  }
}
