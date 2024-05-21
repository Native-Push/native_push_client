import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

part 'send_notification_request.g.dart';

/// A request class representing the data required to send a notification token to the server.
///
/// This class is immutable and uses the `JsonSerializable` package to handle
/// JSON serialization. It contains the notification system and the token.
@immutable
@JsonSerializable()
final class SendNotificationRequest {
  /// Creates an instance of `SendNotificationRequest` with the given [system] and [token].
  ///
  /// The [system] parameter is required and represents the notification service system.
  /// The [token] parameter is required and represents the notification token.
  const SendNotificationRequest({required this.system, required this.token});

  /// The notification service system (e.g., "FCM", "APNS").
  final String system;

  /// The notification token associated with the system.
  final String token;

  /// Converts this `SendNotificationRequest` instance to a JSON map.
  ///
  /// This method is used for serializing the instance to JSON format.
  ///
  /// Example usage:
  /// ```dart
  /// final json = sendNotificationRequestInstance.toJson();
  /// ```
  Map<String, dynamic> toJson() => _$SendNotificationRequestToJson(this);
}
