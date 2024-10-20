import 'package:flutter/material.dart';

class UrlInputForm extends StatefulWidget {
  const UrlInputForm({
    required this.initialValue,
    required this.submitCallback,
    required this.cancelCallback,
    super.key,
  });

  final void Function(String value) submitCallback;

  final void Function(String? value) cancelCallback;

  final String? initialValue;

  @override
  UrlInputFormState createState() {
    return UrlInputFormState();
  }
}

class UrlInputFormState extends State<UrlInputForm> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _discoveryUrlController;

  @override
  void initState() {
    super.initState();

    _discoveryUrlController = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _discoveryUrlController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            validator: (value) {
              final parsedUrl = Uri.tryParse(value ?? "");

              if (parsedUrl == null) {
                return "Please enter a valid URL";
              }

              return null;
            },
            controller: _discoveryUrlController,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      widget.submitCallback(_discoveryUrlController.text);
                    }
                  },
                  child: const Text('Submit'),
                ),
                ElevatedButton(
                  onPressed: () {
                    widget.cancelCallback(widget.initialValue);
                  },
                  child: const Text('Cancel'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
