import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dombaku/kategori_menu/rekomendasi_kawin/hasil_rekomendasi.dart';
import 'package:dombaku/style.dart';
import 'package:flutter/material.dart';
import 'package:dombaku/styleui/appbarstyle.dart';

class RekomendasiKawin extends StatefulWidget {
  const RekomendasiKawin({super.key});

  @override
  State<RekomendasiKawin> createState() => _RekomendasiKawinState();
}

class _RekomendasiKawinState extends State<RekomendasiKawin> {
  final TextEditingController idController = TextEditingController();
  bool isLoading = false;

  @override
  void dispose() {
    idController.dispose();
    super.dispose();
  }

  Future<void> cariRekomendasi() async {
    String idInput = idController.text.trim();

    if (idInput.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Mohon masukkan ID Domba Jantan")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final querySnapshot =
          await FirebaseFirestore.instance
              .collection('rekomendasikawin')
              .where('id_jantan', isEqualTo: idInput)
              .get();

      if (querySnapshot.docs.isNotEmpty) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HasilRekomendasiKawin(idDomba: idInput),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("ID tidak ditemukan dalam data rekomendasi"),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Terjadi kesalahan: $e")));
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(title: "Rekomendasi Kawin"),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const Text(
              "Masukkan ID Domba Jantan:",
              style: RekomendasiKawinDomba.title,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: idController,
                    decoration: InputDecoration(
                      labelText: "ID Domba Jantan",
                      labelStyle: RekomendasiKawinDomba.labeltext,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                InkWell(
                  onTap: () {
                    // QR Scanner bisa ditambahkan di sini nanti
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xff042E22),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.qr_code_scanner,
                      size: 30,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xff1D679E), Color(0xff40C5A2)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ElevatedButton(
                  onPressed: isLoading ? null : cariRekomendasi,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child:
                      isLoading
                          ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 5,
                            ),
                          )
                          : const Text(
                            "Cari Rekomendasi",
                            style: RekomendasiKawinDomba.subtitle,
                          ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
