// Copyright 2024 Contributors to the Eclipse Foundation. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import 'package:dart_wot/core.dart';
import 'package:eclipse_thingweb_app/main.dart';
import 'package:eclipse_thingweb_app/providers/discovery_settings_provider.dart';
import 'package:eclipse_thingweb_app/providers/event_notifications_provider.dart';
import 'package:eclipse_thingweb_app/providers/thing_description_provider.dart';
import 'package:eclipse_thingweb_app/util/snackbar.dart';
import 'package:eclipse_thingweb_app/widgets/notifications_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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

  void _startDiscovery(BuildContext context) async {
    final wot = await ref.watch(wotProvider.future);
    final discoveryConfigurations =
        await ref.watch(discoveryConfigurationsProvider.future);

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

  Widget _obtainThingDescriptionIcon(ThingDescription thingDescription) {
    const defaultIcon = Icon(Icons.devices_other);

    final iconLink = thingDescription.links
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

  @override
  Widget build(BuildContext context) {
    final thingDescriptions = ref.watch(thingDescriptionProvider);

    const discoveryButtonIcon = Icon(Icons.travel_explore);

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => _startDiscovery(context),
        child: discoveryButtonIcon,
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
              final icon = _obtainThingDescriptionIcon(thingDescription);

              return Card(
                child: ListTile(
                  title: Text(thingDescription.title),
                  subtitle: description != null ? Text(description) : null,
                  leading: icon,
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
