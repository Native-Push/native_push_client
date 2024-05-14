import 'package:flutter/cupertino.dart';
import 'package:native_push_client/native_push_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

@immutable
final class ExampleNativePushClient extends NativePushClient {
  ExampleNativePushClient({required this.preferences});

  @override
  final baseUri = Uri.parse('https://native-push.opdehipt.com/api');
  final SharedPreferences preferences;

  @override
  Future<String?> getTokenId() async => (await SharedPreferences.getInstance()).getString('tokenId');

  @override
  Future<void> removeTokenId() async {
    await preferences.remove('tokenId');
  }

  @override
  Future<void> saveTokenId(final String tokenId) async {
    await preferences.setString('tokenId', tokenId);
  }
}
