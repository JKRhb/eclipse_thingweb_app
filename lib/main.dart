// Copyright 2024 Contributors to the Eclipse Foundation. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import 'package:dart_wot/binding_coap.dart';
import 'package:dart_wot/binding_mqtt.dart';
import 'package:dart_wot/binding_http.dart';
import 'package:dart_wot/core.dart';
import 'package:eclipse_thingweb_app/pages/events.dart';
import 'package:eclipse_thingweb_app/pages/thing.dart';
import 'package:flex_seed_scheme/flex_seed_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'dart:developer';

import 'pages/home.dart';
import 'pages/settings.dart';

final wotProvider = FutureProvider.autoDispose((ref) async {
  final servient = Servient.create(clientFactories: [
    CoapClientFactory(),
    MqttClientFactory(),
    HttpClientFactory(),
  ]);

  return servient.start();
});

final consumedThingProvider = FutureProvider.autoDispose
    .family<ConsumedThing, ThingDescription>((ref, thingDescription) async {
  final wot = await ref.watch(wotProvider.future);

  return wot.consume(thingDescription);
});

Future<void> main() async {
  log("Starting app.");

  runApp(
    const ProviderScope(
      child: WotApp(),
    ),
  );
}

class WotApp extends StatelessWidget {
  const WotApp({super.key});

  @override
  Widget build(BuildContext context) {
    const title = "Eclipse Thingweb App";

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
            builder: (context, state) => const HomePage(
              title: title,
            ),
          ),
          GoRoute(
            path: "/settings",
            builder: (context, state) => const SettingsPage(),
          ),
          GoRoute(
            path: "/events",
            builder: (context, state) => const EventsPage(),
          ),
          GoRoute(
            path: '/thing',
            builder: (context, state) {
              final data = state.extra;

              if (data is! ThingDescription) {
                throw StateError(
                  "Expected Thing Description, got $data of type ${data.runtimeType}",
                );
              }

              return ThingPage(
                data,
              );
            },
          ),
        ],
      ),
    );
  }
}
