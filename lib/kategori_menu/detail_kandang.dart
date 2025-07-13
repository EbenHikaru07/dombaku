// import 'package:flutter/material.dart';

// class DetailKandangPage extends StatelessWidget {
//   final String namaKandang;
//   final int kapasitas;
//   final List<String> eartags;

//   const DetailKandangPage({
//     super.key,
//     required this.namaKandang,
//     required this.kapasitas,
//     required this.eartags,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Detail Kandang")),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text("Nama Kandang: $namaKandang", style: TextStyle(fontSize: 18)),
//             SizedBox(height: 8),
//             Text("Kapasitas Maksimum: $kapasitas", style: TextStyle(fontSize: 16)),
//             SizedBox(height: 8),
//             Text("Eartag Domba:", style: TextStyle(fontSize: 16)),
//             Wrap(
//               spacing: 8,
//               runSpacing: 4,
//               children: eartags.map((e) => Chip(label: Text(e))).toList(),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
