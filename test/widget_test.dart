// Copyright 2024 Contributors to the Eclipse Foundation. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import 'package:dart_wot/core.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:eclipse_thingweb_app/main.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    final servient = Servient.create();
    final wot = await servient.start();
    final preferences = SharedPreferencesAsync();

    // Build our app and trigger a frame.
    await tester.pumpWidget(WotApp(wot, preferences));
  });
}
