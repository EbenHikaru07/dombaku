import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dombaku/session/user_session.dart';
import 'package:dombaku/style.dart';
import 'package:flutter/material.dart';
import 'package:dombaku/styleui/appbarstyle.dart';
import 'package:lottie/lottie.dart';

class HasilRekomendasiKawin extends StatefulWidget {
  final String idDomba;

  const HasilRekomendasiKawin({super.key, required this.idDomba});

  @override
  State<HasilRekomendasiKawin> createState() => _HasilRekomendasiKawinState();
}

class _HasilRekomendasiKawinState extends State<HasilRekomendasiKawin> {
  Color getColorFromName(String? colorName) {
    switch (colorName?.toLowerCase()) {
      case 'kuning':
        return Colors.yellow.shade600;
      case 'hijau':
        return Colors.green.shade600;
      case 'merah':
        return Colors.red.shade600;
      case 'biru':
        return Colors.blue.shade600;
      case 'putih':
        return Colors.white;
      case 'orange':
        return Colors.orange.shade600;
      case 'ungu':
        return Colors.purple.shade600;
      default:
        return Colors.grey;
    }
  }

  Color _getTextColorFromBackground(Color bgColor) {
    return bgColor.computeLuminance() > 0.5 ? Colors.black : Colors.white;
  }

  Future<List<Map<String, dynamic>>> getRekomendasi(String idJantan) async {
    final userData = await UserSession.getUserData();
    final namaPeternak = userData['nama_peternak'];

    if (namaPeternak == null) {
      return [];
    }

    final querySnapshot =
        await FirebaseFirestore.instance
            .collection('rekomendasikawin')
            .where('id_jantan', isEqualTo: idJantan)
            .where('nama_peternak', isEqualTo: namaPeternak)
            .get();

    final list =
        querySnapshot.docs.map((doc) {
          final data = doc.data();
          return {
            'id_betina': data['id_betina'],
            'inbreeding':
                data['koefisien_inbreeding']?.toStringAsFixed(0) ?? '0',
            'skor_kecocokan': (data['skor_kecocokan'] * 100).toStringAsFixed(1),
            'skor_value': data['skor_kecocokan'],
            'warna_eartag_betina': data['warna_eartag_betina'],
            'warna_eartag_jantan': data['warna_eartag_jantan'],
          };
        }).toList();

    list.sort(
      (a, b) => (b['skor_value'] as num).compareTo(a['skor_value'] as num),
    );

    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(title: "Hasil Rekomendasi"),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("ID Domba Jantan:", style: HasilRekomendasiStyle.title),
            const SizedBox(height: 10),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: getRekomendasi(widget.idDomba),
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done ||
                    !snapshot.hasData ||
                    snapshot.data!.isEmpty) {
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: 15,
                      horizontal: 10,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xff1D679E), Color(0xff40C5A2)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Image.asset(
                          'assets/images/jantan.png',
                          width: 40,
                          height: 30,
                          fit: BoxFit.cover,
                        ),
                        const SizedBox(width: 10),
                        const Icon(
                          Icons.local_offer,
                          size: 15,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          widget.idDomba,
                          style: HasilRekomendasiStyle.eartag,
                        ),
                      ],
                    ),
                  );
                }

                final jantanColor = getColorFromName(
                  snapshot.data!.first['warna_eartag_jantan'],
                );
                final jantanTextColor = _getTextColorFromBackground(
                  jantanColor,
                );

                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 15,
                    horizontal: 10,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xff1D679E), Color(0xff40C5A2)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Image.asset(
                        'assets/images/jantan.png',
                        width: 40,
                        height: 30,
                        fit: BoxFit.cover,
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: jantanColor,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.local_offer,
                              size: 15,
                              color: jantanTextColor,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              widget.idDomba,
                              style: TextStyle(
                                fontFamily: 'Exo2',
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: jantanTextColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 2),
            const Divider(thickness: 2),
            const SizedBox(height: 2),
            const Text(
              "Domba Betina yang Direkomendasikan:",
              style: HasilRekomendasiStyle.title,
            ),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: getRekomendasi(widget.idDomba),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Lottie.asset(
                            'assets/animations/LoadingUn.json',
                            width: 100,
                            height: 100,
                            fit: BoxFit.contain,
                          ),
                          const Text("Memuat data..."),
                        ],
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return const Center(child: Text("Terjadi kesalahan"));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text("Tidak ada data ditemukan"),
                    );
                  }

                  final list = snapshot.data!;

                  return ListView.separated(
                    itemCount: list.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final item = list[index];
                      final betinaColor = getColorFromName(
                        item['warna_eartag_betina'],
                      );
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                          border: Border.all(
                            color: const Color(0xff40C5A2),
                            width: 1,
                          ),
                        ),
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              child: Image.asset(
                                'assets/images/betina.png',
                                width: 40,
                                height: 30,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: betinaColor,
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.local_offer,
                                          size: 16,
                                          color: _getTextColorFromBackground(
                                            betinaColor,
                                          ),
                                        ),
                                        const SizedBox(width: 5),
                                        Text(
                                          item['id_betina'] ?? 'Tidak tersedia',
                                          style: TextStyle(
                                            fontFamily: 'Exo2',
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                            color: _getTextColorFromBackground(
                                              betinaColor,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xff40C5A2),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        "${item['skor_kecocokan']}%",
                                        style: HasilRekomendasiStyle.persen,
                                      ),
                                    ),
                                    const Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 4,
                                      ),
                                      child: Text(
                                        '/',
                                        style: TextStyle(fontSize: 16),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.orangeAccent,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        "${item['inbreeding']}%",
                                        style: HasilRekomendasiStyle.persen,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                const Text(
                                  "Kecocokan / Inbreeding",
                                  style: HasilRekomendasiStyle.keterangan,
                                ),
                              ],
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
      ),
    );
  }
}
