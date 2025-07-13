import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  final Set<String> _unreadNotificationIds = {};

  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  final List<String> _notifications = [];
  final StreamController<String> _streamController =
      StreamController<String>.broadcast();

  Stream<String> get notificationStream => _streamController.stream;

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);
    _initialized = true;
  }

  Future<void> start() async {
    await initialize();
    _listenToFirestoreNotifications();
  }

  void _listenToFirestoreNotifications() {
    FirebaseFirestore.instance
        .collection('catatan_kesehatan')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .listen((snapshot) {
          for (var docChange in snapshot.docChanges) {
            if (docChange.type == DocumentChangeType.added ||
                docChange.type == DocumentChangeType.modified) {
              final docId = docChange.doc.id;
              final data = docChange.doc.data();
              if (data == null) continue;

              final eartag = data['eartag'] ?? 'Unknown';
              final kesehatan = data['kesehatan'] ?? 'Unknown';
              final keterangan = data['keterangan'] ?? '';
              final editby = data['editby'] ?? '';
              final warna = data['warna_eartag'] ?? '-';
              final timestamp = data['timestamp']?.toDate();

              // ✅ Filter berdasarkan waktu lokal: hanya data terbaru yang di-notif
              final now = DateTime.now().toLocal();
              if (timestamp == null || timestamp.toLocal().isBefore(now)) {
                continue; // Lewati jika timestamp sudah lewat
              }

              final formattedTime =
                  "${timestamp.day}/${timestamp.month}/${timestamp.year} ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}";

              final uiMessage =
                  "$docId|$eartag|$kesehatan|$keterangan|$editby|$warna|$formattedTime";
              final notifMessage =
                  "Eartag: $eartag\nStatus: $kesehatan\n$keterangan";

              if (!_notifications.contains(uiMessage)) {
                _notifications.insert(0, uiMessage);
                _unreadNotificationIds.add(docId);
                _streamController.add(uiMessage);
                _showLocalNotification(
                  "Perubahan Kesehatan Domba",
                  notifMessage,
                );
              }
            }
          }
        });
  }

  int get unreadCount => _unreadNotificationIds.length;

  void markAllAsRead() {
    _unreadNotificationIds.clear();
    _streamController.add("");
  }

  void _showLocalNotification(String title, String body) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'channel_id',
          'Notifikasi',
          channelDescription: 'Notifikasi Kesehatan Domba',
          icon: '@drawable/ic_stat_dombaku',
          importance: Importance.max,
          priority: Priority.high,
        );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    await _flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      notificationDetails,
    );
  }

  List<String> get notifications => List.unmodifiable(_notifications);

  void clearNotifications() {
    _notifications.clear();
    _streamController.add("");
  }

  void dispose() {
    _streamController.close();
  }
}
