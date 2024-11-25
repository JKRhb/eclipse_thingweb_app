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
  directory,
  mdns,
  ;

  String get discoveryMethodSettingsKey => "discoveryMethod:$name";

  String get discoveryUrlSettingsKey => "discoveryUrl:$name";
}

extension DiscoverySettingsKey on ProtocolType {
  String get protocolTypeSettingsKey => "protocolType:$name";
}

final discoveryMethodEnabledProvider = AsyncNotifierProvider.family<
    DiscoveryMethodEnabledNotifier,
    bool,
    DiscoveryMethod>(DiscoveryMethodEnabledNotifier.new);

class DiscoveryMethodEnabledNotifier
    extends BooleanSettingNotifier<DiscoveryMethod> {
  @override
  String get _settingsKey => arg.discoveryMethodSettingsKey;
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

final mdnsConfigurationProvider =
    AsyncNotifierProvider.family<MdnsConfigurationNotifier, bool, ProtocolType>(
        MdnsConfigurationNotifier.new);

abstract class BooleanSettingNotifier<T> extends FamilyAsyncNotifier<bool, T> {
  String get _settingsKey;

  @override
  Future<bool> build(T arg) async {
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

final class MdnsConfigurationNotifier
    extends BooleanSettingNotifier<ProtocolType> {
  @override
  String get _settingsKey => arg.protocolTypeSettingsKey;
}

final discoveryConfigurationsProvider = FutureProvider((ref) async {
  final result = <DiscoveryConfiguration>[];

  final directDiscoveryEnabled = await ref
      .watch(discoveryMethodEnabledProvider(DiscoveryMethod.direct).future);
  final directoryDiscoveryEnabled = await ref
      .watch(discoveryMethodEnabledProvider(DiscoveryMethod.directory).future);
  final mdnsDiscoveryEnabled = await ref
      .watch(discoveryMethodEnabledProvider(DiscoveryMethod.mdns).future);

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

  if (mdnsDiscoveryEnabled) {
    // TODO: Consider discovering TDDs in the future as well and allowing the
    //       setting of the other DNS-SD parameters.

    final mdnsCoapDiscoveryEnabled =
        await ref.watch(mdnsConfigurationProvider(ProtocolType.udp).future);
    final mdnsHttpDiscoveryEnabled =
        await ref.watch(mdnsConfigurationProvider(ProtocolType.udp).future);

    if (mdnsCoapDiscoveryEnabled) {
      result.add(
        const DnsSdDConfiguration(
          protocolType: ProtocolType.udp,
        ),
      );
    }

    if (mdnsHttpDiscoveryEnabled) {
      result.add(
        const DnsSdDConfiguration(),
      );
    }
  }

  return result;
});
