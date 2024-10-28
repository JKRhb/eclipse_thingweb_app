part of "affordance_widget.dart";

final class ActionWidget extends AffordanceWidget {
  const ActionWidget(
    super._consumedThing,
    this._affordanceKey,
    this._action, {
    super.key,
  });

  final dart_wot.Action _action;

  final String _affordanceKey;

  @override
  State<StatefulWidget> createState() => _ActionState();
}

class _ActionState extends State<ActionWidget> {
  dart_wot.Action get _event => widget._action;

  String? get _actionTitle => widget._action.title;

  @override
  Widget build(BuildContext context) {
    final cardTitle = Text(_actionTitle ?? widget._affordanceKey);

    // TODO: Refactor this.
    final actionDescription = _event.description;
    final cardDescription =
        actionDescription != null ? Text(actionDescription) : null;

    return Card(
      child: Column(
        children: [
          ListTile(
            title: cardTitle,
            subtitle: cardDescription,
            trailing: const Text("Action"),
          ),
        ],
      ),
    );
  }
}
