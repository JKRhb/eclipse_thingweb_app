// Copyright 2024 Contributors to the Eclipse Foundation. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import 'package:flutter/material.dart';

class NotificationsBadge extends StatelessWidget {
  const NotificationsBadge(
    this._numberOfUnreadNotifications, {
    super.key,
    void Function()? onPressed,
  }) : _onPressed = onPressed;

  final void Function()? _onPressed;

  final int _numberOfUnreadNotifications;

  static AlignmentGeometry _positionBadge(int notificationsCount) {
    if (notificationsCount > 999) {
      return AlignmentDirectional.topStart;
    }

    return AlignmentDirectional.topEnd;
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Badge.count(
        count: _numberOfUnreadNotifications,
        alignment: _positionBadge(_numberOfUnreadNotifications),
        isLabelVisible: _numberOfUnreadNotifications > 0,
        child: const Icon(Icons.notifications),
      ),
      onPressed: _onPressed,
    );
  }
}
