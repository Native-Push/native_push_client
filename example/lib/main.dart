import 'package:example/example_native_push_client.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:native_push/native_push.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final preferences = await SharedPreferences.getInstance();
  final client = ExampleNativePushClient(preferences: preferences);
  await client.initialize(
    getUserId: () => preferences.getString('user_id'),
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

  runApp(_MyApp(client: client, preferences: preferences, initialNotification: initialNotification));
}

@immutable
final class _MyApp extends StatelessWidget {
  const _MyApp({required this.client, required this.preferences, required this.initialNotification});

  final ExampleNativePushClient client;
  final SharedPreferences preferences;
  final Map<String, dynamic>? initialNotification;

  @override
  Widget build(final BuildContext context) =>
    MaterialApp(
      darkTheme: ThemeData.dark(),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Native push example app'),
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
                    vapidKey: 'BJ4L7FepzRMspZY/utSAxySfXJVw0THgsWIGV5gausv5mvbXW103EfxQkBlXDYC+Z3nsOduWQNBlJrn6pqdQP3Y=',
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

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<ExampleNativePushClient>('client', client))
      ..add(DiagnosticsProperty<SharedPreferences>('preferences', preferences));
  }
}
