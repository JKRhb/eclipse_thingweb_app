// Copyright 2024 Contributors to the Eclipse Foundation. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import 'package:dart_wot/core.dart';
import 'package:eclipse_thingweb_app/main.dart';
import 'package:eclipse_thingweb_app/providers/event_notifications_provider.dart';
import 'package:eclipse_thingweb_app/providers/thing_description_provider.dart';
import 'package:eclipse_thingweb_app/util/snackbar.dart';
import 'package:eclipse_thingweb_app/widgets/notifications_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/settings_provider.dart';

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

  void _startDiscovery(
      BuildContext context, DiscoveryPreferences discoveryPreferences) async {
    final wot = await ref.watch(wotProvider.future);

    final (:discoveryUrl, :discoveryMethod) = discoveryPreferences;

    try {
      if (discoveryUrl == null) {
        throw const DiscoveryException(
          "A discovery URL must be set in the preferences.",
        );
      }

      final parsedDiscoveryUrl = Uri.parse(discoveryUrl);

      // TODO: Parse discovery method as enum
      switch (discoveryMethod ?? "Direct") {
        case "Direct":
          final thingDescription =
              await wot.requestThingDescription(parsedDiscoveryUrl);
          _registerThingDescription(thingDescription);

        case "Directory":
          final discoveryProcess =
              await wot.exploreDirectory(parsedDiscoveryUrl);

          await for (final thingDescription in discoveryProcess) {
            _registerThingDescription(thingDescription);
          }

        default:
          throw DiscoveryException(
            "Unknown or unsupported discovery method $discoveryMethod set.",
          );
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
    final discoverySettings = ref.watch(discoverySettingsProvider);

    const discoveryButtonIcon = Icon(Icons.travel_explore);

    return Scaffold(
      floatingActionButton: switch (discoverySettings) {
        AsyncData(:final value) => FloatingActionButton(
            onPressed: () => _startDiscovery(context, value),
            child: discoveryButtonIcon,
          ),
        AsyncError() => const FloatingActionButton(
            onPressed: null,
            child: discoveryButtonIcon,
          ),
        _ => const CircularProgressIndicator(),
      },
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
        onRefresh: () async {
          final discoverySettings =
              await ref.watch(discoverySettingsProvider.future);

          if (!context.mounted) {
            return;
          }

          _startDiscovery(context, discoverySettings);
        },
        child: ListView(
          children: thingDescriptions.map(
            (thingDescription) {
              final description = thingDescription.description;

              return Card(
                child: ListTile(
                  title: Text(thingDescription.title),
                  subtitle: description != null ? Text(description) : null,
                  // TODO: Use a network icon here.
                  leading: const Icon(Icons.devices_other),
                  onTap: () async {
                    if (!context.mounted) {
                      return;
                    }

                    ScaffoldMessenger.of(context).removeCurrentSnackBar();

                    context.push(
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
