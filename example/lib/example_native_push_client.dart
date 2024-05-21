import 'package:flutter/cupertino.dart';
import 'package:native_push_client/native_push_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// An example implementation of the [NativePushClient] class.
///
/// This class provides concrete implementations for storing, retrieving, and
/// removing the notification token identifier using [SharedPreferences].
@immutable
final class ExampleNativePushClient extends NativePushClient {
  /// Creates an instance of [ExampleNativePushClient] with the given [preferences].
  ///
  /// The [preferences] parameter is required and represents the shared preferences
  /// instance used for storing the notification token identifier.
  ExampleNativePushClient({required this.preferences});

  /// The base URI for the notification server API.
  @override
  final baseUri = Uri.parse('https://native-push.opdehipt.com/api');

  /// The shared preferences instance used for storing the notification token identifier.
  final SharedPreferences preferences;

  /// Retrieves the current notification token identifier from [SharedPreferences].
  ///
  /// Returns the token identifier as a [String], or `null` if no token identifier is stored.
  @override
  Future<String?> getTokenId() async => (await SharedPreferences.getInstance()).getString('tokenId');

  /// Removes the current notification token identifier from [SharedPreferences].
  @override
  Future<void> removeTokenId() async {
    await preferences.remove('tokenId');
  }

  /// Saves the notification token identifier to [SharedPreferences].
  ///
  /// The [tokenId] parameter is the identifier of the notification token to be stored.
  @override
  Future<void> saveTokenId(final String tokenId) async {
    await preferences.setString('tokenId', tokenId);
  }
}
