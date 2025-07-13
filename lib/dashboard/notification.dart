import 'dart:async';
import 'package:dombaku/styleui/appbarstyle.dart';
import 'package:flutter/material.dart';
import 'package:dombaku/dashboard/notification_services.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({Key? key}) : super(key: key);

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  List<String> localNotifications = [];
  late StreamSubscription _notifSubscription;

  @override
  void initState() {
    super.initState();
    NotificationService().markAllAsRead();
    localNotifications = NotificationService().notifications;

    // ✅ Simpan subscription agar bisa dicancel saat dispose
    _notifSubscription = NotificationService().notificationStream.listen((_) {
      if (!mounted) return; // ✅ Cek apakah masih di tree sebelum setState
      setState(() {
        localNotifications = NotificationService().notifications;
      });
    });
  }

  @override
  void dispose() {
    _notifSubscription
        .cancel(); // ✅ Batalkan listener untuk menghindari memory leak
    super.dispose();
  }

  void _clearNotifications() {
    NotificationService().clearNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "Notifikasi Kesehatan Domba",
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: _clearNotifications,
            tooltip: 'Hapus semua notifikasi',
          ),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        color: const Color(0xFFF9F9F9),
        child:
            localNotifications.isEmpty
                ? const Center(child: Text("Belum ada notifikasi"))
                : ListView.builder(
                  itemCount: localNotifications.length,
                  itemBuilder: (context, index) {
                    final item = localNotifications[index];
                    final lines = item.split('|');
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 3,
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '🐑 Eartag: ${lines[1]}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text('🩺 Kesehatan: ${lines[2]}'),
                            Text('📝 Keterangan: ${lines[3]}'),
                            Text('✏️ Diedit oleh: ${lines[4]}'),
                            Text('🏷️ Warna Eartag: ${lines[5]}'),
                            Text('⏰ Waktu: ${lines[6]}'),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      ),
    );
  }
}
