import 'package:dombaku/dashboard/kesehatan/detail_kesehatan.dart';
import 'package:dombaku/session/user_session.dart';
import 'package:dombaku/styleui/appbarstyle2.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';

class KesehatanPage extends StatefulWidget {
  const KesehatanPage({super.key});

  @override
  _KesehatanPageState createState() => _KesehatanPageState();
}

class _KesehatanPageState extends State<KesehatanPage> {
  String _filterEartag = '';
  String? _selectedWarnaEartag;
  String? _selectedStatusKesehatan;
  Map<String, dynamic>? _userData;
  List<QueryDocumentSnapshot>? _docs;
  bool _isLoading = true;
  String? _errorMsg;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final userData = await UserSession.getUserData();
      final namaPeternak = userData['nama_peternak'];

      final snapshot =
          await FirebaseFirestore.instance
              .collection('catatan_kesehatan')
              .where('nama_peternak', isEqualTo: namaPeternak)
              .get();

      final sortedDocs =
          snapshot.docs..sort((a, b) {
            final aTime = (a['timestamp'] as Timestamp).toDate();
            final bTime = (b['timestamp'] as Timestamp).toDate();
            return bTime.compareTo(aTime);
          });

      setState(() {
        _userData = userData;
        _docs = sortedDocs;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMsg = e.toString();
        _isLoading = false;
      });
    }
  }
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'sehat':
        return Colors.green;
      case 'sakit':
        return Colors.amber;
      case 'mortalitas':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    if (difference.inDays > 0) return '${difference.inDays} hari lalu';
    if (difference.inHours > 0) return '${difference.inHours} jam lalu';
    if (difference.inMinutes > 0) return '${difference.inMinutes} menit lalu';
    return 'Baru saja';
  }

  Color _getTextColorFromBackground(Color bgColor) {
    return bgColor.computeLuminance() > 0.5 ? Colors.black : Colors.white;
  }

  Color _getColorFromWarnaEartag(String warna) {
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

  void _showFilterModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Filter Kesehatan Domba",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                      ),
                    ),
                    const Divider(thickness: 1.2),

                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        _buildWarnaItem('merah', Colors.red, setModalState),
                        _buildWarnaItem('kuning', Colors.yellow, setModalState),
                        _buildWarnaItem('hijau', Colors.green, setModalState),
                        _buildWarnaItem('putih', Colors.white, setModalState),
                        _buildWarnaItem('hitam', Colors.black, setModalState),
                        _buildWarnaItem('orange', Colors.orange, setModalState),
                        _buildWarnaItem('ungu', Colors.purple, setModalState),
                        _buildWarnaItem('biru', Colors.blue, setModalState),
                        _buildWarnaItem('coklat', Colors.brown, setModalState),
                        _buildWarnaItem(
                          null,
                          Colors.grey,
                          setModalState,
                          label: 'Semua',
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Status Kesehatan",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      children: [
                        _buildStatusButton('sehat', setModalState),
                        _buildStatusButton('sakit', setModalState),
                        _buildStatusButton('mortalitas', setModalState),
                        _buildStatusButton(null, setModalState, label: 'Semua'),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      alignment: WrapAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width / 2 - 32,
                          child: OutlinedButton.icon(
                            onPressed: () {
                              setState(() {
                                _selectedWarnaEartag = null;
                                _selectedStatusKesehatan = null;
                              });
                              Navigator.pop(context);
                            },
                            icon: const Icon(Icons.refresh, color: Colors.teal),
                            label: const Text(
                              "Reset",
                              style: TextStyle(color: Colors.teal),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.teal),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width / 2 - 32,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              setState(() {});
                              Navigator.pop(context);
                            },
                            icon: const Icon(Icons.check),
                            label: const Text("Terapkan"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildWarnaItem(
    String? value,
    Color color,
    Function setModalState, {
    String? label,
  }) {
    final isSelected = _selectedWarnaEartag == value;
    return GestureDetector(
      onTap: () {
        setModalState(() => _selectedWarnaEartag = value);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected ? Colors.grey.shade200 : Colors.transparent,
            ),
            padding: const EdgeInsets.all(8),
            child: Icon(
              Icons.local_offer,
              color: color,
              size: isSelected ? 30 : 26,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _capitalize(label ?? value ?? "Semua"),
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  String _capitalize(String input) {
    if (input.isEmpty) return input;
    return input[0].toUpperCase() + input.substring(1);
  }

  Widget _buildStatusButton(
    String? status,
    Function setModalState, {
    String? label,
  }) {
    final isSelected = _selectedStatusKesehatan == status;

    Color statusColor;
    switch (status) {
      case 'sehat':
        statusColor = Colors.green;
        break;
      case 'sakit':
        statusColor = Colors.orangeAccent;
        break;
      case 'mortalitas':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.grey;
    }

    return ChoiceChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10,
            height: 10,
            margin: const EdgeInsets.only(right: 6),
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
            ),
          ),
          Text(_capitalize(label ?? status ?? "Semua")),
        ],
      ),
      selected: isSelected,
      selectedColor: Colors.teal,
      backgroundColor: Colors.grey.shade100,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black87,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      onSelected: (_) {
        setModalState(() => _selectedStatusKesehatan = status);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    double fabSize = screenWidth * 0.15;
    fabSize = fabSize.clamp(50, 80);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar2(
        title: "Catatan Kesehatan",
        centerTitle: false,
        actions: [
          // IconButton(
          //   icon: const Icon(Icons.notifications, color: Colors.white),
          //   onPressed: () {},
          // ),
          // IconButton(
          //   icon: CircleAvatar(
          //     backgroundImage: AssetImage('assets/icon/sheep.png'),
          //   ),
          //   onPressed: () {},
          // ),
          // const SizedBox(width: 10),
        ],
      ),
      body: _buildList(),
    );
  }

  Widget _buildList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMsg != null) {
      return Center(child: Text('Terjadi kesalahan: $_errorMsg'));
    }

    if (_userData == null || _userData!['nama_peternak'] == null) {
      return const Center(child: Text("Nama peternak tidak ditemukan."));
    }

    if (_docs == null || _docs!.isEmpty) {
      return const Center(child: Text("Tidak ada data kesehatan."));
    }

    final filteredDocs =
        _docs!.where((doc) {
          final eartag = doc['eartag'].toString().toLowerCase();
          final warna = doc['warna_eartag']?.toString().toLowerCase();
          final status = doc['kesehatan']?.toString().toLowerCase();

          final matchesEartag =
              _filterEartag.isEmpty || eartag.contains(_filterEartag);
          final matchesWarna =
              _selectedWarnaEartag == null || warna == _selectedWarnaEartag;
          final matchesStatus =
              _selectedStatusKesehatan == null ||
              status == _selectedStatusKesehatan;

          return matchesEartag && matchesWarna && matchesStatus;
        }).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
          child: Row(
            children: [
              Expanded(
                flex: 5,
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Cari Eartag',
                    hintStyle: const TextStyle(fontFamily: 'Exo2'),
                    prefixIcon: const Icon(Icons.search, color: Colors.teal),
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    isDense: true,
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _filterEartag = value.trim().toLowerCase();
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                onPressed: _showFilterModal,
                icon: const Icon(Icons.tune, color: Colors.teal),
                tooltip: 'Filter',
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: filteredDocs.length,
            itemBuilder: (context, index) {
              final doc = filteredDocs[index];
              final eartag = doc['eartag'] ?? '';
              final status = doc['kesehatan'] ?? '';
              final keterangan = doc['keterangan'] ?? '';
              final warnaEartag = doc['warna_eartag'] ?? '';
              final timestamp = (doc['timestamp'] as Timestamp).toDate();
              final formattedDate = DateFormat(
                'dd MMMM yyyy',
                'id_ID',
              ).format(timestamp);
              final user = doc['editby'] ?? '';

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DetailKesehatanPage(document: doc),
                    ),
                  );
                },
                child: _buildKesehatanCard(
                  eartag: eartag,
                  status: status,
                  keterangan: keterangan,
                  warnaEartag: warnaEartag,
                  formattedDate: formattedDate,
                  user: user,
                  timestamp: timestamp,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildKesehatanCard({
    required String eartag,
    required String status,
    required String keterangan,
    required String warnaEartag,
    required String formattedDate,
    required String user,
    required DateTime timestamp,
  }) {
    final Color backgroundColor = _getColorFromWarnaEartag(warnaEartag);
    final Color textColor = _getTextColorFromBackground(backgroundColor);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      color: Colors.grey,
      elevation: 5,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.teal.shade100, Colors.teal.shade50],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(5),
                topRight: Radius.circular(5),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: backgroundColor,
                        borderRadius: BorderRadius.circular(1),
                      ),
                      child: Row(
                        children: [
                          Text(
                            'Eartag :',
                            style: TextStyle(
                              fontFamily: 'Exo2',
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Icon(Icons.local_offer, size: 16, color: textColor),
                          Text(
                            eartag,
                            style: TextStyle(
                              fontFamily: 'Exo2',
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: textColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.calendar_today,
                              size: 14,
                              color: Colors.black54,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              formattedDate,
                              style: const TextStyle(
                                fontFamily: 'Exo2',
                                fontSize: 12,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            const Icon(
                              Icons.access_time,
                              size: 12,
                              color: Colors.black45,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _getTimeAgo(timestamp),
                              style: const TextStyle(
                                fontFamily: 'Exo2',
                                fontSize: 10,
                                color: Colors.black45,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.local_hospital,
                      color: Colors.teal,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text(
                                "Status Update:",
                                style: TextStyle(
                                  fontFamily: 'Exo2',
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(status),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                                child: Text(
                                  status,
                                  style: const TextStyle(
                                    fontFamily: 'Exo2',
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            keterangan,
                            style: const TextStyle(
                              fontFamily: 'Exo2',
                              color: Colors.black54,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.teal.shade400,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(5),
                bottomRight: Radius.circular(5),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.person, color: Colors.white, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      "Edit By: $user",
                      style: const TextStyle(
                        fontFamily: 'Exo2',
                        color: Colors.white,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white70,
                  size: 16,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
