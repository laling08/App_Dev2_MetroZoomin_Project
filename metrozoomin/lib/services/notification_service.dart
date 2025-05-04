import 'package:flutter/material.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  Future<void> init() async {
    // Initialize Awesome Notifications
    await AwesomeNotifications().initialize(
      null, // Use default icon
      [
        NotificationChannel(
          channelKey: 'metro_zoomin_channel',
          channelName: 'Metro Zoomin Notifications',
          channelDescription: 'Notifications for Metro Zoomin app',
          defaultColor: Colors.blue,
          ledColor: Colors.white,
          importance: NotificationImportance.High,
          playSound: true,
          enableVibration: true,
        )
      ],
    );

    // Request notification permissions
    await requestNotificationPermissions();
  }

  Future<void> requestNotificationPermissions() async {
    await AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (!isAllowed) {
        // Show dialog to request permissions
        AwesomeNotifications().requestPermissionToSendNotifications();
      }
    });
  }

  Future<void> showNewPostNotification({
    required String username,
    required String station,
  }) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
        channelKey: 'metro_zoomin_channel',
        title: 'New Post from $username',
        body: 'Check out the new post at $station!',
        notificationLayout: NotificationLayout.Default,
        color: Colors.blue,
      ),
    );
  }

  // Listen to notification events
  Future<void> setupNotificationListeners(Function(String) onNotificationTap) async {
    AwesomeNotifications().setListeners(
      onActionReceivedMethod: (ReceivedAction receivedAction) async {
        if (receivedAction.channelKey == 'metro_zoomin_channel') {
          onNotificationTap(receivedAction.id.toString());
        }
      },
    );
  }

  // Dispose notification listeners (no need to close manually)
  void disposeNotificationListeners() {
    // Since setListeners handles streams internally, explicit disposal might not be required.
  }

}
