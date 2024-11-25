// Copyright 2024 Contributors to the Eclipse Foundation. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

part of "affordance_widget.dart";

final class ActionWidget extends AffordanceWidget {
  const ActionWidget(
    super._consumedThing,
    super._affordanceKey,
    dart_wot.Action action, {
    super.key,
  }) : _interactionAffordance = action;

  @override
  final dart_wot.Action _interactionAffordance;

  @override
  ConsumerState<ActionWidget> createState() => _ActionState();
}

final class _ActionState extends _AffordanceState<ActionWidget> {
  ConsumedThing get _consumedThing => widget._consumedThing;

  Future<void> _invokeAction() async {
    final value = ref.refresh(invokeActionProvider((
      _consumedThing,
      widget._affordanceKey,
      // TODO: Add provider for Action input state
      null,
    ),),);

    developer.log("$value");
  }

  @override
  List<Widget> get _cardBody => [];

  @override
  List<Widget> get _cardButtons {
    final data = ref.watch(affordanceStateHistoryProvider((
      thingDescriptionId: _consumedThing.thingDescription.id!,
      affordanceKey: widget._affordanceKey,
      affordanceType: widget.affordanceType
    ),),);

    developer.log("${data.lastOrNull}");

    return [
      IconButton(
        onPressed: _invokeAction,
        // TODO: Improve Icon and button behavior
        icon: const Icon(Icons.pin_invoke),
      ),
    ];
  }
}
