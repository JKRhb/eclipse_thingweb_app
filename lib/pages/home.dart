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

  @override
  void initState() {
    super.initState();

    _discoveryUrl = widget._preferencesAsync.getString(discoveryUrlSettingsKey);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: const Color(0xFFFFFFFF),
        title: Text(widget.title),
        // TODO: Fix theme color
        backgroundColor: Theme.of(context).primaryColor,
        actions: [
          FutureBuilder(
            future: _discoveryUrl,
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
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Discovery process started.')));

                  try {
                    final discoveryUrl = Uri.parse(snapshot.data!);

                    final thingDescription =
                        await widget._wot.requestThingDescription(discoveryUrl);

                    print(thingDescription);

                    setState(
                      () {
                        _thingDescriptions.add(thingDescription);
                      },
                    );
                  } catch (exception) {
                    // TODO: Do something here.
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
