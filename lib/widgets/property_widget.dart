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

  @override
  IconData get affordanceSymbol => Icons.settings;

  ConsumedThing get _consumedThing => widget._consumedThing;

  Property get _property => widget._interactionAffordance;

  String get _propertyKey => widget._affordanceKey;

  // TODO: Replace with global setting
  static const int _maxElements = 50;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    ref
        .read(
          propertyStateNotifier((widget._consumedThing, widget._affordanceKey))
              .notifier,
        )
        .readProperty(
          addToHistory: ["number", "integer"]
              .contains(widget._interactionAffordance.type),
        );
  }

  Future<void> _toggleObserve() async {
    final subscriptionStateNotifier =
        ref.read(subscriptionStateProvider.notifier);

    final hasSubscription = subscriptionStateNotifier.hasSubscription(
      _consumedThing,
      SubscriptionType.property,
      _propertyKey,
    );

    if (hasSubscription) {
      await subscriptionStateNotifier.removeSubscriptionState(
        _consumedThing.thingDescription.id!,
        SubscriptionType.property,
        _propertyKey,
      );
      return;
    }

    await subscriptionStateNotifier.addPropertySubscription(
      _consumedThing,
      _propertyKey,
    );
  }

  Widget get _readPropertyButton {
    final isLoading = ref
        .watch(propertyStateNotifier((_consumedThing, _propertyKey)))
        .isLoading;

    if (isLoading) {
      return IconButton(
        onPressed: null,
        icon: SizedBox(
          height: 15,
          width: 15,
          child: CircularProgressIndicator(
            color: onPrimaryTextColor,
          ),
        ),
        color: onPrimaryTextColor,
        tooltip: "Reading property...",
      );
    }

    return IconButton(
      onPressed: () async {
        await ref
            .read(
              propertyStateNotifier(
                (_consumedThing, _propertyKey),
              ).notifier,
            )
            .readProperty(
              addToHistory: widget._interactionAffordance.isNumericDataType,
            );
      },
      tooltip: "Retrieve the latest property value",
      icon: const Icon(Icons.refresh),
      color: onPrimaryTextColor,
    );
  }

  Widget get _currentValue {
    final imageFormIndex = _property.forms
        .indexWhere((form) => form.contentType.startsWith("image"));

    if (_property.type == null && imageFormIndex != -1) {
      final propertyState = ref.watch(
        propertyStateByteListProvider(
          (widget._consumedThing, widget._affordanceKey),
        ),
      );

      print(propertyState);

      switch (propertyState) {
        case AsyncData(:final value):
          // print(value);
          if (value.isEmpty) {
            return const CircularProgressIndicator();
          }

          // File("test.jpeg").writeAsBytesSync(value);

          return Image.memory(
            Uint8List.fromList(value),
            fit: BoxFit.fitWidth,
            width: MediaQuery.of(context).size.width,
            gaplessPlayback: true,
          );
        case AsyncError():
          return const Text("Failed to retrieve image data");
        default:
          return const CircularProgressIndicator();
      }
    }

    final output = ref.watch(
      propertyStateProvider((widget._consumedThing, widget._affordanceKey)),
    );

    switch (output) {
      case AsyncData(:final value):
        return Text(value.toString());
      default:
        return const CircularProgressIndicator();
    }
  }

  @override
  List<Widget> get _statusWidgets {
    return [
      if (!_property.writeOnly) _currentValue,
    ];
  }

  @override
  List<Widget> get _cardBody {
    return [
      if (!_property.readOnly)
        AffordanceControlsWidget(
          widget._affordanceKey,
          _property,
          _consumedThing,
        ),
      if (widget._interactionAffordance.isNumericDataType)
        PropertyVisualization.create(
          _property,
          ref,
          widget._affordanceKey,
          _maxElements,
          widget._consumedThing.thingDescription.id!,
        ),
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
            color: onPrimaryTextColor,
          ),
        ),
    ];
  }
}
