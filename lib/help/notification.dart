import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:wigoyu/app_color.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Inisialisasi plugin
  Future<void> initialize() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings(
            'app_icon'); // Ganti dengan ikon notifikasi Anda

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await _notificationsPlugin.initialize(
      initializationSettings,
    );
  }

  Future<void> onSelectNotification(String? payload) async {
    if (payload != null) {}
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails('channel_id', 'General Notifications',
            channelDescription:
                'This channel is used for general notifications.',
            importance: Importance.max,
            priority: Priority.high,
            playSound: true,
            sound: RawResourceAndroidNotificationSound('effect'),
            audioAttributesUsage: AudioAttributesUsage.notification);

    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);

    try {
      await _notificationsPlugin.show(
        id,
        title,
        body,
        notificationDetails,
        payload: payload,
      );
    } catch (e) {
      print("Error showing notification: $e");
    }
  }
}
