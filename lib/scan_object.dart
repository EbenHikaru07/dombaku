import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dombaku/dashboard/pendataan/detail_domba.dart';
import 'package:dombaku/dashboard/pendataan/edit_status.dart';
import 'package:dombaku/style.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class EartagScannerPage extends StatefulWidget {
  const EartagScannerPage({Key? key}) : super(key: key);

  @override
  _EartagScannerPageState createState() => _EartagScannerPageState();
}

class _EartagScannerPageState extends State<EartagScannerPage> {
  late CameraController cameraController;
  List<Map<String, String>> scannedResults = [];
  bool _isCameraInitialized = false;
  Timer? _scanTimer;
  bool _isProcessing = false;
  final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
  bool _isFlashOn = false;

  @override
  void initState() {
    super.initState();
    initializeCamera();
  }

  Future<void> initializeCamera() async {
    try {
      final cameras = await availableCameras();
      final firstCamera = cameras.first;
      cameraController = CameraController(firstCamera, ResolutionPreset.max);
      await cameraController.initialize();
      setState(() {
        _isCameraInitialized = true;
      });
      startAutoScanning();
    } catch (e) {
      print("Gagal inisialisasi kamera: $e");
    }
  }

  void startAutoScanning() {
    _scanTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      if (!_isProcessing && cameraController.value.isInitialized) {
        _isProcessing = true;
        bool found = await captureAndScan();
        _isProcessing = false;

        if (found) {
          _scanTimer?.cancel();
        }
      }
    });
  }

  Future<bool> captureAndScan() async {
    try {
      final image = await cameraController.takePicture();
      final imageFile = File(image.path);

      bool found = await recognizeTextAndColor(imageFile);

      setState(() {});
      return found;
    } catch (e) {
      print('Error capturing image: $e');
      return false;
    }
  }

  @override
  void dispose() {
    _scanTimer?.cancel();
    cameraController.dispose();
    textRecognizer.close();
    super.dispose();
  }

  Future<bool> recognizeTextAndColor(File imageFile) async {
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    final inputImage = InputImage.fromFile(imageFile);
    final recognizedText = await textRecognizer.processImage(inputImage);

    final bytes = await imageFile.readAsBytes();
    final uiImage = await decodeImageFromList(bytes);

    final byteData = await uiImage.toByteData(
      format: ui.ImageByteFormat.rawRgba,
    );
    if (byteData == null) return false;

    final pixels = byteData.buffer.asUint8List();
    int width = uiImage.width;
    int height = uiImage.height;

    final newResults = <Map<String, String>>[];
    bool matchFound = false;

    for (TextBlock block in recognizedText.blocks) {
      for (TextLine line in block.lines) {
        final rect = line.boundingBox;
        if (rect == null) continue;

        String text = line.text.trim();

        final isNumeric = RegExp(r'^\d+$').hasMatch(text);
        if (!isNumeric) continue;

        int samplePadding = 10;
        int startX = (rect.left - samplePadding).clamp(0, width - 1).toInt();
        int startY = (rect.top - samplePadding).clamp(0, height - 1).toInt();
        int endX = (rect.right + samplePadding).clamp(0, width - 1).toInt();
        int endY = (rect.bottom + samplePadding).clamp(0, height - 1).toInt();

        int totalR = 0, totalG = 0, totalB = 0;
        int sampleCount = 0;

        for (int x = startX; x <= endX; x++) {
          for (int y = startY; y <= endY; y++) {
            int pixelIndex = (y * width + x) * 4;
            if (pixelIndex + 3 >= pixels.length) continue;

            totalR += pixels[pixelIndex];
            totalG += pixels[pixelIndex + 1];
            totalB += pixels[pixelIndex + 2];
            sampleCount++;
          }
        }

        if (sampleCount == 0) continue;

        int avgR = (totalR / sampleCount).toInt();
        int avgG = (totalG / sampleCount).toInt();
        int avgB = (totalB / sampleCount).toInt();

        final color = Color.fromARGB(255, avgR, avgG, avgB);
        final colorName = getColorName(color);

        final snapshot =
            await FirebaseFirestore.instance
                .collection('manajemendomba')
                .where('eartag', isEqualTo: text)
                .where('warna_eartag', isEqualTo: colorName)
                .get();

        for (var doc in snapshot.docs) {
          newResults.add({
            'text': text,
            'color': colorName,
            'kelamin': doc['kelamin'],
            'kesehatan': doc['kesehatan'],
            'kandang': doc['kandang'],
            'induk_jantan': doc['induk_jantan'],
            'induk_betina': doc['induk_betina'],
            'tanggal_lahir': doc['tanggal_lahir'],
            'bobot_badan': doc['bobot_badan']?.toString() ?? '0',
          });
          matchFound = true;
        }
      }
    }

    if (newResults.isNotEmpty) {
      scannedResults.addAll(newResults);
      await cameraController.pausePreview();
      _scanTimer?.cancel();
    }

    return matchFound;
  }

  String getColorName(Color color) {
    final hsv = HSVColor.fromColor(color);
    final hue = hsv.hue;
    final saturation = hsv.saturation;
    final value = hsv.value;

    final r = color.red;
    final g = color.green;
    final b = color.blue;

    bool isNeutral =
        (r - g).abs() < 15 && (g - b).abs() < 15 && (r - b).abs() < 15;

    if (isNeutral) {
      if (value < 0.2) return 'Hitam';
      if (value >= 0.2 && value <= 0.7) return 'Abu-abu';
      if (value > 0.7) return 'Putih';
    }

    if (hue >= 0 && hue < 20) return 'Merah';
    if (hue >= 20 && hue < 40) return 'Orange';
    if (hue >= 40 && hue < 70) return 'Kuning';
    if (hue >= 70 && hue < 160) return 'Hijau';
    if (hue >= 160 && hue < 250) return 'Biru';
    if (hue >= 250 && hue < 290) return 'Ungu';
    if (hue >= 290 && hue <= 360) return 'Merah';

    return 'Tidak Terdefinisi';
  }

  Widget infoRow(
    IconData icon,
    // String label,
    String value, {
    Color iconColor = Colors.blue,
    Color? backgroundColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 3),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Text(
              //   label,
              //   style: const TextStyle(fontSize: 12, color: Colors.grey),
              // ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget actionButton({
    required IconData icon,
    required String label,
    required List<Color> colors,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 3),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: colors,
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: Colors.white),
            const SizedBox(width: 5),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Visibility(
        visible: scannedResults.isNotEmpty,
        child: FloatingActionButton(
          onPressed: () async {
            try {
              setState(() {
                scannedResults.clear();
              });

              if (!_isCameraInitialized ||
                  !cameraController.value.isInitialized) {
                await initializeCamera();
              } else {
                if (cameraController.value.isPreviewPaused) {
                  await cameraController.resumePreview();
                }
                _scanTimer?.cancel();
                initializeCamera();
              }
            } catch (e) {
              print('Gagal restart kamera atau scan: $e');
            }
          },
          backgroundColor: Colors.grey,
          splashColor: Colors.black26,
          shape: CircleBorder(),
          child: Icon(Icons.refresh, color: Colors.black),
        ),
      ),

      extendBodyBehindAppBar: false,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: AppBar(
          automaticallyImplyLeading: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xff1D679E), Color(0xff40C5A2)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
          ),
          title: const Text('Eartag Scanner'),
          foregroundColor: Colors.white,
          // actions: [
          //   IconButton(
          //     icon: Icon(_isFlashOn ? Icons.flash_on : Icons.flash_off),
          //     onPressed: () async {
          //       if (_isFlashOn) {
          //         await cameraController.setFlashMode(FlashMode.off);
          //       } else {
          //         await cameraController.setFlashMode(FlashMode.torch);
          //       }
          //       setState(() {
          //         _isFlashOn = !_isFlashOn;
          //       });
          //     },
          //   ),
          // ],
        ),
      ),

      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xff1D679E), Color(0xff40C5A2)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
        child:
            _isCameraInitialized
                ? Column(
                  children: [
                    Expanded(
                      flex: 7,
                      child: Container(
                        decoration: BoxDecoration(
                          // borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Color(0xff40C5A2),
                            width: 2,
                          ),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: CameraPreview(cameraController),
                      ),
                    ),
                    Expanded(
                      flex: 4,
                      child:
                          scannedResults.isEmpty
                              ? const Center(
                                child: Text(
                                  "Belum ada hasil scan.",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              )
                              : ListView.builder(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                                itemCount: scannedResults.length,
                                itemBuilder: (context, index) {
                                  final item = scannedResults[index];
                                  final color = getColorFromName(
                                    item['color'] ?? 'grey',
                                  );
                                  final isDark = isDarkColor(color);
                                  final kelamin =
                                      item['kelamin']?.toLowerCase() ?? 'n/a';

                                  IconData genderIcon;
                                  if (kelamin == 'jantan') {
                                    genderIcon = Icons.male;
                                  } else if (kelamin == 'betina') {
                                    genderIcon = Icons.female;
                                  } else {
                                    genderIcon = Icons.help_outline;
                                  }

                                  return Card(
                                    margin: const EdgeInsets.symmetric(
                                      vertical: 8,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    elevation: 3,
                                    child: Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Expanded(
                                                flex: 2,
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Container(
                                                          padding:
                                                              const EdgeInsets.symmetric(
                                                                horizontal: 5,
                                                                vertical: 5,
                                                              ),
                                                          decoration: BoxDecoration(
                                                            color: color,
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  6,
                                                                ),
                                                          ),
                                                          child: Text(
                                                            'Eartag: ${item['text'] ?? 'N/A'}',
                                                            style: TextStyle(
                                                              fontSize: 18,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color:
                                                                  isDark
                                                                      ? Colors
                                                                          .white
                                                                      : Colors
                                                                          .black,
                                                            ),
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          width: 8,
                                                        ),
                                                        CircleAvatar(
                                                          radius: 15,
                                                          backgroundColor:
                                                              Colors
                                                                  .grey
                                                                  .shade300,
                                                          child: Icon(
                                                            genderIcon,
                                                            size: 25,
                                                            color:
                                                                kelamin ==
                                                                        'jantan'
                                                                    ? Colors
                                                                        .blue
                                                                    : kelamin ==
                                                                        'betina'
                                                                    ? Colors
                                                                        .pink
                                                                    : Colors
                                                                        .black54,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),

                                              Expanded(
                                                flex: 2,
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.end,
                                                  children: [
                                                    const Text(
                                                      'Tanggal Lahir',
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.grey,
                                                      ),
                                                    ),
                                                    Text(
                                                      '${item['tanggal_lahir'] ?? 'N/A'}',
                                                      style: const TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),

                                          const SizedBox(height: 5),

                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: GestureDetector(
                                                      onTap: () {
                                                        print(
                                                          'Lihat Detail Kesehatan',
                                                        );
                                                      },
                                                      child: Container(
                                                        padding:
                                                            const EdgeInsets.symmetric(
                                                              vertical: 6,
                                                              horizontal: 6,
                                                            ),
                                                        margin:
                                                            const EdgeInsets.only(
                                                              right: 6,
                                                              bottom: 5,
                                                            ),
                                                        decoration: BoxDecoration(
                                                          color:
                                                              Colors
                                                                  .green
                                                                  .shade50,
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                12,
                                                              ),
                                                        ),
                                                        child: Row(
                                                          children: [
                                                            const Icon(
                                                              Icons
                                                                  .health_and_safety,
                                                              color:
                                                                  Colors.green,
                                                            ),
                                                            const SizedBox(
                                                              width: 12,
                                                            ),
                                                            Expanded(
                                                              child: Text(
                                                                'Kesehatan: ${item['kesehatan'] ?? 'N/A'}',
                                                                style:
                                                                    const TextStyle(
                                                                      fontSize:
                                                                          14,
                                                                    ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  GestureDetector(
                                                    onTap: () {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder:
                                                              (
                                                                context,
                                                              ) => EditStatusDombaPage(
                                                                eartag:
                                                                    item['text'] ??
                                                                    '',
                                                                statusDomba:
                                                                    item['kesehatan'] ??
                                                                    '',
                                                                warnaEartag:
                                                                    item['color'] ??
                                                                    '',
                                                              ),
                                                        ),
                                                      );
                                                    },

                                                    child: Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                            10,
                                                          ),
                                                      margin:
                                                          const EdgeInsets.only(
                                                            bottom: 5,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        color:
                                                            Colors
                                                                .orange
                                                                .shade100,
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              12,
                                                            ),
                                                      ),
                                                      child: const Icon(
                                                        Icons.edit,
                                                        color: Colors.orange,
                                                        size: 18,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),

                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: GestureDetector(
                                                      onTap: () {
                                                        print(
                                                          'Lihat Detail Kandang',
                                                        );
                                                      },
                                                      child: Container(
                                                        padding:
                                                            const EdgeInsets.symmetric(
                                                              vertical: 5,
                                                              horizontal: 5,
                                                            ),
                                                        margin:
                                                            const EdgeInsets.only(
                                                              bottom: 5,
                                                              right: 6,
                                                            ),
                                                        decoration: BoxDecoration(
                                                          color:
                                                              Colors
                                                                  .blue
                                                                  .shade50,
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                12,
                                                              ),
                                                        ),
                                                        child: Row(
                                                          children: [
                                                            const Icon(
                                                              Icons.home_work,
                                                              color:
                                                                  Colors.blue,
                                                            ),
                                                            const SizedBox(
                                                              width: 12,
                                                            ),
                                                            Expanded(
                                                              child: Text(
                                                                'Kandang: ${item['kandang'] ?? 'N/A'}',
                                                                style:
                                                                    const TextStyle(
                                                                      fontSize:
                                                                          14,
                                                                    ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  // GestureDetector(
                                                  //   onTap: () {
                                                  //     print('Update Kandang');
                                                  //   },
                                                  //   child: Container(
                                                  //     padding:
                                                  //         const EdgeInsets.all(
                                                  //           10,
                                                  //         ),
                                                  //     margin:
                                                  //         const EdgeInsets.only(
                                                  //           bottom: 5,
                                                  //         ),
                                                  //     decoration: BoxDecoration(
                                                  //       color:
                                                  //           Colors
                                                  //               .orange
                                                  //               .shade100,
                                                  //       borderRadius:
                                                  //           BorderRadius.circular(
                                                  //             12,
                                                  //           ),
                                                  //     ),
                                                  //     child: const Icon(
                                                  //       Icons.edit,
                                                  //       color: Colors.orange,
                                                  //       size: 18,
                                                  //     ),
                                                  //   ),
                                                  // ),
                                                ],
                                              ),
                                            ],
                                          ),

                                          const SizedBox(height: 5),
                                          SizedBox(
                                            width: double.infinity,
                                            child: actionButton(
                                              icon: Icons.assignment,
                                              label: 'Detail Domba',
                                              colors: [
                                                const Color(0xff1D679E),
                                                const Color(0xff40C5A2),
                                              ],
                                              onPressed: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder:
                                                        (
                                                          context,
                                                        ) => DetailDombaPage(
                                                          eartag: item['text']!,
                                                          nama: item['text']!,
                                                          gender:
                                                              item['kelamin'] ??
                                                              '',
                                                          gambar:
                                                              (item['kelamin'] ??
                                                                              '')
                                                                          .toLowerCase() ==
                                                                      'jantan'
                                                                  ? 'assets/images/jantan.png'
                                                                  : 'assets/images/betina.png',
                                                          idIndukJantan:
                                                              item['induk_jantan'] ??
                                                              '',
                                                          idIndukBetina:
                                                              item['induk_betina'] ??
                                                              '',
                                                          bobot:
                                                              item['bobot_badan'] !=
                                                                      null
                                                                  ? item['bobot_badan']
                                                                      .toString()
                                                                  : '',
                                                          kandang:
                                                              item['kandang'] ??
                                                              '',
                                                          statusDomba:
                                                              item['kesehatan'] ??
                                                              '',
                                                          tanggalLahir:
                                                              item['tanggal_lahir'] ??
                                                              '',
                                                          warnaEartag:
                                                              item['color'] ??
                                                              '',
                                                        ),
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                    ),
                  ],
                )
                : const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
