import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future main() async {
  await dotenv.load(fileName: "env");
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    connectRpc();
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

// https://qiita.com/shohei-y/items/7880598d9c797f277731
void connectRpc() async {
  String rpcUri =
      "ws://127.0.0.1:6463/?v=1&client_id=${dotenv.env['CLIENT_ID']}";
  WebSocketChannel channel = WebSocketChannel.connect(Uri.parse(rpcUri));
  channel.stream.listen((message) {
    print(message);
    // channel.sink.add(json.encode(authMap));
  });
  Map authMap = {
    'cmd': "AUTHENTICATE",
    'args': {'access_token': dotenv.env['ACCESS_TOKEN']},
    'nonce': "counter:1"
  };
  channel.sink.add(json.encode(authMap));
  Map speakMap = {
    'cmd': "SUBSCRIBE",
    'args': {'channel_id': dotenv.env['CHANNEL_ID']},
    'evt': "SPEAKING_START",
    'nonce': "counter:2",
  };
  channel.sink.add(json.encode(speakMap));
}
