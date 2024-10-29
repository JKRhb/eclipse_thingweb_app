// Copyright 2024 Contributors to the Eclipse Foundation. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import 'package:dart_wot/core.dart';
import 'package:dart_wot/core.dart' as dart_wot;
import 'package:eclipse_thingweb_app/providers/subscription_provider.dart';
import 'package:eclipse_thingweb_app/providers/thing_state_provider.dart';
import 'package:eclipse_thingweb_app/util/snackbar.dart';
import 'package:flutter/material.dart';

import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

part "action_widget.dart";
part "property_widget.dart";
part "event_widget.dart";

abstract base class AffordanceWidget extends ConsumerStatefulWidget {
  const AffordanceWidget(
    this._consumedThing,
    this._affordanceKey, {
    super.key,
  });

  final ConsumedThing _consumedThing;

  InteractionAffordance get _interactionAffordance;

  final String _affordanceKey;

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

  String get affordanceType {
    switch (_interactionAffordance) {
      case dart_wot.Action():
        return "Action";
      case Event():
        return "Event";
      case Property():
        return "Property";
    }
  }
}

abstract base class _AffordanceState<T extends AffordanceWidget>
    extends ConsumerState<T> {
  ListTile get _cardHeader {
    final cardTitle =
        Text(widget._interactionAffordance.title ?? widget._affordanceKey);

    final actionDescription = widget._interactionAffordance.description;
    final cardDescription =
        actionDescription != null ? Text(actionDescription) : null;

    return ListTile(
      title: cardTitle,
      subtitle: cardDescription,
      trailing: Text(widget.affordanceType),
    );
  }

  List<Widget> get _cardBody;

  List<Widget> get _cardButtons;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          _cardHeader,
          ..._cardBody,
          OverflowBar(
            alignment: MainAxisAlignment.end,
            children: _cardButtons,
          ),
        ],
      ),
    );
  }
}
