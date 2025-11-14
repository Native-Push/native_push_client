// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'send_notification_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SendNotificationRequest _$SendNotificationRequestFromJson(
        Map<String, dynamic> json) =>
    SendNotificationRequest(
      system: json['system'] as String,
      token: json['token'] as String,
    );

Map<String, dynamic> _$SendNotificationRequestToJson(
        SendNotificationRequest instance) =>
    <String, dynamic>{
      'system': instance.system,
      'token': instance.token,
    };
