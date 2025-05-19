import 'package:dombaku/bottombar/bottom_navbar.dart';
import 'package:dombaku/dashboard/kesehatan/detail_kesehatan.dart';
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
  int _selectedIndex = 3;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
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
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
        hasCenterFAB: false,
      ),
    );
  }

  Widget _buildList() {
    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection('catatan_kesehatan')
              .orderBy('timestamp', descending: true)
              .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 100,
                  height: 100,
                  child: Lottie.asset('assets/animations/LoadingUn.json'),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Memuat data...',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('Tidak ada data kesehatan.'));
        }

        final data = snapshot.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.all(10),
          itemCount: data.length,
          itemBuilder: (context, index) {
            final doc = data[index];
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
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
                color: Colors.grey,
                elevation: 5,
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 5),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.teal.shade100, Colors.teal.shade50],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.only(
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
                                  color: _getColorFromWarnaEartag(warnaEartag),
                                  borderRadius: BorderRadius.circular(1),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Eartag :',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: _getTextColorFromBackground(
                                          _getColorFromWarnaEartag(warnaEartag),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                    Icon(
                                      Icons.local_offer,
                                      size: 16,
                                      color: _getTextColorFromBackground(
                                        _getColorFromWarnaEartag(warnaEartag),
                                      ),
                                    ),
                                    Text(
                                      '$eartag',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: _getTextColorFromBackground(
                                          _getColorFromWarnaEartag(warnaEartag),
                                        ),
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
                                            borderRadius: BorderRadius.circular(
                                              2,
                                            ),
                                          ),
                                          child: Text(
                                            status,
                                            style: const TextStyle(
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

                    // const Divider(
                    //   height: 1,
                    //   color: Colors.grey,
                    //   thickness: 0.5,
                    // ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.teal.shade400,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(5),
                          bottomRight: Radius.circular(5),
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 8,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.person,
                                color: Colors.white,
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                "Edit By: $user",
                                style: const TextStyle(
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
              ),
            );
          },
        );
      },
    );
  }
}
