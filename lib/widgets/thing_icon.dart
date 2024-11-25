// Copyright 2024 Contributors to the Eclipse Foundation. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import "package:dart_wot/core.dart";
import "package:flutter/material.dart";

class ThingIcon extends StatelessWidget {
  const ThingIcon(
    this._thingDescription, {
    super.key,
  });

  final ThingDescription _thingDescription;

  @override
  Widget build(BuildContext context) {
    const defaultIcon = Icon(Icons.devices_other);

    final iconLink = _thingDescription.links
        ?.where(
          (link) => link.rel == "icon" && link.href.scheme.startsWith("http"),
        )
        .firstOrNull
        ?.href
        .toString();

    if (iconLink == null) {
      return defaultIcon;
    }

    const fallbackSize = 24.0;
    final size = Theme.of(context).iconTheme.size ?? fallbackSize;

    return Image.network(
      height: size,
      width: size,
      iconLink,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) {
          return child;
        }
        return const CircularProgressIndicator();
      },
      errorBuilder: (context, error, stackTrace) {
        return defaultIcon;
      },
    );
  }
}
