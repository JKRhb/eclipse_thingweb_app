import 'package:dart_wot/core.dart';
import 'package:ecplise_thingweb_demo_app/main.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'graph.dart';

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
  String? propertyName
});

class _HomePageState extends State<HomePage> {
  final _thingDescriptions = <ThingDescription>[];

  Future<_DiscoveryPreferences> get _discoveryPreferences async {
    final preferences = widget._preferencesAsync;

    return (
      discoveryUrl: await preferences.getString(discoveryUrlSettingsKey),
      discoveryMethod: await preferences.getString(discoveryMethodSettingsKey),
      propertyName: await preferences.getString(propertyNameSettingsKey),
    );
  }

  void _registerThingDescription(
      ThingDescription thingDescription, propertyName) {
    final properties = thingDescription.properties ?? {};

    if (!properties.containsKey(propertyName)) {
      return;
    }

    setState(() {
      _thingDescriptions.add(thingDescription);
    });
  }

  static const _successSnackBar = SnackBar(
    content: Text(
      "Discovery process finished.",
    ),
    behavior: SnackBarBehavior.floating,
  );

  SnackBar _createFailureSnackbar(String errorTitle, String errorMessage) =>
      SnackBar(
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              errorTitle,
            ),
            Text(
              errorMessage,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            )
          ],
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.red,
      );

  void _displaySnackbarMessage(BuildContext context, SnackBar snackbar) =>
      ScaffoldMessenger.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(snackbar);

  void _startDiscovery(
      BuildContext context, _DiscoveryPreferences discoveryPreferences) async {
    setState(() {
      _thingDescriptions.clear();
    });

    final (:discoveryUrl, :discoveryMethod, :propertyName) =
        discoveryPreferences;

    try {
      if (propertyName == null) {
        throw const DiscoveryException(
          "A property name to filter TDs must be set in the preferences.",
        );
      }

      final parsedDiscoveryUrl = Uri.parse(discoveryUrl!);

      switch (discoveryMethod) {
        case "Direct":
          final thingDescription =
              await widget._wot.requestThingDescription(parsedDiscoveryUrl);
          _registerThingDescription(
            thingDescription,
            propertyName,
          );

          if (context.mounted) {
            _displaySnackbarMessage(context, _successSnackBar);
          }

        case "Directory":
          final discoveryProcess =
              await widget._wot.exploreDirectory(parsedDiscoveryUrl);

          await for (final thingDescription in discoveryProcess) {
            _registerThingDescription(
              thingDescription,
              propertyName,
            );
          }

          if (context.mounted) {
            _displaySnackbarMessage(context, _successSnackBar);
          }
      }

      if (_thingDescriptions.isEmpty) {
        throw DiscoveryException(
          "Did not discovery any TDs with property name $propertyName",
        );
      }
    } on DiscoveryException catch (exception) {
      if (!context.mounted) {
        return;
      }
      _displaySnackbarMessage(
        context,
        _createFailureSnackbar(
          "Discovery failed!",
          exception.message,
        ),
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
                  leading: const Icon(Icons.devices),
                  onTap: () async {
                    final propertyName = await widget._preferencesAsync
                        .getString(propertyNameSettingsKey);

                    if (!context.mounted) {
                      return;
                    }

                    if (propertyName == null || propertyName.isEmpty) {
                      final snackbar = _createFailureSnackbar(
                        "Cannot start interaction",
                        "No property name set.",
                      );

                      _displaySnackbarMessage(context, snackbar);
                      return;
                    }

                    final properties = thingDescription.properties ?? {};

                    if (!(properties).containsKey(propertyName)) {
                      final snackbar = _createFailureSnackbar(
                        "Cannot start interaction",
                        "Thing Description does not include property name $propertyName.",
                      );

                      _displaySnackbarMessage(context, snackbar);
                      return;
                    }

                    ScaffoldMessenger.of(context).removeCurrentSnackBar();

                    context.push(
                      "/graph",
                      extra: GraphData(
                        thingDescription,
                        propertyName,
                      ),
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
