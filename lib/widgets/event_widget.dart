part of "affordance_widget.dart";

final class EventWidget extends AffordanceWidget {
  const EventWidget(
    super._consumedThing,
    this._affordanceKey,
    this._event, {
    super.key,
  });

  final Event _event;

  final String _affordanceKey;

  @override
  State<StatefulWidget> createState() => _EventState();
}

class _EventState extends State<EventWidget> {
  Event get _event => widget._event;

  String? get _eventTitle => widget._event.title;

  @override
  Widget build(BuildContext context) {
    final eventDescription = _event.description;

    final cardTitle = Text(_eventTitle ?? widget._affordanceKey);
    final cardDescription =
        eventDescription != null ? Text(eventDescription) : null;

    return Card(
      child: Column(
        children: [
          ListTile(
            title: cardTitle,
            subtitle: cardDescription,
          ),
        ],
      ),
    );
  }
}
