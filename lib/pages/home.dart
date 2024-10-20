import 'package:dart_wot/core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'graph.dart';

class HomePage extends StatefulWidget {
  const HomePage(
    this._wot, {
    super.key,
    required this.title,
  });

  final WoT _wot;

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _thingDescriptions = <ThingDescription>[];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: const Color(0xFFFFFFFF),
        title: Text(widget.title),
        // TODO: Fix theme color
        backgroundColor: Theme.of(context).primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.travel_explore),
            tooltip: 'Show Snackbar',
            onPressed: () async {
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Discovery process started.')));

              final thingDescription =
                  await widget._wot.requestThingDescription(Uri.parse(
                "https://gist.githubusercontent.com/JKRhb/a96353072d3e8e7bbf806421ea85e570/raw/e2c3123897f387dff592fa65fb23aa3c5a48177a/voltage-meter.td.json",
              ));

              setState(
                () {
                  _thingDescriptions.add(thingDescription);
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
