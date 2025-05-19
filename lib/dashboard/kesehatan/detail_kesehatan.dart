import 'package:dombaku/styleui/appbarstyle.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class DetailKesehatanPage extends StatefulWidget {
  final DocumentSnapshot document;

  const DetailKesehatanPage({super.key, required this.document});

  @override
  State<DetailKesehatanPage> createState() => _DetailKesehatanPageState();
}

class _DetailKesehatanPageState extends State<DetailKesehatanPage> {
  late String eartag, status, keterangan, editby, formattedDate;
  bool isVisible = false;

  @override
  void initState() {
    super.initState();
    final data = widget.document;

    eartag = data['eartag'] ?? '';
    status = data['kesehatan'] ?? '';
    keterangan = data['keterangan'] ?? '';
    editby = data['editby'] ?? '';
    final timestamp = (data['timestamp'] as Timestamp).toDate();
    formattedDate = DateFormat('dd MMMM yyyy', 'id_ID').format(timestamp);

    // Memunculkan animasi setelah build
    Future.delayed(const Duration(milliseconds: 300), () {
      setState(() => isVisible = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "Detail Kesehatan Domba"),
      backgroundColor: const Color(0xFFF2F4F7),
      body: AnimatedOpacity(
        opacity: isVisible ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 500),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Card(
            elevation: 10,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 16),
                  const Divider(thickness: 1, color: Color(0xFFE0E0E0)),
                  const SizedBox(height: 12),
                  _buildDetailItem(Icons.badge, "Eartag", eartag),
                  _buildDetailItem(Icons.health_and_safety, "Status", status),
                  _buildDetailItem(Icons.person, "Diedit oleh", editby),
                  _buildDetailItem(Icons.date_range, "Tanggal", formattedDate),
                  _buildDetailItem(Icons.description, "Deskripsi", keterangan),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.teal,
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(14),
          child: const Icon(
            Icons.medical_services,
            color: Colors.white,
            size: 28,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            "Informasi Kesehatan Terkini",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.teal.shade800,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.teal.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.all(8),
            child: Icon(icon, color: Colors.teal, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
