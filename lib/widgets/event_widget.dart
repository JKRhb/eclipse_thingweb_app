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
  bool _subscribed = false;

  Subscription? _subscription;

  Event get _event => widget._event;

  String? get _eventTitle => _event.title;

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
            trailing: const Text("Event"),
          ),
          OverflowBar(
            children: [
              IconButton(
                onPressed: _subscribeToEvent,
                icon: Icon(
                  !_subscribed ? Icons.play_arrow : Icons.stop,
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
