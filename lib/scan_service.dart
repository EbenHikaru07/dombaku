// import 'dart:io';
// import 'package:image_picker/image_picker.dart';
// import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

// class ScanService {
//   final ImagePicker _picker = ImagePicker();

//   // ambil gambar dari galeri
//   Future<File?> pickImage() async {
//     final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
//     return pickedFile != null ? File(pickedFile.path) : null;
//   }

//   // ambil gambar dari kamera
//   Future<File?> takePicture() async {
//     final XFile? pickedFile = await _picker.pickImage(source: ImageSource.camera);
//     return pickedFile != null ? File(pickedFile.path) : null;
//   }

//   // proses OCR menggunakan Google ML Kit
//   Future<String> processImage(File image) async {
//     final inputImage = InputImage.fromFile(image);
//     final textRecognizer = TextRecognizer();
//     final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
//     textRecognizer.close();

//     // ambil hanya angka dari hasil OCR
//     return recognizedText.text.replaceAll(RegExp(r'[^0-9]'), '');
//   }
// }
