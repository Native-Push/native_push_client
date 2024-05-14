import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:native_push/native_push.dart';
import 'package:native_push_client/src/add_notification_response.dart';
import 'package:native_push_client/src/send_notification_request.dart';

typedef StringIdFunction = String? Function();
typedef IntIdFunction = int? Function();

@immutable
abstract base class NativePushClient {
  const NativePushClient();

  static const Map<String, String> _headers = {
    HttpHeaders.acceptHeader : 'application/json',
    HttpHeaders.contentTypeHeader : 'application/json',
  };

  Uri get baseUri;

  Future<void> initialize({
    required final String? Function() getUserId,
    final Map<String, String>? firebaseOptions,
    final bool useDefaultNotificationChannel = false,
  }) async {
    await NativePush.instance.initialize(firebaseOptions: firebaseOptions, useDefaultNotificationChannel: useDefaultNotificationChannel);
    NativePush.instance.notificationTokenStream.listen((final entry) async {
      final (system, token) = entry;
      if (token != null) {
        final userId = getUserId();
        if (userId != null) {
          await _sendTokenToServer(userId: userId, system: system, token: token);
        }
      }
    });
  }

  Stream<Map<String, String>> get notificationStream => NativePush.instance.notificationStream;

  Future<Map<String, String>?> initialNotification() async => NativePush.instance.initialNotification();

  Future<bool> registerForRemoteNotification({required final List<NotificationOption> options, final String? vapidKey}) async =>
      NativePush.instance.registerForRemoteNotification(options: options, vapidKey: vapidKey);

  Future<void> sendTokenToServer({required final String userId}) async {
    final (system, token) = await NativePush.instance.notificationToken;
    if (token != null) {
      await _sendTokenToServer(userId: userId, system: system, token: token);
    }
  }

  Future<void> deleteTokenFromServer(final String userId) async {
    final tokenId = await getTokenId();
    if (tokenId != null) {
      await http.delete(Uri.parse('$baseUri/$userId/token/$tokenId'), headers: _headers);
      await removeTokenId();
    }
  }

  Future<void> saveTokenId(final String tokenId);
  Future<String?> getTokenId();
  Future<void> removeTokenId();

  Future<void> _sendTokenToServer({
    required final String userId,
    required final NotificationService system,
    required final String token,
  }) async {
    final json = jsonEncode(
      SendNotificationRequest(
        system: system.name.toUpperCase(),
        token: token,
      ),
    );

    final tokenId = await getTokenId();
    if (tokenId != null) {
      await http.put(Uri.parse('$baseUri/$userId/token/$tokenId'), body: json, headers: _headers);
    }
    else {
      final httpResp = await http.post(Uri.parse('$baseUri/$userId/token'), body: json, headers: _headers);
      final notificationResp = AddNotificationResponse.fromJson(jsonDecode(httpResp.body));
      await saveTokenId(notificationResp.id);
    }
  }
}
