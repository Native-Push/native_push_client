import 'package:example/example_native_push_client.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:native_push_client/native_push_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

/// The main entry point for the application.
///
/// Initializes the necessary components for push notifications and starts the app.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Retrieve the shared preferences instance.
  final preferences = await SharedPreferences.getInstance();

  // Initialize the NativePushClient.
  final client = ExampleNativePushClient(preferences: preferences);
  await client.initialize(
    getUserId: () => (preferences.getString('user_id'), null),
    firebaseOptions: {
      'projectId': 'native-push-example',
      'applicationId': '1:139523781009:android:0573d8cdeb827f317f6a30',
      'apiKey': 'AIzaSyCkx3B99QxiM0UwVyBdOU53Y8mvZFdRsqA',
    },
    useDefaultNotificationChannel: true,
  );

  // Generate a new user ID if it doesn't exist.
  if (!preferences.containsKey('userId')) {
    await preferences.setString('userId', const Uuid().v4());
  }

  // Retrieve the initial notification if any.
  final initialNotification = await client.initialNotification();

  // Listen to the notification stream.
  client.notificationStream.listen(print);

  // Run the app.
  runApp(_MyApp(client: client, preferences: preferences, initialNotification: initialNotification));
}

/// A stateless widget that represents the main application.
///
/// This widget displays the initial notification and provides buttons to interact
/// with the push notification functionalities.
@immutable
final class _MyApp extends StatelessWidget {
  /// Creates an instance of `_MyApp`.
  ///
  /// The [client] parameter is the instance of [ExampleNativePushClient] used for managing notifications.
  /// The [preferences] parameter is the instance of [SharedPreferences] used for storing app data.
  /// The [initialNotification] parameter is the initial notification received by the app, if any.
  const _MyApp({required this.client, required this.preferences, required this.initialNotification});

  /// The instance of [ExampleNativePushClient] used for managing notifications.
  final ExampleNativePushClient client;

  /// The instance of [SharedPreferences] used for storing app data.
  final SharedPreferences preferences;

  /// The initial notification received by the app, if any.
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
                  print(await client.notificationToken);
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
