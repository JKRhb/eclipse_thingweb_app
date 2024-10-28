// Copyright 2024 Contributors to the Eclipse Foundation. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import 'package:eclipse_thingweb_app/widgets/affordance_widget.dart';
import 'package:flutter/material.dart';
import 'package:dart_wot/core.dart';
import 'package:dart_wot/core.dart' as dart_wot;

/// A page that lists all of the interaction affordances of Thing listed within
/// its [_thingDescription].
///
///
class ThingPage extends StatefulWidget {
  const ThingPage(
    this._wot,
    this._thingDescription, {
    super.key,
  });

  final WoT _wot;

  final ThingDescription _thingDescription;

  @override
  State<ThingPage> createState() => _ThingPageState();
}

class _ThingPageState extends State<ThingPage> {
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

  late Future<ConsumedThing> _consumedThing;

  @override
  void initState() {
    super.initState();

    _consumedThing = widget._wot.consume(widget._thingDescription);
  }

  // TODO: Improve formatting.
  Card get _metadataWidget {
    final id = widget._thingDescription.id;
    return Card(
      child: Column(
        children: [
          ListTile(
            title: Text(widget._thingDescription.title),
            subtitle: Text(widget._thingDescription.description ?? ""),
          ),
          if (id != null) Text("ID: $id"),
        ],
      ),
    );
  }

  FutureBuilder<ConsumedThing> get _affordanceWidgets => FutureBuilder(
        future: _consumedThing,
        builder: (BuildContext context, AsyncSnapshot<ConsumedThing> snapshot) {
          if (snapshot.hasData) {
            return Column(
              children: _interactionAffordances.entries
                  .map(
                    (property) => AffordanceWidget.create(
                      snapshot.data!,
                      property.value,
                      property.key,
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
      );

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
