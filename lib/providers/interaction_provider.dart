// Copyright 2024 Contributors to the Eclipse Foundation. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import "package:dart_wot/core.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "affordance_state_provider.dart";

final readPropertyProvider = FutureProvider.autoDispose
    .family<Object?, (ConsumedThing, String)>((ref, input) async {
  final consumedThing = input.$1;
  final propertyName = input.$2;

  final interactionOutput = await consumedThing.readProperty(propertyName);
  final value = await interactionOutput.value();

  ref
      .read(
        affordanceStateHistoryProvider(
          (
            thingDescriptionId: consumedThing.thingDescription.id!,
            affordanceKey: propertyName,
            affordanceType: AffordanceType.property,
          ),
        ).notifier,
      )
      .update(value);

  return value;
});

final invokeActionProvider = FutureProvider.autoDispose
    .family<Object?, (ConsumedThing, String, InteractionInput?)>(
        (ref, input) async {
  final consumedThing = input.$1;
  final actionName = input.$2;
  final interactionInput = input.$3;

  final interactionOutput = await consumedThing.invokeAction(
    actionName,
    input: interactionInput,
  );
  final value = await interactionOutput.value();

  ref
      .read(
        affordanceStateHistoryProvider(
          (
            thingDescriptionId: consumedThing.thingDescription.id!,
            affordanceKey: actionName,
            affordanceType: AffordanceType.action,
          ),
        ).notifier,
      )
      .update(value);

  return value;
});
