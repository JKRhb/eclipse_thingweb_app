// Copyright 2024 Contributors to the Eclipse Foundation. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import 'package:eclipse_thingweb_app/providers/settings_provider.dart';
import 'package:eclipse_thingweb_app/widgets/input_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_settings_ui/flutter_settings_ui.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({
    super.key,
  });

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  _SettingsPageState();

  static String _formatDiscoveryUrl(String? discoveryUrl) {
    const maxUrlLength = 20;

    if (discoveryUrl == null) {
      return "Unset";
    }

    if (discoveryUrl.length > maxUrlLength) {
      return "${discoveryUrl.substring(0, maxUrlLength)}...";
    }

    return discoveryUrl;
  }

  @override
  Widget build(BuildContext context) {
    final discoveryUrl = ref.watch(discoverUrlProvider);
    final discoveryMethod = ref.watch(discoverMethodProvider);

    const settingsTileColor = Colors.blueGrey;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: SettingsList(
        lightTheme:
            const SettingsThemeData(settingsListBackground: Colors.white),
        sections: [
          SettingsSection(
            tiles: [
              SettingsTile(
                backgroundColor: settingsTileColor,
                title: const Text('Discovery URL'),
                trailing: switch (discoveryUrl) {
                  AsyncData(:final value) => Text(_formatDiscoveryUrl(value)),
                  AsyncError(:final error) => Text('Error occurred: $error'),
                  _ => const CircularProgressIndicator(),
                },
                leading: const Icon(Icons.link),
                onPressed: (BuildContext context) async {
                  final currentValue =
                      await ref.read(discoverUrlProvider.future);

                  final result = await _openDialog(
                    "Enter a Discovery URL",
                    currentValue,
                    validator: (value) {
                      final parsedUrl = Uri.tryParse(value ?? "");

                      if (parsedUrl == null) {
                        return "Please enter a valid URL";
                      }

                      return null;
                    },
                  );

                  final notifier = ref.read(discoverUrlProvider.notifier);

                  if (result == null) {
                    notifier.remove();
                    return;
                  }

                  notifier.write(result);
                },
              ),
              SettingsTile(
                backgroundColor: settingsTileColor,
                title: const Text('Discovery Method'),
                leading: const Icon(Icons.language),
                trailing: switch (discoveryMethod) {
                  AsyncData(:final value) => DropdownButton<String>(
                      style: Theme.of(context).textTheme.bodyMedium,
                      value: value,
                      onChanged: (String? newValue) async {
                        final notifier =
                            ref.read(discoverMethodProvider.notifier);

                        if (newValue != null) {
                          await notifier.write(newValue);

                          return;
                        }

                        await notifier.remove();
                      },
                      items: <String>['Direct', 'Directory']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ), //=> Text(_formatDiscoveryUrl(value)),
                  AsyncError(:final error) => Text('Error occurred: $error'),
                  _ => const CircularProgressIndicator(),
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<String?> _openDialog(
    String dialogTitle,
    String? initialValue, {
    String? Function(String?)? validator,
  }) =>
      showDialog<String>(
        context: context,
        builder: (context) => Dialog(
          child: SizedBox(
            height: 200,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    dialogTitle,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const Spacer(),
                  InputForm(
                    initialValue: initialValue,
                    submitCallback: (value) {
                      Navigator.of(context).pop(value);
                    },
                    cancelCallback: (value) {
                      Navigator.of(context).pop(value);
                    },
                    validator: validator,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}
