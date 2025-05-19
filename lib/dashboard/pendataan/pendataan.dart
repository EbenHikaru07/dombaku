import 'package:dombaku/bottombar/bottom_navbar.dart';
import 'package:dombaku/dashboard/pendataan/detail_domba.dart';
// import 'package:dombaku/dashboard/pendataan/tambah_data.dart';
// import 'package:dombaku/scan.dart';
import 'package:dombaku/style.dart';
import 'package:dombaku/styleui/appbarstyle2.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lottie/lottie.dart';

class PendataanPage extends StatefulWidget {
  const PendataanPage({super.key});

  @override
  State<PendataanPage> createState() => _PendataanPageState();
}

class _PendataanPageState extends State<PendataanPage> {
  int _selectedIndex = 1;
  bool isLoading = true;
  TextEditingController searchController = TextEditingController();
  List<Map<String, dynamic>> dataDomba = [];
  List<Map<String, dynamic>> filteredDomba = [];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchDataDomba();
    searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    String keyword = searchController.text.toLowerCase();
    setState(() {
      filteredDomba =
          dataDomba.where((domba) {
            return domba['eartag'].toLowerCase().contains(keyword);
          }).toList();
    });
  }

  Future<void> fetchDataDomba() async {
    setState(() => isLoading = true);

    final snapshot =
        await FirebaseFirestore.instance.collection('manajemendomba').get();
    final List<Map<String, dynamic>> loadedData = [];

    for (var doc in snapshot.docs) {
      final data = doc.data();
      String jenisKelamin = data['kelamin'] ?? '';
      String gambar =
          jenisKelamin == 'Jantan'
              ? 'assets/images/jantan.png'
              : 'assets/images/betina.png';

      loadedData.add({
        'eartag': data['eartag'] ?? '',
        'nama': data['eartag'] ?? '',
        'gender': jenisKelamin,
        'gambar': gambar,
        'induk_jantan': data['induk_jantan'] ?? '',
        'induk_betina': data['induk_betina'] ?? '',
        'bobot_badan':
            data['bobot_badan'] != null ? data['bobot_badan'].toString() : '',
        'kandang': data['kandang'] ?? '',
        'kesehatan': data['kesehatan'] ?? '',
        'keterangan': data['keterangan'] ?? '',
        'warna_eartag': data['warna_eartag'] ?? '',
        'tanggal_lahir': data['tanggal_lahir'] ?? '',
      });
    }

    setState(() {
      dataDomba = loadedData;
      filteredDomba = loadedData;
      isLoading = false;
    });
  }

  Color _getStatusColor(String? status) {
    if (status == 'Sehat') {
      return Colors.green.withOpacity(0.2);
    } else if (status == 'Mortalitas') {
      return Colors.red.withOpacity(0.2);
    } else if (status == 'Sakit') {
      return Colors.yellow.withOpacity(0.2);
    } else {
      return Colors.grey.withOpacity(0.2);
    }
  }

  Color _getTextColor(String? status) {
    if (status == 'Sehat') {
      return Colors.green;
    } else if (status == 'Mortalitas') {
      return Colors.red;
    } else if (status == 'Sakit') {
      return Colors.yellow;
    } else {
      return Colors.grey;
    }
  }

  Color _getTextColorFromBackground(Color bgColor) {
    return bgColor.computeLuminance() > 0.5 ? Colors.black : Colors.white;
  }

  Color _getColorFromWarnaEartag(String warna) {
    switch (warna.toLowerCase()) {
      case 'merah':
        return Colors.red;
      case 'kuning':
        return Colors.yellow.shade700;
      case 'hijau':
        return Colors.green;
      case 'putih':
        return Colors.white;
      case 'hitam':
        return Colors.black;
      case 'orange':
        return Colors.orange;
      case 'ungu':
        return Colors.purple;
      case 'biru':
        return Colors.blue;
      case 'coklat':
        return Colors.brown;
      default:
        return Colors.grey.shade400;
    }
  }

  String hitungUmur(String tanggalLahir) {
    if (tanggalLahir.isEmpty) return '-';

    try {
      final birthDate = DateTime.parse(tanggalLahir);
      final now = DateTime.now();

      int tahun = now.year - birthDate.year;
      int bulan = now.month - birthDate.month;
      int hari = now.day - birthDate.day;

      if (hari < 0) {
        final prevMonth = DateTime(now.year, now.month, 0);
        hari += prevMonth.day;
        bulan--;
      }

      if (bulan < 0) {
        bulan += 12;
        tahun--;
      }

      String umur = '';
      if (tahun > 0) umur += '$tahun thn ';
      if (bulan > 0) umur += '$bulan bln ';
      if (hari > 0) umur += '$hari hr';

      return umur.trim().isEmpty ? 'Baru lahir' : umur.trim();
    } catch (e) {
      return '-';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF0F0F0),
      appBar: CustomAppBar2(
        title: "Data Domba",
        actions: [
          IconButton(
            icon: const Icon(Icons.tornado_rounded, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 2),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12.withOpacity(0.1),
                    blurRadius: 3,
                    spreadRadius: 2,
                    offset: const Offset(1, 3),
                  ),
                ],
              ),
              child: TextField(
                controller: searchController,
                decoration: InputStyling.searchBarDataStyle,
                style: const TextStyle(color: Colors.black),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child:
                  isLoading
                      ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 100,
                              height: 100,
                              child: Lottie.asset(
                                'assets/animations/LoadingUn.json',
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              "Memuat data...",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      )
                      : ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        itemCount: filteredDomba.length,
                        itemBuilder: (context, index) {
                          final domba = filteredDomba[index];
                          return Card(
                            color: Colors.white,
                            margin: const EdgeInsets.symmetric(vertical: 7),
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(10),
                              onTap: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => DetailDombaPage(
                                          eartag: domba['eartag']!,
                                          nama: domba['eartag']!,
                                          gender: domba['gender']!,
                                          gambar: domba['gambar']!,
                                          idIndukJantan: domba['induk_jantan']!,
                                          idIndukBetina: domba['induk_betina']!,
                                          bobot:
                                              domba['bobot_badan']!.toString(),
                                          kandang: domba["kandang"]!,
                                          statusDomba: domba['kesehatan']!,
                                          tanggalLahir: domba['tanggal_lahir']!,
                                          warnaEartag:
                                              domba['warna_eartag'] ?? '',
                                        ),
                                  ),
                                );

                                if (result != null && result == 'refresh') {
                                  await fetchDataDomba();
                                }
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(50),
                                      child: Image.asset(
                                        domba['gambar']!,
                                        width: 60,
                                        height: 60,
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 5,
                                            ),
                                            decoration: BoxDecoration(
                                              color: _getColorFromWarnaEartag(
                                                domba['warna_eartag'] ?? '',
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                              border: Border.all(
                                                color: Colors.black12,
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  Icons.local_offer,
                                                  size: 16,
                                                  color: _getTextColorFromBackground(
                                                    _getColorFromWarnaEartag(
                                                      domba['warna_eartag'] ??
                                                          '',
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 6),
                                                Text(
                                                  domba['eartag'] ??
                                                      'Tidak tersedia',
                                                  style: AppTextStyles.titleBlack.copyWith(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.w600,
                                                    color: _getTextColorFromBackground(
                                                      _getColorFromWarnaEartag(
                                                        domba['warna_eartag'] ??
                                                            '',
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(height: 8.0),
                                          Row(
                                            children: [
                                              if (domba['gender'] == 'Betina')
                                                Icon(
                                                  Icons.female,
                                                  size: 20,
                                                  color: Colors.pinkAccent,
                                                )
                                              else if (domba['gender'] ==
                                                  'Jantan')
                                                Icon(
                                                  Icons.male,
                                                  size: 20,
                                                  color: Colors.blueAccent,
                                                )
                                              else
                                                Icon(
                                                  Icons.help_outline,
                                                  size: 20,
                                                  color: Colors.grey,
                                                ),

                                              const SizedBox(width: 12),

                                              Icon(
                                                Icons.access_time,
                                                size: 14,
                                                color: Colors.grey[600],
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                '${domba['bobot_badan'] ?? '-'} kg',
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.grey[800],
                                                ),
                                              ),
                                              const SizedBox(width: 12),

                                              Icon(
                                                Icons.cake,
                                                size: 14,
                                                color: Colors.grey[600],
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                hitungUmur(
                                                  domba['tanggal_lahir'] ?? '',
                                                ),
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.grey[800],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: _getStatusColor(
                                              domba['kesehatan'] ??
                                                  'Tidak tersedia',
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                          ),
                                          child: Text(
                                            domba['kesehatan'] ??
                                                'Tidak tersedia',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: _getTextColor(
                                                domba['kesehatan'] ??
                                                    'Tidak tersedia',
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
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
        hasCenterFAB: false,
      ),
    );
  }
}
