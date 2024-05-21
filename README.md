# Native Push Client

`native_push_client` is a Flutter library that provides a convenient interface for managing push notifications, including sending tokens to a server, receiving notifications, and handling token updates. This library utilizes `native_push` for handling platform-specific push notification operations and `shared_preferences` for token persistence.

## Features

- Initialize push notifications with Firebase options
- Listen for incoming notifications
- Register for remote notifications
- Send notification tokens to a server
- Manage notification tokens locally using shared preferences

## Installation

Add `native_push_client` to your `pubspec.yaml` file:

```yaml
dependencies:
  native_push_client:
    git:
      url: https://github.com/your_username/native_push_client.git
      ref: main
  native_push: ^1.0.0
  shared_preferences: ^2.0.13
  json_annotation: ^6.1.4

dev_dependencies:
  flutter_test:
    sdk: flutter
  build_runner: ^2.1.7
  json_serializable: ^6.1.4
  mockito: ^5.0.17
```

Then run `flutter pub get` to fetch the dependencies.

Please see [native_push](https://github.com/Native-Push/native_push) for platform instructions.

## Usage

### Example

Below is an example of how to use `native_push_client` in a Flutter application:

```dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:native_push_client/native_push_client.dart';
import 'package:uuid/uuid.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final preferences = await SharedPreferences.getInstance();
  final client = ExampleNativePushClient(preferences: preferences);
  await client.initialize(
    getUserId: () => (preferences.getString('user_id'), null),
    firebaseOptions: {
      'projectId': 'native-push-example',
      'applicationId': '1:139523781009:android:0573d8cdeb827f317f6a30',
    },
    useDefaultNotificationChannel: true,
  );

  if (!preferences.containsKey('userId')) {
    await preferences.setString('userId', const Uuid().v4());
  }

  final initialNotification = await client.initialNotification();

  client.notificationStream.listen(print);

  runApp(MyApp(client: client, preferences: preferences, initialNotification: initialNotification));
}

class MyApp extends StatelessWidget {
  const MyApp({required this.client, required this.preferences, required this.initialNotification});

  final ExampleNativePushClient client;
  final SharedPreferences preferences;
  final Map<String, dynamic>? initialNotification;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Native Push Example App'),
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Initial notification: $initialNotification'),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () async {
                  await client.registerForRemoteNotification(
                    options: [NotificationOption.alert, NotificationOption.badge, NotificationOption.sound],
                    vapidKey: 'YOUR_VAPID_KEY_HERE',
                  );
                },
                child: const Text('Register for notification'),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () async {
                  await client.sendTokenToServer(userId: preferences.getString('userId')!);
                },
                child: const Text('Send to server'),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () async {
                  print(await NativePush.instance.notificationToken);
                },
                child: const Text('Print token'),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () async {
                  await preferences.setString('userId', const Uuid().v4());
                  await preferences.remove('tokenId');
                },
                child: const Text('Reset'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

### ExampleNativePushClient

To create a custom implementation of `NativePushClient`, extend it and provide implementations for the abstract methods:

```dart
import 'package:shared_preferences/shared_preferences.dart';
import 'package:native_push_client/native_push_client.dart';

class ExampleNativePushClient extends NativePushClient {
  ExampleNativePushClient({required this.preferences});

  @override
  final baseUri = Uri.parse('https://your-api-endpoint.com/api');
  final SharedPreferences preferences;

  @override
  Future<String?> getTokenId() async => preferences.getString('tokenId');

  @override
  Future<void> saveTokenId(String tokenId) async {
    await preferences.setString('tokenId', tokenId);
  }

  @override
  Future<void> removeTokenId() async {
    await preferences.remove('tokenId');
  }
}
```

## Contributing

Contributions are welcome! Please submit a pull request or open an issue to discuss changes.

## License

This project is licensed under the BSD-3 License - see the [LICENSE](LICENSE) file for details.
