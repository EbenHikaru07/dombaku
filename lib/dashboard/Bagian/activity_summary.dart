import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dombaku/session/user_session.dart';
import 'package:flutter/material.dart';
import 'package:dombaku/style.dart';
import 'package:lottie/lottie.dart';

class ActivitySummary extends StatelessWidget {
  const ActivitySummary({super.key});

  Stream<Map<String, dynamic>> getDataRingkasanStream() async* {
    final userData = await UserSession.getUserData();
    final String? namaPeternak = userData['nama_peternak'];

    if (namaPeternak == null) {
      yield {
        'total': 0,
        'sehat': 0,
        'sakit': 0,
        'mortalitas': 0,
        'tidakDiketahui': 0,
        'persenSehat': '0.0',
      };
      return;
    }

    yield* FirebaseFirestore.instance
        .collection('manajemendomba')
        .where('nama_peternak', isEqualTo: namaPeternak)
        .snapshots()
        .map((snapshot) {
          int total = snapshot.docs.length;
          int sehat = 0;
          int sakit = 0;
          int mortalitas = 0;
          int tidakDiketahui = 0;

          for (var doc in snapshot.docs) {
            final data = doc.data() as Map<String, dynamic>;
            final status = data['kesehatan']?.toString().toLowerCase();

            if (status == 'sehat') {
              sehat++;
            } else if (status == 'sakit') {
              sakit++;
            } else if (status == 'mortalitas') {
              mortalitas++;
            } else {
              tidakDiketahui++;
            }
          }

          double persenSehat = total > 0 ? (sehat / total) * 100 : 0;

          return {
            'total': total,
            'sehat': sehat,
            'sakit': sakit,
            'mortalitas': mortalitas,
            'tidakDiketahui': tidakDiketahui,
            'persenSehat': persenSehat.toStringAsFixed(1),
          };
        });
  }

  Future<int> getJumlahKelahiranHariIni() async {
    final userData = await UserSession.getUserData();
    final String? namaPeternak = userData['nama_peternak'];
    if (namaPeternak == null) return 0;

    final today = DateTime.now();
    final formattedToday =
        "${today.year.toString().padLeft(4, '0')}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";

    final snapshot =
        await FirebaseFirestore.instance
            .collection('manajemenkelahiran')
            .where('tanggal_lahir', isEqualTo: formattedToday)
            .where('nama_peternak', isEqualTo: namaPeternak)
            .get();

    return snapshot.docs.length;
  }

  Future<String> getRingkasanPerkawinan() async {
    final userData = await UserSession.getUserData();
    final String? namaPeternak = userData['nama_peternak'];
    if (namaPeternak == null) return "0 / 0.00%";

    final snapshot =
        await FirebaseFirestore.instance
            .collection('rekomendasikawin')
            .where('nama_peternak', isEqualTo: namaPeternak)
            .get();

    int totalBetina = snapshot.docs.length;
    double totalRasio = 0;

    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final rasio = double.tryParse(data['skor_kecocokan'].toString()) ?? 0;
      totalRasio += rasio;
    }

