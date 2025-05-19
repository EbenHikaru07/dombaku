import 'package:dombaku/style.dart';
import 'package:dombaku/styleui/appbarstyle.dart';
import 'package:flutter/material.dart';

class DetailKawinPage extends StatefulWidget {
  final Map<String, dynamic> kandang;

  const DetailKawinPage({Key? key, required this.kandang}) : super(key: key);

  @override
  State<DetailKawinPage> createState() => _DetailKawinPageState();
}

class _DetailKawinPageState extends State<DetailKawinPage> {
  @override
  Widget build(BuildContext context) {
    final kandang = widget.kandang;
    List<String> allDombaIds = [...kandang['idJantan'], ...kandang['idBetina']];

    return Scaffold(
      appBar: CustomAppBar(title: kandang['namaKandang']),

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
                            style: RiwayarKawinDomba.subtitle,
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Text(
                            kandang['namaKandang'],
                            style: RiwayarKawinDomba.title,
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            "Selesai",
                            style: RiwayarKawinDomba.subtitle,
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Image.asset('assets/images/betina.png', width: 40),
                          Text(
                            "${kandang['betina']}",
                            style: RiwayarKawinDomba.subtitle,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Divider(color: Colors.black),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(kandang['mulai'], style: RiwayarKawinDomba.subtitle),
                      Text(
                        kandang['selesai'],
                        style: RiwayarKawinDomba.subtitle,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text("EARTAG Betina", style: RiwayarKawinDomba.title),
                Text("EARTAG Jantan", style: RiwayarKawinDomba.title),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children:
                          kandang['idJantan']
                              .map<Widget>((id) => Text(id))
                              .toList(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children:
                          kandang['idBetina']
                              .map<Widget>((id) => Text(id))
                              .toList(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade900,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                onPressed: () {
                  _showUpdatePopup(context, allDombaIds);
                },
                icon: const Icon(Icons.edit, color: Colors.white),
                label: const Text("Perbarui", style: RiwayarKawinDomba.title),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showUpdatePopup(BuildContext context, List<String> allDombaIds) {
    String? selectedDomba;
    String? selectedStatus;
    TextEditingController deskripsiController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (_) => Dialog(
            backgroundColor: Colors.white70,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Perbarui Status Domba",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: selectedDomba,
                    hint: const Text("Pilih ID Domba"),
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                    items:
                        allDombaIds
                            .map(
                              (id) =>
                                  DropdownMenuItem(value: id, child: Text(id)),
                            )
                            .toList(),
                    onChanged: (value) => selectedDomba = value,
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: selectedStatus,
                    hint: const Text("Pilih Status"),
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                    items:
                        ["Sehat", "Tidak Sehat", "Lainnya"]
                            .map(
                              (status) => DropdownMenuItem(
                                value: status,
                                child: Text(status),
                              ),
                            )
                            .toList(),
                    onChanged: (value) => selectedStatus = value,
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: deskripsiController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      hintText: "Masukkan deskripsi...",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      onPressed: () {
                        print(
                          "Domba: $selectedDomba, Status: $selectedStatus, Deskripsi: ${deskripsiController.text}",
                        );
                        Navigator.pop(context);
                      },
                      child: const Text(
                        "Simpan",
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }
}
