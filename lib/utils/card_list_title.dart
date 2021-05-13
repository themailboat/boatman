import 'package:flutter/material.dart';

class CardListTitle extends StatelessWidget {
  final String text;
  CardListTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(children: [
        Text(
          text,
          style: TextStyle(color: Theme.of(context).hintColor),
        )
      ]),
      padding: EdgeInsets.only(left: 16, top: 8, bottom: 8),
    );
  }
}
