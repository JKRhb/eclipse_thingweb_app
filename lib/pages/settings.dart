// Copyright 2024 Contributors to the Eclipse Foundation. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import 'package:eclipse_thingweb_app/main.dart';
import 'package:eclipse_thingweb_app/widgets/input_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_settings_ui/flutter_settings_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage(
    this._preferencesAsync, {
    super.key,
  });

  final SharedPreferencesAsync _preferencesAsync;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  _SettingsPageState();

  late Future<String?> _discoveryMethod;

  late Future<String?> _discoveryUrl;

  late Future<String?> _propertyName;

  @override
  void initState() {
    super.initState();

    _discoveryMethod =
        widget._preferencesAsync.getString(discoveryMethodSettingsKey);
    _discoveryUrl = widget._preferencesAsync.getString(discoveryUrlSettingsKey);
    _propertyName = widget._preferencesAsync.getString(propertyNameSettingsKey);
  }

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
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: SettingsList(
        sections: [
          SettingsSection(
            tiles: [
              SettingsTile(
                title: const Text('Discovery URL'),
                trailing: FutureBuilder(
                  future: _discoveryUrl,
                  builder: (
                    context,
                    snapshot,
                  ) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    } else {
                      if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      }

                      final currentDiscoveryUrl = snapshot.data;
                      final formattedDiscoveryUrl =
                          _formatDiscoveryUrl(currentDiscoveryUrl);

                      return Text(formattedDiscoveryUrl);
                    }
                  },
                ),
                leading: const Icon(Icons.link),
                onPressed: (BuildContext context) async {
                  final currentValue = await widget._preferencesAsync
                      .getString(discoveryUrlSettingsKey);

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

                  if (result == null) {
                    await widget._preferencesAsync
                        .remove(discoveryUrlSettingsKey);

                    setState(() {
                      _discoveryUrl = Future.value(null);
                    });
                    return;
                  }

                  await widget._preferencesAsync.setString(
                    discoveryUrlSettingsKey,
                    result,
                  );

                  setState(() {
                    _discoveryUrl = Future.value(result);
                  });
                },
              ),
              SettingsTile(
                title: const Text('Discovery Method'),
                leading: const Icon(Icons.language),
                trailing: FutureBuilder(
                  future: _discoveryMethod,
                  builder: (
                    context,
                    snapshot,
                  ) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    } else {
                      if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      }

                      final currentDiscoveryMethod = snapshot.data;

                      return DropdownButton<String>(
                        style: Theme.of(context).textTheme.bodyMedium,
                        value: currentDiscoveryMethod,
                        onChanged: (String? newValue) async {
                          if (newValue == null) {
                            await widget._preferencesAsync
                                .remove(discoveryMethodSettingsKey);

                            setState(() {
                              _discoveryMethod =
                                  Future.value(defaultDiscoveryMethod);
                            });
                            return;
                          }

                          await widget._preferencesAsync.setString(
                            discoveryMethodSettingsKey,
                            newValue,
                          );

                          setState(() {
                            _discoveryMethod = Future.value(newValue);
                          });
                        },
                        items: <String>['Direct', 'Directory']
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      );
                    }
                  },
                ),
              ),
              SettingsTile(
                title: const Text('Property Name'),
                leading: const Icon(Icons.featured_play_list),
                trailing: FutureBuilder(
                  future: _propertyName,
                  builder: (
                    context,
                    snapshot,
                  ) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    } else {
                      if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      }

                      final currentPropertyName = snapshot.data;

                      return Text(
                        currentPropertyName ?? "Unset",
                        softWrap: true,
                        overflow: TextOverflow.ellipsis,
                      );
                    }
                  },
                ),
                onPressed: (BuildContext context) async {
                  final currentValue = await widget._preferencesAsync
                      .getString(propertyNameSettingsKey);

                  final result = await _openDialog(
                    "Enter a Property Name",
                    currentValue,
                  );

                  if (result == null) {
                    await widget._preferencesAsync
                        .remove(propertyNameSettingsKey);

                    setState(() {
                      _propertyName = Future.value(null);
                    });
                    return;
                  }

                  await widget._preferencesAsync.setString(
                    propertyNameSettingsKey,
                    result,
                  );

                  setState(() {
                    _propertyName = Future.value(result);
                  });
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
