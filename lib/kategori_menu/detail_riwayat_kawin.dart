// import 'package:flutter/material.dart';

// class DetailRiwayatKawin extends StatelessWidget {
//   final Map<String, dynamic> data;

//   const DetailRiwayatKawin({super.key, required this.data});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(data['koloni']),
//         backgroundColor: Colors.green,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text("Jumlah Jantan: ${data['jantan']}"),
//             Text("Jumlah Betina: ${data['betina']}"),
//             const SizedBox(height: 10),
//             Text("Tanggal Awal: ${data['tglAwal']}"),
//             Text("Tanggal Akhir: ${data['tglAkhir']}"),
//             const SizedBox(height: 20),
//             Text("Catatan koloni: ${data['koloni']}"),
//           ],
//         ),
//       ),
//     );
//   }
// }
