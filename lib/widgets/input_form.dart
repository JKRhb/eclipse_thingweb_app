// Copyright 2024 Contributors to the Eclipse Foundation. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import 'package:flutter/material.dart';

class InputForm extends StatefulWidget {
  const InputForm({
    required this.initialValue,
    required this.submitCallback,
    required this.cancelCallback,
    this.validator,
    super.key,
  });

  final void Function(String value) submitCallback;

  final void Function(String? value) cancelCallback;

  final String? initialValue;

  final String? Function(String?)? validator;

  @override
  InputFormState createState() {
    return InputFormState();
  }
}

class InputFormState extends State<InputForm> {
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
            validator: widget.validator,
            controller: _discoveryUrlController,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
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
