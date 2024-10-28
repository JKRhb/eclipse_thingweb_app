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

  bool _observing = false;

  Object? _lastValue;

  ConsumedThing get consumedThing => widget._consumedThing;

  final List<(int, double)> _data = [];

  int get _initialWindowIndex => max(0, _data.length - _maxElements);

  List<(int, double)> get _dataWindow {
    final result = <(int, double)>[];

    for (var i = _initialWindowIndex; i < _data.length; i++) {
      result.add(_data[i]);
    }

    return result;
  }

  Property get _property => widget._interactionAffordance;

  String get _propertyKey => widget._affordanceKey;

  String? get _propertyTitle => _property.title;

  final int _maxElements = 50;

  Subscription? _subscription;

  @override
  void dispose() {
    _subscription?.stop();
    _subscription = null;
    super.dispose();
  }

  Future<void> _readValue() async {
    try {
      final output = await consumedThing.readProperty(_propertyKey);
      final value = await output.value();

      if (value is num) {
        _data.add((DateTime.now().millisecondsSinceEpoch, value.toDouble()));
      }

      setState(() {
        _lastValue = value;
      });
    } on Exception catch (exception) {
      if (!mounted) {
        return;
      }

      displayErrorMessageSnackbar(
        context,
        "Reading value failed",
        exception.toString(),
      );
    }
  }

  Future<void> _toggleObserve() async {
    if (_observing) {
      await _subscription?.stop();
    }

    setState(() {
      _observing = !_observing;
    });

    if (!_observing) {
      return;
    }

    _subscription = await consumedThing.observeProperty(
      _propertyKey,
      (interactionOutput) async {
        final value = await interactionOutput.value();

        if (_subscription != null && value is num) {
          _data.add((DateTime.now().millisecondsSinceEpoch, value.toDouble()));
        }

        setState(() {
          _lastValue = value;
        });
      },
    );
  }

  bool get isNumericDataType => ["integer", "number"].contains(_property.type);

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
          OverflowBar(
            alignment: MainAxisAlignment.end,
            children: [
              if (!_property.writeOnly)
                IconButton(
                  onPressed: _readValue,
                  icon: const Icon(Icons.download),
                ),
              if (_property.observable)
                IconButton(
                  onPressed: _toggleObserve,
                  icon: Icon(
                    !_observing ? Icons.play_arrow : Icons.stop,
                  ),
                ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(16.0),
            alignment: Alignment.centerLeft,
            child: Text(_lastValue != null ? "Current value: $_lastValue" : ""),
          ),
          if (isNumericDataType && _dataWindow.isNotEmpty)
            _PropertyVisualization(_property, _dataWindow),
        ],
      ),
    );
  }
}

class _PropertyVisualization extends StatelessWidget {
  const _PropertyVisualization(this._property, this._data);

  final Property _property;

  String? get _propertyTitle => _property.title;

  final List<(int, double)> _data;

  List<FlSpot> get _spots =>
      _data.map((e) => FlSpot(e.$1.toDouble(), e.$2)).toList();

  Text? get axisTitle =>
      _propertyTitle != null ? Text("$_propertyTitle over Time") : null;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 2.0,
      child: LineChart(
        LineChartData(
          minY: _property.minimum?.toDouble(),
          maxY: _property.maximum?.toDouble(),
          clipData: const FlClipData.all(),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              axisNameWidget: const Text('Time'),
              axisNameSize: 24,
              sideTitles: SideTitles(
                showTitles: true,
                // FIXME: This is still not that great
                interval: const Duration(seconds: 60).inMilliseconds.toDouble(),
                getTitlesWidget: (value, metaData) {
                  final DateTime date =
                      DateTime.fromMillisecondsSinceEpoch(value.toInt());
                  final parts = date.toIso8601String().split("T");

                  return SideTitleWidget(
                    axisSide: AxisSide.bottom,
                    child: Text(parts.first),
                  );
                },
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
            ),
          ],
        ),
        duration: Duration.zero,
      ),
    );
  }
}