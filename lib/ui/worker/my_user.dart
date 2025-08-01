// Copyright © 2022-2025 IT ENGINEERING MANAGEMENT INC,
//                       <https://github.com/team113>
//
// This program is free software: you can redistribute it and/or modify it under
// the terms of the GNU Affero General Public License v3.0 as published by the
// Free Software Foundation, either version 3 of the License, or (at your
// option) any later version.
//
// This program is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
// FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License v3.0 for
// more details.
//
// You should have received a copy of the GNU Affero General Public License v3.0
// along with this program. If not, see
// <https://www.gnu.org/licenses/agpl-3.0.html>.

import 'package:get/get.dart';

import '/domain/model/my_user.dart';
import '/domain/service/disposable_service.dart';
import '/domain/service/my_user.dart';
import '/routes.dart';
import '/util/platform_utils.dart';
import '/util/web/web_utils.dart';

/// Worker responsible for updating the [RouterState.prefix] with the
/// [MyUser.unreadChatsCount].
class MyUserWorker extends DisposableService {
  MyUserWorker(this._myUser);

  /// [MyUserService], used to listen to the [MyUser] changes.
  final MyUserService _myUser;

  /// [Worker] reacting on the [MyUser] changes.
  Worker? _worker;

  /// [MyUser.unreadChatsCount] latest value, used to exclude the unnecessary
  /// [_updateBadge] invokes.
  int? _lastUnreadChatsCount;

  @override
  void onInit() {
    _updateBadge(_myUser.myUser.value?.unreadChatsCount ?? 0);

    _worker = ever(
      _myUser.myUser,
      (MyUser? u) => _updateBadge(u?.unreadChatsCount ?? 0),
    );

    super.onInit();
  }

  @override
  void onClose() {
    _worker?.dispose();
    router.prefix.value = null;
    _updateBadge(0);
    super.onClose();
  }

  /// Updates the application's badge with the provided [count].
  void _updateBadge(int count) async {
    if (_lastUnreadChatsCount != count) {
      _lastUnreadChatsCount = count;

      await PlatformUtils.setAppBadge(count);

      router.prefix.value = count == 0 ? null : '($count)';

      if (count > 0) {
        WebUtils.setAlertFavicon();
      } else {
        WebUtils.setDefaultFavicon();
      }
    }
  }
}
