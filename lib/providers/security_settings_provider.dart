// Copyright 2024 Contributors to the Eclipse Foundation. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import 'dart:convert';

import 'package:eclipse_thingweb_app/providers/settings_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _trustedSecuritySettingsKey = "trusted-certificates";

typedef Certificate = ({
  List<int> certificate,
  String? password,
});

final trustedCertificatesProvider =
    AsyncNotifierProvider<TrustedCertficatesNotifier, List<Certificate>>(
        TrustedCertficatesNotifier.new);

class TrustedCertficatesNotifier extends AsyncNotifier<List<Certificate>> {
  @override
  Future<List<Certificate>> build() async {
    final value = await ref.watch(
        stringListPreferencesProvider(_trustedSecuritySettingsKey).future);

    return value
            ?.map(
              (certificate) => (
                certificate: utf8.encode(certificate).toList(),
                password: null
              ),
            )
            .toList() ??
        [];
  }

  Future<void> add(String certificate) async {
    final stringListPreferenceNotifier = ref.read(
        stringListPreferencesProvider(_trustedSecuritySettingsKey).notifier);
    await stringListPreferenceNotifier.add(certificate);
  }

  Future<void> replace(String oldCertificate, String newCertificate) async {
    final stringListPreferenceNotifier = ref.read(
        stringListPreferencesProvider(_trustedSecuritySettingsKey).notifier);

    await stringListPreferenceNotifier.replace(oldCertificate, newCertificate);
  }

  Future<void> remove(String certificate) async {
    final stringListPreferenceNotifier = ref.read(
        stringListPreferencesProvider(_trustedSecuritySettingsKey).notifier);

    await stringListPreferenceNotifier.remove(certificate);
  }
}
