import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dombaku/dashboard/kesehatan/detail_kesehatan.dart';
import 'package:dombaku/dashboard/pendataan/detail_domba.dart';
import 'package:dombaku/dashboard/pendataan/edit_status.dart';
import 'package:dombaku/kategori_menu/rekomendasi_kawin/hasil_rekomendasi.dart';
import 'package:dombaku/session/user_session.dart';
import 'package:dombaku/style.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:lottie/lottie.dart';

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
  String? _namaPeternak;

  @override
  void initState() {
    super.initState();
    loadUserSessionAndInitCamera();
  }

  Future<void> loadUserSessionAndInitCamera() async {
    final userData = await UserSession.getUserData();
    setState(() {
      _namaPeternak = userData['nama_peternak'];
    });
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
    _scanTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
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
    if (_namaPeternak == null) {
      print("Nama peternakan belum tersedia, hentikan proses scan!");
      return false;
    }

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
                .where('nama_peternak', isEqualTo: _namaPeternak)
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
            'nama_peternak': doc['nama_peternak'],
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

  Future<void> cekRekomendasiDanNavigasi(
    BuildContext context,
    String eartag,
  ) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 100,
                height: 100,
                child: Lottie.asset('assets/animations/LoadingUn.json'),
              ),
            ],
          ),
        );
      },
    );

    try {
      final querySnapshot =
          await FirebaseFirestore.instance
              .collection('rekomendasikawin')
              .where('id_jantan', isEqualTo: eartag)
              .get();

      Navigator.of(context).pop();

      if (querySnapshot.docs.isNotEmpty) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HasilRekomendasiKawin(idDomba: eartag),
          ),
        );
      } else {
        showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: Text("Data Tidak Ditemukan"),
                content: Text(
                  "Eartag $eartag tidak memiliki data rekomendasi kawin.",
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text("Tutup"),
                  ),
                ],
              ),
        );
      }
    } catch (e) {
      Navigator.of(context).pop();

      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: Text("Kesalahan"),
              content: Text("Terjadi kesalahan saat mencari data:\n$e"),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text("Tutup"),
                ),
              ],
            ),
      );
    }
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
          backgroundColor: Colors.grey.withOpacity(0.5),
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
          title: const Text(
            'Eartag Scanner',
            style: TextStyle(fontFamily: 'Exo2'),
          ),
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
                                    fontFamily: 'Exo2',
                                    fontSize: 16,
                                    color: Colors.grey,
                                  ),
                                ),
                              )
                              : ListView.builder(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
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
                                  final eartag = item['text'] ?? 'N/A';

                                  IconData genderIcon;
                                  Color genderColor;
                                  if (kelamin == 'jantan') {
                                    genderIcon = Icons.male;
                                    genderColor = Colors.blue;
                                  } else if (kelamin == 'betina') {
                                    genderIcon = Icons.female;
                                    genderColor = Colors.pink;
                                  } else {
                                    genderIcon = Icons.help_outline;
                                    genderColor = Colors.grey;
                                  }

                                  return Card(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    elevation: 5,
                                    margin: const EdgeInsets.symmetric(
                                      vertical: 5,
                                    ),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [
                                            Color(0xff1D679E),
                                            Color(0xff40C5A2),
                                          ],
                                          begin: Alignment.centerLeft,
                                          end: Alignment.centerRight,
                                        ),
                                        borderRadius: const BorderRadius.all(
                                          Radius.circular(16),
                                        ),
                                        border: Border.all(
                                          color: Colors.white.withOpacity(0.5),
                                          width: 1.5,
                                        ),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(16),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Row(
                                                  children: [
                                                    Container(
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            horizontal: 10,
                                                            vertical: 6,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        color: color,
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              8,
                                                            ),
                                                      ),
                                                      child: Row(
                                                        children: [
                                                          Icon(
                                                            Icons.local_offer,
                                                            color:
                                                                isDark
                                                                    ? Colors
                                                                        .white
                                                                    : Colors
                                                                        .black,
                                                          ),
                                                          const SizedBox(
                                                            width: 5,
                                                          ),
                                                          Text(
                                                            eartag,
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  'Exo2',
                                                              fontSize: 17,
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
                                                        ],
                                                      ),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    CircleAvatar(
                                                      radius: 18,
                                                      // backgroundColor:
                                                      //     genderColor
                                                      //         .withOpacity(0.2),
                                                      backgroundColor: Colors
                                                          .white
                                                          .withOpacity(0.7),
                                                      child: Icon(
                                                        genderIcon,
                                                        color: genderColor,
                                                        size: 25,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Row(
                                                  children: [
                                                    const SizedBox(width: 5),

                                                    if (kelamin
                                                            ?.trim()
                                                            .toLowerCase() ==
                                                        "jantan")
                                                      Container(
                                                        decoration: BoxDecoration(
                                                          gradient: LinearGradient(
                                                            colors: [
                                                              Color(0xff1D679E),
                                                              Color(0xff40C5A2),
                                                            ],
                                                            begin:
                                                                Alignment
                                                                    .topLeft,
                                                            end:
                                                                Alignment
                                                                    .bottomRight,
                                                          ),
                                                          shape:
                                                              BoxShape.circle,
                                                        ),
                                                        child: IconButton(
                                                          icon: Icon(
                                                            Icons
                                                                .schema_rounded,
                                                            size: 20,
                                                          ),
                                                          color: Colors.white,
                                                          tooltip:
                                                              'Rekomendasi Kawin',
                                                          onPressed: () {
                                                            if (eartag !=
                                                                    null &&
                                                                eartag
                                                                    .isNotEmpty) {
                                                              cekRekomendasiDanNavigasi(
                                                                context,
                                                                eartag,
                                                              );
                                                            }
                                                          },
                                                        ),
                                                      ),
                                                  ],
                                                ),
                                              ],
                                            ),

                                            const SizedBox(height: 10),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Expanded(
                                                  child: GestureDetector(
                                                    onTap: () async {
                                                      final eartag =
                                                          item['text']?.trim();
                                                      if (eartag == null ||
                                                          eartag.isEmpty) {
                                                        ScaffoldMessenger.of(
                                                          context,
                                                        ).showSnackBar(
                                                          const SnackBar(
                                                            content: Text(
                                                              'Eartag tidak valid.',
                                                            ),
                                                          ),
                                                        );
                                                        return;
                                                      }
                                                      try {
                                                        final snapshot =
                                                            await FirebaseFirestore
                                                                .instance
                                                                .collection(
                                                                  'catatan_kesehatan',
                                                                )
                                                                .where(
                                                                  'eartag',
                                                                  isEqualTo:
                                                                      eartag,
                                                                )
                                                                .orderBy(
                                                                  'timestamp',
                                                                  descending:
                                                                      true,
                                                                )
                                                                .limit(1)
                                                                .get();

                                                        if (snapshot
                                                            .docs
                                                            .isNotEmpty) {
                                                          final doc =
                                                              snapshot
                                                                  .docs
                                                                  .first;
                                                          Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder:
                                                                  (_) =>
                                                                      DetailKesehatanPage(
                                                                        document:
                                                                            doc,
                                                                      ),
                                                            ),
                                                          );
                                                        } else {
                                                          ScaffoldMessenger.of(
                                                            context,
                                                          ).showSnackBar(
                                                            SnackBar(
                                                              content: Text(
                                                                'Data kesehatan eartag "$eartag" tidak ada',
                                                              ),
                                                              backgroundColor:
                                                                  Colors.orange,
                                                            ),
                                                          );
                                                        }
                                                      } catch (e) {
                                                        print(
                                                          'Error saat mengambil data kesehatan: $e',
                                                        );
                                                        ScaffoldMessenger.of(
                                                          context,
                                                        ).showSnackBar(
                                                          SnackBar(
                                                            content: Text(
                                                              'Terjadi kesalahan: $e',
                                                            ),
                                                            backgroundColor:
                                                                Colors.red,
                                                          ),
                                                        );
                                                      }
                                                    },
                                                    child: Container(
                                                      margin:
                                                          const EdgeInsets.only(
                                                            right: 4,
                                                          ),
                                                      padding:
                                                          const EdgeInsets.all(
                                                            10,
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
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          const Icon(
                                                            Icons
                                                                .health_and_safety,
                                                            color: Colors.green,
                                                          ),
                                                          const SizedBox(
                                                            height: 4,
                                                          ),
                                                          Text(
                                                            'Kesehatan',
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  'Exo2',
                                                              fontSize: 12,
                                                              color:
                                                                  Colors
                                                                      .grey[700],
                                                            ),
                                                          ),
                                                          Text(
                                                            '${item['kesehatan'] ?? 'N/A'}',
                                                            style:
                                                                const TextStyle(
                                                                  fontFamily:
                                                                      'Exo2',
                                                                  fontSize: 14,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
                                                  child: Container(
                                                    margin:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 4,
                                                        ),
                                                    padding:
                                                        const EdgeInsets.all(
                                                          10,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color:
                                                          Colors.blue.shade50,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            12,
                                                          ),
                                                    ),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        const Icon(
                                                          Icons
                                                              .house_siding_rounded,
                                                          color: Colors.blue,
                                                        ),
                                                        const SizedBox(
                                                          height: 4,
                                                        ),
                                                        Text(
                                                          'Kandang',
                                                          style: TextStyle(
                                                            fontFamily: 'Exo2',
                                                            fontSize: 12,
                                                            color:
                                                                Colors
                                                                    .grey[700],
                                                          ),
                                                        ),
                                                        Text(
                                                          '${item['kandang'] ?? 'N/A'}',
                                                          style:
                                                              const TextStyle(
                                                                fontFamily:
                                                                    'Exo2',
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
                                                  child: Container(
                                                    margin:
                                                        const EdgeInsets.only(
                                                          left: 4,
                                                        ),
                                                    padding:
                                                        const EdgeInsets.all(
                                                          10,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color:
                                                          Colors.orange.shade50,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            12,
                                                          ),
                                                    ),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        const Icon(
                                                          Icons
                                                              .timelapse_rounded,
                                                          color: Colors.orange,
                                                        ),
                                                        const SizedBox(
                                                          height: 4,
                                                        ),
                                                        Text(
                                                          'Lahir',
                                                          style: TextStyle(
                                                            fontFamily: 'Exo2',
                                                            fontSize: 12,
                                                            color:
                                                                Colors
                                                                    .grey[700],
                                                          ),
                                                        ),
                                                        Text(
                                                          '${item['tanggal_lahir'] ?? 'N/A'}',
                                                          style:
                                                              const TextStyle(
                                                                fontFamily:
                                                                    'Exo2',
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 5.0),
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: TextButton.icon(
                                                    onPressed: () {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder:
                                                              (
                                                                _,
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
                                                      print(
                                                        'Edit status domba',
                                                      );
                                                    },
                                                    icon: Icon(
                                                      Icons.edit,
                                                      size: 18,
                                                      color: Colors.white,
                                                    ),
                                                    label: Text(
                                                      "Edit Status",
                                                      style: TextStyle(
                                                        fontFamily: 'Exo2',
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                    style: TextButton.styleFrom(
                                                      backgroundColor: Color(
                                                        0xFF6C63FF,
                                                      ),
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                            vertical: 12,
                                                          ),
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              10,
                                                            ),
                                                      ),
                                                    ),
                                                  ),
                                                ),

                                                SizedBox(width: 8),
                                                Expanded(
                                                  child: TextButton.icon(
                                                    onPressed: () {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder:
                                                              (
                                                                _,
                                                              ) => DetailDombaPage(
                                                                eartag:
                                                                    item['text'] ??
                                                                    '',
                                                                nama:
                                                                    item['text'] ??
                                                                    '',
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
                                                                    item['bobot_badan']
                                                                        ?.toString() ??
                                                                    '',
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
                                                                namaPeternak:
                                                                    item['nama_peternak'] ??
                                                                    '',
                                                              ),
                                                        ),
                                                      );
                                                      print(
                                                        'Lihat detail domba',
                                                      );
                                                    },
                                                    icon: Icon(
                                                      Icons.info_outline,
                                                      size: 18,
                                                      color: Colors.white,
                                                    ),
                                                    label: Text(
                                                      "Detail",
                                                      style: TextStyle(
                                                        fontFamily: 'Exo2',
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                    style: TextButton.styleFrom(
                                                      backgroundColor: Color(
                                                        0xFF00BFA6,
                                                      ), // teal flat modern
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                            vertical: 12,
                                                          ),
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              10,
                                                            ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                    ),
                  ],
                )
                : Center(
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
                        "Memuat kamera...",
                        style: TextStyle(
                          fontFamily: 'Exo2',
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
      ),
    );
  }
}
