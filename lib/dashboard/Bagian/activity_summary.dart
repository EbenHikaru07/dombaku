import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:dombaku/style.dart';
import 'package:lottie/lottie.dart';

class ActivitySummary extends StatelessWidget {
  const ActivitySummary({super.key});

  Stream<Map<String, dynamic>> getDataRingkasanStream() {
    return FirebaseFirestore.instance
        .collection('manajemendomba')
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
    final today = DateTime.now();
    final formattedToday =
        "${today.year.toString().padLeft(4, '0')}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";

    QuerySnapshot snapshot =
        await FirebaseFirestore.instance
            .collection('manajeenkelahiran')
            .where('tanggal_lahir', isEqualTo: formattedToday)
            .get();

    return snapshot.docs.length;
  }

  @override
  Widget build(BuildContext context) {
    List<String> labels = [
      "Jumlah Domba",
      "Kesehatan Ternak",
      "Kelahiran",
      "Null",
    ];

    List<String> values = ["Null", "Null", "Null", "Null"];

    // List<List<Color>> gradientColors = [
    //   [Colors.grey.shade300, Colors.grey.shade300],
    //   [Colors.grey.shade300, Colors.grey.shade300],
    //   [Colors.grey.shade300, Colors.grey.shade300],
    //   [Colors.grey.shade300, Colors.grey.shade300],
    // ];
    List<List<Color>> gradientColors = [
      [Color(0xff1D679E), Color(0xff40C5A2)],
      [Color(0xff1D679E), Color(0xff40C5A2)],
      [Colors.purple.shade200, Colors.red.shade400],
      [Colors.orange.shade200, Colors.grey.shade400],
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

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
                    };

                    IconData backgroundIcon =
                        labelIcons[label] ?? Icons.do_not_disturb;
                    IconData? statusIcon;

                    bool isKesehatan = label == "Kesehatan Ternak";
                    bool isJumlahDomba = label == "Jumlah Domba";

                    Color bgColor = Colors.transparent;

                    if (isKesehatan) {
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
                    } else if (isJumlahDomba) {
                      int jumlah =
                          int.tryParse(value.replaceAll(' Ekor', '')) ?? 0;
                      if (jumlah > 200) {
                        bgColor = Colors.green.shade300;
                        statusIcon = Icons.thumb_up_alt_rounded;
                      } else if (jumlah >= 100) {
                        bgColor = Colors.orange.shade300;
                        statusIcon = Icons.info_outline;
                      } else {
                        bgColor = Colors.red.shade300;
                        statusIcon = Icons.priority_high;
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
                                        (isKesehatan || isJumlahDomba)
                                            ? bgColor.withOpacity(0.9)
                                            : Colors.black.withOpacity(0.25),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      if (statusIcon != null)
                                        Icon(
                                          statusIcon,
                                          size: 16,
                                          color: Colors.white,
                                        ),
                                      const SizedBox(width: 5),
                                      Text(
                                        value,
                                        style: GridActivityDashboard.subtitle,
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
        ),
      ],
    );
  }
}
