// Copyright 2024 Contributors to the Eclipse Foundation. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import "dart:async";

import "package:dart_wot/core.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../widgets/property_visualization.dart";
import "affordance_state_provider.dart";
import "event_notifications_provider.dart";

class PropertyStateNotifier
    extends FamilyAsyncNotifier<InteractionOutput?, (ConsumedThing, String)> {
  AsyncValue<InteractionOutput?>? _oldState;

  @override
  Future<InteractionOutput?> build((ConsumedThing, String) ref) async {
    return null;
  }

  void _setInteractionOutput(InteractionOutput interactionOutput) {
    state = AsyncData(interactionOutput);
  }

  void setTemporaryValue(InteractionOutput interactionOutput) {
    _oldState = state;
    state = AsyncData(interactionOutput);
  }

  void revertTemporaryValue() {
    final oldState = _oldState;
    if (oldState != null) {
      state = oldState;
      _oldState = null;
    }
  }

  Future<void> readProperty({bool addToHistory = false}) async {
    final consumedThing = arg.$1;
    final propertyName = arg.$2;

    final oldState = state;

    try {
      final interactionOutput = await consumedThing.readProperty(propertyName);

      // final value = await interactionOutput.value();
      // if (addToHistory) {
      //   ref
      //       .read(
      //         affordanceStateHistoryProvider(
      //           (
      //             affordanceKey: arg.$2,
      //             affordanceType: AffordanceType.property,
      //             thingDescriptionId: arg.$1.thingDescription.id!
      //           ),
      //         ).notifier,
      //       )
      //       .update(value);
      // }

      state = AsyncData(interactionOutput);
    } on Exception {
      state = oldState;
    }
  }
}

final propertyStateNotifier = AsyncNotifierProvider.family<
    PropertyStateNotifier, InteractionOutput?, (ConsumedThing, String)>(
  PropertyStateNotifier.new,
);

final propertyStateProvider =
    FutureProvider.family<Object?, (ConsumedThing, String)>((ref, arg) async {
  final interactionOutput = await ref.watch(propertyStateNotifier(arg).future);

  return interactionOutput?.value();
});

final propertyStateStreamProvider =
    FutureProvider.family<Stream<List<int>>, (ConsumedThing, String)>(
        (ref, arg) async {
  final interactionOutput = await ref.watch(propertyStateNotifier(arg).future);

  // print(await interactionOutput?.value());

  return interactionOutput?.data ?? const Stream.empty();
});

final propertyStateByteListProvider =
    FutureProvider.family<List<int>, (ConsumedThing, String)>((ref, arg) async {
  final stream = await ref.watch(propertyStateStreamProvider(arg).future);

  final result = <int>[];

  await for (final element in stream) {
    result.addAll(element);
  }

  return result;
});

class SubscriptionState {
  SubscriptionState(
    this.subscription, {
    required this.thingDescriptionId,
    required this.subscriptionType,
    required this.affordanceKey,
  });

  final Subscription subscription;

  final String thingDescriptionId;

  final SubscriptionType subscriptionType;

  final String affordanceKey;
}

class _SubscriptionStateNotifier extends Notifier<List<SubscriptionState>> {
  @override
  List<SubscriptionState> build() {
    return [];
  }

  bool hasSubscription(
    ConsumedThing consumedThing,
    SubscriptionType subscriptionType,
    String affordanceKey,
  ) =>
      state
          .where(
            (subscriptionState) =>
                subscriptionState.thingDescriptionId ==
                    consumedThing.thingDescription.id! &&
                subscriptionState.subscriptionType == subscriptionType &&
                subscriptionState.affordanceKey == affordanceKey,
          )
          .isNotEmpty;

  Future<void> addEventSubscription(
    ConsumedThing consumedThing,
    String affordanceKey, {
    void Function(Object? value)? subscriptionCallback,
  }) async {
    final subscription = await consumedThing.subscribeEvent(affordanceKey,
        (interactionOutput) async {
      final value = await interactionOutput.value();

      ref.read(eventNotificationProvider.notifier).addEventNotification(
            EventNotification(
              data: value,
              thingDescription: consumedThing.thingDescription,
            ),
          );

      subscriptionCallback?.call(value);
    });

    state = [
      ...state,
      SubscriptionState(
        subscription,
        thingDescriptionId: consumedThing.thingDescription.id!,
        subscriptionType: SubscriptionType.event,
        affordanceKey: affordanceKey,
      ),
    ];
  }

  Future<void> addPropertySubscription(
    ConsumedThing consumedThing,
    String affordanceKey,
  ) async {
    final subscription = await consumedThing.observeProperty(affordanceKey,
        (interactionOutput) async {
      ref
          .read(propertyStateNotifier((consumedThing, affordanceKey)).notifier)
          ._setInteractionOutput(interactionOutput);

      if (!(consumedThing
              .thingDescription.properties?[affordanceKey]?.isNumericDataType ??
          false)) {
        return;
      }

      final value = await interactionOutput.value();

      if (value is num) {
        ref
            .read(
              affordanceStateHistoryProvider(
                (
                  thingDescriptionId: consumedThing.thingDescription.id!,
                  affordanceKey: affordanceKey,
                  affordanceType: AffordanceType.property,
                ),
              ).notifier,
            )
            .update(value.toDouble());
      }
    });

    state = [
      ...state,
      SubscriptionState(
        subscription,
        thingDescriptionId: consumedThing.thingDescription.id!,
        subscriptionType: SubscriptionType.property,
        affordanceKey: affordanceKey,
      ),
    ];
  }

  Future<void> removeSubscriptionState(
    String thingDescriptionId,
    SubscriptionType subscriptionType,
    String affordanceKey,
  ) async {
    final result = <SubscriptionState>[];

    for (final subscriptionState in state) {
      if (subscriptionState.thingDescriptionId == thingDescriptionId &&
          subscriptionState.subscriptionType == subscriptionType &&
          subscriptionState.affordanceKey == affordanceKey) {
        await subscriptionState.subscription.stop();
      } else {
        result.add(subscriptionState);
      }
    }

    state = result;
  }

  void clear() {
    state = [];
  }
}

final subscriptionStateProvider =
    NotifierProvider<_SubscriptionStateNotifier, List<SubscriptionState>>(() {
  return _SubscriptionStateNotifier();
});
