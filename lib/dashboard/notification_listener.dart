// import 'dart:async';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:dombaku/dashboard/notification_services.dart';

// class NotificationListenerService {
//   static final List<StreamSubscription> _subscriptions = [];

//   static void start() {
//     final List<String> collectionsToWatch = [
//       'catatan_kesehatan',
//       'rekomendasikawin',
//       'manajemendomba',
//     ];

//     for (String collection in collectionsToWatch) {
//       final sub = FirebaseFirestore.instance
//           .collection(collection)
//           .snapshots()
//           .listen((snapshot) {
//         for (var change in snapshot.docChanges) {
//           if (change.type == DocumentChangeType.added) {
//             NotificationService.showNotification(
//               id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
//               title: 'Data Baru di $collection',
//               body: 'Ada data baru ditambahkan!',
//               payload: collection,
//             );
//           } else if (change.type == DocumentChangeType.modified) {
//             NotificationService.showNotification(
//               id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
//               title: 'Data Diperbarui di $collection',
//               body: 'Ada data yang diperbarui!',
//               payload: collection,
//             );
//           }
//         }
//       });

//       _subscriptions.add(sub);
//     }
//   }

//   static void stop() {
//     for (var sub in _subscriptions) {
//       sub.cancel();
//     }
//     _subscriptions.clear();
//   }
// }
