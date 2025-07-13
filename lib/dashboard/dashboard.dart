import 'dart:async';

import 'package:dombaku/dashboard/Bagian/activity_summary.dart';
import 'package:dombaku/dashboard/Bagian/kategori_menu.dart';
import 'package:dombaku/dashboard/carousel/carousel.dart';
import 'package:dombaku/dashboard/notification_services.dart';
import 'package:dombaku/session/user_session.dart';
import 'package:dombaku/starting/login.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:dombaku/dashboard/notification.dart';
// import 'package:dombaku/kategori_menu/catatan_ternak.dart';
// import 'package:dombaku/kategori_menu/manajemen_kandang.dart';
// import 'package:dombaku/kategori_menu/rekomendasi_kawin.dart';
// import 'package:dombaku/kategori_menu/riwayat_kawin.dart';
// import 'package:dombaku/starting/cover.dart';
import 'package:dombaku/style.dart';

class DashboardPage extends StatefulWidget {
  final int selectedIndex;

  const DashboardPage({super.key, this.selectedIndex = 0});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _notificationCount = 0;
  final String _currentDate = getCurrentDate();
  String _username = '';
  String _email = '';
  String _peternak = '';
  bool isPressed = false;
  late final StreamSubscription _notifSubscription;

  @override
  void initState() {
    super.initState();
    loadUserData();
    _notificationCount = NotificationService().unreadCount;

    _notifSubscription = NotificationService().notificationStream.listen((_) {
      if (!mounted) return;
      setState(() {
        _notificationCount = NotificationService().unreadCount;
      });
    });

    NotificationService().start();
  }

  @override
  void dispose() {
    _notifSubscription.cancel();
    super.dispose();
  }

  void loadUserData() async {
    final userData = await UserSession.getUserData();
    setState(() {
      _username = userData['username'] ?? '';
      _email = userData['email'] ?? '';
      _peternak = userData['nama_peternak'] ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          PreferredSize(
            preferredSize: const Size.fromHeight(200),
            child: AppBar(
              automaticallyImplyLeading: false,
              backgroundColor: const Color(0xff042E22),
              elevation: 0,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(10),
                ),
              ),
              flexibleSpace: LayoutBuilder(
                builder: (context, constraints) {
                  final screenWidth = MediaQuery.of(context).size.width;

                  return Padding(
                    padding: const EdgeInsets.fromLTRB(12, 33, 12, 15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(
                                'Halo, Sahabat DombaKu!',
                                style: AppTextStyles.subtitle.copyWith(
                                  color: Colors.white,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Row(
                              children: [
                                Stack(
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.notifications,
                                        color: Colors.white,
                                      ),
                                      onPressed: () {
                                        setState(() => _notificationCount = 0);
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (context) => NotificationPage(),
                                          ),
                                        );
                                      },
                                    ),
                                    if (_notificationCount > 0)
                                      Positioned(
                                        right: 6,
                                        top: 6,
                                        child: Container(
                                          width: 16,
                                          height: 16,
                                          decoration: const BoxDecoration(
                                            color: Colors.red,
                                            shape: BoxShape.circle,
                                          ),
                                          alignment: Alignment.center,
                                          child: Text(
                                            '$_notificationCount',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.logout,
                                    color: Colors.white,
                                  ),
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder:
                                          (context) => Dialog(
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.all(20),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  const Icon(
                                                    Icons.logout,
                                                    size: 48,
                                                    color: Colors.redAccent,
                                                  ),
                                                  const SizedBox(height: 12),
                                                  const Text(
                                                    "Keluar Aplikasi?",
                                                    style: TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 8),
                                                  const Text(
                                                    "Apakah Anda yakin ingin keluar dari aplikasi?",
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.black87,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 20),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Expanded(
                                                        child: OutlinedButton(
                                                          onPressed:
                                                              () =>
                                                                  Navigator.pop(
                                                                    context,
                                                                  ),
                                                          child: const Text(
                                                            "Batal",
                                                          ),
                                                          style: OutlinedButton.styleFrom(
                                                            foregroundColor:
                                                                Colors
                                                                    .grey[700],
                                                            side:
                                                                const BorderSide(
                                                                  color:
                                                                      Colors
                                                                          .grey,
                                                                ),
                                                            shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    10,
                                                                  ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(width: 10),
                                                      Expanded(
                                                        child: ElevatedButton(
                                                          onPressed: () async {
                                                            await UserSession.clearSession();
                                                            Navigator.pushReplacement(
                                                              context,
                                                              MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        LoginPage(),
                                                              ),
                                                            );
                                                          },
                                                          style: ElevatedButton.styleFrom(
                                                            backgroundColor:
                                                                Colors
                                                                    .redAccent,
                                                            shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    10,
                                                                  ),
                                                            ),
                                                          ),
                                                          child: const Text(
                                                            "Keluar",
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 2.0),
                        Row(
                          children: [
                            const CircleAvatar(
                              radius: 22,
                              backgroundImage: AssetImage(
                                'assets/images/man.png',
                              ),
                              backgroundColor: Colors.transparent,
                            ),
                            const SizedBox(width: 10),

                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _username.isNotEmpty ? _username : 'User',
                                    style: AppTextStyles.title.copyWith(
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    _peternak.isNotEmpty
                                        ? _peternak
                                        : 'Peternakan belum tersedia',
                                    style: AppTextStyles.subtitle2.copyWith(
                                      color: Colors.white,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),

                            Text(
                              _currentDate,
                              style: AppTextStyles.dateTimeStyle.copyWith(
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Dokumentasi Domba",
                        style: AppTextStyles.titleDash,
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  const SizedBox(height: 185, child: AutoScrollPageView()),
                  KategoriMenuWidget(),

                  const SizedBox(height: 10),

                  ActivitySummary(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String getCurrentDate() {
  initializeDateFormatting('id_ID');
  DateTime now = DateTime.now();
  return DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(now);
}
