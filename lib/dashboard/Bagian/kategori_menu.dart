// kategori_menu_widget.dart

import 'package:flutter/material.dart';
import 'package:dombaku/kategori_menu/catatan_ternak.dart';
import 'package:dombaku/kategori_menu/manajemen_kandang.dart';
import 'package:dombaku/kategori_menu/rekomendasi_kawin.dart';
import 'package:dombaku/kategori_menu/riwayat_kawin.dart';
import 'package:dombaku/style.dart';

class KategoriMenuWidget extends StatefulWidget {
  const KategoriMenuWidget({Key? key}) : super(key: key);

  @override
  State<KategoriMenuWidget> createState() => _KategoriMenuWidgetState();
}

class _KategoriMenuWidgetState extends State<KategoriMenuWidget> {
  final List<Widget> kategoriPages = const [
    RekomendasiKawin(),
    ManajemenKandang(),
    RiwayatKawin(),
    ListCatatanTernak(),
  ];

  final List<IconData> kategoriIcons = [
    Icons.schema_rounded,
    Icons.manage_search,
    Icons.checklist_rounded,
    Icons.task_alt_rounded,
  ];

  final List<String> kategoriItemNames = [
    "Rekomendasi Kawin",
    "Manajemen Kandang",
    "Riwayat Kawin",
    "Riwayat Ternak",
  ];

  final List<List<Color>> gradients = [
    [Color(0xff1D679E), Color(0xff40C5A2)],
    [Color(0xff1D679E), Color(0xff40C5A2)],
    [Color(0xff1D679E), Color(0xff40C5A2)],
    [Color(0xff1D679E), Color(0xff40C5A2)],
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text("Kategori Menu", style: AppTextStyles.titleDash),
          ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          itemCount: kategoriPages.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 15,
            mainAxisSpacing: 20,
            childAspectRatio: 0.75,
          ),
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => kategoriPages[index]),
                );
              },
              child: Column(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: gradients[index],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          blurRadius: 6,
                          offset: Offset(2, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        kategoriIcons[index],
                        size: 30,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    kategoriItemNames[index],
                    textAlign: TextAlign.center,
                    style: AppTextStyles.gridText,
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
