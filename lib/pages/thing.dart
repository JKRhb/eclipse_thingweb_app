// Copyright 2024 Contributors to the Eclipse Foundation. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import 'package:flutter/material.dart';
import 'package:dart_wot/core.dart';
import 'package:fl_chart/fl_chart.dart';

import "dart:math";

class ThingData {
  ThingData(this.thingDescription, this.propertyName);

  final ThingDescription thingDescription;

  final String propertyName;
}

class ThingPage extends StatefulWidget {
  const ThingPage(
    this._wot,
    this._thingDescription, {
    super.key,
    required this.title,
  });

  final String title;

  final WoT _wot;

  final ThingDescription _thingDescription;

  @override
  State<ThingPage> createState() => _ThingPageState();
}

class _ThingPageState extends State<ThingPage> {
  Map<String, Property> get _properties =>
      widget._thingDescription.properties ?? {};

  late Future<ConsumedThing> _consumedThing;

  @override
  void initState() {
    super.initState();

    _consumedThing = widget._wot.consume(widget._thingDescription);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        title: Text(widget._thingDescription.title),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FutureBuilder(
                future: _consumedThing,
                builder: (BuildContext context,
                    AsyncSnapshot<ConsumedThing> snapshot) {
                  if (snapshot.hasData) {
                    return Column(
                      children: _properties.entries
                          .map(
                            (property) => PropertyWidget(
                              snapshot.data!,
                              property.key,
                              property.value,
                            ),
                          )
                          .toList(),
                    );
                  }

                  if (snapshot.hasError) {
                    throw snapshot.error!;
                  }

                  return const CircularProgressIndicator();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PropertyWidget extends StatefulWidget {
  const PropertyWidget(
    this._consumedThing,
    this._propertyKey,
    this._property, {
    super.key,
  });

  final ConsumedThing _consumedThing;

  final Property _property;

  final String _propertyKey;

  @override
  State<StatefulWidget> createState() => _PropertyState();
}

class _PropertyState extends State<PropertyWidget> {
  _PropertyState();

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

  Property get _property => widget._property;

  String? get _propertyTitle => _property.title;

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
      final propertyName = widget._propertyKey;

      final consumedThing = widget._consumedThing;
      _subscription = await consumedThing.observeProperty(propertyName,
          (interactionOutput) async {
        final value = await interactionOutput.value();

        if (_subscription != null && value is num) {
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
    final propertyTitle = _propertyTitle;
    final propertyDescription = widget._property.description;

    final cardTitle = propertyTitle != null ? Text(propertyTitle) : null;
    final cardDescription =
        propertyDescription != null ? Text(propertyDescription) : null;

    return Card(
      child: Column(
        children: [
          ListTile(
            title: cardTitle,
            subtitle: cardDescription,
          ),
          _PropertyVisualization(_property, _dataWindow),
          OverflowBar(
            children: [
              IconButton(
                onPressed: _triggerConsumption,
                icon: Icon(
                  !_running ? Icons.play_arrow : Icons.stop,
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}

class _PropertyVisualization extends StatelessWidget {
  const _PropertyVisualization(this._property, this._data);

  final Property _property;

  String? get _propertyTitle => _property.title;

  final List<(double, double)> _data;

  List<FlSpot> get _spots => _data.map((e) => FlSpot(e.$1, e.$2)).toList();

  Text? get axisTitle =>
      _propertyTitle != null ? Text("$_propertyTitle over Time") : null;

  @override
  Widget build(BuildContext context) => AspectRatio(
        aspectRatio: 2.0,
        child: LineChart(
          LineChartData(
            minY: _property.minimum?.toDouble(),
            maxY: _property.maximum?.toDouble(),
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
                spots: _spots,
              )
            ],
          ),
          duration: Duration.zero,
        ),
      );
}
