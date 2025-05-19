import 'package:cloud_firestore/cloud_firestore.dart';
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

  Stream<List<Map<String, dynamic>>> getRiwayatStream() {
    return FirebaseFirestore.instance
        .collection('riwayat')
        .orderBy('waktu', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return data;
          }).toList();
        });
  }

  Color _parseColorFromString(String colorName) {
    switch (colorName.toLowerCase()) {
      case 'merah':
        return Colors.red;
      case 'biru':
        return Colors.blue;
      case 'kuning':
        return Colors.yellow.shade700;
      case 'hijau':
        return Colors.green;
      case 'hitam':
        return Colors.black;
      case 'putih':
        return Colors.white;
      case 'ungu':
        return Colors.purple;
      case 'coklat':
        return Colors.brown;
      case 'abu':
      case 'abu-abu':
        return Colors.grey;
      default:
        return Colors.grey.shade800;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: "Riwayat Ternak"),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Cari berdasarkan Eartag Domba',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _filterEartag = value.trim().toLowerCase();
                });
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: getRiwayatStream(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('Terjadi kesalahan.'));
                }

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

                final filteredData =
                    snapshot.data!.where((data) {
                      final eartag =
                          data['eartag']?.toString().toLowerCase() ?? '';
                      return eartag.contains(_filterEartag);
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
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: filteredData.length,
                  itemBuilder: (context, index) {
                    final data = filteredData[index];
                    final dataSebelum =
                        data['data_sebelum'] as Map<String, dynamic>? ?? {};
                    final dataSetelah =
                        data['data_setelah'] as Map<String, dynamic>? ?? {};

                    String kandangSebelum = dataSebelum['kandang'] ?? '-';
                    String kandangSetelah = dataSetelah['kandang'] ?? '-';
                    String deskripsi = data['deskripsi'] ?? '-';
                    String eartag = data['eartag'] ?? '-';
                    String kategori = data['kategori'] ?? '-';
                    String oleh = data['oleh'] ?? '-';
                    String warnaEartag = data['warna_eartag'] ?? '-';

                    String formattedDate = '-';
                    if (data['waktu'] != null && data['waktu'] is Timestamp) {
                      Timestamp waktu = data['waktu'];
                      formattedDate = DateFormat(
                        'dd MMMM yyyy, HH:mm',
                        'id_ID',
                      ).format(waktu.toDate());
                    }

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.teal.shade400,
                                  Colors.teal.shade200,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(12),
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 10,
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 24,
                                  backgroundColor: _parseColorFromString(
                                    warnaEartag,
                                  ),
                                  child: Text(
                                    eartag,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.category,
                                            size: 16,
                                            color: Colors.white,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            kategori,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.access_time,
                                            size: 14,
                                            color: Colors.white70,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            formattedDate,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.teal.shade100,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
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
                                  icon: Icons.person_outline,
                                  label: "Oleh",
                                  value: oleh,
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
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              fontSize: 14,
            ),
            children: [
              TextSpan(
                text: value,
                style: const TextStyle(fontWeight: FontWeight.normal),
              ),
            ],
          ),
        ),
      ),
    ],
  );
}
