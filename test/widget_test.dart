// Copyright 2024 Contributors to the Eclipse Foundation. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import "package:eclipse_thingweb_app/main.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:flutter_test/flutter_test.dart";

void main() {
  testWidgets("Basic app test", (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: WotApp(),
      ),
    );
  });
}
