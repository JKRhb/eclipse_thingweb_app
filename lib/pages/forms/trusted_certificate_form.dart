// Copyright 2024 Contributors to the Eclipse Foundation. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import '../../providers/security_settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TrustedCertificateFormPage extends ConsumerStatefulWidget {
  const TrustedCertificateFormPage(
    this._title, {
    super.key,
    this.initialValue,
  });

  final String _title;

  final String? initialValue;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      TrustedCertificateFormPageState();
}

class TrustedCertificateFormPageState
    extends ConsumerState<TrustedCertificateFormPage> {
  final _formKey = GlobalKey<FormState>();

  final _formFieldTextEditingController = TextEditingController();

  final _labelTextEditingController = TextEditingController();

  String? get _initialValue => widget.initialValue;

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
          padding: const EdgeInsets.all(20.0),
          children: [
            TextFormField(
              maxLines: 10,
              decoration: const InputDecoration(
                // hintText: 'Certificate',
                labelText: 'Certificate',
                // floatingLabelBehavior: FloatingLabelBehavior.never,
              ),
              controller: _formFieldTextEditingController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please insert a certificate.';
                }

                // TODO: Add better validation
                if (!value.startsWith("-----BEGIN CERTIFICATE-----") ||
                    !value.endsWith("-----END CERTIFICATE-----")) {
                  return "Please insert a valid certificate in PEM format";
                }

                return null;
              },
            ),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Label',
              ),
              controller: _labelTextEditingController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please insert a label.';
                }

                return null;
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final notifier =
                        ref.read(trustedCertificatesProvider.notifier);

                    final newValue = _formFieldTextEditingController.text;
                    final label = _labelTextEditingController.text;

                    final initialValue = _initialValue;
                    if (initialValue == null) {
                      await notifier.add(newValue);
                    } else {
                      await notifier.replace(initialValue, newValue);
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
        ),
      ),
    );
  }
}
