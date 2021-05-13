import 'package:boatman_flutter/drawer.dart';
import 'package:boatman_flutter/utils/auto_scaffold.dart';
import 'package:boatman_flutter/utils/card_list_title.dart';
import 'package:flutter/material.dart' hide ExpansionPanel, ExpansionPanelList;
import 'package:mailer/mailer.dart';

import '../utils/expansion_panel.dart' show ExpansionPanel, ExpansionPanelList;

class MailBody extends StatelessWidget {
  final Message message;
  final bool showSubject;

  MailBody({Key? key, required this.message, this.showSubject: false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var query = MediaQuery.of(context);
    return Column(
      children: [
        Container(
          child: Row(
            children: [
              CircleAvatar(
                backgroundImage: null,
              ),
              Padding(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (showSubject)
                        Text(
                          message.subject ?? "No subject",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      Text.rich(TextSpan(
                          text: message.fromAsAddress.name != null
                              ? message.fromAsAddress.name!
                              : message.fromAsAddress.mailAddress,
                          children: [
                            if (message.fromAsAddress.name != null)
                              TextSpan(
                                  text:
                                      "(${message.fromAsAddress.mailAddress})",
                                  style: TextStyle(
                                      color: Theme.of(context).hintColor)),
                            TextSpan(
                                text: " sent to ",
                                style: TextStyle(
                                    color: Theme.of(context).hintColor)),
                            TextSpan(
                              text: "me",
                            )
                          ]))
                    ]),
                padding: EdgeInsets.only(left: 16),
              )
            ],
          ),
          padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        ),
        if (query.size.width < 600) SizedBox(height: 16),
        Container(
          alignment: Alignment.topLeft,
          padding: EdgeInsets.only(
              left: query.size.width >= 600 ? 72 : 16, right: 16),
          child: message.text != null ? Text(message.text!) : Text("No body"),
        ),
        SizedBox(
          height: 48,
        )
      ],
    );
  }
}

class MailReplyPan extends StatelessWidget {
  final Address? defaultReplyAddress;
  MailReplyPan({Key? key, this.defaultReplyAddress}) : super(key: key);

  String getReplyTooltip() {
    if (this.defaultReplyAddress != null) {
      if (this.defaultReplyAddress!.name != null) {
        return "Reply to \"${this.defaultReplyAddress!.name}\"...";
      } else {
        return "Reply to \"${this.defaultReplyAddress!.mailAddress}\"...";
      }
    } else {
      return "Reply to...";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Row(
        children: [
          Padding(
            child: Icon(Icons.reply, color: Theme.of(context).hintColor),
            padding: EdgeInsets.only(right: 16),
          ),
          Text(
            getReplyTooltip(),
            style: TextStyle(color: Theme.of(context).hintColor),
          )
        ],
      ),
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
    );
  }
}

class MailExpansionPanelBuilder {
  final Message message;
  final MailListState parent;
  bool isExpanded = false;

  MailExpansionPanelBuilder({required this.message, required this.parent});

  Widget getTitle(BuildContext context) {
    return Text(
      message.subject != null ? message.subject! : "No title",
    );
  }

  Widget getSubtitle(BuildContext context) {
    var mediaQuery = MediaQuery.of(context);
    var spans = <InlineSpan>[];
    spans.add(TextSpan(
      text: this.message.fromAsAddress.name ??
          this.message.fromAsAddress.mailAddress,
      style: Theme.of(context).textTheme.bodyText1,
    ));
    if (this.message.text != null) {
      if (mediaQuery.size.width >= 600)
        spans.add(TextSpan(text: ' - '));
      else
        spans.add(TextSpan(text: "\n"));
      spans.add(TextSpan(
          text: this.message.text!.length > 68
              ? this.message.text!.substring(0, 68) + '...'
              : this.message.text));
    }
    return Text.rich(TextSpan(children: spans));
  }

