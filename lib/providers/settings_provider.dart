// Copyright 2024 Contributors to the Eclipse Foundation. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import 'package:eclipse_thingweb_app/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final preferences = SharedPreferencesAsync();

final booleanPreferencesProvider =
    AsyncNotifierProvider.family<BooleanPreferenceNotifier, bool?, String>(
        BooleanPreferenceNotifier.new);

class BooleanPreferenceNotifier extends FamilyAsyncNotifier<bool?, String> {
  @override
  Future<bool?> build(String arg) async {
    return preferences.getBool(arg);
  }
}

final doublePreferencesProvider =
    AsyncNotifierProvider.family<DoublePreferenceNotifier, double?, String>(
        DoublePreferenceNotifier.new);

class DoublePreferenceNotifier extends FamilyAsyncNotifier<double?, String> {
  @override
  Future<double?> build(String arg) async {
    return preferences.getDouble(arg);
  }
}

final integerPreferencesProvider =
    AsyncNotifierProvider.family<IntegerPreferenceNotifier, int?, String>(
        IntegerPreferenceNotifier.new);

class IntegerPreferenceNotifier extends FamilyAsyncNotifier<int?, String> {
  @override
  Future<int?> build(String arg) async {
    return preferences.getInt(arg);
  }
}

final stringPreferencesProvider =
    AsyncNotifierProvider.family<StringPreferenceNotifier, String?, String>(
        StringPreferenceNotifier.new);

class StringPreferenceNotifier extends FamilyAsyncNotifier<String?, String> {
  @override
  Future<String?> build(String arg) async {
    return preferences.getString(arg);
  }

  Future<void> remove() async {
    // TODO: Refactor
    await preferences.remove(arg);
    state = const AsyncData(null);
  }

  Future<void> write(String result) async {
    // TODO: Refactor
    await preferences.setString(arg, result);
    state = AsyncData(result);
  }
}

final stringListPreferencesProvider = AsyncNotifierProvider.family<
    StringListPreferenceNotifier,
    List<String>?,
    String>(StringListPreferenceNotifier.new);

class StringListPreferenceNotifier
    extends FamilyAsyncNotifier<List<String>?, String> {
  @override
  Future<List<String>?> build(String arg) async {
    return preferences.getStringList(arg);
  }
}

typedef DiscoveryPreferences = ({
  String? discoveryUrl,
  String? discoveryMethod,
});

final discoverySettingsProvider =
    FutureProvider.autoDispose<DiscoveryPreferences>((ref) async {
  final discoveryUrl = await ref
      .watch(stringPreferencesProvider(discoveryUrlSettingsKey).future);
  final discoveryMethod = await ref
      .watch(stringPreferencesProvider(discoveryMethodSettingsKey).future);

  return (discoveryUrl: discoveryUrl, discoveryMethod: discoveryMethod);
});
