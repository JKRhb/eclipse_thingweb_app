import 'package:flutter/material.dart';
import 'package:flutter_settings_ui/flutter_settings_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage(this._preferences, {super.key});

  final SharedPreferences _preferences;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: const Color(0xFFFFFFFF),
        title: const Text("Settings"),
        // TODO: Fix theme color
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: SettingsList(
        sections: [
          SettingsSection(
            title: const Text('Section'),
            tiles: [
              SettingsTile(
                title: const Text('Language'),
                // subtitle: 'English',
                leading: const Icon(Icons.language),
                onPressed: (BuildContext context) {},
              ),
              SettingsTile.switchTile(
                title: const Text('Use fingerprint'),
                leading: const Icon(Icons.fingerprint),
                initialValue:
                    widget._preferences.getBool("use-fingerprint") ?? true,
                onToggle: (bool value) {
                  setState(() {
                    widget._preferences.setBool("use-fingerprint", value);
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
