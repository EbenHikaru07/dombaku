import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:dombaku/styleui/appbarstyle.dart';
import 'package:lottie/lottie.dart';

class HasilRekomendasiKawin extends StatelessWidget {
  final String idDomba;

  const HasilRekomendasiKawin({super.key, required this.idDomba});

  Future<List<Map<String, dynamic>>> getRekomendasi(String idJantan) async {
    final querySnapshot =
        await FirebaseFirestore.instance
            .collection('rekomendasikawin')
            .where('id_jantan', isEqualTo: idJantan)
            .get();

    final list =
        querySnapshot.docs.map((doc) {
          final data = doc.data();
          return {
            'id_betina': data['id_betina'],
            'inbreeding': data['inbreeding']?.toStringAsFixed(0) ?? 0.0,
            'skor_kecocokan': (data['skor_kecocokan'] * 100).toStringAsFixed(1),
            'skor_value': data['skor_kecocokan'],
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
            const Text(
              "ID Domba Jantan:",
              style: TextStyle(
                fontSize: 16,
                color: Colors.black87,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xff1D679E), Color(0xff40C5A2)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Image.asset(
                    'assets/images/jantan.png',
                    width: 40,
                    height: 30,
                    fit: BoxFit.cover,
                  ),
                  SizedBox(width: 10),
                  Text(
                    idDomba,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            const Divider(thickness: 2),
            const SizedBox(height: 10),
            const Text(
              "Domba Betina yang Direkomendasikan:",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: getRekomendasi(idDomba),
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
                          Text("Memuat data..."),
                        ],
                      ),
                    );
                    ;
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
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (context, index) {
                      final item = list[index];
                      return ListTile(
                        dense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10.0,
                          vertical: 0.0,
                        ),
                        leading: Image.asset(
                          'assets/images/betina.png',
                          width: 40,
                          height: 30,
                          fit: BoxFit.cover,
                        ),
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "${item['id_betina']}",
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),

                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8.0,
                                vertical: 4.0,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: Color(0xff40C5A2),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 5,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Text(
                                "${item['skor_kecocokan']}%",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 2.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Inbreeding:"),
                              Text(
                                "${item['inbreeding']}%",
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
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
