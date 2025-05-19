// import 'dart:async';
// import 'dart:io';
// import 'dart:ui' as ui;
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:camera/camera.dart';
// import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

// class EartagScannerPage extends StatefulWidget {
//   const EartagScannerPage({Key? key}) : super(key: key);

//   @override
//   _EartagScannerPageState createState() => _EartagScannerPageState();
// }

// class _EartagScannerPageState extends State<EartagScannerPage> {
//   late CameraController cameraController;
//   List<Map<String, String>> scannedResults = [];
//   bool _isCameraInitialized = false;
//   Timer? _scanTimer;
//   bool _isProcessing = false;
//   final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

//   @override
//   void initState() {
//     super.initState();
//     initializeCamera();
//   }

//   Future<void> initializeCamera() async {
//     try {
//       final cameras = await availableCameras();
//       final firstCamera = cameras.first;
//       cameraController = CameraController(firstCamera, ResolutionPreset.medium);
//       await cameraController.initialize();
//       setState(() {
//         _isCameraInitialized = true;
//       });
//       startAutoScanning();
//     } catch (e) {
//       print("Gagal inisialisasi kamera: $e");
//     }
//   }

//   void startAutoScanning() {
//     _scanTimer = Timer.periodic(const Duration(seconds: 2), (timer) async {
//       if (!_isProcessing && cameraController.value.isInitialized) {
//         _isProcessing = true;
//         bool found = await captureAndScan();
//         _isProcessing = false;

//         if (found) {
//           _scanTimer?.cancel();
//         }
//       }
//     });
//   }

//   Future<bool> captureAndScan() async {
//     try {
//       final image = await cameraController.takePicture();
//       final imageFile = File(image.path);

//       bool found = await recognizeTextAndColor(imageFile);

//       setState(() {});
//       return found;
//     } catch (e) {
//       print('Error capturing image: $e');
//       return false;
//     }
//   }

//   @override
//   void dispose() {
//     _scanTimer?.cancel();
//     cameraController.dispose();
//     textRecognizer.close();
//     super.dispose();
//   }

//   Future<bool> recognizeTextAndColor(File imageFile) async {
//     final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
//     final inputImage = InputImage.fromFile(imageFile);
//     final recognizedText = await textRecognizer.processImage(inputImage);

//     final bytes = await imageFile.readAsBytes();
//     final uiImage = await decodeImageFromList(bytes);

//     final byteData = await uiImage.toByteData(
//       format: ui.ImageByteFormat.rawRgba,
//     );
//     if (byteData == null) return false;

//     final pixels = byteData.buffer.asUint8List();
//     int width = uiImage.width;
//     int height = uiImage.height;

//     scannedResults.clear();
//     bool matchFound = false;

//     for (TextBlock block in recognizedText.blocks) {
//       for (TextLine line in block.lines) {
//         final rect = line.boundingBox;
//         if (rect == null) continue;

//         String text = line.text.trim();

//         final isNumeric = RegExp(r'^\d+$').hasMatch(text);
//         if (!isNumeric) continue;

//         int samplePadding = 10;
//         int startX = (rect.left - samplePadding).clamp(0, width - 1).toInt();
//         int startY = (rect.top - samplePadding).clamp(0, height - 1).toInt();
//         int endX = (rect.right + samplePadding).clamp(0, width - 1).toInt();
//         int endY = (rect.bottom + samplePadding).clamp(0, height - 1).toInt();

//         int totalR = 0, totalG = 0, totalB = 0;
//         int sampleCount = 0;

//         for (int x = startX; x <= endX; x++) {
//           for (int y = startY; y <= endY; y++) {
//             int pixelIndex = (y * width + x) * 4;
//             if (pixelIndex + 3 >= pixels.length) continue;

//             totalR += pixels[pixelIndex];
//             totalG += pixels[pixelIndex + 1];
//             totalB += pixels[pixelIndex + 2];
//             sampleCount++;
//           }
//         }

//         if (sampleCount == 0) continue;

//         int avgR = (totalR / sampleCount).toInt();
//         int avgG = (totalG / sampleCount).toInt();
//         int avgB = (totalB / sampleCount).toInt();

//         final color = Color.fromARGB(255, avgR, avgG, avgB);
//         final colorName = getColorName(color);

//         final snapshot =
//             await FirebaseFirestore.instance
//                 .collection('manajemendomba')
//                 .where('eartag', isEqualTo: text)
//                 .where('warna_eartag', isEqualTo: colorName)
//                 .get();

//         if (snapshot.docs.isNotEmpty) {
//           for (var doc in snapshot.docs) {
//             scannedResults.add({
//               'text': text,
//               'color': colorName,
//               'kelamin': doc['kelamin'],
//               'kesehatan': doc['kesehatan'],
//               'induk_jantan': doc['induk_jantan'],
//               'induk_betina': doc['induk_betina'],
//               'tanggal_lahir': doc['tanggal_lahir'],
//             });
//           }
//           return true;
//         }

//         return false;
//       }
//     }

