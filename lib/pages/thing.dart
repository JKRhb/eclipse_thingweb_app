// Copyright 2024 Contributors to the Eclipse Foundation. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import 'package:eclipse_thingweb_app/main.dart';
import 'package:eclipse_thingweb_app/widgets/affordance_widget.dart';
import 'package:flutter/material.dart';
import 'package:dart_wot/core.dart';
import 'package:dart_wot/core.dart' as dart_wot;
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A page that lists all the interaction affordances of a Thing listed within
/// its [_thingDescription].
class ThingPage extends ConsumerStatefulWidget {
  const ThingPage(
    this._thingDescription, {
    super.key,
  });

  final ThingDescription _thingDescription;

  @override
  ConsumerState<ThingPage> createState() => _ThingPageState();
}

class _ThingPageState extends ConsumerState<ThingPage> {
  Map<String, Property> get _properties =>
      widget._thingDescription.properties ?? {};

  Map<String, dart_wot.Action> get _actions =>
      widget._thingDescription.actions ?? {};

  Map<String, Event> get _events => widget._thingDescription.events ?? {};

  Map<String, InteractionAffordance> get _interactionAffordances =>
      Map.fromEntries(
        [
          ..._properties.entries,
          ..._actions.entries,
          ..._events.entries,
        ],
      );

  // TODO: Improve formatting.
  Card get _metadataWidget {
    final id = widget._thingDescription.id;
    final description = widget._thingDescription.description;
    return Card(
      child: Column(
        children: [
          if (description != null)
            ListTile(
              subtitle: Text(description),
            ),
          if (id != null) Text("ID: $id"),
        ],
      ),
    );
  }

  Widget get _affordanceWidgets {
    final consumedThing =
        ref.watch(consumedThingProvider(widget._thingDescription));

    return switch (consumedThing) {
      AsyncData(:final value) => Column(
          children: _interactionAffordances.entries
              .map(
                (property) => AffordanceWidget.create(
                  value,
                  property.value,
                  property.key,
                ),
              )
              .toList(),
        ),
      AsyncError(:final error) => throw error,
      _ => const CircularProgressIndicator(),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        title: Text(widget._thingDescription.title),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _metadataWidget,
            _affordanceWidgets,
          ],
        ),
      ),
    );
  }
}
