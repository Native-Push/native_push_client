import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

part 'send_notification_request.g.dart';

@immutable
@JsonSerializable()
final class SendNotificationRequest {
  const SendNotificationRequest({required this.system, required this.token});

  final String system;
  final String token;

  Map<String, dynamic> toJson() => _$SendNotificationRequestToJson(this);
}