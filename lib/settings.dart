import 'package:flutter/material.dart';
import 'package:nice_buttons/nice_buttons.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import "./entities/shared.dart";

extension GetByKeyIndex on Map {
  elementAt(int index) => this.values.elementAt(index);
}

class SettingsPage extends StatefulWidget {
  const SettingsPage(
      {super.key,
      required this.pusher,
      required this.shared,
      required this.onLog});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".
  final PusherChannelsFlutter pusher;
  final Shared shared;
  final Function onLog;

  @override
  State<SettingsPage> createState() => _SettingsPageState();

}

class _SettingsPageState extends State<SettingsPage> {
  int _counter = 0;

  final _apiKey = TextEditingController();
  final _cluster = TextEditingController();
  final _channelName = TextEditingController();
  final _eventName = TextEditingController();
  final _channelFormKey = GlobalKey<FormState>();
  final _eventFormKey = GlobalKey<FormState>();
  final _data = TextEditingController();

// Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _apiKey.text = prefs.getString("apiKey") ?? '';
      _cluster.text = prefs.getString("cluster") ?? 'eu';
      _channelName.text = prefs.getString("channelName") ?? 'my-channel';
      _eventName.text = prefs.getString("eventName") ?? 'event';
      _data.text = prefs.getString("data") ?? 'test';
    });
  }

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  void onConnectionStateChange(dynamic currentState, dynamic previousState) {
    widget.onLog("Connection: $currentState");
  }

  void onError(String message, int? code, dynamic e) {
    widget.onLog("onError: $message code: $code exception: $e");
  }

  void onEvent(PusherEvent event) {
    widget.onLog("onEvent: $event");
  }

  void onSubscriptionSucceeded(String channelName, dynamic data) {
    widget.onLog("onSubscriptionSucceeded: $channelName data: $data");
    final me = widget.pusher.getChannel(channelName)?.me;
    widget.onLog("Me: $me");
  }

  void onSubscriptionError(String message, dynamic e) {
    widget.onLog("onSubscriptionError: $message Exception: $e");
  }

  void onDecryptionFailure(String event, String reason) {
    widget.onLog("onDecryptionFailure: $event reason: $reason");
  }

  void onMemberAdded(String channelName, PusherMember member) {
    widget.onLog("onMemberAdded: $channelName user: $member");
  }

  void onMemberRemoved(String channelName, PusherMember member) {
    widget.onLog("onMemberRemoved: $channelName user: $member");
  }

  void onTriggerEventPressed() async {
    var eventFormValidated = _eventFormKey.currentState!.validate();

    if (!eventFormValidated) {
      return;
    }
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("eventName", _eventName.text);
    prefs.setString("data", _data.text);
    widget.pusher.trigger(PusherEvent(
        channelName: _channelName.text,
        eventName: _eventName.text,
        data: _data.text));
  }
  void onDisconnectPressed() async {
    await widget.pusher.disconnect();
    setState(() {
      widget.shared.isConnected = false;
    });    
  }
  void onConnectPressed() async {
    if (!_channelFormKey.currentState!.validate()) {
      return;
    }
    // Remove keyboard
    FocusScope.of(context).requestFocus(FocusNode());
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("apiKey", _apiKey.text);
    prefs.setString("cluster", _cluster.text);
    prefs.setString("channelName", _channelName.text);
    setState(() {
      widget.shared.channel = _channelName.text;
    });
    try {
      await widget.pusher.init(
        apiKey: _apiKey.text,
        cluster: _cluster.text,
        onConnectionStateChange: onConnectionStateChange,
        onError: onError,
        onSubscriptionSucceeded: onSubscriptionSucceeded,
        onEvent: onEvent,
        onSubscriptionError: onSubscriptionError,
        onDecryptionFailure: onDecryptionFailure,
        onMemberAdded: onMemberAdded,
        onMemberRemoved: onMemberRemoved,
        // authEndpoint: "<Your Authendpoint Url>",
        // onAuthorizer: onAuthorizer
      );
      await widget.pusher.subscribe(channelName: _channelName.text);
      await widget.pusher.connect();
      setState(() {
        widget.shared.isConnected = true;
      });
    } catch (e) {
      widget.onLog("ERROR: $e");
    }
  }

  String getChannel() {
    return _channelName.text;
  }

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
        key: _channelFormKey,
        child: Column(children: <Widget>[
          TextFormField(
            controller: _apiKey,
            validator: (String? value) {
              return (value != null && value.isEmpty)
                  ? 'Por favor ingrese el API key.'
                  : null;
            },
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.all(16.0),
              labelText: 'API Key (Ejemplo: c32633cbff70a4071112)',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
          const SizedBox(
            height: 32.0,
          ),
          TextFormField(
            controller: _cluster,
            validator: (String? value) {
              return (value != null && value.isEmpty)
                  ? 'Por favor ingrese el cluster.'
                  : null;
            },
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.all(16.0),
              labelText: 'Cluster (Ejemplo: eu) (Ejemplo: us2)',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
          const SizedBox(
            height: 32.0,
          ),
          TextFormField(
            controller: _channelName,
            validator: (String? value) {
              return (value != null && value.isEmpty)
                  ? 'Por favor ingrese el channel.'
                  : null;
            },
            decoration: InputDecoration(
              labelText: 'Channel',
              contentPadding: const EdgeInsets.all(16.0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
          const SizedBox(
            height: 24.0,
          ),
          widget.shared.isConnected?
          NiceButtons(
            startColor: Colors.red,
            endColor: Colors.redAccent,
            borderColor: Colors.red,
            stretch: false,
            gradientOrientation: GradientOrientation.Vertical,
            onTap: (finish) {
              onDisconnectPressed();
            },
            child: const Text(
              'Desconectar',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ):          
          NiceButtons(
            startColor: Colors.deepPurple,
            endColor: Colors.deepPurpleAccent,
            borderColor: Colors.deepPurple,
            stretch: false,
            gradientOrientation: GradientOrientation.Vertical,
            onTap: (finish) {
              onConnectPressed();
            },
            child: const Text(
              'Conectar',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ),
        ]));
  }
}
