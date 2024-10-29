// Copyright 2024 Contributors to the Eclipse Foundation. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

part of "affordance_widget.dart";

final class EventWidget extends AffordanceWidget {
  const EventWidget(
    super._consumedThing,
    super._affordanceKey,
    Event event, {
    super.key,
  }) : _interactionAffordance = event;

  @override
  ConsumerState<EventWidget> createState() => _EventState();

  @override
  final Event _interactionAffordance;
}

final class _EventState extends _AffordanceState<EventWidget> {
  void _subscribeToEvent() async {
    final subscriptionState = ref.read(
      subscriptionStateProvider.notifier,
    );

    final subscribed = subscriptionState.hasSubscription(
      widget._consumedThing,
      SubscriptionType.event,
      widget._affordanceKey,
    );

    if (subscribed) {
      await subscriptionState.removeSubscriptionState(
        widget._consumedThing.thingDescription.id!,
        SubscriptionType.event,
        widget._affordanceKey,
      );
      return;
    }

    await subscriptionState.addSubscriptionState(
      widget._consumedThing,
      widget._affordanceKey,
    );

    if (!mounted) {
      return;
    }

    displaySuccessMessageSnackbar(
      context,
      "Subscribed to Event: ${widget._interactionAffordance.title ?? widget._affordanceKey}",
    );
  }

  @override
  List<Widget> get _cardBody => [];

  @override
  List<Widget> get _cardButtons {
    final subscribed = ref
        .watch(
          subscriptionStateProvider,
        )
        .where(
          (subscriptionState) =>
              subscriptionState.thingDescriptionId ==
                  widget._consumedThing.thingDescription.id! &&
              subscriptionState.subscriptionType == SubscriptionType.event &&
              subscriptionState.affordanceKey == widget._affordanceKey,
        )
        .isNotEmpty;

    return [
      IconButton(
        onPressed: _subscribeToEvent,
        icon: Icon(
          !subscribed ? Icons.play_arrow : Icons.stop,
        ),
      )
    ];
  }
}
