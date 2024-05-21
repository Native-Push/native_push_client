import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:native_push/native_push.dart';
import 'package:native_push_client/src/add_notification_response.dart';
import 'package:native_push_client/src/send_notification_request.dart';

typedef StringIdFunction = String? Function();
typedef IntIdFunction = int? Function();

/// An abstract base class for handling push notification functionalities.
///
/// This class is intended to be extended by concrete implementations that provide
/// specific behavior for managing push notifications, including initialization,
/// token handling, and notification registration.
@immutable
abstract base class NativePushClient {
  /// Default constructor for [NativePushClient].
  const NativePushClient();

  /// Generates the headers for HTTP requests, including authorization if provided.
  ///
  /// The [authorization] parameter is an optional authorization token to be included
  /// in the headers.
  static Map<String, String> _headers({required final String? authorization}) {
    final headers = {
      HttpHeaders.acceptHeader : 'application/json',
      HttpHeaders.contentTypeHeader : 'application/json',
    };
    if (authorization != null) {
      headers[HttpHeaders.authorizationHeader] = authorization;
    }
    return headers;
  }

  /// The base URI for the notification server.
  Uri get baseUri;

  /// Initializes the push notification client.
  ///
  /// The [getUserId] parameter is a function that returns a tuple of user ID and authorization.
  /// The [firebaseOptions] parameter provides options for Firebase configuration.
  /// The [useDefaultNotificationChannel] parameter indicates whether to use the default notification channel.
  Future<void> initialize({
    required final (String?, String?) Function() getUserId,
    final Map<String, String>? firebaseOptions,
    final bool useDefaultNotificationChannel = false,
  }) async {
    await NativePush.instance.initialize(firebaseOptions: firebaseOptions, useDefaultNotificationChannel: useDefaultNotificationChannel);
    NativePush.instance.notificationTokenStream.listen((final entry) async {
      final (system, token) = entry;
      if (token != null) {
        final (userId, authorization) = getUserId();
        if (userId != null) {
          await _sendTokenToServer(userId: userId, system: system, token: token, authorization: authorization);
        }
      }
    });
  }

  /// A stream of notifications received by the client.
  Stream<Map<String, String>> get notificationStream => NativePush.instance.notificationStream;

  /// The current notification token with the system which provided it.
  Future<(NotificationService, String?)> get notificationToken => NativePush.instance.notificationToken;

  /// Retrieves the initial notification if available.
  Future<Map<String, String>?> initialNotification() async => NativePush.instance.initialNotification();

  /// Registers the client for remote notifications with specified [options] and optional [vapidKey].
  Future<bool> registerForRemoteNotification({required final List<NotificationOption> options, final String? vapidKey}) async =>
      NativePush.instance.registerForRemoteNotification(options: options, vapidKey: vapidKey);

  /// Sends the current notification token to the server.
  ///
  /// The [userId] parameter is the identifier for the user.
  /// The [authorization] parameter is an optional authorization token.
  Future<void> sendTokenToServer({required final String userId, final String? authorization}) async {
    final (system, token) = await NativePush.instance.notificationToken;
    if (token != null) {
      await _sendTokenToServer(userId: userId, system: system, token: token, authorization: authorization);
    }
  }

  /// Deletes the notification token from the server for the specified [userId].
  ///
  /// The [authorization] parameter is an optional authorization token.
  Future<void> deleteTokenFromServer(final String userId, {final String? authorization}) async {
    final tokenId = await getTokenId();
    if (tokenId != null) {
      await http.delete(Uri.parse('$baseUri/$userId/token/$tokenId'), headers: _headers(authorization: authorization));
      await removeTokenId();
    }
  }

  /// Saves the notification token identifier.
  ///
  /// The [tokenId] parameter is the identifier of the notification token.
  Future<void> saveTokenId(final String tokenId);

  /// Retrieves the current notification token identifier.
  Future<String?> getTokenId();

  /// Removes the current notification token identifier.
  Future<void> removeTokenId();

  /// Sends the notification token to the server.
  ///
  /// This method is used internally to send the notification token to the server.
  /// The [userId] parameter is the identifier for the user.
  /// The [system] parameter is the notification service system.
  /// The [token] parameter is the notification token.
  /// The [authorization] parameter is an optional authorization token.
  Future<void> _sendTokenToServer({
    required final String userId,
    required final NotificationService system,
    required final String token,
    required final String? authorization,
  }) async {
    final json = jsonEncode(
      SendNotificationRequest(
        system: system.name.toUpperCase(),
        token: token,
      ),
    );

    final tokenId = await getTokenId();
    if (tokenId != null) {
      await http.put(Uri.parse('$baseUri/$userId/token/$tokenId'), body: json, headers: _headers(authorization: authorization));
    }
    else {
      final httpResp = await http.post(Uri.parse('$baseUri/$userId/token'), body: json, headers: _headers(authorization: authorization));
      final notificationResp = AddNotificationResponse.fromJson(jsonDecode(httpResp.body));
      await saveTokenId(notificationResp.id);
    }
  }
}
