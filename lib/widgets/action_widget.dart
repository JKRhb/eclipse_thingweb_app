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
  State<StatefulWidget> createState() => _ActionState();
}

final class _ActionState extends _AffordanceState<ActionWidget> {
  void _invokeAction() async {
    await widget._consumedThing.invokeAction(widget._affordanceKey);
  }

  @override
  List<Widget> get _cardBody => [];

  @override
  List<Widget> get _cardButtons => [
        IconButton(
          onPressed: _invokeAction,
          // TODO: Improve Icon and button behavior
          icon: const Icon(Icons.pin_invoke),
        ),
      ];
}
