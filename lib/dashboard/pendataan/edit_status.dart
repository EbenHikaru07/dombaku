import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dombaku/session/user_session.dart';
import 'package:dombaku/styleui/appbarstyle.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class EditStatusDombaPage extends StatefulWidget {
  final String eartag;
  final String statusDomba;
  final String warnaEartag;

  const EditStatusDombaPage({
    super.key,
    required this.eartag,
    required this.statusDomba,
    required this.warnaEartag,
  });

  @override
  State<EditStatusDombaPage> createState() => _EditStatusDombaPageState();
}

class _EditStatusDombaPageState extends State<EditStatusDombaPage> {
  String selectedStatus = 'Normal';
  final TextEditingController _deskripsiController = TextEditingController();

  @override
  void initState() {
    super.initState();

    List<String> validStatus = ['Sehat', 'Sakit', 'Mortalitas'];

    if (validStatus.contains(widget.statusDomba)) {
      selectedStatus = widget.statusDomba;
    } else {
      selectedStatus = '';
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Error"),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  void _simpanStatus() async {
    String deskripsi = _deskripsiController.text.trim();

    if (deskripsi.isEmpty) {
      _showErrorDialog("Deskripsi tidak boleh kosong");
      return;
    }

    _showLottieLoadingDialog();

    try {
      final userData = await UserSession.getUserData();
      final username = userData['username'] ?? 'Unknown';
      final namaPeternak = userData['nama_peternak'] ?? 'Unknown';

      await FirebaseFirestore.instance.collection('catatan_kesehatan').add({
        'eartag': widget.eartag,
        'warna_eartag': widget.warnaEartag,
        'kesehatan': selectedStatus,
        'keterangan': deskripsi,
        'timestamp': FieldValue.serverTimestamp(),
        'editby': username,
        'nama_peternak': namaPeternak,
      });

      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance
              .collection('manajemendomba')
              .where('eartag', isEqualTo: widget.eartag)
              .where('warna_eartag', isEqualTo: widget.warnaEartag)
              .where('nama_peternak', isEqualTo: namaPeternak)
              .get();

      if (querySnapshot.docs.isNotEmpty) {
        String docId = querySnapshot.docs.first.id;
        await FirebaseFirestore.instance
            .collection('manajemendomba')
            .doc(docId)
            .update({'kesehatan': selectedStatus, 'keterangan': deskripsi});
      }

      if (mounted) Navigator.of(context).pop();
      if (mounted) Navigator.pop(context, selectedStatus);
    } catch (e) {
      if (mounted) Navigator.of(context).pop();
      if (mounted) _showErrorDialog("Terjadi kesalahan: $e");
    }
  }

  void _showLottieLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Lottie.asset(
                  'assets/animations/LoadingUn.json',
                  width: 100,
                  height: 100,
                  repeat: true,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Menyimpan data...',
                  style: TextStyle(
                    fontFamily: 'Exo2',
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color getColorFromWarna(String warna) {
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

  bool isDarkColor(Color color) {
    return color.computeLuminance() < 0.5;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: "Edit Status Domba"),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 12,
                ),
                decoration: BoxDecoration(
                  color: getColorFromWarna(widget.warnaEartag),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.black),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.local_offer,
                      color:
                          isDarkColor(getColorFromWarna(widget.warnaEartag))
                              ? Colors.white
                              : Colors.black,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Eartag Domba: ${widget.eartag}",
                      style: TextStyle(
                        fontFamily: 'Exo2',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color:
                            isDarkColor(getColorFromWarna(widget.warnaEartag))
                                ? Colors.white
                                : Colors.black,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                "Pilih Status",
                style: TextStyle(fontFamily: 'Exo2', fontSize: 16),
              ),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: selectedStatus.isNotEmpty ? selectedStatus : null,
                items: [
                  const DropdownMenuItem(value: '', child: Text("")),
                  ...['Sehat', 'Sakit', 'Mortalitas'].map(
                    (status) => DropdownMenuItem(
                      value: status,
                      child: Text(status, style: TextStyle(fontFamily: 'Exo2')),
                    ),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    selectedStatus = value!;
                  });
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                "Deskripsi",
                style: TextStyle(fontFamily: 'Exo2', fontSize: 16),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _deskripsiController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: "Masukkan deskripsi terkait kondisi domba...",
                  hintStyle: TextStyle(fontFamily: 'Exo2'),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              GestureDetector(
                onTap: _simpanStatus,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xff042E22),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.save_alt_rounded, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        "Simpan",
                        style: TextStyle(
                          fontFamily: 'Exo2',
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
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
