import 'package:flutter/material.dart';

import 'utils/user.dart';

class DrawerNavigatorObserver extends NavigatorObserver {
  @override
  void didPush(Route route, Route? previousRoute) {
    BoatmanDrawer.currentRoute = route.settings.name;
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    BoatmanDrawer.currentRoute = route.settings.name;
  }
}

class BoatmanDrawer extends StatelessWidget {
  static String? currentRoute;

  bool isSelected(String routeName) {
    return routeName == currentRoute;
  }

  @override
  Widget build(BuildContext context) {
    var widgets = <Widget>[
      if (User.current != null)
        UserAccountsDrawerHeader(
          accountName: Text(User.current?.name ?? "*Secretman*"),
          accountEmail: Text(User.current!.mailAddress),
          currentAccountPicture: CircleAvatar(
            backgroundColor: Theme.of(context).platform == TargetPlatform.iOS
                ? Colors.blue
                : Colors.white,
            child: Text(
              (User.current!.name ?? "*")[0],
              style: TextStyle(fontSize: 40.0),
            ),
          ),
        ),
      ListTile(
        leading: Icon(Icons.inbox),
        title: Text("Inbox"),
        onTap: () => Navigator.of(context).popAndPushNamed('/'),
        selected: isSelected('/'),
      ),
      ListTile(
        leading: Icon(Icons.send),
        title: Text("Sent"),
        onTap: () => Navigator.of(context).popAndPushNamed('/sent'),
        selected: isSelected('/sent'),
      ),
      ListTile(
        leading: Icon(Icons.drafts),
        title: Text("Drafts"),
        onTap: () => Navigator.of(context).popAndPushNamed('/drafts'),
        selected: isSelected('/drafts'),
      ),
      ListTile(
        leading: Icon(Icons.archive),
        title: Text("Archives"),
        onTap: () => Navigator.of(context).popAndPushNamed('/archives'),
        selected: isSelected('/archives'),
      ),
      ListTile(
        leading: Icon(Icons.report),
        title: Text("Spam"),
        onTap: () => Navigator.of(context).popAndPushNamed('/spam'),
        selected: isSelected('/spam'),
      ),
      Divider(
        height: 2,
      ),
      ListTile(
        leading: Icon(Icons.settings),
        title: Text("Settings"),
      )
    ];

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: widgets,
      ),
    );
  }
}
