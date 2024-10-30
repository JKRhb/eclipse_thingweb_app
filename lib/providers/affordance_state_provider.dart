// Copyright 2024 Contributors to the Eclipse Foundation. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import 'package:flutter_riverpod/flutter_riverpod.dart';

final affordanceStateHistoryProvider = StateNotifierProvider.family<
    AffordanceHistoryState,
    List<(int, Object?)>,
    ({
      String thingDescriptionId,
      String affordanceKey,
    })>(
  (ref, parameters) {
    final (:thingDescriptionId, :affordanceKey) = parameters;
    return AffordanceHistoryState(
      ref,
      thingDescriptionId,
      affordanceKey,
    );
  },
);

class AffordanceHistoryState extends StateNotifier<List<(int, Object?)>> {
  AffordanceHistoryState(
    this.ref,
    this.thingDescriptionId,
    this.affordanceKey,
  ) : super([]);

  final String thingDescriptionId;

  final String affordanceKey;

  final Ref ref;

  void update(Object? value) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;

    state = [...state, (timestamp, value)];
  }
}
