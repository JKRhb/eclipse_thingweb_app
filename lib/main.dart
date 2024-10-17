import 'package:dart_wot/binding_mqtt.dart';
import 'package:dart_wot/binding_http.dart';
import 'package:dart_wot/core.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import "dart:math";

final Map<String, BasicCredentials> basicCredentials = {
  "urn:test": const BasicCredentials("rw", "readwrite"),
};

Future<BasicCredentials?> basicCredentialsCallback(
  Uri uri,
  AugmentedForm? form, [
  BasicCredentials? invalidCredentials,
]) async {
  final id = form?.tdIdentifier;

  return basicCredentials[id];
}

Future<void> main() async {
  final servient = Servient.create(clientFactories: [
    MqttClientFactory(basicCredentialsCallback: basicCredentialsCallback),
    HttpClientFactory()
  ]);
  final wot = await servient.start();

  runApp(WotApp(wot));
}

class WotApp extends StatelessWidget {
  const WotApp(this._wot, {super.key});

  final WoT _wot;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    const title = "Eclipse Thingweb OCX Demo";
    return MaterialApp(
      title: title,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromRGBO(51, 184, 164, 0)),
        useMaterial3: true,
      ),
      home: MyHomePage(_wot, title: title),
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

  String? _graphTitle;

  final int _maxElements = 50;

  ConsumedThing? _consumedThing;

  Future<void> _triggerConsumption() async {
    if (_consumedThing == null) {
      const thingDescriptionUrl =
          "https://gist.githubusercontent.com/JKRhb/a96353072d3e8e7bbf806421ea85e570/raw/2047d057e81d1cbd5661227d2d8933dda1704d12/voltage-meter.td.json";

      final thingDescription = await widget._wot.requestThingDescription(
        Uri.parse(thingDescriptionUrl),
      );

      const propertyName = "voltage";

      _graphTitle = thingDescription.properties?[propertyName]?.title;

      final consumedThing = await widget._wot.consume(thingDescription);
      consumedThing.observeProperty(propertyName, (interactionOutput) async {
        final value = await interactionOutput.value();

        if (value is int) {
          setState(() {
            _data.add((_counter.toDouble(), value.toDouble()));
            _counter++;
          });
        }
      });

      _consumedThing = consumedThing;
    }
  }

  @override
  Widget build(BuildContext context) {
    final foo = _graphTitle != null ? Text("$_graphTitle over Time") : null;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (_data.isNotEmpty)
              AspectRatio(
                  aspectRatio: 2.0,
                  child: LineChart(
                    LineChartData(
                      minY: 0,
                      maxY: 100,
                      clipData: const FlClipData.all(),
                      titlesData: FlTitlesData(
                        bottomTitles: const AxisTitles(
                          axisNameWidget: Text(''),
                          axisNameSize: 24,
                          sideTitles: SideTitles(
                            showTitles: false,
                            reservedSize: 0,
                          ),
                        ),
                        topTitles: AxisTitles(
                          axisNameWidget: foo,
                          axisNameSize: 24,
                          sideTitles: const SideTitles(
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
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: _triggerConsumption,
            tooltip: 'Discover',
            child: const Icon(
              Icons.explore,
            ),
          ),
        ],
      ),
    );
  }
}
