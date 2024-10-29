// Copyright 2024 Contributors to the Eclipse Foundation. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import 'package:eclipse_thingweb_app/providers/event_notifications_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EventsPage extends ConsumerStatefulWidget {
  const EventsPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => EventsPageState();
}

class EventsPageState extends ConsumerState<EventsPage> {
  @override
  Widget build(BuildContext context) {
    final events = ref.watch(eventNotificationProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications"),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        leading: IconButton(
          icon: const Icon(
            Icons.chevron_left_rounded,
            size: 40,
          ),
          onPressed: () {
            Navigator.of(context).pop();

            final eventNotificationNotifier =
                ref.read(eventNotificationProvider.notifier);

            eventNotificationNotifier.markAllAsRead();
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: events.reversed
              .map(
                (eventNotification) => Card(
                  child: ListTile(
                    title: const Text("Event"),
                    subtitle: Text(
                      "Value: ${eventNotification.data}",
                    ),
                    trailing:
                        !eventNotification.read ? const Icon(Icons.abc) : null,
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}