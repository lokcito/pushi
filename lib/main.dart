import 'package:flutter/material.dart';
import 'package:pushi/settings.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';
import "./entities/shared.dart";
import 'dart:async';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pushi',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final PusherChannelsFlutter pusher = PusherChannelsFlutter.getInstance();
  final Shared _shared = Shared("", false);

  MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  SettingsPage? settings;

  @override
  void initState() {
    super.initState();
  }

  final _listViewController = ScrollController();
  String _log = "";

  void log(String text) {
    print("LOG: $text");
    setState(() {
      _log += "$text\n";
      Timer(
          const Duration(milliseconds: 100),
          () => _listViewController
              .jumpTo(_listViewController.position.maxScrollExtent));
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> drawerItemWidgets = [
      const DrawerHeader(
        decoration: BoxDecoration(
          color: Colors.deepPurple,
        ),
        child: Center(
            child: Text(
          'Pushi event listener',
          style: TextStyle(color: Colors.white, fontSize: 24.0),
        )),
      ),
    ];
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pushi"),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: drawerItemWidgets,
        ),
      ),
      body: Padding(
          padding: const EdgeInsets.only(
              top: 8.0, left: 16.0, right: 16.0, bottom: 32.0),
          child: ListView(
              controller: _listViewController,
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              children: <Widget>[
                const SizedBox(
                  height: 10,
                ),
                SettingsPage(
                  pusher: widget.pusher,
                  shared: widget._shared,
                  onLog: log,
                ),
                const SizedBox(
                  height: 10,
                ),
                Container(
                    decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(5)),
                    padding: const EdgeInsets.all(10.0),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Text(_log,
                          style: widget._shared.isConnected
                              ? TextStyle(color: Colors.green)
                              : TextStyle(color: Colors.red)),
                    )),
              ])),
    );
  }
}

class Page {
  final String title;
  final IconData iconData;
  final Widget widget;
  Page(this.title, this.iconData, this.widget);
}
