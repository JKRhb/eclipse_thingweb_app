// Copyright 2024 Contributors to the Eclipse Foundation. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import 'package:flutter_riverpod/flutter_riverpod.dart';

final affordanceStateProvider = StateNotifierProvider.family<
    AffordanceState,
    Object?,
    ({
      String thingDescriptionId,
      String affordanceKey,
    })>(
  (ref, parameters) {
    final (:thingDescriptionId, :affordanceKey) = parameters;
    return AffordanceState(
      ref,
      thingDescriptionId,
      affordanceKey,
    );
  },
);

class AffordanceState extends StateNotifier<Object?> {
  AffordanceState(
    this.ref,
    this.thingDescriptionId,
    this.affordanceKey,
  ) : super(null);

  final String thingDescriptionId;

  final String affordanceKey;

  final Ref ref;

  void update(Object? value) {
    state = value;
  }
}
