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

    _notifSubscription = NotificationService().notificationStream.listen((_) {
      if (!mounted) return;
      setState(() {
        localNotifications = NotificationService().notifications;
      });
    });
  }

  @override
  void dispose() {
    _notifSubscription
        .cancel();
    super.dispose();
  }

  void _clearNotifications() {
    NotificationService().clearNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "Notifikasi Kesehatan",
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

                    if (lines.length < 7) {
                      return const Card(
                        color: Colors.redAccent,
                        margin: EdgeInsets.symmetric(vertical: 6),
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Text(
                            '⚠️ Format notifikasi tidak valid.',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      );
                    }

                    final eartag = lines[1];
                    final kesehatan = lines[2];
                    final keterangan = lines[3];
                    final editby = lines[4];
                    final warnaEartag = lines[5];
                    final waktu = lines[6];

                    final waktuParts = waktu.split(' ');
                    final tanggal = waktuParts.isNotEmpty ? waktuParts[0] : '-';
                    final jam = waktuParts.length > 1 ? waktuParts[1] : '-';

                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 3,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '🐑 Eartag: $eartag',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      tanggal,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    Text(
                                      jam,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            _infoRow(
                              Icons.favorite,
                              'Kesehatan',
                              kesehatan,
                              Colors.green,
                            ),
                            const SizedBox(height: 6),
                            _infoRow(
                              Icons.notes,
                              'Keterangan',
                              keterangan,
                              Colors.blueGrey,
                            ),
                            const SizedBox(height: 6),
                            _infoRow(
                              Icons.label,
                              'Warna Eartag',
                              warnaEartag,
                              Colors.orange,
                            ),

                            const SizedBox(height: 12),
                            const Divider(thickness: 1.2),
                            const SizedBox(height: 6),

                            Row(
                              children: [
                                const Icon(
                                  Icons.edit,
                                  color: Colors.deepPurple,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Diedit oleh: $editby',
                                    style: const TextStyle(
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                              ],
                            ),
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

Widget _infoRow(IconData icon, String label, String value, Color color) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(icon, color: color, size: 20),
      const SizedBox(width: 8),
      Expanded(
        child: RichText(
          text: TextSpan(
            style: const TextStyle(fontSize: 14, color: Colors.black87),
            children: [
              TextSpan(
                text: '$label: ',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              TextSpan(text: value),
            ],
          ),
        ),
      ),
    ],
  );
}
