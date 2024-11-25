// Copyright 2024 Contributors to the Eclipse Foundation. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import "package:dart_wot/core.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

class _ThingDescriptionNotifier extends Notifier<List<ThingDescription>> {
  @override
  List<ThingDescription> build() {
    return [];
  }

  void addThingDescription(ThingDescription thingDescription) {
    if (thingDescription.id == null) {
      throw Exception(
        "Thing Description with title ${thingDescription.title} does not "
        "contain an ID.",
      );
    }

    bool thingDescriptionExists = false;
    final result = <ThingDescription>[];

    for (final existingThingDescription in state) {
      if (existingThingDescription.id == thingDescription.id) {
        result.add(thingDescription);
        thingDescriptionExists = true;
      } else {
        result.add(existingThingDescription);
      }
    }

    if (!thingDescriptionExists) {
      result.add(thingDescription);
    }

    state = result;
  }

  void removeThingDescription(String thingDescriptionId) {
    state = [
      for (final thingDescription in state)
        if (thingDescription.id != thingDescriptionId) thingDescription,
    ];
  }

  void clear() {
    state = [];
  }
}

final thingDescriptionProvider =
    NotifierProvider<_ThingDescriptionNotifier, List<ThingDescription>>(() {
  return _ThingDescriptionNotifier();
});
