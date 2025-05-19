import 'package:dombaku/dashboard/pendataan/edit_status.dart';
import 'package:dombaku/style.dart';
import 'package:flutter/material.dart';

class DetailDombaPage extends StatefulWidget {
  final String eartag;
  final String nama;
  final String gender;
  final String gambar;
  final String idIndukJantan;
  final String idIndukBetina;
  final String bobot;
  final String tanggalLahir;
  final String kandang;
  final String statusDomba;
  final String warnaEartag;

  const DetailDombaPage({
    super.key,
    required this.eartag,
    required this.nama,
    required this.gender,
    required this.gambar,
    required this.idIndukJantan,
    required this.idIndukBetina,
    required this.bobot,
    required this.tanggalLahir,
    required this.kandang,
    required this.statusDomba,
    required this.warnaEartag,
  });

  @override
  _DetailDombaPageState createState() => _DetailDombaPageState();
}

class _DetailDombaPageState extends State<DetailDombaPage> {
  late String statusDomba;

  @override
  void initState() {
    super.initState();
    statusDomba = widget.statusDomba;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 190,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(15),
                  bottomRight: Radius.circular(15),
                ),
                image: DecorationImage(
                  image: AssetImage("assets/slide/slidesheep2.jpg"),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Positioned(
            top: 40,
            left: 10,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
          Positioned(
            top: 45,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                  child: CircleAvatar(
                    radius: 33,
                    backgroundColor: Colors.grey[200],
                    child: ClipOval(
                      child: Image.asset(
                        widget.gambar,
                        width: 70,
                        height: 70,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 6,
                    horizontal: 12,
                  ),
                  decoration: BoxDecoration(
                    color: getColorFromWarnaEartag(widget.warnaEartag),
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: Colors.black),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.local_offer,
                        size: 18,
                        color:
                            getColorFromWarnaEartag(
                                      widget.warnaEartag,
                                    ).computeLuminance() >
                                    0.5
                                ? Colors.black
                                : Colors.white,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        "Eartag: ${widget.eartag}",
                        style: AppTextStyles.title.copyWith(
                          color:
                              getColorFromWarnaEartag(
                                        widget.warnaEartag,
                                      ).computeLuminance() >
                                      0.5
                                  ? Colors.black
                                  : Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 200,
            left: 10,
            right: 10,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white70,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 5,
                    spreadRadius: 2,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Color(0xff042E22),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 16,
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info, color: Colors.white, size: 22),
                          SizedBox(width: 8),
                          Text("Detail Domba", style: AppTextStyles.title),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 450,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDetailItem(
                            "Eartag Domba",
                            widget.eartag,
                            Icons.confirmation_number,
                          ),
                          _buildDetailItem(
                            "Jenis Kelamin",
                            widget.gender,
                            widget.gender == "Jantan"
                                ? Icons.male
                                : Icons.female,
                          ),
                          _buildDetailItem(
                            "Tanggal Lahir",
                            widget.tanggalLahir,
                            Icons.calendar_today,
                          ),
                          _buildDetailItem(
                            "Eartag Induk Betina",
                            widget.idIndukBetina,
                            Icons.female,
                          ),
                          _buildDetailItem(
                            "Eartag Induk Jantan",
                            widget.idIndukJantan,
                            Icons.male,
                          ),
                          _buildDetailItem(
                            "Bobot Badan",
                            "${widget.bobot} KG",
                            Icons.scale,
                          ),
                          _buildDetailItem(
                            "Kandang",
                            widget.kandang,
                            Icons.home,
                          ),
                          _buildStatusItem(context),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String title, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: DetailDomba.title),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(icon, size: 20, color: Colors.green[700]),
              const SizedBox(width: 6),
              Text(value, style: DetailDomba.value),
            ],
          ),
          const Divider(),
        ],
      ),
    );
  }

  Widget _buildStatusItem(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Status Domba", style: DetailDomba.title),
          const SizedBox(height: 6),
          Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(
                  vertical: 6,
                  horizontal: 12,
                ),
                decoration: BoxDecoration(
                  color: getStatusColor(statusDomba).withOpacity(0.2),
                  border: Border.all(
                    color: getStatusColor(statusDomba),
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      getStatusIcon(statusDomba),
                      color: getStatusColor(statusDomba),
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      statusDomba,
                      style: TextStyle(
                        fontFamily: 'Exo2',
                        fontSize: 16,
                        color: getStatusColor(statusDomba),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => EditStatusDombaPage(
                            eartag: widget.eartag,
                            statusDomba:
                                widget.statusDomba.isNotEmpty
                                    ? widget.statusDomba
                                    : '',
                            warnaEartag: widget.warnaEartag,
                          ),
                    ),
                  );

                  if (result != null && result is String && result.isNotEmpty) {
                    setState(() {
                      statusDomba = result;
                    });
                    Navigator.pop(context, 'refresh');
                  }
                },

                child: const Icon(Icons.edit, color: Colors.grey, size: 25),
              ),
            ],
          ),
          const Divider(),
        ],
      ),
    );
  }
}
