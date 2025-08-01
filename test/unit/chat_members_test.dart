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

import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:messenger/api/backend/schema.dart';
import 'package:messenger/domain/model/chat.dart';
import 'package:messenger/domain/model/user.dart';
import 'package:messenger/domain/repository/auth.dart';
import 'package:messenger/domain/repository/chat.dart';
import 'package:messenger/domain/repository/settings.dart';
import 'package:messenger/domain/service/auth.dart';
import 'package:messenger/domain/service/chat.dart';
import 'package:messenger/provider/drift/account.dart';
import 'package:messenger/provider/drift/background.dart';
import 'package:messenger/provider/drift/call_credentials.dart';
import 'package:messenger/provider/drift/call_rect.dart';
import 'package:messenger/provider/drift/chat.dart';
import 'package:messenger/provider/drift/chat_credentials.dart';
import 'package:messenger/provider/drift/chat_item.dart';
import 'package:messenger/provider/drift/chat_member.dart';
import 'package:messenger/provider/drift/credentials.dart';
import 'package:messenger/provider/drift/draft.dart';
import 'package:messenger/provider/drift/drift.dart';
import 'package:messenger/provider/drift/locks.dart';
import 'package:messenger/provider/drift/monolog.dart';
import 'package:messenger/provider/drift/my_user.dart';
import 'package:messenger/provider/drift/settings.dart';
import 'package:messenger/provider/drift/user.dart';
import 'package:messenger/provider/drift/version.dart';
import 'package:messenger/provider/gql/exceptions.dart';
import 'package:messenger/provider/gql/graphql.dart';
import 'package:messenger/routes.dart';
import 'package:messenger/store/auth.dart';
import 'package:messenger/store/call.dart';
import 'package:messenger/store/chat.dart';
import 'package:messenger/store/settings.dart';
import 'package:messenger/store/user.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'chat_members_test.mocks.dart';

