// Copyright 2024 Contributors to the Eclipse Foundation. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

part of "affordance_widget.dart";

final class PropertyWidget extends AffordanceWidget {
  const PropertyWidget(
    super._consumedThing,
    super._affordanceKey,
    Property property, {
    super.key,
  }) : _interactionAffordance = property;

  @override
  final Property _interactionAffordance;

  @override
  ConsumerState<PropertyWidget> createState() => _PropertyState();
}

final class _PropertyState extends _AffordanceState<PropertyWidget> {
  _PropertyState();

  ConsumedThing get _consumedThing => widget._consumedThing;

  Property get _property => widget._interactionAffordance;

  String get _propertyKey => widget._affordanceKey;

  // TODO: Replace with global setting
  static const int _maxElements = 50;

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _toggleObserve() async {
    final subscriptionStateNotifier =
        ref.read(subscriptionStateProvider.notifier);

    final hasSubscription = subscriptionStateNotifier.hasSubscription(
        _consumedThing, SubscriptionType.property, _propertyKey);

    if (hasSubscription) {
      subscriptionStateNotifier.removeSubscriptionState(
          _consumedThing.thingDescription.id!,
          SubscriptionType.property,
          _propertyKey);
      return;
    }

    subscriptionStateNotifier.addPropertySubscription(
      _consumedThing,
      _propertyKey,
    );
  }

  Widget get _readPropertyButton {
    final isLoading = ref
        .watch(readPropertyProvider((_consumedThing, _propertyKey)))
        .isLoading;

    if (isLoading) {
      return const IconButton(
        onPressed: null,
        icon: SizedBox(
          height: 15,
          width: 15,
          child: CircularProgressIndicator(),
        ),
        tooltip: "Reading property...",
      );
    }

    return IconButton(
      onPressed: () =>
          ref.refresh(readPropertyProvider((_consumedThing, _propertyKey))),
      tooltip: "Retrieve the latest property value",
      icon: const Icon(Icons.refresh),
    );
  }

  Widget get _currentValue {
    final value =
        ref.watch(readPropertyProvider((_consumedThing, _propertyKey)));

    switch (value) {
      case AsyncError(:final error):
        developer.log(
          "Getting the current value failed.",
          name: "_PropertyState",
          error: error,
        );
        return const Text('Failed to retrieve the property value.');
      case AsyncData(:final value):
        return Text(value.toString());
      default:
        return LoadingAnimationWidget.staggeredDotsWave(
          color: Colors.black,
          size: 20,
        );
    }
  }

  @override
  List<Widget> get _cardBody {
    final currentValue = _currentValue;

    final propertyVisualization = PropertyVisualization.create(
      _property,
      ref,
      widget._affordanceKey,
      _maxElements,
      widget._consumedThing.thingDescription.id!,
    );

    return [
      Container(
        padding: const EdgeInsets.all(16.0),
        alignment: Alignment.centerLeft,
        child: Row(
          children: [
            const Text("Current value: "),
            currentValue,
          ],
        ),
      ),
      if (propertyVisualization != null) propertyVisualization,
    ];
  }

  bool get _isSubscribed => ref
          .watch(
        subscriptionStateProvider,
      )
          .where(
        (subscriptionState) {
          return subscriptionState.thingDescriptionId ==
                  widget._consumedThing.thingDescription.id! &&
              subscriptionState.subscriptionType == SubscriptionType.property &&
              subscriptionState.affordanceKey == _propertyKey;
        },
      ).isNotEmpty;

  @override
  List<Widget> get _cardButtons {
    final isSubscribed = _isSubscribed;

    final observeButtonTooltip =
        "${!isSubscribed ? "Start" : "Stop"} observing this property";

    return [
      if (!_property.writeOnly) _readPropertyButton,
      if (_property.observable)
        IconButton(
          onPressed: _toggleObserve,
          tooltip: observeButtonTooltip,
          icon: Icon(
            !isSubscribed ? Icons.remove_red_eye : Icons.cancel,
          ),
        ),
    ];
  }
}
