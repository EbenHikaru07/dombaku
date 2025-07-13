import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dombaku/session/user_session.dart';
import 'package:dombaku/style.dart';
import 'package:dombaku/styleui/appbarstyle.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';

class ListCatatanTernak extends StatefulWidget {
  const ListCatatanTernak({super.key});

  @override
  State<ListCatatanTernak> createState() => _ListCatatanTernakState();
}

class _ListCatatanTernakState extends State<ListCatatanTernak> {
  String _filterEartag = '';
  String? _selectedWarnaEartag;

  Future<String?> _getNamaPeternak() async {
    try {
      final userData = await UserSession.getUserData();
      return userData['nama_peternak'];
    } catch (e) {
      debugPrint("Gagal mengambil data pengguna: $e");
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> fetchRiwayatByPeternak() async {
    try {
      final namaPeternak = await _getNamaPeternak();

      if (namaPeternak == null || namaPeternak.isEmpty) {
        debugPrint("nama_peternak tidak tersedia");
        return [];
      }

      final snapshot =
          await FirebaseFirestore.instance
              .collection('riwayat')
              .where('nama_peternak', isEqualTo: namaPeternak)
              .orderBy('waktu', descending: true)
              .get();

      final allData =
          snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return data;
          }).toList();

      final filteredData =
          allData.where((doc) {
            final eartag = doc['eartag']?.toString().toLowerCase() ?? '';
            final warna = doc['warna_eartag']?.toString().toLowerCase();
            final matchesEartag =
                _filterEartag.isEmpty || eartag.contains(_filterEartag);
            final matchesWarna =
                _selectedWarnaEartag == null || warna == _selectedWarnaEartag;
            return matchesEartag && matchesWarna;
          }).toList();

      return filteredData;
    } catch (e) {
      debugPrint("Gagal mengambil data riwayat: $e");
      return [];
    }
  }