//     return false;
//   }

//   String getColorName(Color color) {
//     final hsv = HSVColor.fromColor(color);
//     final hue = hsv.hue;
//     final saturation = hsv.saturation;
//     final value = hsv.value;

//     final r = color.red;
//     final g = color.green;
//     final b = color.blue;

//     bool isNeutral =
//         (r - g).abs() < 15 && (g - b).abs() < 15 && (r - b).abs() < 15;

//     if (isNeutral) {
//       if (value < 0.2) return 'Hitam';
//       if (value >= 0.2 && value <= 0.7) return 'Abu-abu';
//       if (value > 0.7) return 'Putih';
//     }

//     if (hue >= 0 && hue < 20) return 'Merah';
//     if (hue >= 20 && hue < 40) return 'Orange';
//     if (hue >= 40 && hue < 70) return 'Kuning';
//     if (hue >= 70 && hue < 160) return 'Hijau';
//     if (hue >= 160 && hue < 250) return 'Biru';
//     if (hue >= 250 && hue < 290) return 'Ungu';
//     if (hue >= 290 && hue <= 360) return 'Merah';

//     return 'Tidak Terdefinisi';
//   }

//   Widget infoRow(
//     IconData icon,
//     String label,
//     String value, {
//     Color iconColor = Colors.blue,
//     Color? backgroundColor,
//   }) {
//     return Container(
//       padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
//       decoration: BoxDecoration(
//         color:
//             backgroundColor ??
//             Colors.transparent,
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: Row(
//         children: [
//           Icon(icon, color: iconColor),
//           const SizedBox(width: 8),
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 label,
//                 style: const TextStyle(fontSize: 12, color: Colors.grey),
//               ),
//               Text(
//                 value,
//                 style: const TextStyle(
//                   fontSize: 14,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget actionButton({
//     required IconData icon,
//     required String label,
//     required List<Color> colors,
//     required VoidCallback onPressed,
//   }) {
//     return GestureDetector(
//       onTap: onPressed,
//       child: Container(
//         padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 3),
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             colors: colors,
//             begin: Alignment.centerLeft,
//             end: Alignment.centerRight,
//           ),
//           borderRadius: BorderRadius.circular(5),
//         ),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.start,
//           children: [
//             Icon(icon, size: 20, color: Colors.white),
//             const SizedBox(width: 5),
//             Text(
//               label,
//               style: const TextStyle(
//                 fontSize: 14,
//                 fontWeight: FontWeight.w500,
//                 color: Colors.white,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       extendBodyBehindAppBar: false,
//       appBar: PreferredSize(
//         preferredSize: const Size.fromHeight(kToolbarHeight),
//         child: AppBar(
//           automaticallyImplyLeading: true,
//           elevation: 0,
//           backgroundColor: Colors.transparent,
//           flexibleSpace: Container(
//             decoration: const BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [Color(0xff1D679E), Color(0xff40C5A2)],
//                 begin: Alignment.centerLeft,
//                 end: Alignment.centerRight,
//               ),
//             ),
//           ),
//           title: const Text('Eartag Scanner'),
//           foregroundColor: Colors.white,
//         ),
//       ),
//       body: Container(
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             colors: [Color(0xff1D679E), Color(0xff40C5A2)],
//             begin: Alignment.centerLeft,
//             end: Alignment.centerRight,
//           ),
//         ),
//         child:
//             _isCameraInitialized
//                 ? Column(
//                   children: [
//                     Expanded(
//                       flex: 8,
//                       child: Container(
//                         decoration: BoxDecoration(
//                           // borderRadius: BorderRadius.circular(10),
//                           border: Border.all(
//                             color: Color(0xff40C5A2),
//                             width: 2,
//                           ),
//                         ),
//                         clipBehavior: Clip.antiAlias,
//                         child: CameraPreview(cameraController),
//                       ),
//                     ),
//                     Expanded(
//                       flex: 3,
//                       child:
//                           scannedResults.isEmpty
//                               ? const Center(
//                                 child: Text(
//                                   "Belum ada hasil scan.",
//                                   style: TextStyle(
//                                     fontSize: 16,
//                                     color: Colors.white,
//                                   ),
//                                 ),
//                               )
//                               : ListView.builder(
//                                 padding: const EdgeInsets.symmetric(
//                                   horizontal: 12,
//                                   vertical: 10,
//                                 ),
//                                 itemCount: scannedResults.length,
//                                 itemBuilder: (context, index) {
//                                   final item = scannedResults[index];
//                                   final color = getColorFromName(
//                                     item['color'] ?? 'grey',
//                                   );
//                                   final isDark = isDarkColor(color);

//                                   return Card(
//                                     margin: const EdgeInsets.symmetric(
//                                       vertical: 8,
//                                     ),
//                                     shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(16),
//                                     ),
//                                     elevation: 4,
//                                     child: Padding(
//                                       padding: const EdgeInsets.all(16),
//                                       child: Column(
//                                         crossAxisAlignment:
//                                             CrossAxisAlignment.start,
//                                         children: [
//                                           Row(
//                                             crossAxisAlignment:
//                                                 CrossAxisAlignment.start,
//                                             children: [
//                                               Container(
//                                                 padding:
//                                                     const EdgeInsets.symmetric(
//                                                       horizontal: 12,
//                                                       vertical: 6,
//                                                     ),
//                                                 decoration: BoxDecoration(
//                                                   color: color,
//                                                   borderRadius:
//                                                       BorderRadius.circular(12),
//                                                 ),
//                                                 child: Text(
//                                                   'Eartag: ${item['text'] ?? 'N/A'}',
//                                                   style: TextStyle(
//                                                     fontSize: 16,
//                                                     fontWeight: FontWeight.bold,
//                                                     color:
//                                                         isDark
//                                                             ? Colors.white
//                                                             : Colors.black,
//                                                   ),
//                                                 ),
//                                               ),
//                                               const Spacer(),
//                                               Column(
//                                                 crossAxisAlignment:
//                                                     CrossAxisAlignment.end,
//                                                 children: [
//                                                   const Text(
//                                                     'Tanggal Lahir',
//                                                     style: TextStyle(
//                                                       fontSize: 12,
//                                                       color: Colors.grey,
//                                                     ),
//                                                   ),
//                                                   Text(
//                                                     '${item['tanggal_lahir'] ?? 'N/A'}',
//                                                     style: const TextStyle(
//                                                       fontSize: 14,
//                                                       fontWeight:
//                                                           FontWeight.bold,
//                                                     ),
//                                                   ),
//                                                 ],
//                                               ),
//                                             ],
//                                           ),

//                                           const SizedBox(height: 10),

//                                           Row(
//                                             children: [
//                                               Expanded(
//                                                 child: infoRow(
//                                                   Icons.male,
//                                                   'Kelamin',
//                                                   item['kelamin'] ?? 'N/A',
//                                                   iconColor: Colors.blue,
//                                                   backgroundColor: Colors.blue,
//                                                 ),
//                                               ),
//                                               Expanded(
//                                                 child: infoRow(
//                                                   Icons.health_and_safety,
//                                                   'Kesehatan',
//                                                   item['kesehatan'] ?? 'N/A',
//                                                   iconColor: Colors.white,
//                                                   backgroundColor:
//                                                       _getKesehatanColor(
//                                                         item['kesehatan'] ??
//                                                             'N/A',
//                                                       ),
//                                                 ),
//                                               ),
//                                             ],
//                                           ),

//                                           const SizedBox(height: 10),

//                                           Row(
//                                             children: [
//                                               Expanded(
//                                                 child: actionButton(
//                                                   icon: Icons.assignment,
//                                                   label: 'Pendataan',
//                                                   colors: [
//                                                     Color(0xff1D679E),
//                                                     Color(0xff40C5A2),
//                                                   ],
//                                                   onPressed: () {
//                                                     // TODO
//                                                   },
//                                                 ),
//                                               ),
//                                               const SizedBox(width: 8),
//                                               Expanded(
//                                                 child: actionButton(
//                                                   icon: Icons.local_hospital,
//                                                   label: 'Kesehatan',
//                                                   colors: [
//                                                     Color(0xff1D679E),
//                                                     Color(0xff40C5A2),
//                                                   ],
//                                                   onPressed: () {
//                                                     // TODO
//                                                   },
//                                                 ),
//                                               ),
//                                               const SizedBox(width: 8),
//                                               Expanded(
//                                                 child: actionButton(
//                                                   icon: Icons.history,
//                                                   label: 'Riwayat',
//                                                   colors: [
//                                                     Color(0xff1D679E),
//                                                     Color(0xff40C5A2),
//                                                   ],
//                                                   onPressed: () {
//                                                     // TODO
//                                                   },
//                                                 ),
//                                               ),
//                                             ],
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                   );
//                                 },
//                               ),
//                     ),
//                   ],
//                 )
//                 : const Center(child: CircularProgressIndicator()),
//       ),
//     );
//   }

//   bool isDarkColor(Color color) {
//     return color.computeLuminance() < 0.5;
//   }

//   Color getColorFromName(String colorName) {
//     switch (colorName) {
//       case 'Merah':
//         return Colors.red;
//       case 'Kuning':
//         return Colors.yellow;
//       case 'Hijau':
//         return Colors.green;
//       case 'Orange':
//         return Colors.orange;
//       case 'Putih':
//         return Colors.white;
//       case 'Hitam':
//         return Colors.black;
//       case 'Biru':
//         return Colors.blue;
//       default:
//         return Colors.grey;
//     }
//   }
// }

// Color _getKesehatanColor(String kesehatan) {
//   switch (kesehatan) {
//     case 'Sehat':
//       return Colors.green.shade500;
//     case 'Sakit':
//       return Colors.yellow;
//     case 'Mortalitas':
//       return Colors.red;
//     default:
//       return Colors.grey;
//   }
// }
