// Copyright 2024 Contributors to the Eclipse Foundation. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import "dart:developer";

import "package:dart_wot/core.dart";
import "package:flex_seed_scheme/flex_seed_scheme.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";

import "pages/events.dart";
import "pages/forms/discovery_uri_form.dart";
import "pages/forms/trusted_certificate_form.dart";
import "pages/home.dart";
import "pages/settings.dart";
import "pages/thing.dart";
import "providers/discovery_settings_provider.dart";
import "providers/security_settings_provider.dart";

Future<void> main() async {
  log("Starting app.");

  runApp(
    const ProviderScope(
      child: WotApp(),
    ),
  );
}

typedef _DiscoveryUriFormsParameter = ({
  DiscoveryMethod discoveryMethod,
  Uri? initialUrl,
});

class WotApp extends StatelessWidget {
  const WotApp({super.key});

  @override
  Widget build(BuildContext context) {
    const title = "Eclipse Thingweb App";

    const thingwebPrimary = Color(0x00067362);
    const thingwebSecondary = Color(0x00B84A91);

    final colorScheme = SeedColorScheme.fromSeeds(
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
            path: "/",
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
            path: "/form",
            builder: (context, state) {
              final discoveryParameters =
                  state.extra! as _DiscoveryUriFormsParameter;

              return DiscoveryUriFormsPage(
                discoveryParameters.discoveryMethod,
                initialUrl: discoveryParameters.initialUrl,
              );
            },
          ),
          GoRoute(
            path: "/certificate-form",
            builder: (context, state) {
              final existingCertificate = state.extra as LabeledCertificate?;

              return TrustedCertificateFormPage(
                "Add a Trusted Certificate",
                initialValue: existingCertificate,
              );
            },
          ),
          GoRoute(
            path: "/thing",
            builder: (context, state) {
              final data = state.extra! as ThingDescription;

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