  Widget _buildHeader(BuildContext context, bool isExpanded) {
    if (isExpanded) {
      return Row(
        children: [
          Expanded(
              child: ListTile(
            leading: IconButton(
                icon: Icon(Icons.close),
                onPressed: () => parent.closePanel(this)),
            title: getTitle(context),
            minVerticalPadding: 0,
          )),
          IconButton(
            icon: Icon(Icons.done),
            onPressed: null,
          ),
          IconButton(onPressed: null, icon: Icon(Icons.delete)),
          IconButton(onPressed: null, icon: Icon(Icons.more_vert)),
        ],
      );
    } else {
      var mediaQuery = MediaQuery.of(context);
      return ListTile(
        title: getTitle(context),
        subtitle: getSubtitle(context),
        isThreeLine: mediaQuery.size.width < 600,
      );
    }
  }

  Widget _buildBody(BuildContext context) {
    return Column(
      children: [
        Divider(
          height: 2,
        ),
        MailBody(
          message: message,
          showSubject: false,
        ),
        Divider(
          height: 2,
        ),
        MailReplyPan(
          defaultReplyAddress: message.fromAsAddress,
        ),
      ],
    );
  }

  ExpansionPanel build(BuildContext context) {
    return ExpansionPanel(
      headerBuilder: this._buildHeader,
      body: this._buildBody(context),
      canTapOnHeader: !isExpanded,
      isExpanded: isExpanded,
    );
  }
}

class MailList extends StatefulWidget {
  final List<Message> messages;
  MailList({Key? key, required this.messages}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return MailListState(this.messages);
  }
}

class MailListState extends State<MailList> {
  final List<Message> messages;
  late List<MailExpansionPanelBuilder> builders;

  MailListState(this.messages) {
    _completeUpdate();
  }

  void _completeUpdate() {
    this.builders = messages
        .map((e) => MailExpansionPanelBuilder(message: e, parent: this))
        .toList();
  }

  void closePanel(MailExpansionPanelBuilder builder) {
    var index = this.builders.indexOf(builder);
    if (index == -1) {
      return;
    }
    setState(() {
      builder.isExpanded = !builder.isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ExpansionPanelList(
      children: builders.map((e) => e.build(context)).toList(),
      expansionCallback: (panelIndex, isExpanded) => this.setState(() {
        this.builders[panelIndex].isExpanded = !isExpanded;
      }),
      autoTrailingButton: false,
      expandedHeaderPadding: EdgeInsets.symmetric(vertical: 4),
    );
  }
}

class InboxPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var sampleMessage = Message();
    sampleMessage
      ..from = Address("support@mailboat.xyz", "Mailboat")
      ..recipients.add(Address("jack.cooper@foo.bar", "Jack Cooper"))
      ..subject = "Welcome to mailboat!"
      ..text = "Mailboat is a email software for everyone." * 10;
    var sampleMessage2 = Message();
    sampleMessage2
      ..from = Address("support@mailboat.xyz")
      ..recipients.add(Address("jack.cooper@foo.bar", "Jack Cooper"))
      ..subject = "Welcome to mailboat!"
      ..text = "Mailboat is a email software for everyone." * 10;
    return AutoScaffold(
      appBar: AppBar(
        title: Text("Inbox"),
        actions: [
          IconButton(
            onPressed: null,
            icon: Icon(Icons.search),
            tooltip: "Search",
          ),
          IconButton(
            onPressed: null,
            icon: Icon(Icons.filter_list),
            tooltip: "Filter",
          ),
        ],
      ),
      drawer: BoatmanDrawer(),
      body: Scrollbar(
          child: SingleChildScrollView(
              child: Column(
        children: [
          Row(children: [
            Expanded(child: CardListTitle("Today")),
            Container(
              child: IconButton(
                icon: Icon(Icons.done_all),
                onPressed: null,
              ),
              alignment: Alignment.centerRight,
            )
          ]),
          MailList(
            messages: [sampleMessage, sampleMessage2],
          ),
          SizedBox(
            height: 96,
          ),
        ],
      ))),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.edit),
        onPressed: null,
      ),
    );
  }
}
