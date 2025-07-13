import 'package:dombaku/dashboard/pendataan/detail_domba.dart';
import 'package:dombaku/session/user_session.dart';
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
  bool isLoading = true;
  TextEditingController searchController = TextEditingController();
  List<Map<String, dynamic>> dataDomba = [];
  List<Map<String, dynamic>> filteredDomba = [];
  String selectedKesehatan = 'Semua';
  String selectedGender = 'Semua';
  String selectedWarna = 'Semua';
  String sortTanggal = 'Terbaru';
  String sortBobot = 'Tertinggi';

  @override
  void initState() {
    super.initState();
    fetchDataDomba();
    searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    _applyFilters();
  }

  Future<void> fetchDataDomba() async {
    setState(() => isLoading = true);

    final userData = await UserSession.getUserData();
    final String? namaPeternak = userData['nama_peternak'];

    if (namaPeternak == null || namaPeternak.isEmpty) {
      setState(() {
        isLoading = false;
        dataDomba = [];
        filteredDomba = [];
      });
      return;
    }

    final snapshot =
        await FirebaseFirestore.instance
            .collection('manajemendomba')
            .where('nama_peternak', isEqualTo: namaPeternak)
            .get();

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
        'nama_peternak': data['nama_peternak'] ?? '',
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

  Widget _buildFilterDialog() {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Filter Data Domba',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Icon(Icons.filter_alt_rounded, color: Colors.teal),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Divider(),
            _buildDropdown(
              'Kesehatan',
              ['Semua', 'Sehat', 'Sakit', 'Mortalitas'],
              selectedKesehatan,
              (val) {
                if (val != null) setState(() => selectedKesehatan = val);
              },
            ),
            const SizedBox(height: 10),
            _buildDropdown(
              'Gender',
              ['Semua', 'Jantan', 'Betina'],
              selectedGender,
              (val) {
                if (val != null) setState(() => selectedGender = val);
              },
            ),
            const SizedBox(height: 10),
            _buildDropdown(
              'Warna Eartag',
              [
                'Semua',
                'Merah',
                'Kuning',
                'Hijau',
                'Biru',
                'Putih',
                'Hitam',
                'Orange',
                'Ungu',
                'Biru',
                'Coklat',
              ],
              selectedWarna,
              (val) {
                if (val != null) setState(() => selectedWarna = val);
              },
            ),
            const SizedBox(height: 10),
            _buildDropdown(
              'Sortir Tanggal Lahir',
              ['Terbaru', 'Terlama'],
              sortTanggal,
              (val) {
                if (val != null) setState(() => sortTanggal = val);
              },
            ),
            const SizedBox(height: 10),
            _buildDropdown(
              'Sortir Bobot',
              ['Tertinggi', 'Terendah'],
              sortBobot,
              (val) {
                if (val != null) setState(() => sortBobot = val);
              },
            ),
          ],
        ),
      ),
      actionsPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      actions: [
        TextButton.icon(
          onPressed: () {
            setState(() {
              selectedKesehatan = 'Semua';
              selectedGender = 'Semua';
              selectedWarna = 'Semua';
              sortTanggal = 'Terbaru';
              sortBobot = 'Tertinggi';
              filteredDomba = [...dataDomba];
            });
            Navigator.of(context).pop();
          },
          icon: const Icon(Icons.refresh, color: Colors.grey),
          label: const Text('Reset', style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: () {
            _applyFilters();
            Navigator.of(context).pop();
          },
          icon: const Icon(Icons.check, color: Colors.white),
          label: const Text('Terapkan', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  Widget _buildDropdown(
    String label,
    List<String> options,
    String selected,
    ValueChanged<String?> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          DropdownButton<String>(
            isExpanded: true,
            value: selected,
            items:
                options
                    .map(
                      (item) =>
                          DropdownMenuItem(value: item, child: Text(item)),
                    )
                    .toList(),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  void _applyFilters() {
    String keyword = searchController.text.toLowerCase();
    List<Map<String, dynamic>> filtered = [...dataDomba];

    filtered =
        filtered.where((d) {
          final eartag = d['eartag']?.toLowerCase() ?? '';
          return eartag.contains(keyword);
        }).toList();

    if (selectedKesehatan != 'Semua') {
      filtered =
          filtered.where((d) => d['kesehatan'] == selectedKesehatan).toList();
    }

    if (selectedGender != 'Semua') {
      filtered = filtered.where((d) => d['gender'] == selectedGender).toList();
    }

    if (selectedWarna != 'Semua') {
      filtered =
          filtered.where((d) => d['warna_eartag'] == selectedWarna).toList();
    }

    filtered.sort((a, b) {
      final tglA =
          DateTime.tryParse(a['tanggal_lahir'] ?? '') ?? DateTime(2000);
      final tglB =
          DateTime.tryParse(b['tanggal_lahir'] ?? '') ?? DateTime(2000);
      return sortTanggal == 'Terbaru'
          ? tglB.compareTo(tglA)
          : tglA.compareTo(tglB);
    });

    filtered.sort((a, b) {
      final bobotA = double.tryParse(a['bobot_badan']) ?? 0;
      final bobotB = double.tryParse(b['bobot_badan']) ?? 0;
      return sortBobot == 'Tertinggi'
          ? bobotB.compareTo(bobotA)
          : bobotA.compareTo(bobotB);
    });

    setState(() {
      filteredDomba = filtered;
    });
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
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => _buildFilterDialog(),
              );
            },
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
                                          eartag: domba['eartag'] ?? '',
                                          nama: domba['eartag'] ?? '',
                                          gender: domba['gender'] ?? '',
                                          gambar: domba['gambar'] ?? '',
                                          idIndukJantan:
                                              domba['induk_jantan'] ?? '',
                                          idIndukBetina:
                                              domba['induk_betina'] ?? '',
                                          bobot:
                                              domba['bobot_badan'] ??
                                              ''.toString(),
                                          kandang: domba["kandang"] ?? '',
                                          statusDomba: domba['kesehatan'] ?? '',
                                          tanggalLahir:
                                              domba['tanggal_lahir'] ?? '',
                                          warnaEartag:
                                              domba['warna_eartag'] ?? '',
                                          namaPeternak:
                                              domba['nama_peternak'] ?? '',
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
                                                Icons.scale_rounded,
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
                                                Icons.calendar_today,
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
    );
  }
}
