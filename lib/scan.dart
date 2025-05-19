// import 'dart:async';
// import 'package:camera/camera.dart';
// import 'package:dombaku/style.dart';
// import 'package:flutter/material.dart';
// import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:dombaku/dashboard/pendataan/detail_domba.dart';
// import 'package:lottie/lottie.dart';

// class ScanPage extends StatefulWidget {
//   const ScanPage({super.key});

//   @override
//   State<ScanPage> createState() => _ScanPageState();
// }

// class _ScanPageState extends State<ScanPage> {
//   late CameraController _controller;
//   Future<void>? _initializeControllerFuture;

//   bool _isProcessing = false;
//   Timer? _scanTimer;
//   bool _isNavigated = false;

//   @override
//   void initState() {
//     super.initState();
//     _initCamera();
//   }

//   Future<void> _initCamera() async {
//     try {
//       final cameras = await availableCameras();
//       final camera = cameras.first;

//       _controller = CameraController(camera, ResolutionPreset.medium);
//       _initializeControllerFuture = _controller.initialize();

//       await _initializeControllerFuture;

//       if (mounted) {
//         setState(() {});
//         _startAutoScan();
//       }
//     } on CameraException catch (e) {
//       if (e.code == 'CameraAccessDenied') {
//         _showCameraDeniedDialog();
//       } else {
//         debugPrint('Camera error: ${e.description}');
//       }
//     } catch (e) {
//       debugPrint('Unexpected error: $e');
//     }
//   }

//   void _showCameraDeniedDialog() {
//     showDialog(
//       context: context,
//       builder:
//           (context) => AlertDialog(
//             title: const Text('Izin Kamera Ditolak'),
//             content: const Text(
//               'Aplikasi memerlukan akses kamera untuk memindai ID Domba.\n'
//               'Silakan aktifkan izin kamera melalui pengaturan perangkat Anda.',
//             ),
//             actions: [
//               TextButton(
//                 child: const Text('Tutup'),
//                 onPressed: () => Navigator.of(context).pop(),
//               ),
//             ],
//           ),
//     );
//   }

//   void _startAutoScan() {
//     _scanTimer = Timer.periodic(const Duration(seconds: 1), (_) {
//       if (!_isProcessing && !_isNavigated) {
//         _processScan();
//       }
//     });
//   }

//   Future<void> _processScan() async {
//     if (!mounted) return;

//     setState(() {
//       _isProcessing = true;
//     });

//     try {
//       final image = await _controller.takePicture();
//       final inputImage = InputImage.fromFilePath(image.path);
//       final textRecognizer = TextRecognizer(
//         script: TextRecognitionScript.latin,
//       );
//       final recognizedText = await textRecognizer.processImage(inputImage);
//       final scannedText = recognizedText.text;

//       final possibleId = _extractId(scannedText);

//       if (possibleId != null) {
//         final snapshot =
//             await FirebaseFirestore.instance
//                 .collection('manajemendomba')
//                 .where('eartag', isEqualTo: possibleId)
//                 .get();

//         if (snapshot.docs.isNotEmpty && !_isNavigated) {
//           _isNavigated = true;
//           final data = snapshot.docs.first.data();

//           if (!mounted) return;

//           Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(
//               builder:
//                   (context) => DetailDombaPage(
//                     eartag: data['eartag'] ?? '',
//                     nama: data['nama'] ?? '',
//                     gender: data['kelamin'] ?? '',
//                     gambar:
//                         data['kelamin'] == 'Jantan'
//                             ? 'assets/images/jantan.png'
//                             : 'assets/images/betina.png',
//                     idIndukJantan: data['induk_jantan'] ?? '',
//                     idIndukBetina: data['induk_betina'] ?? '',
//                     bobot:
//                         data['bobot_badan'] != null
//                             ? data['bobot_badan'].toString()
//                             : '',
//                     kandang: data['kandang'] ?? '',
//                     statusDomba: data['kesehatan'] ?? '',
//                     tanggalLahir: data['tanggal_lahir'] ?? '',
//                   ),
//             ),
//           );
//         }
//       }
//     } catch (e) {
//       debugPrint('Scan error: $e');
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isProcessing = false;
//         });
//       }
//     }
//   }

//   String? _extractId(String text) {
//     final regex = RegExp(r'\b\d+\b');
//     final match = regex.firstMatch(text);
//     return match?.group(0);
//   }

//   @override
//   void dispose() {
//     _scanTimer?.cancel();
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Scan Domba", style: AppTextStyles.title),
//         backgroundColor: Colors.black,
//         iconTheme: const IconThemeData(color: Colors.white),
//         foregroundColor: Colors.white,
//       ),
//       body: Container(
//         color: Colors.black,
//         child:
//             _initializeControllerFuture == null
//                 ? Center(
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       SizedBox(
//                         height: 150,
//                         child: Lottie.asset(
//                           'assets/animations/LoadingScan.json',
//                           width: 200,
//                           height: 200,
//                           fit: BoxFit.contain,
//                         ),
//                       ),
//                       const SizedBox(height: 10),
//                       const Text(
//                         'Menyiapkan kamera...',
//                         style: AppTextStyles.subtitle,
//                       ),
//                     ],
//                   ),
//                 )
//                 : FutureBuilder(
//                   future: _initializeControllerFuture,
//                   builder: (context, snapshot) {
//                     if (snapshot.connectionState == ConnectionState.done) {
//                       return Stack(
//                         children: [
//                           CameraPreview(_controller),
//                           if (_isProcessing)
//                             Center(
//                               child: SizedBox(
//                                 height: 550,
//                                 width: 550,
//                                 child: Lottie.asset(
//                                   'assets/animations/ScanDots.json',
//                                   fit: BoxFit.contain,
//                                 ),
//                               ),
//                             ),
//                           Align(
//                             alignment: Alignment.bottomCenter,
//                             child: Container(
//                               padding: const EdgeInsets.all(16),
//                               child: Column(
//                                 mainAxisSize: MainAxisSize.min,
//                                 children: [
//                                   SizedBox(
//                                     height: 80,
//                                     child: Lottie.asset(
//                                       'assets/animations/LoadingScan.json',
//                                       width: 180,
//                                       height: 180,
//                                       fit: BoxFit.contain,
//                                     ),
//                                   ),
//                                   const Text(
//                                     'Scanning...',
//                                     style: AppTextStyles.title,
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                         ],
//                       );
//                     } else {
//                       return Center(
//                         child: Column(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             SizedBox(
//                               height: 150,
//                               child: Lottie.asset(
//                                 'assets/animations/LoadingScan.json',
//                                 width: 200,
//                                 height: 200,
//                                 fit: BoxFit.contain,
//                               ),
//                             ),
//                             const SizedBox(height: 10),
//                             const Text(
//                               'Menyiapkan kamera...',
//                               style: TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 16,
//                               ),
//                             ),
//                           ],
//                         ),
//                       );
//                     }
//                   },
//                 ),
//       ),
//     );
//   }
// }
