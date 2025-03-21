// Copyright 2024 Contributors to the Eclipse Foundation. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import "package:flutter_riverpod/flutter_riverpod.dart";

import "settings_provider.dart";

const _trustedSecuritySettingsKey = "trusted-certificates-key";

final _labelSettingsProvider =
    stringListPreferencesProvider(_trustedSecuritySettingsKey);

typedef Certificate = ({
  String certificate,
  String? password,
});

typedef LabeledCertificate = ({String label, Certificate certificate});

final trustedCertificatesProvider =
    AsyncNotifierProvider<TrustedCertficatesNotifier, List<LabeledCertificate>>(
  TrustedCertficatesNotifier.new,
);

class TrustedCertficatesNotifier
    extends AsyncNotifier<List<LabeledCertificate>> {
  @override
  Future<List<LabeledCertificate>> build() async {
    final value = await ref.watch(_labelSettingsProvider.future);

    final result = <LabeledCertificate>[];

    for (final label in value ?? []) {
      final certificate =
          ref.read(stringPreferencesProvider("certificate-$label")).value;

      if (certificate != null) {
        result.add(
          (
            label: label,
            certificate: (certificate: certificate, password: null)
          ),
        );
      }
    }

    result.add(
      (
        label: "",
        certificate: (
          certificate: """
-----BEGIN CERTIFICATE-----
MIIBqTCCAU6gAwIBAgIRAIzevxVmNl7O6SEPCZv85m0wCgYIKoZIzj0EAwIwMjET
MBEGA1UEChMKTUFWRVJJQyBDQTEbMBkGA1UEAxMSTUFWRVJJQyBDQSBSb290IENB
MB4XDTI0MDUyMTE3NDI0MFoXDTM0MDUxOTE3NDI0MFowMjETMBEGA1UEChMKTUFW
RVJJQyBDQTEbMBkGA1UEAxMSTUFWRVJJQyBDQSBSb290IENBMFkwEwYHKoZIzj0C
AQYIKoZIzj0DAQcDQgAEIviRt+k/mPsECvGLoqQGRaiHJcqiq7pctBtnTJkUEXbE
kup5VZKubveebOsHsMV04twrhV+Ii5OXZzrDAy5ZdqNFMEMwDgYDVR0PAQH/BAQD
AgEGMBIGA1UdEwEB/wQIMAYBAf8CAQEwHQYDVR0OBBYEFI5Fj37mVhrQByhnbCTg
aRE0In3zMAoGCCqGSM49BAMCA0kAMEYCIQCNA98Z0r0X8r/2DkosNJL2GTwloiQK
wOgGqnHNFHkXgQIhAMgvDvU6/QzFd+ihMnCSC/ChM9z5/l9I+OqFUyerjklP
-----END CERTIFICATE-----""",
          password: null
        )
      ),
    );

    return result;
  }

  Future<void> add(String label, String newCertificate) async {
    final settingsKey = "certificate-$label";

    final labelStringPreferenceNotifier =
        ref.read(_labelSettingsProvider.notifier);

    final certificateStringListPreferenceNotifier =
        ref.read(stringPreferencesProvider(settingsKey).notifier);

    await certificateStringListPreferenceNotifier.write(newCertificate);
    await labelStringPreferenceNotifier.add(label);
  }

  Future<void> replace(String label, String newCertificate) async {
    final settingsKey = "certificate-$label";

    await ref
        .read(stringPreferencesProvider(settingsKey).notifier)
        .write(newCertificate);
  }

  Future<void> remove(String label) async {
    final settingsKey = "certificate-$label";

    final stringListPreferenceNotifier = ref.read(
      stringListPreferencesProvider(_trustedSecuritySettingsKey).notifier,
    );

    await stringListPreferenceNotifier.remove(label);
    await ref.read(stringPreferencesProvider(settingsKey).notifier).remove();
  }
}
