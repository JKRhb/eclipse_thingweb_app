import 'package:flutter/material.dart';
import 'package:dart_wot/core.dart';
import 'package:fl_chart/fl_chart.dart';

import "dart:math";

// TODO: Use a record for this instead
class GraphData {
  GraphData(this.thingDescription, this.propertyName);

  final ThingDescription thingDescription;

  final String propertyName;
}

class GraphPage extends StatefulWidget {
  const GraphPage(
    this._wot,
    this._thingDescription,
    this.propertyName, {
    super.key,
    required this.title,
  });

  final String title;

  final WoT _wot;

  final ThingDescription _thingDescription;

  final String propertyName;

  @override
  State<GraphPage> createState() => _GraphPageState();
}

class _GraphPageState extends State<GraphPage> {
  _GraphPageState();

  bool _running = false;

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

  Subscription? _subscription;

  @override
  void dispose() {
    _subscription?.stop();
    _subscription = null;
    _consumedThing = null;
    super.dispose();
  }

  Future<void> _triggerConsumption() async {
    if (_running) {
      await _subscription?.stop();
    }

    setState(() {
      if (_running) {
        _subscription = null;
        _consumedThing = null;
      }
      _running = !_running;
    });

    if (!_running) {
      return;
    }

    if (_consumedThing == null) {
      final propertyName = widget.propertyName;
      final thingDescription = widget._thingDescription;

      _graphTitle = thingDescription.properties?[propertyName]?.title;

      final consumedThing = await widget._wot.consume(thingDescription);
      _subscription = await consumedThing.observeProperty(propertyName,
          (interactionOutput) async {
        final value = await interactionOutput.value();

        if (_subscription != null && value is int) {
          setState(() {
            _data.add((_counter.toDouble(), value.toDouble()));
            _counter++;
          });
        }
      });

      setState(() {
        _consumedThing = consumedThing;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final axisTitle =
        _graphTitle != null ? Text("$_graphTitle over Time") : null;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget._thingDescription.title),
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
                          axisNameWidget: axisTitle,
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
            tooltip: 'Start',
            child: Icon(
              !_running ? Icons.play_arrow : Icons.stop,
            ),
          ),
        ],
      ),
    );
  }
}
