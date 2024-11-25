// Copyright 2024 Contributors to the Eclipse Foundation. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import "package:flutter_riverpod/flutter_riverpod.dart";

enum AffordanceType {
  property,
  action,
  event,
  ;

  @override
  String toString() {
    switch (this) {
      case AffordanceType.property:
        return "Property";
      case AffordanceType.action:
        return "Action";
      case AffordanceType.event:
        return "Event";
    }
  }
}

final affordanceStateHistoryProvider = StateNotifierProvider.family<
    AffordanceHistoryState,
    List<(int, Object?)>,
    ({
      String thingDescriptionId,
      String affordanceKey,
      AffordanceType affordanceType,
    })>(
  (ref, parameters) {
    final (
      :thingDescriptionId,
      :affordanceKey,
      :affordanceType,
    ) = parameters;
    return AffordanceHistoryState(
      ref,
      thingDescriptionId,
      affordanceKey,
      affordanceType,
    );
  },
);

class AffordanceHistoryState extends StateNotifier<List<(int, Object?)>> {
  AffordanceHistoryState(
    this.ref,
    this.thingDescriptionId,
    this.affordanceKey,
    this.affordanceType,
  ) : super([]);

  final String thingDescriptionId;

  final String affordanceKey;

  final AffordanceType affordanceType;

  final Ref ref;

  void update(Object? value) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;

    state = [...state, (timestamp, value)];
  }
}
