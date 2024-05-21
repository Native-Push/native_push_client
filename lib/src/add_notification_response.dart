import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

part 'add_notification_response.g.dart';

/// A response class representing the result of adding a notification.
///
/// This class is immutable and uses the `JsonSerializable` package to handle
/// JSON serialization. It contains the `id` of the notification that was added.
@immutable
@JsonSerializable()
final class AddNotificationResponse {
  /// Creates an instance of `AddNotificationResponse` with the given [id].
  ///
  /// The [id] parameter is required and represents the unique identifier of the
  /// added notification.
  const AddNotificationResponse({required this.id});

  /// A factory constructor for creating a new `AddNotificationResponse` instance
  /// from a JSON map.
  ///
  /// The [json] parameter should contain the key-value pairs corresponding to the
  /// fields of `AddNotificationResponse`.
  ///
  /// Example usage:
  /// ```dart
  /// final response = AddNotificationResponse.fromJson(jsonMap);
  /// ```
  factory AddNotificationResponse.fromJson(final Map<String, dynamic> json) => _$AddNotificationResponseFromJson(json);

  /// The unique identifier of the added notification.
  final String id;
}
