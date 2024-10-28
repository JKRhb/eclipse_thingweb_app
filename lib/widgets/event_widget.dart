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
  State<StatefulWidget> createState() => _EventState();

  @override
  final Event _interactionAffordance;
}

final class _EventState extends _AffordanceState<EventWidget> {
  bool _subscribed = false;

  Subscription? _subscription;

  void _subscribeToEvent() async {
    if (_subscribed) {
      await _subscription?.stop();
    }

    setState(() {
      _subscribed = !_subscribed;
    });

    if (!_subscribed) {
      return;
    }

    _subscription = await widget._consumedThing.subscribeEvent(
      widget._affordanceKey,
      (interactionOutput) async {
        final value = await interactionOutput.value();

        if (!mounted) {
          return;
        }

        // TODO: Handle event data more elegantly
        displaySuccessMessageSnackbar(
          context,
          value.toString(),
        );
      },
    );
  }

  @override
  List<Widget> get _cardBody => [];

  @override
  List<Widget> get _cardButtons => [
        IconButton(
          onPressed: _subscribeToEvent,
          icon: Icon(
            !_subscribed ? Icons.play_arrow : Icons.stop,
          ),
        )
      ];
}
