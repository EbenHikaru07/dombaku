import 'package:dombaku/session/user_session.dart';
import 'package:dombaku/style.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dombaku/styleui/appbarstyle.dart';
import 'package:lottie/lottie.dart';

class ManajemenKandang extends StatefulWidget {
  const ManajemenKandang({super.key});

  @override
  State<ManajemenKandang> createState() => _ManajemenKandangState();
}

class _ManajemenKandangState extends State<ManajemenKandang> {
  List<Map<String, dynamic>> _kandangList = [];
  List<Map<String, dynamic>> _filteredKandangList = [];
  bool _isLoading = true;
  String _selectedStatus = 'Semua';

  @override
  void initState() {
    super.initState();
    _fetchKandangData();
  }

  void _fetchKandangData() async {
    try {
      final userData = await UserSession.getUserData();
      final String? namaPeternak = userData['nama_peternak'];

      if (namaPeternak == null || namaPeternak.isEmpty) {
        setState(() {
          _kandangList = [];
          _filteredKandangList = [];
          _isLoading = false;
        });
        return;
      }

      final snapshot =
          await FirebaseFirestore.instance
              .collection('manajemenkandang')
              .where('nama_peternak', isEqualTo: namaPeternak)
              .get();

      final List<Map<String, dynamic>> list = [];

      for (var doc in snapshot.docs) {
        List<dynamic> eartagIds = doc['eartag_domba'] ?? [];

        list.add({
          'namaKandang': doc['nama_kandang'] ?? '',
          'kapasitas': doc['kapasitas_maks'] ?? 0,
          'status': doc['status'] ?? 'Tidak Diketahui',
          'eartags': eartagIds.map((e) => e.toString()).toList(),
        });
      }

      setState(() {
        _kandangList = list;
        _applyFilter();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      debugPrint("Terjadi kesalahan saat mengambil data kandang: $e");
    }
  }

  void _applyFilter() {
    if (_selectedStatus == 'Semua') {
      _filteredKandangList = _kandangList;
    } else {
      _filteredKandangList =
          _kandangList
              .where(
                (item) =>
                    item['status'].toString().toLowerCase() ==
                    _selectedStatus.toLowerCase(),
              )
              .toList();
    }
  }

  void _onFilterChanged(String? newValue) {
    if (newValue == null) return;
    setState(() {
      _selectedStatus = newValue;
      _applyFilter();
    });
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'tersedia':
        return Colors.amber.shade700.withOpacity(0.1);
      case 'terisi':
        return Colors.blue.shade700.withOpacity(0.5);
      case 'tidak tersedia':
        return Colors.red.shade700;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(title: "Manajemen Kandang"),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child:
            _isLoading
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
                      SizedBox(height: 10),
                      Text("Memuat data..."),
                    ],
                  ),
                )
                : Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Filter Status:",
                          style: ManajemenKandangStyle.title,
                        ),
                        DropdownButton<String>(
                          value: _selectedStatus,
                          items:
                              const [
                                    'Semua',
                                    'Tersedia',
                                    'Terisi',
                                    'Tidak Tersedia',
                                  ]
                                  .map(
                                    (status) => DropdownMenuItem(
                                      value: status,
                                      child: Text(
                                        status,
                                        style: ManajemenKandangStyle.dropdown,
                                      ),
                                    ),
                                  )
                                  .toList(),
                          onChanged: _onFilterChanged,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Expanded(child: _buildKandangList()),
                  ],
                ),
      ),
    );
  }

  Widget _buildKandangList() {
    if (_filteredKandangList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 150,
              width: 150,
              child: Image.asset(
                'assets/images/empty_data.png',
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Tidak ada data kandang.',
              style: ManajemenKandangStyle.unknown,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _filteredKandangList.length,
      itemBuilder: (context, index) {
        final data = _filteredKandangList[index];
        final isAvailable =
            data['status'].toString().toLowerCase() == 'tersedia';

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors:
                  isAvailable
                      ? [Colors.green.shade800, Colors.green.shade400]
                      : [Color(0xff1D679E), Color(0xff40C5A2)],
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 6,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.house_siding_rounded,
                        color: Colors.white,
                      ),
                      SizedBox(width: 5.0),

                      Text(
                        "${data['namaKandang']}",
                        style: ManajemenKandangStyle.title2,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        "( Max ${data['kapasitas']} )",
                        style: ManajemenKandangStyle.subtitle2,
                      ),
                    ],
                  ),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(data['status']),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      data['status'],
                      style: ManajemenKandangStyle.subtitle,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                "Domba didalam:",
                style: ManajemenKandangStyle.subtitle,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children:
                    (data['eartags'] as List<dynamic>).map<Widget>((tag) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.white60),
                        ),
                        child: Text(
                          tag.toString(),
                          style: ManajemenKandangStyle.data,
                        ),
                      );
                    }).toList(),
              ),
              const SizedBox(height: 4),
            ],
          ),
        );
      },
    );
  }
}
