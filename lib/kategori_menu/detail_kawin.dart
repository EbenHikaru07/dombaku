import 'package:dombaku/style.dart';
import 'package:dombaku/styleui/appbarstyle.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DetailKawinPage extends StatefulWidget {
  final Map<String, dynamic> kandang;

  const DetailKawinPage({Key? key, required this.kandang}) : super(key: key);

  @override
  State<DetailKawinPage> createState() => _DetailKawinPageState();
}

class _DetailKawinPageState extends State<DetailKawinPage> {
  String formatTanggal(DateTime tanggal) {
    return DateFormat('dd MMMM yyyy', 'id_ID').format(tanggal);
  }

  @override
  Widget build(BuildContext context) {
    final kandang = widget.kandang;

    return Scaffold(
      // appBar: CustomAppBar(title: kandang['namaKandang']),
      appBar: CustomAppBar(title: 'Detail'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xff1D679E), Color(0xff40C5A2)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          Image.asset('assets/images/jantan.png', width: 40),
                          Text(
                            "${kandang['jantan']}",
                            style: RiwayatKawinClass.jumlah,
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Text(
                            kandang['namaKandang'],
                            style: RiwayatKawinClass.kandang,
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Image.asset('assets/images/betina.png', width: 40),
                          Text(
                            "${kandang['betina']}",
                            style: RiwayatKawinClass.jumlah,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Divider(color: Colors.black),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Mulai: ${formatTanggal(kandang['mulai'])}",
                        style: RiwayatKawinClass.tanggal,
                      ),
                      Text(
                        "Selesai: ${formatTanggal(kandang['selesai'])}",
                        style: RiwayatKawinClass.tanggal,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Color(0xFFE3F2FD),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "EARTAG Jantan",
                            style: RiwayatKawinClass.title,
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: List<Widget>.from(
                              (kandang['idJantan'] as List).map(
                                (id) => Chip(
                                  label: Text(
                                    id,
                                    style: RiwayatKawinClass.data,
                                  ),
                                  backgroundColor: Color(0xFF64B5F6),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Color(0xFFFCE4EC),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "EARTAG Betina",
                            style: RiwayatKawinClass.title,
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: List<Widget>.from(
                              (kandang['idBetina'] as List).map(
                                (id) => Chip(
                                  label: Text(
                                    id,
                                    style: RiwayatKawinClass.data,
                                  ),
                                  backgroundColor: Color(0xFFF06292),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
