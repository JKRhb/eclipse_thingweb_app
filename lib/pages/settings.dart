// Copyright 2024 Contributors to the Eclipse Foundation. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

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
  _SettingsPageState();

  @override
  Widget build(BuildContext context) {
    final directMethodEnabled =
        ref.watch(discoveryMethodEnabledProvider(DiscoveryMethod.direct));
    final directDiscoveryUrls =
        ref.watch(discoveryUrlProvider(DiscoveryMethod.direct));

    final directoryMethodEnabled =
        ref.watch(discoveryMethodEnabledProvider(DiscoveryMethod.directory));
    final directoryDiscoveryUrls =
        ref.watch(discoveryUrlProvider(DiscoveryMethod.directory));

    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: SettingsList(
        sections: [
          SettingsSection(
            title: const Text("Direct Discovery"),
            tiles: [
              SettingsTile.switchTile(
                title: const Text('Use Direct Discovery'),
                leading: const Icon(Icons.navigation),
                onToggle: (bool value) async {
                  await ref
                      .read(
                          discoveryMethodEnabledProvider(DiscoveryMethod.direct)
                              .notifier)
                      .toggle();
                },
                initialValue: directMethodEnabled.value,
              ),
              SettingsTile.navigation(
                title: const Text('Add Discovery URL'),
                leading: const Icon(Icons.add),
                onPressed: (context) {
                  context.push(
                    "/form",
                    extra: DiscoveryMethod.direct,
                  );
                },
              ),
              ...(directDiscoveryUrls.value ?? <Uri>[]).map(
                (uri) => SettingsTile(
                  leading: const Icon(Icons.link),
                  title: Text(uri.toString()),
                  trailing: IconButton(
                    onPressed: () {
                      final notifier = ref.read(
                          discoveryUrlProvider(DiscoveryMethod.direct)
                              .notifier);

                      notifier.remove(uri);
                    },
                    icon: const Icon(Icons.remove),
                  ),
                ),
              ),
            ],
          ),
          SettingsSection(
            title: const Text("Directory Discovery"),
            tiles: [
              SettingsTile.switchTile(
                title: const Text('Use Directory Discovery'),
                leading: const Icon(Icons.navigation),
                onToggle: (bool value) async {
                  await ref
                      .read(discoveryMethodEnabledProvider(
                              DiscoveryMethod.directory)
                          .notifier)
                      .toggle();
                },
                initialValue: directoryMethodEnabled.value,
              ),
              SettingsTile.navigation(
                onPressed: (context) {
                  context.push(
                    "/form",
                    extra: DiscoveryMethod.directory,
                  );
                },
                title: const Text('Add Discovery URL'),
                leading: const Icon(Icons.add),
              ),
              ...(directoryDiscoveryUrls.value ?? <Uri>[]).map(
                (uri) => SettingsTile(
                  leading: const Icon(Icons.link),
                  title: Text(uri.toString()),
                  trailing: IconButton(
                    onPressed: () {
                      final notifier = ref.read(
                          discoveryUrlProvider(DiscoveryMethod.directory)
                              .notifier);

                      notifier.remove(uri);
                    },
                    icon: const Icon(Icons.remove),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
