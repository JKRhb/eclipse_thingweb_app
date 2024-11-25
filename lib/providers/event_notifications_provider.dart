// Copyright 2024 Contributors to the Eclipse Foundation. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import "package:dart_wot/core.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

class EventNotification {
  EventNotification({
    required this.data,
    required this.thingDescription,
    this.read = false,
  }) : id = _nextId++;

  EventNotification copy({
    bool read = false,
  }) {
    return EventNotification(
      data: data,
      thingDescription: thingDescription,
      read: read,
    );
  }

  final int id;

  static int _nextId = 0;

  final Object? data;

  final bool read;

  final ThingDescription thingDescription;
}

class _EventNotificationNotifier extends Notifier<List<EventNotification>> {
  @override
  List<EventNotification> build() {
    return [];
  }

  void addEventNotification(EventNotification eventNotification) =>
      state = [...state, eventNotification];

  void removeEventNotification(int eventNotificationId) {
    state = [
      for (final eventNotification in state)
        if (eventNotification.id != eventNotificationId) eventNotification,
    ];
  }

  void clear() {
    state = [];
  }

  void markAllAsRead() {
    state = [
      for (final eventNotification in state) eventNotification.copy(read: true),
    ];
  }
}

final eventNotificationProvider =
    NotifierProvider<_EventNotificationNotifier, List<EventNotification>>(() {
  return _EventNotificationNotifier();
});
