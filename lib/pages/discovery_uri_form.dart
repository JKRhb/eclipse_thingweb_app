// Copyright 2024 Contributors to the Eclipse Foundation. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import 'package:eclipse_thingweb_app/providers/discovery_settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DiscoveryUriFormsPage extends ConsumerStatefulWidget {
  const DiscoveryUriFormsPage(
    this._discoveryMethod, {
    Uri? initialUrl,
    super.key,
  }) : _initialUrl = initialUrl;

  final Uri? _initialUrl;

  final DiscoveryMethod _discoveryMethod;

  String get _title => _initialUrl == null
      ? "Please enter a Discovery URL"
      : "Edit Discovery URL";

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => FormsPageState();
}

class FormsPageState extends ConsumerState<DiscoveryUriFormsPage> {
  final _formKey = GlobalKey<FormState>();

  final _formFieldTextEditingController = TextEditingController();

  Uri? get _initialUrl => widget._initialUrl;

  @override
  void initState() {
    super.initState();

    final initialUrl = _initialUrl;

    if (initialUrl != null) {
      _formFieldTextEditingController.text = initialUrl.toString();
    }
  }

  @override
  void dispose() {
    _formFieldTextEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget._title),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: Form(
          key: _formKey,
          child: ListView(
            // crossAxisAlignment: CrossAxisAlignment.end,
            padding: const EdgeInsets.all(10.0),
            children: [
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Discovery URL',
                ),
                controller: _formFieldTextEditingController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a URI.';
                  }

                  final uri = Uri.tryParse(value);

                  if (uri == null) {
                    return "Please enter a valid URI.";
                  }

                  if (!uri.isAbsolute) {
                    return "Please enter an absolute URI.";
                  }

                  return null;
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      final notifier = ref.read(
                          discoveryUrlProvider(widget._discoveryMethod)
                              .notifier);

                      final uri =
                          Uri.parse(_formFieldTextEditingController.text);

                      final initialUrl = _initialUrl;
                      if (initialUrl == null) {
                        await notifier.add(uri);
                      } else {
                        await notifier.replace(initialUrl, uri);
                      }

                      if (!context.mounted) {
                        return;
                      }

                      Navigator.of(context).pop();
                    }
                  },
                  child: const Text('Submit'),
                ),
              ),
            ],
          )),
    );
  }
}
