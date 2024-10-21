import 'package:dart_wot/binding_mqtt.dart';
import 'package:dart_wot/binding_http.dart';
import 'package:dart_wot/core.dart';
import 'package:ecplise_thingweb_demo_app/pages/graph.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'pages/home.dart';
import 'pages/settings.dart';

const discoveryMethodSettingsKey = "discovery-method-key";
const discoveryUrlSettingsKey = "discovery-url-key";

final Map<String, BasicCredentials> basicCredentials = {
  "urn:test": const BasicCredentials("test-user", "Swampland-Submerge5-Catsup"),
};

Future<BasicCredentials?> basicCredentialsCallback(
  Uri uri,
  AugmentedForm? form, [
  BasicCredentials? invalidCredentials,
]) async {
  final id = form?.tdIdentifier;

  return basicCredentials[id];
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final servient = Servient.create(clientFactories: [
    MqttClientFactory(basicCredentialsCallback: basicCredentialsCallback),
    HttpClientFactory()
  ]);
  final wot = await servient.start();

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
    const thingwebColor = Color.fromRGBO(51, 184, 164, 0);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: title,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: thingwebColor,
        ),
        useMaterial3: true,
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
              })
        ],
      ),
    );
  }
}
