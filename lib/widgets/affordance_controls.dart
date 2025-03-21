import "package:dart_wot/core.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../providers/affordance_state_provider.dart";
import "../providers/interaction_provider.dart";
import "../providers/wot_providers.dart";

class AffordanceControlsWidget extends ConsumerStatefulWidget {
  const AffordanceControlsWidget(
    this._affordanceKey,
    this._interactionAffordance,
    this._consumedThing, {
    super.key,
  });

  final String _affordanceKey;

  // TODO: Make generic over all interaction affordances
  final Property _interactionAffordance;

  final ConsumedThing _consumedThing;

  @override
  ConsumerState<AffordanceControlsWidget> createState() =>
      AffordanceControlsState();
}

class AffordanceControlsState extends ConsumerState<AffordanceControlsWidget> {
  Property get _property => widget._interactionAffordance;

  // AutoDisposeFutureProvider get _readPropertyProvider =>
  //     readPropertyProvider((widget._consumedThing, widget._affordanceKey));

  Object? _lastValue;

  // switch (value) {
  //   case AsyncError(:final error):
  //     // developer.log(
  //     //   "Getting the current value failed.",
  //     //   name: "_PropertyState",
  //     //   error: error,
  //     // );
  //     return const Text("Failed to retrieve the property value.");
  //   case AsyncData(:final value):
  //     return Text(value.toString());
  //   default:
  //     return LoadingAnimationWidget.staggeredDotsWave(
  //       color: Colors.black,
  //       size: 20,
  //     );
  // }
  // }

  // @override
  // Widget build(BuildContext context) {
  //   if (_property.readOnly) {
  //     // TODO: This should probably rather be enforced some other way
  //     throw StateError("Encountered a property that is not writable");
  //   }

  //   final propertyType = _property.type;

  //   final currentValue = ref.watch(
  //     readPropertyProvider((widget._consumedThing, widget._affordanceKey)),
  //   );

  //   final temporaryValue = ref.watch(
  //     temporaryAffordanceStateProvider(
  //       (
  //         affordanceKey: widget._affordanceKey,
  //         affordanceType: AffordanceType.property,
  //         thingDescriptionId: widget._consumedThing.thingDescription.id!
  //       ),
  //     ),
  //   );

  //   final temporaryValueNotifer = ref.read(
  //     temporaryAffordanceStateProvider(
  //       (
  //         affordanceKey: widget._affordanceKey,
  //         affordanceType: AffordanceType.property,
  //         thingDescriptionId: widget._consumedThing.thingDescription.id!
  //       ),
  //     ).notifier,
  //   );

  //   // if (currentValue.isLoading) {
  //   //   return const CircularProgressIndicator();
  //   // }

  //   print(propertyType);
  //   print(temporaryValue);

  //   if (propertyType == "boolean") {
  //     print(currentValue);

  //     if (currentValue.hasValue) {
  //       return Switch(
  //         value: (currentValue.value as bool?) ?? false,
  //         onChanged: (newValue) {
  //           // temporaryValueNotifer.update(value);
  //           ref.read(
  //             writePropertyProvider(
  //               (
  //                 widget._consumedThing,
  //                 widget._affordanceKey,
  //                 newValue.asInteractionInput()
  //               ),
  //             ),
  //           );
  //         },
  //       );
  //     }
  //     const test = CircularProgressIndicator();

  //     return test;
  //     // switch (currentValue) {
  //     //   case AsyncData(:final value):
  //     //     return Switch(
  //     //       value: (temporaryValue as bool?) ?? false,
  //     //       onChanged: (newValue) {
  //     //         temporaryValueNotifer.update(value);
  //     //         ref.read(
  //     //           writePropertyProvider(
  //     //             (
  //     //               widget._consumedThing,
  //     //               widget._affordanceKey,
  //     //               newValue.asInteractionInput()
  //     //             ),
  //     //           ),
  //     //         );
  //     //       },
  //     //     );
  //     //   default:
  //     //     return Switch(
  //     //       value: (temporaryValue as bool?) ?? false,
  //     //       onChanged: null,
  //     //     );
  //   }

  //   // final currentValue = _currentValue;
  //   // return FutureBuilder(
  //   //   future: _currentValue,
  //   //   builder: (status, snapshot) {
  //   //     if (snapshot.hasData) {
  //   //       final data = snapshot.data! as bool;

  //   // }

  //   //     return const Switch(value: false, onChanged: null);
  //   //   },
  //   // );
  //   // }

  //   if (propertyType == "integer") {
  //     final minimum = _property.minimum;
  //     final maximum = _property.maximum;
  //     if (minimum != null && maximum != null) {
  //       if (!currentValue.hasValue) {
  //         return Slider(
  //           value: (_lastValue as double?) ?? minimum.toDouble(),
  //           min: minimum.toDouble(),
  //           max: minimum.toDouble(),
  //           onChanged: null,
  //         );
  //       }

  //       return Slider(
  //         value: (currentValue.value! as int).toDouble(),
  //         min: minimum.toDouble(),
  //         max: maximum.toDouble(),
  //         onChanged: (value) {},
  //         onChangeEnd: (value) {
  //           ref.read(
  //             writePropertyProvider(
  //               (
  //                 widget._consumedThing,
  //                 widget._affordanceKey,
  //                 value.toInt().asInteractionInput()
  //               ),
  //             ),
  //           );
  //         },
  //       );
  //     }
  //   }

  //   if (propertyType == "object") {}

  //   // TODO: Remove this placeholder
  //   return const SizedBox.shrink();
  // }

  Future<void>? _pendingFuture;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      // We listen to the pending operation, to update the UI accordingly.
      future: _pendingFuture,
      builder: (context, snapshot) {
        // Compute whether there is an error state or not.
        // The connectionState check is here to handle when the operation is retried.
        final isErrored = snapshot.hasError &&
            snapshot.connectionState != ConnectionState.waiting;

        return Row(
          children: [
            ElevatedButton(
              style: ButtonStyle(
                // If there is an error, we show the button in red
                backgroundColor: WidgetStatePropertyAll(
                  isErrored ? Colors.red : null,
                ),
              ),
              onPressed: () {
                // We keep the future returned by addTodo in a variable
                // final future = ref
                //     .read(todoListProvider.notifier)
                //     .addTodo(Todo(description: 'This is a new todo'));

                // We store that future in the local state
                setState(() {
                  // _pendingAddTodo = future;
                });
              },
              child: const Text(''),
            ),
            // The operation is pending, let's show a progress indicator
            if (snapshot.connectionState == ConnectionState.waiting) ...[
              const SizedBox(width: 8),
              const CircularProgressIndicator(),
            ]
          ],
        );
      },
    );
  }
}
