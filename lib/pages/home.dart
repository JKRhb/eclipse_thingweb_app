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

class _HomePageState extends State<HomePage> {
  final _thingDescriptions = <ThingDescription>[];

  Future<({String? discoveryUrl, String? discoveryMethod})>
      get _obtainDiscoveryPreferences async {
    final preferences = widget._preferencesAsync;

    return (
      discoveryUrl: await preferences.getString(discoveryUrlSettingsKey),
      discoveryMethod: await preferences.getString(discoveryMethodSettingsKey),
    );
  }

  void _registerThingDescription(ThingDescription thingDescription) {
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

  SnackBar _createFailureSnackbar(String errorMessage) => SnackBar(
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Discovery failed!",
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        actions: [
          FutureBuilder(
            future: _obtainDiscoveryPreferences,
            builder: (context, snapshot) {
              const icon = Icon(Icons.travel_explore);
              const disabledButton = IconButton(onPressed: null, icon: icon);

              if (snapshot.connectionState == ConnectionState.waiting ||
                  snapshot.hasError) {
                return disabledButton;
              }

              return IconButton(
                icon: icon,
                tooltip: 'Discover TDs',
                onPressed: () async {
                  setState(() {
                    _thingDescriptions.clear();
                  });

                  final (:discoveryUrl, :discoveryMethod) = snapshot.data!;

                  try {
                    final parsedDiscoveryUrl = Uri.parse(discoveryUrl!);

                    switch (discoveryMethod) {
                      case "Direct":
                        final thingDescription = await widget._wot
                            .requestThingDescription(parsedDiscoveryUrl);
                        _registerThingDescription(thingDescription);

                        if (context.mounted) {
                          _displaySnackbarMessage(context, _successSnackBar);
                          return;
                        }

                      case "Directory":
                        final discoveryProcess = await widget._wot
                            .exploreDirectory(parsedDiscoveryUrl);

                        await for (final thingDescription in discoveryProcess) {
                          _registerThingDescription(thingDescription);
                        }

                        if (context.mounted) {
                          _displaySnackbarMessage(context, _successSnackBar);
                        }
                    }
                  } on Exception catch (exception) {
                    if (!context.mounted) {
                      return;
                    }
                    _displaySnackbarMessage(
                        context,
                        _createFailureSnackbar(
                          exception.toString(),
                        ));
                  }
                },
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => {
              context.push("/settings"),
            },
          )
        ],
      ),
      body: ListView(
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

                  if (propertyName == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Error: No property name set.'),
                      ),
                    );
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
    );
  }
}
