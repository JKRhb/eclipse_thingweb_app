// Copyright 2024 Contributors to the Eclipse Foundation. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import 'package:dart_wot/binding_mqtt.dart';
import 'package:dart_wot/binding_http.dart';
import 'package:dart_wot/core.dart';
import 'package:eclipse_thingweb_app/pages/graph.dart';
import 'package:flex_seed_scheme/flex_seed_scheme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'pages/home.dart';
import 'pages/settings.dart';

const discoveryMethodSettingsKey = "discovery-method-key";
const discoveryUrlSettingsKey = "discovery-url-key";
const propertyNameSettingsKey = "property-name-key";

const defaultDiscoveryMethod = "Direct";

Future<void> main() async {
  final servient = Servient.create(clientFactories: [
    MqttClientFactory(),
    HttpClientFactory(),
  ]);
  final wot = servient.startClientFactories();

  final preferences = SharedPreferencesAsync();

  runApp(WotApp(wot, preferences));
}

class WotApp extends StatelessWidget {
  const WotApp(this._wot, this._preferences, {super.key});

  final WoT _wot;

  final SharedPreferencesAsync _preferences;

  @override
  Widget build(BuildContext context) {
    const title = "Voltage Monitor";

    const thingwebPrimary = Color(0x00067362);
    const thingwebSecondary = Color(0x00B84A91);

    final colorScheme = SeedColorScheme.fromSeeds(
      brightness: Brightness.light,
      primaryKey: thingwebPrimary,
      secondaryKey: thingwebSecondary,
      tones: FlexTones.vivid(Brightness.light),
    );

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: title,
      theme: ThemeData(
        colorScheme: colorScheme,
      ),
      routerConfig: GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => HomePage(
              _wot,
              _preferences,
              title: title,
            ),
          ),
          GoRoute(
            path: "/settings",
            builder: (context, state) => SettingsPage(_preferences),
          ),
          GoRoute(
            path: '/graph',
            builder: (context, state) {
              final data = state.extra;

              if (data is! GraphData) {
                throw StateError("Got $data, ${data.runtimeType}");
              }

              return GraphPage(
                _wot,
                data.thingDescription,
                data.propertyName,
                title: title,
              );
            },
          ),
        ],
      ),
    );
  }
}