  void _showFilterModal() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Filter Warna Eartag",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal,
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Divider(thickness: 1.2),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _buildWarnaItem('merah', Colors.red, setModalState),
                      _buildWarnaItem('kuning', Colors.yellow, setModalState),
                      _buildWarnaItem('hijau', Colors.green, setModalState),
                      _buildWarnaItem('putih', Colors.white, setModalState),
                      _buildWarnaItem('hitam', Colors.black, setModalState),
                      _buildWarnaItem('orange', Colors.orange, setModalState),
                      _buildWarnaItem('ungu', Colors.purple, setModalState),
                      _buildWarnaItem('biru', Colors.blue, setModalState),
                      _buildWarnaItem('coklat', Colors.brown, setModalState),
                      _buildWarnaItem(
                        null,
                        Colors.grey,
                        setModalState,
                        label: 'Semua',
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () {
                          setState(() => _selectedWarnaEartag = null);
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.refresh, color: Colors.teal),
                        label: const Text(
                          "Reset",
                          style: TextStyle(color: Colors.teal),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.teal),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          setState(() {});
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.check, color: Colors.white),
                        label: const Text(
                          "Terapkan",
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildWarnaItem(
    String? value,
    Color color,
    Function setModalState, {
    String? label,
  }) {
    final isSelected = _selectedWarnaEartag == value;
    return GestureDetector(
      onTap: () {
        setModalState(() => _selectedWarnaEartag = value);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected ? Colors.grey.shade200 : Colors.transparent,
            ),
            padding: const EdgeInsets.all(8),
            child: Icon(
              Icons.local_offer,
              color: color,
              size: isSelected ? 30 : 26,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _capitalize(label ?? value ?? "Semua"),
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  String _capitalize(String input) {
    if (input.isEmpty) return input;
    return input[0].toUpperCase() + input.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: "Riwayat Ternak"),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 10.0,
              vertical: 10.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      flex: 5,
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Cari Eartag',
                          hintStyle: TextStyle(fontFamily: 'Exo2'),
                          prefixIcon: const Icon(
                            Icons.search,
                            color: Colors.teal,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 12,
                          ),
                          isDense: true,
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _filterEartag = value.trim().toLowerCase();
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      onPressed: _showFilterModal,
                      icon: const Icon(Icons.tune, color: Colors.teal),
                      tooltip: 'Filter Warna Eartag',
                    ),
                  ],
                ),
              ],
            ),
          ),

          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: fetchRiwayatByPeternak(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 100,
                          width: 100,
                          child: Lottie.asset(
                            'assets/animations/LoadingUn.json',
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          "Memuat data...",
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text("Terjadi kesalahan: ${snapshot.error}"),
                  );
                }

                final allData = snapshot.data ?? [];

                final filteredData =
                    allData.where((data) {
                      final eartag =
                          data['eartag']?.toString().toLowerCase() ?? '';
                      final warna =
                          data['warna_eartag']?.toString().toLowerCase() ?? '';
                      final cocokEartag = eartag.contains(_filterEartag);
                      final cocokWarna =
                          _selectedWarnaEartag == null ||
                          warna == _selectedWarnaEartag!.toLowerCase();
                      return cocokEartag && cocokWarna;
                    }).toList();

                if (filteredData.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 100,
                          width: 100,
                          child: Image.asset(
                            'assets/images/empty_data.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(height: 15),
                        const Text(
                          "Tidak ada data catatan.",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                            fontFamily: 'Exo2',
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: filteredData.length,
                  itemBuilder: (context, index) {
                    final data = filteredData[index];
                    final eartag = data['eartag'] ?? '-';
                    final warnaEartag = data['warna_eartag'] ?? '-';
                    final oleh = data['oleh'] ?? '-';
                    final kategori = data['kategori'] ?? '-';
                    final deskripsi = data['deskripsi'] ?? '-';
                    final dataSebelum =
                        data['data_sebelum'] as Map<String, dynamic>? ?? {};
                    final dataSetelah =
                        data['data_setelah'] as Map<String, dynamic>? ?? {};
                    final kandangSebelum = dataSebelum['kandang'] ?? '-';
                    final kandangSetelah = dataSetelah['kandang'] ?? '-';

                    String formattedDate = '-';
                    if (data['waktu'] != null && data['waktu'] is Timestamp) {
                      formattedDate = DateFormat(
                        'dd MMMM yyyy, HH:mm',
                        'id_ID',
                      ).format((data['waktu'] as Timestamp).toDate());
                    }

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.teal.shade500,
                                  Colors.teal.shade300,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(12),
                              ),
                            ),
                            padding: const EdgeInsets.all(10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: getColorFromWarnaEartag(warnaEartag),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.local_offer,
                                        size: 16,
                                        color:
                                            isDarkColor(
                                                  getColorFromWarnaEartag(
                                                    warnaEartag,
                                                  ),
                                                )
                                                ? Colors.white
                                                : Colors.black,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        eartag,
                                        style: TextStyle(
                                          fontFamily: 'Exo2',
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color:
                                              isDarkColor(
                                                    getColorFromWarnaEartag(
                                                      warnaEartag,
                                                    ),
                                                  )
                                                  ? Colors.white
                                                  : Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      formattedDate,
                                      style: TextStyle(
                                        fontFamily: 'Exo2',
                                        fontSize: 12,
                                        color: Colors.white70,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.person_outline,
                                          size: 14,
                                          color: Colors.white,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          oleh,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: Colors.white,
                                            fontFamily: 'Exo2',
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildKandangTransition(
                                  kandangSebelum,
                                  kandangSetelah,
                                ),
                                const Divider(height: 20),
                                _buildInfoRow(
                                  icon: Icons.widgets,
                                  label: "Kategori",
                                  value: kategori,
                                ),
                                const SizedBox(height: 10),
                                _buildInfoRow(
                                  icon: Icons.description_outlined,
                                  label: "Deskripsi",
                                  value: deskripsi,
                                  isMultiline: true,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

Widget _buildKandangTransition(String sebelum, String setelah) {
  return Container(
    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
    decoration: BoxDecoration(
      color: Colors.teal.shade50,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.teal.shade200),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Perpindahan Kandang",
          style: TextStyle(
            fontFamily: 'Exo2',
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: Colors.teal.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    sebelum,
                    style: const TextStyle(
                      fontFamily: 'Exo2',
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Icon(Icons.arrow_forward, color: Colors.teal, size: 24),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: Colors.teal.shade300,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    setelah,
                    style: const TextStyle(
                      fontFamily: 'Exo2',
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

Widget _buildInfoRow({
  required IconData icon,
  required String label,
  required String value,
  bool isMultiline = false,
}) {
  return Row(
    crossAxisAlignment:
        isMultiline ? CrossAxisAlignment.start : CrossAxisAlignment.center,
    children: [
      Icon(icon, color: Colors.teal.shade400, size: 20),
      const SizedBox(width: 10),
      Expanded(
        child: RichText(
          text: TextSpan(
            text: "$label : ",
            style: const TextStyle(
              fontFamily: 'Exo2',
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              fontSize: 14,
            ),
            children: [
              TextSpan(
                text: value,
                style: const TextStyle(
                  fontFamily: 'Exo2',
                  fontWeight: FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    ],
  );
}
