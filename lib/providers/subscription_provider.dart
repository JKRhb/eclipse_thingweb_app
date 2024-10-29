// Copyright 2024 Contributors to the Eclipse Foundation. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import 'package:dart_wot/core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'event_notifications_provider.dart';

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
          .where((subscriptionState) =>
              subscriptionState.thingDescriptionId ==
                  consumedThing.thingDescription.id! &&
              subscriptionState.subscriptionType == subscriptionType &&
              subscriptionState.affordanceKey == affordanceKey)
          .isNotEmpty;

  Future<void> addSubscriptionState(
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
      SubscriptionState(subscription,
          thingDescriptionId: consumedThing.thingDescription.id!,
          subscriptionType: SubscriptionType.event,
          affordanceKey: affordanceKey)
    ];
  }

  Future<void> removeSubscriptionState(
    String thingDescriptionId,
    SubscriptionType subscriptionType,
    String affordanceKey,
  ) async {
    final result = <SubscriptionState>[];

    for (final subscriptionState in state) {
      if (subscriptionState.thingDescriptionId != thingDescriptionId &&
          subscriptionState.subscriptionType != subscriptionType &&
          subscriptionState.affordanceKey != affordanceKey) {
        result.add(subscriptionState);
      } else {
        await subscriptionState.subscription.stop();
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
