// Copyright 2024 Contributors to the Eclipse Foundation. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import 'package:dart_wot/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_settings_ui/flutter_settings_ui.dart';
import 'package:go_router/go_router.dart';

import '../providers/discovery_settings_provider.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({
    super.key,
  });

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  SettingsTile _createSettingsSectionTitle(
    String sectionTitle,
    DiscoveryMethod discoveryMethod,
  ) {
    final methodEnabled =
        ref.watch(discoveryMethodEnabledProvider(discoveryMethod));

    return SettingsTile.switchTile(
      title: Text('Use $sectionTitle'),
      leading: const Icon(Icons.navigation),
      onToggle: (bool value) async {
        await ref
            .read(discoveryMethodEnabledProvider(discoveryMethod).notifier)
            .toggle();
      },
      initialValue: methodEnabled.value,
    );
  }

  SettingsTile _createBooleanSettingsTile(
    AsyncNotifierFamilyProvider booleanProvider,
    String label,
  ) {
    final settingEnabled = ref.watch(booleanProvider);

    return SettingsTile.switchTile(
      title: Text(label),
      leading: const Icon(Icons.navigation),
      onToggle: (bool value) async {
        final notifier =
            ref.read(booleanProvider.notifier) as BooleanSettingNotifier;
        await notifier.toggle();
      },
      initialValue: settingEnabled.value,
    );
  }

  SettingsSection _createUrlSettingsSection(
    String sectionTitle,
    DiscoveryMethod discoveryMethod,
  ) {
    final methodEnabled =
        ref.watch(discoveryMethodEnabledProvider(discoveryMethod));
    final discoveryUrls = ref.watch(discoveryUrlProvider(discoveryMethod));

    return SettingsSection(
      title: Text(sectionTitle),
      tiles: [
        _createSettingsSectionTitle(sectionTitle, discoveryMethod),
        if (methodEnabled.value == true)
          SettingsTile.navigation(
            title: const Text('Add Discovery URL'),
            leading: const Icon(Icons.add),
            onPressed: (context) {
              context.push(
                "/form",
                extra: (
                  discoveryMethod: discoveryMethod,
                  initialUrl: null,
                ),
              );
            },
          ),
        if (methodEnabled.value == true)
          ...(discoveryUrls.value ?? <Uri>[]).map(
            (uri) => SettingsTile(
              leading: const Icon(Icons.link),
              title: Text(uri.toString()),
              trailing: IconButton(
                onPressed: () {
                  final notifier =
                      ref.read(discoveryUrlProvider(discoveryMethod).notifier);

                  notifier.remove(uri);
                },
                icon: const Icon(Icons.remove),
                tooltip: "Remove Discovery URL",
              ),
              onPressed: (context) {
                context.push(
                  "/form",
                  extra: (
                    discoveryMethod: discoveryMethod,
                    initialUrl: uri,
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final mdnsEnabled =
        ref.watch(discoveryMethodEnabledProvider(DiscoveryMethod.mdns)).value ??
            false;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: SettingsList(
        sections: [
          _createUrlSettingsSection(
            "Direct Discovery",
            DiscoveryMethod.direct,
          ),
          _createUrlSettingsSection(
            "Directory Discovery",
            DiscoveryMethod.directory,
          ),
          SettingsSection(
            tiles: [
              _createSettingsSectionTitle("DNS-SD", DiscoveryMethod.mdns),
              if (mdnsEnabled)
                _createBooleanSettingsTile(
                  mdnsConfigurationProvider(ProtocolType.tcp),
                  "HTTP-based Discovery",
                ),
              if (mdnsEnabled)
                _createBooleanSettingsTile(
                  mdnsConfigurationProvider(ProtocolType.udp),
                  "CoAP-based Discovery",
                ),
            ],
          )
        ],
      ),
    );
  }
}
