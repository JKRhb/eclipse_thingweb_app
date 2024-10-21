import 'package:ecplise_thingweb_demo_app/main.dart';
import 'package:ecplise_thingweb_demo_app/widgets/url_input_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_settings_ui/flutter_settings_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

const defaultUrl =
    "https://gist.githubusercontent.com/JKRhb/a96353072d3e8e7bbf806421ea85e570/raw/e2c3123897f387dff592fa65fb23aa3c5a48177a/voltage-meter.td.json";

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

  String? _discoveryMethod;

  String? _discoveryUrl;

  late Future<String?> _discoveryMethodFuture;

  late Future<String?> _discoveryUrlFuture;

  @override
  void initState() {
    super.initState();

    _discoveryMethodFuture =
        widget._preferencesAsync.getString(discoveryMethodSettingsKey);
    _discoveryUrlFuture =
        widget._preferencesAsync.getString(discoveryUrlSettingsKey);
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
                  future: _discoveryUrlFuture,
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

                      final currentDiscoveryUrl =
                          _discoveryUrl ?? snapshot.data;

                      return SizedBox(
                        width: 150,
                        child: Text(
                          currentDiscoveryUrl ?? "Unset",
                          softWrap: true,
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }
                  },
                ),
                leading: const Icon(Icons.link),
                onPressed: (BuildContext context) async {
                  final result = await _openDialog();

                  if (result == _discoveryUrl) {
                    return;
                  }

                  setState(() {
                    if (result?.isEmpty ?? true) {
                      _discoveryUrl = null;
                      return;
                    }
                  });
                  _discoveryUrl = result;

                  if (result == null) {
                    await widget._preferencesAsync
                        .remove(discoveryUrlSettingsKey);
                    return;
                  }

                  await widget._preferencesAsync.setString(
                    discoveryUrlSettingsKey,
                    result,
                  );
                },
              ),
              SettingsTile(
                title: const Text('Discovery Method'),
                leading: const Icon(Icons.language),
                trailing: FutureBuilder(
                  future: _discoveryMethodFuture,
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

                      final currentDiscoveryMethod =
                          _discoveryMethod ?? snapshot.data;

                      return DropdownButton<String>(
                        value: currentDiscoveryMethod,
                        onChanged: (String? newValue) async {
                          setState(() {
                            _discoveryMethod = newValue;
                          });

                          if (newValue == null) {
                            await widget._preferencesAsync
                                .remove(discoveryMethodSettingsKey);
                            return;
                          }

                          await widget._preferencesAsync.setString(
                            discoveryMethodSettingsKey,
                            newValue,
                          );
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
              )
            ],
          ),
        ],
      ),
    );
  }

  Future<String?> _openDialog() => showDialog<String>(
        context: context,
        builder: (context) => Dialog(
          child: SizedBox(
            height: 200,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  const Text(
                    "Enter a URL",
                    style: TextStyle(fontSize: 20),
                  ),
                  const Spacer(),
                  UrlInputForm(
                    initialValue: _discoveryUrl,
                    submitCallback: (value) {
                      Navigator.of(context).pop(value);
                    },
                    cancelCallback: (value) {
                      Navigator.of(context).pop(value);
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}
