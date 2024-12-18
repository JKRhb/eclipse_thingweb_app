// Copyright 2024 Contributors to the Eclipse Foundation. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import "package:dart_wot/core.dart" as dart_wot;
import "package:dart_wot/core.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../providers/wot_providers.dart";
import "../widgets/affordance_widget.dart";
import "../widgets/thing_icon.dart";

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
  ThingDescription get thingDescription => widget._thingDescription;

  Map<String, Property> get _properties => thingDescription.properties ?? {};

  Map<String, dart_wot.Action> get _actions => thingDescription.actions ?? {};

  Map<String, Event> get _events => thingDescription.events ?? {};

  Map<String, InteractionAffordance> get _interactionAffordances =>
      Map.fromEntries(
        [
          ..._properties.entries,
          ..._actions.entries,
          ..._events.entries,
        ],
      );

  TableRow _formatTableRow(
    String leftColumnData,
    String rightColumnData,
  ) =>
      TableRow(
        children: [
          Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 16.0),
            child: Text(
              leftColumnData,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Text(rightColumnData),
        ],
      );

  Card get _metadataWidget {
    final id = thingDescription.id;
    final description = thingDescription.description;
    final version = thingDescription.version?.instance;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ListTile(
            leading: ThingIcon(thingDescription),
            tileColor: Theme.of(context).primaryColor,
            textColor: Theme.of(context).colorScheme.onPrimary,
            iconColor: Theme.of(context).colorScheme.onPrimary,
            title: const Text("Metadata"),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                  ),
                  child: Table(
                    columnWidths: const <int, TableColumnWidth>{
                      0: IntrinsicColumnWidth(),
                      1: FlexColumnWidth(),
                    },
                    children: [
                      for (final (fieldName, fieldData) in [
                        ("Description", description),
                        ("ID", id),
                        ("Version", version),
                      ])
                        if (fieldData != null)
                          _formatTableRow(fieldName, fieldData),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget get _affordanceWidgets {
    final consumedThing = ref.watch(consumedThingProvider(thingDescription));

    return switch (consumedThing) {
      AsyncData(:final value) => Column(
          children: _interactionAffordances.entries
              .map(
                (interactionAffordanceEntry) => Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: AffordanceWidget.create(
                    value,
                    interactionAffordanceEntry.value,
                    interactionAffordanceEntry.key,
                  ),
                ),
              )
              .toList(),
        ),
      AsyncError(:final error) => throw Exception(error.toString()),
      _ => const CircularProgressIndicator(),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        title: Text(thingDescription.title),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.notifications,
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.menu,
            ),
          ),
        ],
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
