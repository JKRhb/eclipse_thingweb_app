// Copyright 2024 Contributors to the Eclipse Foundation. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import "package:flutter/material.dart";

/// Displays a [SnackBar] with a [successMessage] within the current [context].
///
/// Before the message is displayed, the current [SnackBar] is going to be
/// removed.
void displaySuccessMessageSnackbar(
  BuildContext context,
  String successMessage,
) {
  final snackbar = _createSuccessSnackbar(successMessage);

  _displaySnackbarMessage(context, snackbar);
}

/// Displays a [SnackBar] with an [errorMessage] and the specified [errorTitle]
/// within the current [context].
///
/// Before the message is displayed, the current [SnackBar] is going to be
/// removed.
void displayErrorMessageSnackbar(
    BuildContext context, String errorTitle, String errorMessage,) {
  final snackbar = _createErrorSnackbar(errorTitle, errorMessage);

  _displaySnackbarMessage(context, snackbar);
}

/// Displays a [snackbar] within the current [context].
void _displaySnackbarMessage(BuildContext context, SnackBar snackbar) =>
    ScaffoldMessenger.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(snackbar);

SnackBar _createSuccessSnackbar(String snackbarMessage) {
  return SnackBar(
    content: Text(
      snackbarMessage,
    ),
  );
}

SnackBar _createErrorSnackbar(String errorTitle, String errorMessage) =>
    SnackBar(
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            errorTitle,
          ),
          Text(
            errorMessage,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
      backgroundColor: Colors.red,
    );
