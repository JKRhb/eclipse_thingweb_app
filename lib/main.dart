import 'package:dart_wot/binding_mqtt.dart';
import 'package:dart_wot/binding_http.dart';
import 'package:dart_wot/core.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import "dart:math";

Future<void> main() async {
  final servient = Servient.create(clientFactories: [MqttClientFactory(), HttpClientFactory()]);
  final wot = await servient.start();

  runApp(WotApp(wot));
}

class WotApp extends StatelessWidget {
  const WotApp(this._wot, {super.key});

  final WoT _wot;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Eclipse Thingweb OSX Demo App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromRGBO(51, 184, 164, 0)),
        useMaterial3: true,
      ),
      home: MyHomePage(_wot, title: 'OSX Demo App'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage(
    this._wot, {
    super.key,
    required this.title,
  });

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  final WoT _wot;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  _MyHomePageState();

  int _counter = 0;

  final List<(double, double)> _data = [];

  List<(double, double)> get _dataWindow {
    final result = <(double, double)>[];

    for (var i = max(0, _data.length - _maxElements); i < _data.length; i++) {
      result.add(_data[i]);
    }

    return result;
  }

  final int _maxElements = 50;

  Future<void> _incrementCounter() async {
    final yo = await widget._wot.requestThingDescription(
        Uri.parse("https://zion.vaimee.com/.well-known/wot"));
    print(yo.title);

    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.

      _data.add((_counter.toDouble(), Random().nextDouble() * 100));

      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            AspectRatio(
                aspectRatio: 2.0,
                child: LineChart(
                  LineChartData(
                    minY: 0,
                    maxY: 100,
                    clipData: const FlClipData.all(),
                    titlesData: const FlTitlesData(
                      bottomTitles: AxisTitles(
                        axisNameWidget: Text('Insert property name here'),
                        axisNameSize: 24,
                        sideTitles: SideTitles(
                          showTitles: false,
                          reservedSize: 0,
                        ),
                      ),
                      topTitles: AxisTitles(
                        axisNameWidget: Text('Insert time stamps here.'),
                        axisNameSize: 24,
                        sideTitles: SideTitles(
                          showTitles: false,
                          reservedSize: 0,
                        ),
                      ),
                    ),
                    lineBarsData: [
                      LineChartBarData(
                          show: true,
                          isCurved: true,
                          spots: _dataWindow
                              .map((e) => FlSpot(e.$1, e.$2))
                              .toList())
                    ],
                  ),
                  duration: Duration.zero,
                )),
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
