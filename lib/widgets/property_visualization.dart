// Copyright 2024 Contributors to the Eclipse Foundation. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import 'dart:math';

import 'package:dart_wot/core.dart';
import 'package:eclipse_thingweb_app/providers/affordance_state_provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PropertyVisualization extends StatelessWidget {
  const PropertyVisualization(
    this._property,
    this._ref,
    this._affordanceKey,
    this._maxElements,
    this._thingDescriptionId, {
    super.key,
  });

  static bool _isNumericDataType(Property property) =>
      ["integer", "number"].contains(property.type);

  static PropertyVisualization? create(
    Property property,
    WidgetRef ref,
    String affordanceKey,
    int maxElements,
    String thingDescriptionId,
  ) {
    if (!_isNumericDataType(property)) {
      return null;
    }

    return PropertyVisualization(
      property,
      ref,
      affordanceKey,
      maxElements,
      thingDescriptionId,
    );
  }

  final WidgetRef _ref;

  final Property _property;

  String? get _propertyTitle => _property.title;

  final String _affordanceKey;

  final String _thingDescriptionId;

  final int _maxElements;

  ({
    String thingDescriptionId,
    String affordanceKey,
    AffordanceType affordanceType,
  }) get _accessor => (
        affordanceKey: _affordanceKey,
        thingDescriptionId: _thingDescriptionId,
        affordanceType: AffordanceType.property,
      );

  int get _initialWindowIndex => max(0, _data.length - _maxElements);

  List<(int, double)> get _dataWindow {
    final result = <(int, double)>[];
    final data = _data;

    for (var i = _initialWindowIndex; i < data.length; i++) {
      result.add(data[i]);
    }

    return result;
  }

  // TODO: Refactor
  List<(int, double)> get _data {
    final data = _ref.watch(affordanceStateHistoryProvider(_accessor));

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

  List<FlSpot> get _spots =>
      _dataWindow.map((e) => FlSpot(e.$1.toDouble(), e.$2)).toList();

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