    double rataRasio = totalBetina > 0 ? totalRasio / totalBetina : 0;
    return '$totalBetina / ${(rataRasio).toStringAsFixed(2)}%';
  }

  @override
  Widget build(BuildContext context) {
    List<String> labels = [
      "Jumlah Domba",
      "Kesehatan Ternak",
      "Kelahiran",
      "Perkawinan",
    ];

    List<String> values = ["Null", "Null", "Null", "Null"];

    List<List<Color>> gradientColors = [
      [Color(0xff1D679E), Color(0xff40C5A2)],
      [Color(0xff1D679E), Color(0xff40C5A2)],
      [Colors.purple.shade200, Colors.red.shade400],
      [Colors.purple.shade200, Colors.red.shade400],
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                Text(
                  "Ringkasan Aktivitas Hari Ini",
                  style: AppTextStyles.titleDash,
                ),
                SizedBox(width: 5),
                Icon(Icons.error_outline, color: Colors.red, size: 20),
              ],
            ),
          ),
        ),
        const SizedBox(height: 5.0),

        StreamBuilder<Map<String, dynamic>>(
          stream: getDataRingkasanStream(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(
                child: Column(
                  children: [
                    Lottie.asset(
                      'assets/animations/LoadingUn.json',
                      width: 100,
                    ),
                    Text("Memuat data..."),
                  ],
                ),
              );
            }

            final dataRingkasan = snapshot.data!;
            values[0] = '${dataRingkasan['total']} Ekor';
            values[1] = '${dataRingkasan['persenSehat']}%';

            return FutureBuilder<int>(
              future: getJumlahKelahiranHariIni(),
              builder: (context, kelahiranSnapshot) {
                values[2] =
                    kelahiranSnapshot.hasData
                        ? '${kelahiranSnapshot.data} Ekor'
                        : 'Memuat...';

                return FutureBuilder<String>(
                  future: getRingkasanPerkawinan(),
                  builder: (context, perkawinanSnapshot) {
                    values[3] =
                        perkawinanSnapshot.hasData
                            ? perkawinanSnapshot.data!
                            : 'Memuat...';

                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 8,
                            mainAxisExtent: 75,
                          ),
                      itemCount: 4,
                      itemBuilder: (context, index) {
                        String label = labels[index];
                        String value = values[index];

                        final Map<String, IconData> labelIcons = {
                          "Jumlah Domba": Icons.pets,
                          "Kesehatan Ternak": Icons.health_and_safety,
                          "Kelahiran": Icons.volunteer_activism,
                          "Perkawinan": Icons.favorite,
                        };

                        IconData backgroundIcon =
                            labelIcons[label] ?? Icons.help_outline;
                        IconData? statusIcon;

                        Color bgColor = Colors.transparent;

                        if (label == "Kesehatan Ternak") {
                          double persen =
                              double.tryParse(value.replaceAll('%', '')) ?? 0;
                          if (persen == 100) {
                            bgColor = Colors.green.shade300;
                            statusIcon = Icons.check_circle;
                          } else if (persen > 0) {
                            bgColor = Colors.orange.shade300;
                            statusIcon = Icons.warning_amber_rounded;
                          } else {
                            bgColor = Colors.red.shade300;
                            statusIcon = Icons.error;
                          }
                        } else if (label == "Jumlah Domba") {
                          int jumlah =
                              int.tryParse(value.replaceAll(' Ekor', '')) ?? 0;
                          if (jumlah > 200) {
                            bgColor = Colors.green.shade300;
                            // statusIcon = Icons.thumb_up_alt_rounded;
                          } else if (jumlah >= 100) {
                            bgColor = Colors.orange.shade300;
                            // statusIcon = Icons.info_outline;
                          } else {
                            bgColor = Colors.red.shade300;
                            // statusIcon = Icons.priority_high;
                          }
                        }

                        return Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: gradientColors[index],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.all(8),
                          child: Stack(
                            children: [
                              Positioned(
                                right: -5,
                                bottom: 0,
                                child: Icon(
                                  backgroundIcon,
                                  size: 60,
                                  color: Colors.white.withOpacity(0.1),
                                ),
                              ),
                              Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      label,
                                      textAlign: TextAlign.center,
                                      style: GridActivityDashboard.title,
                                    ),
                                    const SizedBox(height: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color:
                                            (label == "Kesehatan Ternak" ||
                                                    label == "Jumlah Domba")
                                                ? bgColor.withOpacity(0.9)
                                                : Colors.black.withOpacity(
                                                  0.25,
                                                ),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          if (statusIcon != null)
                                            Icon(
                                              statusIcon,
                                              size: 16,
                                              color: Colors.white,
                                            ),
                                          if (statusIcon != null)
                                            const SizedBox(width: 5),
                                          Flexible(
                                            child: Text(
                                              value,
                                              textAlign: TextAlign.center,
                                              style:
                                                  GridActivityDashboard
                                                      .subtitle,
                                            ),
                                          ),
                                        ],
                                      ),
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
                );
              },
            );
          },
        ),
      ],
    );
  }
}
