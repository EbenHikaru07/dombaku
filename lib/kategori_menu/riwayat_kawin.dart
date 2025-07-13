import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dombaku/kategori_menu/detail_kawin.dart';
import 'package:dombaku/session/user_session.dart';
import 'package:dombaku/style.dart';
import 'package:flutter/material.dart';
import 'package:dombaku/styleui/appbarstyle.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';

class RiwayatKawin extends StatefulWidget {
  const RiwayatKawin({super.key});

  @override
  State<RiwayatKawin> createState() => _RiwayatKawinState();
}

class _RiwayatKawinState extends State<RiwayatKawin> {
  String? selectedGroup;
  Map<String, dynamic>? selectedKandang;
  String? selectedStatus;

  List<Map<String, dynamic>> dataPerkawinan = [];
  bool isLoading = true;
  String formatTanggal(DateTime tanggal) {
    return DateFormat('dd MMMM yyyy', 'id_ID').format(tanggal);
  }

  @override
  void initState() {
    super.initState();
    fetchPerkawinanData();
  }

  Future<void> fetchPerkawinanData() async {
    try {
      final userData = await UserSession.getUserData();
      final String? namaPeternak = userData['nama_peternak'];

      if (namaPeternak == null || namaPeternak.isEmpty) {
        setState(() {
          dataPerkawinan = [];
          isLoading = false;
        });
        return;
      }

      final snapshot =
          await FirebaseFirestore.instance
              .collection('perkawinan')
              .where('nama_peternak', isEqualTo: namaPeternak)
              .get();

      final fetchedData =
          snapshot.docs.map((doc) {
            final data = doc.data();
            return {
              "namaKandang": data["kandang"],
              "jantan": 1,
              "betina": (data["betina"] as List).length,
              "mulai": DateTime.parse(data["tanggal_mulai"]),
              "selesai": DateTime.parse(data["tanggal_selesai"]),
              "idJantan": [data["eartag_pejantan"]],
              "idBetina": List<String>.from(data["betina"]),
            };
          }).toList();

      setState(() {
        dataPerkawinan = fetchedData;
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Gagal mengambil data perkawinan: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  String _getStatus(DateTime tanggalSelesai) {
    final now = DateTime.now();
    if (tanggalSelesai.isBefore(now)) {
      return "Selesai";
    } else {
      return "On Progress";
    }
  }

  Color _getStatusColor(DateTime tanggalSelesai) {
    final now = DateTime.now();
    if (tanggalSelesai.isBefore(now)) {
      return Colors.green;
    } else {
      return Colors.yellow;
    }
  }

  List<Map<String, dynamic>> _filteredData() {
    if (selectedStatus == null) return dataPerkawinan;
    return dataPerkawinan.where((data) {
      final status = _getStatus(data['selesai']);
      return status == selectedStatus;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title:
            selectedKandang == null
                ? "Riwayat Kawin"
                : selectedKandang!["namaKandang"],
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: selectedKandang == null ? _buildKandangList() : Container(),
      ),
    );
  }

  Widget _buildKandangList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xff1D679E), Color(0xff40C5A2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Rekap Kawin", style: RiwayatKawinClass.title2),
              IconButton(
                icon: const Icon(
                  Icons.tornado_rounded,
                  color: Colors.white,
                  size: 30,
                ),
                onPressed: () async {
                  final selected = await showMenu<String>(
                    context: context,
                    position: RelativeRect.fromLTRB(
                      MediaQuery.of(context).size.width,
                      kToolbarHeight + 50,
                      16,
                      0,
                    ),
                    items: [
                      const PopupMenuItem<String>(
                        value: 'Semua',
                        child: Text(
                          'Semua',
                          style: TextStyle(
                            fontFamily: 'Exo2',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const PopupMenuItem<String>(
                        value: 'Selesai',
                        child: Text(
                          'Selesai',
                          style: TextStyle(
                            fontFamily: 'Exo2',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const PopupMenuItem<String>(
                        value: 'On Progress',
                        child: Text(
                          'On Progress',
                          style: TextStyle(
                            fontFamily: 'Exo2',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  );

                  if (selected != null) {
                    setState(() {
                      selectedStatus = selected == 'Semua' ? null : selected;
                    });
                  }
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child:
              isLoading
                  ? Center(
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
                  )
                  : dataPerkawinan.isEmpty
                  ? Center(
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
                          "Tidak ada data perkawinan.",
                          style: RiwayatKawinClass.unknown,
                        ),
                      ],
                    ),
                  )
                  : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children:
                        _filteredData().map((data) {
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (_) => DetailKawinPage(kandang: data),
                                ),
                              );
                            },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xff1D679E),
                                    Color(0xff40C5A2),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        children: [
                                          Image.asset(
                                            'assets/images/jantan.png',
                                            width: 50,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            "${data['jantan']}",
                                            style: RiwayatKawinClass.jumlah,
                                          ),
                                        ],
                                      ),
                                      Column(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.white.withOpacity(
                                                0.6,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                            ),
                                            child: ShaderMask(
                                              shaderCallback:
                                                  (
                                                    bounds,
                                                  ) => const LinearGradient(
                                                    colors: [
                                                      Color(0xff1D679E),
                                                      Color(0xff40C5A2),
                                                    ],
                                                    begin: Alignment.topLeft,
                                                    end: Alignment.bottomRight,
                                                  ).createShader(bounds),
                                              child: Text(
                                                data['namaKandang'],
                                                style: RiwayatKawinClass.title2,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            _getStatus(data['selesai']),
                                            style: TextStyle(
                                              fontFamily: 'Exo2',
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                              color: _getStatusColor(
                                                data['selesai'],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),

                                      Column(
                                        children: [
                                          Image.asset(
                                            'assets/images/betina.png',
                                            width: 50,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            "${data['betina']}",
                                            style: RiwayatKawinClass.jumlah,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const Divider(
                                    thickness: 1,
                                    color: Colors.white,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "Mulai: ${formatTanggal(data['mulai'])}",
                                          style: RiwayatKawinClass.tanggal,
                                        ),
                                        Text(
                                          "Selesai: ${formatTanggal(data['selesai'])}",
                                          style: RiwayatKawinClass.tanggal,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                  ),
        ),
      ],
    );
  }
}
