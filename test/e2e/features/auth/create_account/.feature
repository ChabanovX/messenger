# Copyright © 2022-2025 IT ENGINEERING MANAGEMENT INC,
#                       <https://github.com/team113>
#
# This program is free software: you can redistribute it and/or modify it under
# the terms of the GNU Affero General Public License v3.0 as published by the
# Free Software Foundation, either version 3 of the License, or (at your
# option) any later version.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License v3.0 for
# more details.
#
# You should have received a copy of the GNU Affero General Public License v3.0
# along with this program. If not, see
# <https://www.gnu.org/licenses/agpl-3.0.html>.

Feature: Account creation

  Scenario: User creates a new account
    When I tap `StartButton` button
    And I wait until `IntroductionView` is present
    And I scroll `IntroductionScrollable` until `ProceedButton` is present
    And I tap `ProceedButton` button

    When I tap `MenuButton` button
    And I tap `PublicInformation` button
    And I wait until `MyProfileView` is present
    And I wait until `NameField` is present
    And I fill `NameField` field with "Alice"

    When I scroll `MyProfileScrollable` until `SetPassword` is present
    And I tap `SetPassword` button
    And I fill `NewPasswordField` field with "123"
    And I fill `RepeatPasswordField` field with "123"
    And I tap `Proceed` button
    And I tap `CloseButton` button
    Then I wait until `ChangePassword` is present

    When I scroll `MenuListView` until `DangerZone` is present
    And I tap `DangerZone` button
    Then I wait until `EraseView` is present

    When I scroll `EraseScrollable` until `ConfirmDelete` is present
    And I tap `ConfirmDelete` button
    And I tap `Proceed` button
    Then I wait until `ConfirmAccountDeletion` is present

    When I fill `PasswordField` field with "123"
    And I tap `Proceed` button

    Then I wait until `AuthView` is present
    And I pause for 1 second

  Scenario: User creates a new account with login and password
    When I tap `RegisterButton` button
    Then I wait until `LoginView` is present

    When I tap `LoginAndPassword` button
    And I fill `UsernameField` field with random login
    And I fill `PasswordField` field with "123"
    And I fill `RepeatPasswordField` field with "123"

    When I tap `RegisterButton` button
    Then I wait until `HomeView` is present

    When I tap `MenuButton` button
    And I tap `PublicInformation` button
    Then I wait until `MyProfileView` is present
    And I tap `PublicInformation` button
    And I scroll `MyProfileScrollable` until `LoginField` is present
    And I scroll `MyProfileScrollable` until `ChangePassword` is present
