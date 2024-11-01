// Copyright 2024 Contributors to the Eclipse Foundation. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final _preferences = SharedPreferencesAsync();

final booleanPreferencesProvider =
    AsyncNotifierProvider.family<BooleanPreferenceNotifier, bool?, String>(
        BooleanPreferenceNotifier.new);

class BooleanPreferenceNotifier extends FamilyAsyncNotifier<bool?, String> {
  @override
  Future<bool?> build(String arg) async {
    return _preferences.getBool(arg);
  }

  Future<void> remove() async {
    await _preferences.remove(arg);
    state = const AsyncData(null);
  }

  Future<void> write(bool value) async {
    await _preferences.setBool(arg, value);
    state = AsyncData(value);
  }
}

final doublePreferencesProvider =
    AsyncNotifierProvider.family<DoublePreferenceNotifier, double?, String>(
        DoublePreferenceNotifier.new);

class DoublePreferenceNotifier extends FamilyAsyncNotifier<double?, String> {
  @override
  Future<double?> build(String arg) async {
    return _preferences.getDouble(arg);
  }

  Future<void> remove() async {
    await _preferences.remove(arg);
    state = const AsyncData(null);
  }

  Future<void> write(double value) async {
    await _preferences.setDouble(arg, value);
    state = AsyncData(value);
  }
}

final integerPreferencesProvider =
    AsyncNotifierProvider.family<IntegerPreferenceNotifier, int?, String>(
        IntegerPreferenceNotifier.new);

class IntegerPreferenceNotifier extends FamilyAsyncNotifier<int?, String> {
  @override
  Future<int?> build(String arg) async {
    return _preferences.getInt(arg);
  }

  Future<void> remove() async {
    await _preferences.remove(arg);
    state = const AsyncData(null);
  }

  Future<void> write(int value) async {
    await _preferences.setInt(arg, value);
    state = AsyncData(value);
  }
}

final stringPreferencesProvider =
    AsyncNotifierProvider.family<StringPreferenceNotifier, String?, String>(
        StringPreferenceNotifier.new);

class StringPreferenceNotifier extends FamilyAsyncNotifier<String?, String> {
  @override
  Future<String?> build(String arg) async {
    return _preferences.getString(arg);
  }

  Future<void> remove() async {
    await _preferences.remove(arg);
    state = const AsyncData(null);
  }

  Future<void> write(String value) async {
    await _preferences.setString(arg, value);
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
    return _preferences.getStringList(arg);
  }

  Future<void> clear() async {
    await _preferences.remove(arg);
    state = const AsyncData(null);
  }

  Future<void> write(List<String> value) async {
    await _preferences.setStringList(arg, value);
    state = AsyncData(value);
  }

  Future<void> add(String value) async {
    final currentValues = (await _preferences.getStringList(arg)) ?? [];

    final newValues = [...currentValues, value];

    await write(newValues);
  }

  Future<void> replace(String existingValue, String newValue) async {
    final currentValues = (await _preferences.getStringList(arg)) ?? [];

    final newValues = [
      for (final value in currentValues)
        if (value == existingValue) newValue else value,
    ];

    await write(newValues);
  }

  Future<void> remove(String value) async {
    final currentValues = await _preferences.getStringList(arg);

    final newValue =
        currentValues?.where((element) => element != value).toList() ?? [];

    await write(newValue);
  }
}