@GenerateMocks([GraphQlProvider])
void main() async {
  setUp(Get.reset);

  final CommonDriftProvider common = CommonDriftProvider.memory();
  final ScopedDriftProvider scoped = ScopedDriftProvider.memory();

  final graphQlProvider = MockGraphQlProvider();
  Get.put<GraphQlProvider>(graphQlProvider);
  when(graphQlProvider.disconnect()).thenAnswer((_) => () {});

  final credentialsProvider = Get.put(CredentialsDriftProvider(common));
  final accountProvider = Get.put(AccountDriftProvider(common));

  var recentChats = {
    'recentChats': {
      'edges': [],
      'pageInfo': {
        'endCursor': 'endCursor',
        'hasNextPage': false,
        'startCursor': 'startCursor',
        'hasPreviousPage': false,
      },
    },
  };

  var favoriteChats = {
    'favoriteChats': {
      'edges': [],
      'pageInfo': {
        'endCursor': 'endCursor',
        'hasNextPage': false,
        'startCursor': 'startCursor',
        'hasPreviousPage': false,
      },
      'ver': '0',
    },
  };

  var chatData = {
    'num': '1234567890123456',
    'id': '0d72d245-8425-467a-9ebd-082d4f47850b',
    'avatar': null,
  };

  var addChatMemberData = {
    'addChatMember': {
      '__typename': 'ChatEventsVersioned',
      'events': [
        {
          '__typename': 'EventChatItemPosted',
          'chatId': '0d72d245-8425-467a-9ebd-082d4f47850b',
          'item': {
            'node': {
              '__typename': 'ChatInfo',
              'id': 'id',
              'chatId': '0d72d245-8425-467a-9ebd-082d4f47850b',
              'authorId': 'me',
              'at': DateTime.now().toString(),
              'ver': '0',
              'author': {
                '__typename': 'User',
                'id': '0d72d245-8425-467a-9ebd-082d4f47850a',
                'num': '1234567890123456',
                'login': null,
                'name': null,
                'emails': {'confirmed': []},
                'phones': {'confirmed': []},
                'chatDirectLink': null,
                'hasPassword': false,
                'unreadChatsCount': 0,
                'ver': '0',
                'presence': 'AWAY',
                'online': {'__typename': 'UserOnline'},
                'mutualContactsCount': 0,
                'contacts': [],
                'isDeleted': false,
                'isBlocked': {'ver': '0'},
              },
              'action': {
                '__typename': 'ChatInfoActionMemberAdded',
                'user': {
                  '__typename': 'User',
                  'id': '0d72d245-8425-467a-9ebd-082d4f47850a',
                  'num': '1234567890123456',
                  'login': null,
                  'name': null,
                  'emails': {'confirmed': []},
                  'phones': {'confirmed': []},
                  'chatDirectLink': null,
                  'hasPassword': false,
                  'unreadChatsCount': 0,
                  'ver': '0',
                  'presence': 'AWAY',
                  'online': {'__typename': 'UserOnline'},
                  'mutualContactsCount': 0,
                  'contacts': [],
                  'isDeleted': false,
                  'isBlocked': {'ver': '0'},
                },
              },
            },
            'cursor': '123',
          },
        },
      ],
      'ver': '0',
    },
  };

  var removeChatMemberData = {
    'removeChatMember': {
      '__typename': 'ChatEventsVersioned',
      'events': [
        {
          '__typename': 'EventChatItemPosted',
          'chatId': '0d72d245-8425-467a-9ebd-082d4f47850b',
          'item': {
            'node': {
              '__typename': 'ChatInfo',
              'id': 'id',
              'chatId': '0d72d245-8425-467a-9ebd-082d4f47850b',
              'authorId': 'me',
              'at': DateTime.now().toString(),
              'ver': '0',
              'author': {
                '__typename': 'User',
                'id': '0d72d245-8425-467a-9ebd-082d4f47850a',
                'num': '1234567890123456',
                'login': null,
                'name': null,
                'emails': {'confirmed': []},
                'phones': {'confirmed': []},
                'chatDirectLink': null,
                'hasPassword': false,
                'unreadChatsCount': 0,
                'ver': '0',
                'presence': 'AWAY',
                'online': {'__typename': 'UserOnline'},
                'mutualContactsCount': 0,
                'contacts': [],
                'isDeleted': false,
                'isBlocked': {'ver': '0'},
              },
              'action': {
                '__typename': 'ChatInfoActionMemberRemoved',
                'user': {
                  '__typename': 'User',
                  'id': '0d72d245-8425-467a-9ebd-082d4f47850a',
                  'num': '1234567890123456',
                  'login': null,
                  'name': null,
                  'emails': {'confirmed': []},
                  'phones': {'confirmed': []},
                  'chatDirectLink': null,
                  'hasPassword': false,
                  'unreadChatsCount': 0,
                  'ver': '0',
                  'presence': 'AWAY',
                  'online': {'__typename': 'UserOnline'},
                  'mutualContactsCount': 0,
                  'contacts': [],
                  'isDeleted': false,
                  'isBlocked': {'ver': '0'},
                },
              },
            },
            'cursor': '123',
          },
        },
      ],
      'ver': '0',
    },
  };

  when(graphQlProvider.keepOnline()).thenAnswer((_) => const Stream.empty());

  when(
    graphQlProvider.favoriteChatsEvents(any),
  ).thenAnswer((_) => const Stream.empty());

  when(
    graphQlProvider.getUser(any),
  ).thenAnswer((_) => Future.value(GetUser$Query.fromJson({'user': null})));
  when(graphQlProvider.getMonolog()).thenAnswer(
    (_) => Future.value(GetMonolog$Query.fromJson({'monolog': null}).monolog),
  );

  Future<ChatService> init(GraphQlProvider graphQlProvider) async {
    final settingsProvider = Get.put(SettingsDriftProvider(common));
    final myUserProvider = Get.put(MyUserDriftProvider(common));
    final userProvider = UserDriftProvider(common, scoped);
    final chatItemProvider = Get.put(ChatItemDriftProvider(common, scoped));
    final chatMemberProvider = Get.put(ChatMemberDriftProvider(common, scoped));
    final chatProvider = Get.put(ChatDriftProvider(common, scoped));
    final backgroundProvider = Get.put(BackgroundDriftProvider(common));
    final callCredentialsProvider = Get.put(
      CallCredentialsDriftProvider(common, scoped),
    );
    final chatCredentialsProvider = Get.put(
      ChatCredentialsDriftProvider(common, scoped),
    );
    final callRectProvider = Get.put(CallRectDriftProvider(common, scoped));
    final monologProvider = Get.put(MonologDriftProvider(common));
    final draftProvider = Get.put(DraftDriftProvider(common, scoped));
    final sessionProvider = Get.put(VersionDriftProvider(common));
    final locksProvider = Get.put(LockDriftProvider(common));

    final AbstractSettingsRepository settingsRepository = Get.put(
      SettingsRepository(
        const UserId('me'),
        settingsProvider,
        backgroundProvider,
        callRectProvider,
      ),
    );

    Get.put(graphQlProvider);
    final AuthService authService = Get.put(
      AuthService(
        Get.put<AbstractAuthRepository>(
          AuthRepository(Get.find(), myUserProvider, credentialsProvider),
        ),
        credentialsProvider,
        accountProvider,
        locksProvider,
      ),
    );
    router = RouterState(authService);
    authService.init();

    final UserRepository userRepository = Get.put(
      UserRepository(graphQlProvider, userProvider),
    );
    final CallRepository callRepository = Get.put(
      CallRepository(
        graphQlProvider,
        userRepository,
        callCredentialsProvider,
        chatCredentialsProvider,
        settingsRepository,
        me: const UserId('me'),
      ),
    );
    final AbstractChatRepository chatRepository =
        Get.put<AbstractChatRepository>(
          ChatRepository(
            graphQlProvider,
            chatProvider,
            chatItemProvider,
            chatMemberProvider,
            callRepository,
            draftProvider,
            userRepository,
            sessionProvider,
            monologProvider,
            me: const UserId('me'),
          ),
        );

    return Get.put(ChatService(chatRepository, authService));
  }

  when(
    graphQlProvider.recentChats(
      first: anyNamed('first'),
      after: null,
      last: null,
      before: null,
      noFavorite: anyNamed('noFavorite'),
      withOngoingCalls: anyNamed('withOngoingCalls'),
    ),
  ).thenAnswer((_) => Future.value(RecentChats$Query.fromJson(recentChats)));

  when(
    graphQlProvider.favoriteChats(
      first: anyNamed('first'),
      after: null,
      last: null,
      before: null,
    ),
  ).thenAnswer(
    (_) => Future.value(FavoriteChats$Query.fromJson(favoriteChats)),
  );

  when(
    graphQlProvider.getChat(
      const ChatId('0d72d245-8425-467a-9ebd-082d4f47850b'),
    ),
  ).thenAnswer((_) => Future.value(GetChat$Query.fromJson({'chat': chatData})));

  when(
    graphQlProvider.recentChatsTopEvents(3),
  ).thenAnswer((_) => const Stream.empty());
  when(
    graphQlProvider.incomingCallsTopEvents(3),
  ).thenAnswer((_) => const Stream.empty());

  when(
    graphQlProvider.chatEvents(
      const ChatId('fc95f181-ae23-41b7-b246-5d6bdbe577a1'),
      any,
      any,
    ),
  ).thenAnswer((_) => const Stream.empty());

  when(
    graphQlProvider.chatEvents(
      const ChatId('c36343e2-e8af-4d55-9982-38ba68d2b785'),
      any,
      any,
    ),
  ).thenAnswer((_) => const Stream.empty());

  test('ChatService successfully adds a participant to chat', () async {
    when(
      graphQlProvider.addChatMember(
        const ChatId('0d72d245-8425-467a-9ebd-082d4f47850b'),
        const UserId('0d72d245-8425-467a-9ebd-082d4f47850a'),
      ),
    ).thenAnswer(
      (_) => Future.value(
        AddChatMember$Mutation.fromJson(addChatMemberData).addChatMember
            as AddChatMember$Mutation$AddChatMember$ChatEventsVersioned,
      ),
    );

    final ChatService chatService = await init(graphQlProvider);

    await chatService.addChatMember(
      const ChatId('0d72d245-8425-467a-9ebd-082d4f47850b'),
      const UserId('0d72d245-8425-467a-9ebd-082d4f47850a'),
    );

    verify(
      graphQlProvider.addChatMember(
        const ChatId('0d72d245-8425-467a-9ebd-082d4f47850b'),
        const UserId('0d72d245-8425-467a-9ebd-082d4f47850a'),
      ),
    );
  });

  test(
    'ChatService throws AddChatMemberException when adding new chat member',
    () async {
      when(
        graphQlProvider.addChatMember(
          const ChatId('0d72d245-8425-467a-9ebd-082d4f47850b'),
          const UserId('0d72d245-8425-467a-9ebd-082d4f47850a'),
        ),
      ).thenThrow(const AddChatMemberException(AddChatMemberErrorCode.blocked));

      final ChatService chatService = await init(graphQlProvider);

      dynamic exception;

      try {
        await chatService.addChatMember(
          const ChatId('0d72d245-8425-467a-9ebd-082d4f47850b'),
          const UserId('0d72d245-8425-467a-9ebd-082d4f47850a'),
        );
      } catch (e) {
        exception = e;
      }

      expect(exception.runtimeType, AddChatMemberException);

      await Future.delayed(Duration.zero);

      verify(
        graphQlProvider.addChatMember(
          const ChatId('0d72d245-8425-467a-9ebd-082d4f47850b'),
          const UserId('0d72d245-8425-467a-9ebd-082d4f47850a'),
        ),
      );
    },
  );

  test('ChatService successfully removes participant from the chat', () async {
    when(
      graphQlProvider.removeChatMember(
        const ChatId('0d72d245-8425-467a-9ebd-082d4f47850b'),
        const UserId('0d72d245-8425-467a-9ebd-082d4f47850a'),
      ),
    ).thenAnswer(
      (_) => Future.value(
        RemoveChatMember$Mutation.fromJson(
              removeChatMemberData,
            ).removeChatMember
            as RemoveChatMember$Mutation$RemoveChatMember$ChatEventsVersioned,
      ),
    );

    final ChatService chatService = await init(graphQlProvider);

    await chatService.removeChatMember(
      const ChatId('0d72d245-8425-467a-9ebd-082d4f47850b'),
      const UserId('0d72d245-8425-467a-9ebd-082d4f47850a'),
    );

    verify(
      graphQlProvider.removeChatMember(
        const ChatId('0d72d245-8425-467a-9ebd-082d4f47850b'),
        const UserId('0d72d245-8425-467a-9ebd-082d4f47850a'),
      ),
    );
  });

  test(
    'ChatService does not throw RemoveChatMemberException when removing chat member',
    () async {
      when(
        graphQlProvider.removeChatMember(
          const ChatId('0d72d245-8425-467a-9ebd-082d4f47850b'),
          const UserId('0d72d245-8425-467a-9ebd-082d4f47850a'),
        ),
      ).thenThrow(
        const RemoveChatMemberException(RemoveChatMemberErrorCode.unknownChat),
      );

      final ChatService chatService = await init(graphQlProvider);

      await chatService.removeChatMember(
        const ChatId('0d72d245-8425-467a-9ebd-082d4f47850b'),
        const UserId('0d72d245-8425-467a-9ebd-082d4f47850a'),
      );

      verify(
        graphQlProvider.removeChatMember(
          const ChatId('0d72d245-8425-467a-9ebd-082d4f47850b'),
          const UserId('0d72d245-8425-467a-9ebd-082d4f47850a'),
        ),
      );
    },
  );

  tearDown(() async => await Future.wait([common.close(), scoped.close()]));
}
