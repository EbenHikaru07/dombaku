import 'package:dombaku/dashboard/Bagian/activity_summary.dart';
import 'package:dombaku/dashboard/Bagian/kategori_menu.dart';
import 'package:dombaku/scan_object.dart';
import 'package:dombaku/session/user_session.dart';
import 'package:dombaku/starting/login.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:dombaku/carousel/carousel.dart';
import 'package:dombaku/dashboard/notification.dart';
import 'package:dombaku/bottombar/bottom_navbar.dart';
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
  int _selectedIndex = 0;
  int _notificationCount = 3;
  final String _currentDate = getCurrentDate();
  String _username = '';
  String _email = '';
  bool isPressed = false;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.selectedIndex;
    loadUserData();
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  void loadUserData() async {
    final userData = await UserSession.getUserData();
    setState(() {
      _username = userData['username'] ?? '';
      _email = userData['email'] ?? '';
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
                    padding: const EdgeInsets.fromLTRB(15, 35, 15, 16),
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
                                          (context) => AlertDialog(
                                            title: const Text("Konfirmasi"),
                                            content: const Text(
                                              "Apakah Anda yakin ingin logout?",
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed:
                                                    () =>
                                                        Navigator.pop(context),
                                                child: const Text("Batal"),
                                              ),
                                              TextButton(
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
                                                child: const Text("Logout"),
                                              ),
                                            ],
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
                                  const SizedBox(height: 4),
                                  Text(
                                    _email.isNotEmpty
                                        ? _email
                                        : 'Email belum tersedia',
                                    style: AppTextStyles.subtitle2.copyWith(
                                      color: Colors.white,
                                    ),
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
                  // const SizedBox(height: 10),
                  // Padding(
                  //   padding: AppPadding.h10,
                  //   child: Row(
                  //     children: [
                  //       Expanded(
                  //         child: Container(
                  //           decoration: BoxDecoration(
                  //             boxShadow: const [
                  //               BoxShadow(
                  //                 color: Colors.black38,
                  //                 blurRadius: 2,
                  //                 spreadRadius: 1,
                  //                 offset: Offset(2, 2),
                  //               ),
                  //             ],
                  //             borderRadius: BorderRadius.circular(10),
                  //           ),
                  //           child: TextField(
                  //             decoration: InputStyling.searchBarDashboardStyle,
                  //             style: const TextStyle(color: Colors.black),
                  //           ),
                  //         ),
                  //       ),
                  //       const SizedBox(width: 10),
                  //       GestureDetector(
                  //         onTap: () {
                  //           print('Scan icon tapped');
                  //           Navigator.push(
                  //             context,
                  //             MaterialPageRoute(
                  //               builder: (_) => EartagScannerPage(),
                  //             ),
                  //           );
                  //         },
                  //         child: Container(
                  //           height: 50,
                  //           width: 50,
                  //           decoration: BoxDecoration(
                  //             color: Color(0xff042E22),
                  //             borderRadius: BorderRadius.circular(10),
                  //             boxShadow: const [
                  //               BoxShadow(
                  //                 color: Colors.black38,
                  //                 blurRadius: 2,
                  //                 spreadRadius: 1,
                  //                 offset: Offset(2, 2),
                  //               ),
                  //             ],
                  //           ),
                  //           child: const Icon(
                  //             Icons.qr_code_scanner,
                  //             color: Colors.white,
                  //             size: 30,
                  //           ),
                  //         ),
                  //       ),
                  //     ],
                  //   ),
                  // ),
                  // const SizedBox(height: 10),
                  const SizedBox(height: 5),
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
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        hasCenterFAB: true,
      ),
      floatingActionButton: Listener(
        onPointerDown: (_) => setState(() => isPressed = true),
        onPointerUp: (_) {
          setState(() => isPressed = false);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => EartagScannerPage()),
          );
        },
        child: AnimatedContainer(
          duration: Duration(milliseconds: 150),
          height: isPressed ? 50 : 60,
          width: isPressed ? 50 : 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [Color(0xff042E22).withOpacity(0.85), Color(0xff042E22)],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Icon(
            Icons.document_scanner_outlined,
            color: Colors.white,
            size: 30,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

String getCurrentDate() {
  initializeDateFormatting('id_ID');
  DateTime now = DateTime.now();
  return DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(now);
}
