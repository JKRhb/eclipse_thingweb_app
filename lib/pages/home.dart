// Copyright 2024 Contributors to the Eclipse Foundation. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import 'package:dart_wot/core.dart';
import 'package:eclipse_thingweb_app/main.dart';
import 'package:eclipse_thingweb_app/util/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage(
    this._wot,
    this._preferencesAsync, {
    super.key,
    required this.title,
  });

  final WoT _wot;

  final SharedPreferencesAsync _preferencesAsync;

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

typedef _DiscoveryPreferences = ({
  String? discoveryUrl,
  String? discoveryMethod,
});

class _HomePageState extends State<HomePage> {
  final _thingDescriptions = <ThingDescription>[];

  Future<_DiscoveryPreferences> get _discoveryPreferences async {
    final preferences = widget._preferencesAsync;

    return (
      discoveryUrl: await preferences.getString(discoveryUrlSettingsKey),
      discoveryMethod:
          (await preferences.getString(discoveryMethodSettingsKey) ??
              defaultDiscoveryMethod),
    );
  }

  void _registerThingDescription(ThingDescription thingDescription) {
    setState(() {
      _thingDescriptions.add(thingDescription);
    });
  }

  void _startDiscovery(
      BuildContext context, _DiscoveryPreferences discoveryPreferences) async {
    setState(() {
      _thingDescriptions.clear();
    });

    final (:discoveryUrl, :discoveryMethod) = discoveryPreferences;

    try {
      if (discoveryUrl == null) {
        throw const DiscoveryException(
          "A discovery URL must be set in the preferences.",
        );
      }

      final parsedDiscoveryUrl = Uri.parse(discoveryUrl);

      switch (discoveryMethod) {
        case "Direct":
          final thingDescription =
              await widget._wot.requestThingDescription(parsedDiscoveryUrl);
          _registerThingDescription(thingDescription);

        case "Directory":
          final discoveryProcess =
              await widget._wot.exploreDirectory(parsedDiscoveryUrl);

          await for (final thingDescription in discoveryProcess) {
            _registerThingDescription(thingDescription);
          }

        default:
          throw DiscoveryException(
            "Unknown or unsupported discovery method $discoveryMethod set.",
          );
      }

      if (_thingDescriptions.isEmpty) {
        throw const DiscoveryException(
          "No TDs have been discovered.",
        );
      }

      if (context.mounted) {
        displaySuccessMessageSnackbar(context, "Discovery process finished.");
      }
    } on DiscoveryException catch (exception) {
      if (!context.mounted) {
        return;
      }
      displayErrorMessageSnackbar(
        context,
        "Discovery failed!",
        exception.message,
      );
    } on FormatException catch (exception) {
      if (!context.mounted) {
        return;
      }
      displayErrorMessageSnackbar(
        context,
        "Failed to decode discovery result!",
        exception.message,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FutureBuilder(
        future: _discoveryPreferences,
        builder: (context, snapshot) {
          const icon = Icon(Icons.travel_explore);
          const disabledButton =
              FloatingActionButton(onPressed: null, child: icon);

          if (snapshot.connectionState == ConnectionState.waiting ||
              snapshot.hasError) {
            return disabledButton;
          }

          return FloatingActionButton(
            tooltip: 'Discover TDs',
            onPressed: () => _startDiscovery(context, snapshot.data!),
            child: icon,
          );
        },
      ),
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => {
              context.push("/settings"),
            },
          )
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          final discoveryPreferences = await _discoveryPreferences;

          if (!context.mounted) {
            return;
          }

          _startDiscovery(context, discoveryPreferences);
        },
        child: ListView(
          children: _thingDescriptions.map(
            (thingDescription) {
              final description = thingDescription.description;

              return Card(
                child: ListTile(
                  title: Text(thingDescription.title),
                  subtitle: description != null ? Text(description) : null,
                  leading: const Icon(Icons.electric_bolt),
                  onTap: () async {
                    if (!context.mounted) {
                      return;
                    }

                    ScaffoldMessenger.of(context).removeCurrentSnackBar();

                    context.push(
                      "/thing",
                      extra: thingDescription,
                    );
                  },
                ),
              );
            },
          ).toList(),
        ),
      ),
    );
  }
}
