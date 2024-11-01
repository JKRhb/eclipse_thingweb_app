// Copyright 2024 Contributors to the Eclipse Foundation. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import 'package:dart_wot/core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'settings_provider.dart';

enum DiscoveryMethod {
  direct,
  directory;

  String get discoveryMethodSettingsKey => "discoveryMethod:$name";

  String get discoveryUrlSettingsKey => "discoveryUrl:$name";
}

final discoveryMethodEnabledProvider = AsyncNotifierProvider.family<
    DiscoveryMethodEnabledNotifier,
    bool,
    DiscoveryMethod>(DiscoveryMethodEnabledNotifier.new);

class DiscoveryMethodEnabledNotifier
    extends FamilyAsyncNotifier<bool, DiscoveryMethod> {
  String get _settingsKey => arg.discoveryMethodSettingsKey;

  @override
  Future<bool> build(DiscoveryMethod arg) async {
    final value =
        await ref.watch(booleanPreferencesProvider(_settingsKey).future);

    return value ?? false;
  }

  Future<void> toggle() async {
    final provider = booleanPreferencesProvider(_settingsKey);

    final notifier = ref.read(provider.notifier);
    final value = (await ref.watch(provider.future)) ?? false;

    notifier.write(!value);
  }
}

final discoveryUrlProvider = AsyncNotifierProvider.family<DiscoveryUrlNotifier,
    List<Uri>, DiscoveryMethod>(DiscoveryUrlNotifier.new);

class DiscoveryUrlNotifier
    extends FamilyAsyncNotifier<List<Uri>, DiscoveryMethod> {
  String get _settingsKey => arg.discoveryUrlSettingsKey;

  @override
  Future<List<Uri>> build(DiscoveryMethod arg) async {
    final value =
        await ref.watch(stringListPreferencesProvider(_settingsKey).future);

    return value?.map(Uri.parse).toList() ?? [];
  }

  AsyncNotifierFamilyProvider<StringListPreferenceNotifier, List<String>?,
      String> get _provider => stringListPreferencesProvider(_settingsKey);

  StringListPreferenceNotifier get _notifier => ref.read(_provider.notifier);

  Future<void> add(Uri uri) async => await _notifier.add(uri.toString());

  Future<void> replace(Uri existingUri, Uri uri) async =>
      await _notifier.replace(
        existingUri.toString(),
        uri.toString(),
      );

  Future<void> remove(Uri uri) async => await _notifier.remove(uri.toString());
}

final discoveryConfigurationsProvider = FutureProvider((ref) async {
  final result = <DiscoveryConfiguration>[];

  final directDiscoveryEnabled = await ref
      .watch(discoveryMethodEnabledProvider(DiscoveryMethod.direct).future);
  final directoryDiscoveryEnabled = await ref
      .watch(discoveryMethodEnabledProvider(DiscoveryMethod.directory).future);

  if (directDiscoveryEnabled) {
    final directDiscoveryUrls =
        await ref.watch(discoveryUrlProvider(DiscoveryMethod.direct).future);

    result.addAll(directDiscoveryUrls.map((url) => DirectConfiguration(url)));
  }

  if (directoryDiscoveryEnabled) {
    final directoryDiscoveryUrls =
        await ref.watch(discoveryUrlProvider(DiscoveryMethod.directory).future);

    result.addAll(
      directoryDiscoveryUrls.map(
        // TODO: Also set the other parameters here
        (url) => ExploreDirectoryConfiguration(
          url,
        ),
      ),
    );
  }

  return result;
});
