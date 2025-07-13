import 'package:dombaku/bottombar/bottom_navbar.dart';
import 'package:flutter/material.dart';
import 'package:dombaku/dashboard/dashboard.dart';
import 'package:dombaku/dashboard/kesehatan/kesehatan.dart';
import 'package:dombaku/dashboard/laporan.dart';
import 'package:dombaku/dashboard/pendataan/pendataan.dart';
import 'package:dombaku/scan_object.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  bool isPressed = false;

  final List<Widget> _pages = [
    const DashboardPage(key: ValueKey("Dashboard")),
    const PendataanPage(key: ValueKey("Pendataan")),
    const LaporanPage(key: ValueKey("Laporan")),
    const KesehatanPage(key: ValueKey("Kesehatan")),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex], // ← Tanpa animasi
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
        hasCenterFAB: _selectedIndex == 0,
      ),
      floatingActionButton:
          _selectedIndex == 0
              ? Listener(
                onPointerDown: (_) => setState(() => isPressed = true),
                onPointerUp: (_) {
                  setState(() => isPressed = false);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => EartagScannerPage()),
                  );
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  height: isPressed ? 50 : 60,
                  width: isPressed ? 50 : 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xff042E22),
                        const Color(0xff042E22).withOpacity(0.9),
                      ],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.document_scanner_outlined,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              )
              : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
