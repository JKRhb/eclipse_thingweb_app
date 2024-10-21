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

  late Future<String?> _discoveryUrl;

  late Future<String?> _discoveryMethod;

  Future<({String? discoveryUrl, String? discoveryMethod})>
      get _obtainPreferences async {
    final result = await Future.wait([_discoveryUrl, _discoveryMethod]);

    return (discoveryUrl: result[0], discoveryMethod: result[1]);
  }

  @override
  void initState() {
    super.initState();

    _discoveryUrl = widget._preferencesAsync.getString(discoveryUrlSettingsKey);

    _discoveryMethod =
        widget._preferencesAsync.getString(discoveryMethodSettingsKey);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        actions: [
          FutureBuilder(
            future: _obtainPreferences,
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
                        setState(
                          () {
                            _thingDescriptions.add(thingDescription);
                          },
                        );
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content:
                                      Text('Discovery process finished.')));
                          return;
                        }

                      case "Directory":
                        final discoveryProcess = await widget._wot
                            .exploreDirectory(parsedDiscoveryUrl);

                        await for (final thingDescription in discoveryProcess) {
                          setState(
                            () {
                              _thingDescriptions.add(thingDescription);
                            },
                          );
                        }

                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content:
                                      Text('Discovery process finished.')));
                        }
                    }
                  } catch (exception) {
                    if (!context.mounted) {
                      return;
                    }
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Discovery process failed.')));
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
      body: Column(
        children: _thingDescriptions
            .map((thingDescription) => ListTile(
                  title: Text(thingDescription.title),
                  onTap: () {
                    context.push(
                      "/graph",
                      extra: GraphData(
                        thingDescription,
                        "status",
                      ),
                    );
                  },
                ))
            .toList(),
      ),
    );
  }
}
