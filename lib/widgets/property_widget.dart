// Copyright 2024 Contributors to the Eclipse Foundation. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

part of "affordance_widget.dart";

final class PropertyWidget extends AffordanceWidget {
  const PropertyWidget(
    super._consumedThing,
    super._affordanceKey,
    Property property, {
    super.key,
  }) : _interactionAffordance = property;

  @override
  final Property _interactionAffordance;

  @override
  ConsumerState<PropertyWidget> createState() => _PropertyState();
}

final class _PropertyState extends _AffordanceState<PropertyWidget> {
  _PropertyState();

  ConsumedThing get consumedThing => widget._consumedThing;

  ({
    String thingDescriptionId,
    String affordanceKey,
  }) get _accessor => (
        affordanceKey: widget._affordanceKey,
        thingDescriptionId: widget._consumedThing.thingDescription.id!,
      );

  // TODO: Refactor
  List<(int, double)> get _data {
    final data = ref.read(affordanceStateHistoryProvider(_accessor));

    if (data.isEmpty) {
      return [];
    }

    if (data is List<(int, double)>) {
      return data;
    }

    final result = <(int, double)>[];

    for (final dataPoint in data) {
      if (dataPoint is (int, double)) {
        result.add(dataPoint);
      }
    }

    return result;
  }

  int get _initialWindowIndex => max(0, _data.length - _maxElements);

  List<(int, double)> get _dataWindow {
    final result = <(int, double)>[];
    final data = _data;

    for (var i = _initialWindowIndex; i < data.length; i++) {
      result.add(data[i]);
    }

    return result;
  }

  Property get _property => widget._interactionAffordance;

  String get _propertyKey => widget._affordanceKey;

  final int _maxElements = 50;

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _readValue() async {
    try {
      final output = await consumedThing.readProperty(_propertyKey);
      final value = await output.value();

      final accessor = (
        affordanceKey: widget._affordanceKey,
        thingDescriptionId: widget._consumedThing.thingDescription.id!,
      );

      if (value is num) {
        ref.read(affordanceStateHistoryProvider(accessor).notifier).update(
          (
            DateTime.now().millisecondsSinceEpoch,
            value.toDouble(),
          ),
        );
      }

      ref
          .read(
            affordanceStateProvider(accessor).notifier,
          )
          .update(value);
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
    final subscriptionStateNotifier =
        ref.read(subscriptionStateProvider.notifier);

    final hasSubscription = subscriptionStateNotifier.hasSubscription(
        consumedThing, SubscriptionType.property, _propertyKey);

    if (hasSubscription) {
      subscriptionStateNotifier.removeSubscriptionState(
          consumedThing.thingDescription.id!,
          SubscriptionType.property,
          _propertyKey);
      return;
    }

    subscriptionStateNotifier.addPropertySubscription(
      consumedThing,
      _propertyKey,
    );
  }

  bool get isNumericDataType => ["integer", "number"].contains(_property.type);

  @override
  List<Widget> get _cardBody {
    final value = ref.watch(
      affordanceStateProvider((
        affordanceKey: widget._affordanceKey,
        thingDescriptionId: widget._consumedThing.thingDescription.id!,
      )),
    );

    return [
      if (value != null)
        Container(
          padding: const EdgeInsets.all(16.0),
          alignment: Alignment.centerLeft,
          child: Text("Current value: $value"),
        ),
      if (isNumericDataType && _dataWindow.isNotEmpty)
        _PropertyVisualization(_property, _dataWindow),
    ];
  }

  @override
  List<Widget> get _cardButtons {
    final subscribed = ref
        .watch(
      subscriptionStateProvider,
    )
        .where(
      (subscriptionState) {
        return subscriptionState.thingDescriptionId ==
                widget._consumedThing.thingDescription.id! &&
            subscriptionState.subscriptionType == SubscriptionType.property &&
            subscriptionState.affordanceKey == _propertyKey;
      },
    ).isNotEmpty;

    final observeButtonTooltip =
        "${!subscribed ? "Start" : "Stop"} observing this property";

    return [
      if (!_property.writeOnly)
        IconButton(
          onPressed: _readValue,
          tooltip: "Retrieve the latest property value",
          icon: const Icon(Icons.refresh),
        ),
      if (_property.observable)
        IconButton(
          onPressed: _toggleObserve,
          tooltip: observeButtonTooltip,
          icon: Icon(
            !subscribed ? Icons.remove_red_eye : Icons.cancel,
          ),
        ),
    ];
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
    return ExpansionTile(
      title: const Text('Data Visualization'),
      children: [
        AspectRatio(
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
                    interval:
                        const Duration(seconds: 60).inMilliseconds.toDouble(),
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
        ),
      ],
    );
  }
}
