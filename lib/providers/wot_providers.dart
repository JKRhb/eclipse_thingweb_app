import "dart:convert";

import "package:dart_wot/binding_coap.dart";
import "package:dart_wot/binding_http.dart";
import "package:dart_wot/binding_mqtt.dart";
import "package:dart_wot/core.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "security_settings_provider.dart";

final httpClientConfigProvider = FutureProvider.autoDispose((ref) async {
  final labeledCertificates =
      await ref.watch(trustedCertificatesProvider.future);

  return HttpClientConfig(
    trustedCertificates: labeledCertificates
        .map(
          (labeledCertificate) => (
            certificate:
                utf8.encode(labeledCertificate.certificate.certificate),
            password: labeledCertificate.certificate.password
          ),
        )
        .toList(),
  );
});

final wotProvider = FutureProvider.autoDispose((ref) async {
  final httpClientConfig = await ref.watch(httpClientConfigProvider.future);

  final servient = Servient.create(
    clientFactories: [
      CoapClientFactory(),
      MqttClientFactory(),
      HttpClientFactory(
        httpClientConfig: httpClientConfig,
      ),
    ],
  );

  return servient.start();
});

final consumedThingProvider = FutureProvider.autoDispose
    .family<ConsumedThing, ThingDescription>((ref, thingDescription) async {
  final wot = await ref.watch(wotProvider.future);

  return wot.consume(thingDescription);
});
