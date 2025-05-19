import 'package:dombaku/styleui/appbarstyle.dart';
import 'package:flutter/material.dart';

class NotificationItem {
  final String message;

  NotificationItem({required this.message});
}

class NotificationPage extends StatefulWidget {
  const NotificationPage({Key? key}) : super(key: key);

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  List<NotificationItem> notifications = [];

  @override
  void initState() {
    super.initState();
    notifications = [
      NotificationItem(message: "Domba ID 011 telah dikawinkan"),
      NotificationItem(message: "Jumlah domba saat ini 50 ekor"),
      NotificationItem(message: "Domba ID 007 mengalami gejala sakit"),
      NotificationItem(message: "Domba baru telah ditambahkan"),
      NotificationItem(message: "Domba ID 023 berhasil dikawinkan"),
      NotificationItem(message: "Domba ID 005 menunjukkan kesehatan menurun"),
      NotificationItem(message: "Jumlah domba bertambah menjadi 51 ekor"),
    ];
  }

  Icon _getIconByMessage(String message) {
    if (message.contains("kawin")) {
      return const Icon(Icons.favorite, color: Colors.pink);
    } else if (message.contains("sakit") || message.contains("kesehatan")) {
      return const Icon(Icons.warning_amber, color: Colors.red);
    } else if (message.contains("Jumlah") ||
        message.contains("bertambah") ||
        message.contains("domba baru")) {
      return const Icon(Icons.pets, color: Colors.green);
    } else {
      return const Icon(Icons.notifications, color: Colors.grey);
    }
  }

  Color _getCardColor(String message) {
    if (message.contains("kawin")) {
      return Colors.pink.shade50;
    } else if (message.contains("sakit") || message.contains("kesehatan")) {
      return Colors.red.shade50;
    } else if (message.contains("Jumlah") ||
        message.contains("bertambah") ||
        message.contains("domba baru")) {
      return Colors.green.shade50;
    } else {
      return Colors.grey.shade100;
    }
  }

  void _deleteAllNotifications() {
    setState(() {
      notifications.clear();
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Semua notifikasi dihapus")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "Notifikasi Domba",
        actions:
            notifications.isNotEmpty
                ? [
                  IconButton(
                    icon: const Icon(Icons.delete_forever),
                    tooltip: "Hapus Semua",
                    onPressed: _deleteAllNotifications,
                  ),
                ]
                : null,
      ),

      body:
          notifications.isEmpty
              ? const Center(child: Text("Tidak ada notifikasi"))
              : ListView.builder(
                itemCount: notifications.length,
                padding: const EdgeInsets.all(12),
                itemBuilder: (context, index) {
                  final notif = notifications[index];
                  return Dismissible(
                    key: UniqueKey(),
                    direction: DismissDirection.endToStart,
                    onDismissed: (direction) {
                      setState(() {
                        notifications.removeAt(index);
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Notifikasi dihapus")),
                      );
                    },
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      color: Colors.red,
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    child: Card(
                      color: _getCardColor(notif.message),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 3,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        leading: _getIconByMessage(notif.message),
                        title: Text(
                          notif.message,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Notifikasi: ${notif.message}'),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
