// Copyright 2024 Contributors to the Eclipse Foundation. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import "package:dart_wot/core.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";

import "../providers/discovery_settings_provider.dart";
import "../providers/event_notifications_provider.dart";
import "../providers/thing_description_provider.dart";
import "../providers/wot_providers.dart";
import "../util/snackbar.dart";
import "../widgets/notifications_badge.dart";
import "../widgets/thing_icon.dart";

class HomePage extends ConsumerStatefulWidget {
  const HomePage({
    super.key,
    required this.title,
  });

  final String title;

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  void _registerThingDescription(ThingDescription thingDescription) {
    ref
        .read(thingDescriptionProvider.notifier)
        .addThingDescription(thingDescription);
  }

  Future<void> _startDiscovery(BuildContext context) async {
    final wot = await ref.watch(wotProvider.future);
    final discoveryConfigurations =
        await ref.watch(discoveryConfigurationsProvider.future);

    if (discoveryConfigurations.isEmpty && context.mounted) {
      displayErrorMessageSnackbar(
        context,
        "Discovery failed",
        "No discovery methods have been configured in the settings!",
      );
      return;
    }

    final thingDiscovery = wot.discover(discoveryConfigurations);

    try {
      await for (final thingDescription in thingDiscovery) {
        _registerThingDescription(thingDescription);
      }

      if (context.mounted) {
        displaySuccessMessageSnackbar(context, "Discovery process finished.");
      }
    } on DiscoveryException catch (exception) {
      if (!context.mounted) {
        return;
      }
      displayErrorMessageSnackbar(
        context,
        "Discovery failed!",
        exception.message,
      );
    } on FormatException catch (exception) {
      if (!context.mounted) {
        return;
      }
      displayErrorMessageSnackbar(
        context,
        "Failed to decode discovery result!",
        exception.message,
      );
    }
  }

  int get _numberOfUnreadNotifications => ref
      .watch(eventNotificationProvider)
      .where((eventNotification) => !eventNotification.read)
      .length;

  @override
  Widget build(BuildContext context) {
    final thingDescriptions = ref.watch(thingDescriptionProvider);
    final hasThingDescriptions = thingDescriptions.isNotEmpty;

    return Scaffold(
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () => _startDiscovery(context),
            heroTag: "btn1",
            child: const Icon(Icons.travel_explore),
          ),
          if (hasThingDescriptions)
            const SizedBox(
              height: 10,
            ),
          if (hasThingDescriptions)
            FloatingActionButton(
              onPressed: () {
                ref.read(thingDescriptionProvider.notifier).clear();
              },
              heroTag: "btn2",
              child: const Icon(Icons.clear),
            ),
        ],
      ),
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        actions: [
          NotificationsBadge(
            _numberOfUnreadNotifications,
            onPressed: () {
              context.push("/events");
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => {
              context.push("/settings"),
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(discoveryConfigurationsProvider.future),
        child: ListView(
          children: thingDescriptions.map(
            (thingDescription) {
              final description = thingDescription.description;

              return Card(
                child: ListTile(
                  title: Text(thingDescription.title),
                  subtitle: description != null ? Text(description) : null,
                  leading: ThingIcon(thingDescription),
                  onTap: () async {
                    if (!context.mounted) {
                      return;
                    }

                    await context.push(
                      "/thing",
                      extra: thingDescription,
                    );
                  },
                ),
              );
            },
          ).toList(),
        ),
      ),
    );
  }
}
