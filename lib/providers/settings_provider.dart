// Copyright 2024 Contributors to the Eclipse Foundation. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

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

  Future<void> remove() async {
    await preferences.remove(arg);
    state = const AsyncData(null);
  }

  Future<void> write(bool value) async {
    await preferences.setBool(arg, value);
    state = AsyncData(value);
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

  Future<void> remove() async {
    await preferences.remove(arg);
    state = const AsyncData(null);
  }

  Future<void> write(double value) async {
    await preferences.setDouble(arg, value);
    state = AsyncData(value);
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

  Future<void> remove() async {
    await preferences.remove(arg);
    state = const AsyncData(null);
  }

  Future<void> write(int value) async {
    await preferences.setInt(arg, value);
    state = AsyncData(value);
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
    await preferences.remove(arg);
    state = const AsyncData(null);
  }

  Future<void> write(String value) async {
    await preferences.setString(arg, value);
    state = AsyncData(value);
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

  Future<void> remove() async {
    await preferences.remove(arg);
    state = const AsyncData(null);
  }

  Future<void> write(List<String> value) async {
    await preferences.setStringList(arg, value);
    state = AsyncData(value);
  }
}

typedef DiscoveryPreferences = ({
  String? discoveryUrl,
  String? discoveryMethod,
});

final discoverMethodProvider =
    stringPreferencesProvider("discovery-method-key");

final discoverUrlProvider = stringPreferencesProvider("discovery-url-key");

final discoverySettingsProvider =
    FutureProvider.autoDispose<DiscoveryPreferences>((ref) async {
  final discoveryUrl = await ref.watch(discoverUrlProvider.future);
  final discoveryMethod = await ref.watch(discoverMethodProvider.future);

  return (discoveryUrl: discoveryUrl, discoveryMethod: discoveryMethod);
});
