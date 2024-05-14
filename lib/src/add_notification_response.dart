import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

part 'add_notification_response.g.dart';

@immutable
@JsonSerializable()
final class AddNotificationResponse {
  const AddNotificationResponse({required this.id});

  factory AddNotificationResponse.fromJson(final Map<String, dynamic> json) => _$AddNotificationResponseFromJson(json);

  final String id;
}