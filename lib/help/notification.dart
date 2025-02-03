import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Inisialisasi plugin
  Future<void> initialize() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings(
            '@mipmap/ic_launcher'); // Ganti dengan ikon notifikasi Anda

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await _notificationsPlugin.initialize(
      initializationSettings,
    );
  }

  // Fungsi callback ketika notifikasi di-tap
  Future<void> onSelectNotification(String? payload) async {
    // Tambahkan logika Anda di sini, seperti navigasi ke halaman tertentu
    if (payload != null) {
      // print("Payload notifikasi: $payload");
    }
  }

  // Fungsi untuk menampilkan notifikasi biasa
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'channel_id', // ID channel
      'General Notifications', // Nama channel
      channelDescription: 'This channel is used for general notifications.',
      importance: Importance.high,
      priority: Priority.high,
      ticker: 'ticker',
    );

    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);

    try {
      await _notificationsPlugin.show(
        id, // ID unik notifikasi
        title, // Judul notifikasi
        body, // Isi notifikasi
        notificationDetails,
        payload: payload, // Data tambahan yang bisa dikirim bersama notifikasi
      );
    } catch (e) {
      print("Error showing notification: $e");
    }
  }
}
