import 'package:dart_wot/core.dart';
import 'package:dart_wot/core.dart' as dart_wot;
import 'package:eclipse_thingweb_app/util/snackbar.dart';
import 'package:flutter/material.dart';

import 'dart:math';

import 'package:fl_chart/fl_chart.dart';

part "action_widget.dart";
part "property_widget.dart";
part "event_widget.dart";

abstract base class AffordanceWidget extends StatefulWidget {
  const AffordanceWidget(
    this._consumedThing, {
    super.key,
  });

  final ConsumedThing _consumedThing;

  factory AffordanceWidget.create(
    ConsumedThing consumedThing,
    InteractionAffordance interactionAffordance,
    String affordanceKey,
  ) {
    switch (interactionAffordance) {
      case dart_wot.Action():
        return ActionWidget(
            consumedThing, affordanceKey, interactionAffordance);
      case Property():
        return PropertyWidget(
            consumedThing, affordanceKey, interactionAffordance);
      case Event():
        return EventWidget(consumedThing, affordanceKey, interactionAffordance);
    }
  }
}
