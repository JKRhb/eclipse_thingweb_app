// Copyright 2024 Contributors to the Eclipse Foundation. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

part of "affordance_widget.dart";

final class PropertyWidget extends AffordanceWidget {
  const PropertyWidget(
    super._consumedThing,
    this._affordanceKey,
    Property property, {
    super.key,
  }) : _interactionAffordance = property;

  final Property _interactionAffordance;

  final String _affordanceKey;

  @override
  State<StatefulWidget> createState() => _PropertyState();
}

// TODO: Create super class for the affordance state
class _PropertyState extends State<PropertyWidget> {
  _PropertyState();

  bool _running = false;

  int _counter = 0;

  final List<(double, double)> _data = [];

  int get _initialWindowIndex => max(0, _data.length - _maxElements);

  List<(double, double)> get _dataWindow {
    final result = <(double, double)>[];

    for (var i = _initialWindowIndex; i < _data.length; i++) {
      result.add(_data[i]);
    }

    return result;
  }

  Property get _property => widget._interactionAffordance;

  String get _propertyKey => widget._affordanceKey;

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
      final propertyName = _propertyKey;

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
    final propertyDescription = _property.description;

    final cardTitle = Text(_propertyTitle ?? widget._affordanceKey);
    final cardDescription =
        propertyDescription != null ? Text(propertyDescription) : null;

    return Card(
      child: Column(
        children: [
          ListTile(
            title: cardTitle,
            subtitle: cardDescription,
            trailing: const Text("Property"),
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
