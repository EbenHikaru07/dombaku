import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dombaku/bottombar/bottom_navbar.dart';
import 'package:dombaku/styleui/appbarstyle2.dart';
import 'package:flutter/material.dart';
import 'package:dombaku/style.dart';
import 'package:fl_chart/fl_chart.dart';

class LaporanPage extends StatefulWidget {
  const LaporanPage({super.key});
  // const LaporanPage({Key? key}) : super(key: key);

  @override
  State<LaporanPage> createState() => _LaporanPageState();
}

class _LaporanPageState extends State<LaporanPage> {
  int _selectedIndex = 2;
  StreamSubscription? umurSubscription;
  StreamSubscription? genderSubscription;
  StreamSubscription? perMonthSubscription;

  Map<String, int> monthData = {
    'Jan': 0,
    'Feb': 0,
    'Mar': 0,
    'Apr': 0,
    'May': 0,
    'Jun': 0,
    'Jul': 0,
    'Aug': 0,
    'Sep': 0,
    'Oct': 0,
    'Nov': 0,
    'Dec': 0,
  };

  Map<String, int> umurKategori = {
    '< 6 Bln': 0,
    '6 - 12 Bln': 0,
    '12 - 18 Bln': 0,
    '> 18 Bln': 0,
  };

  Map<String, int> genderData = {'Jantan': 0, 'Betina': 0};

  int selectedYear = 2025;

  @override
  void initState() {
    super.initState();
    listenDombaPerMonth(selectedYear);
    listenToUmurKategori();
    listenToGender();
  }

  @override
  void dispose() {
    perMonthSubscription?.cancel();
    umurSubscription?.cancel();
    genderSubscription?.cancel();
    super.dispose();
  }

  void _changeYear(int newYear) {
    setState(() {
      selectedYear = newYear;
    });
    listenDombaPerMonth(newYear);
  }

  double _getMaxY() {
    if (umurKategori.isEmpty) return 5;
    int maxValue = umurKategori.values.fold(
      0,
      (prev, element) => element > prev ? element : prev,
    );
    return (maxValue + 1).toDouble();
  }

  void listenToUmurKategori() {
    umurSubscription = FirebaseFirestore.instance
        .collection('manajemendomba')
        .snapshots()
        .listen((snapshot) {
          Map<String, int> kategori = {
            '< 6 Bln': 0,
            '6 - 12 Bln': 0,
            '12 - 18 Bln': 0,
            '> 18 Bln': 0,
          };

          DateTime now = DateTime.now();

          for (var doc in snapshot.docs) {
            try {
              DateTime tanggalLahir = DateTime.parse(doc['tanggal_lahir']);
              int usiaBulan =
                  (now.year - tanggalLahir.year) * 12 +
                  (now.month - tanggalLahir.month);

              if (usiaBulan < 6) {
                kategori['< 6 Bln'] = kategori['< 6 Bln']! + 1;
              } else if (usiaBulan < 12) {
                kategori['6 - 12 Bln'] = kategori['6 - 12 Bln']! + 1;
              } else if (usiaBulan < 18) {
                kategori['12 - 18 Bln'] = kategori['12 - 18 Bln']! + 1;
              } else {
                kategori['> 18 Bln'] = kategori['> 18 Bln']! + 1;
              }
            } catch (_) {}
          }

          setState(() {
            umurKategori = kategori;
          });
        });
  }

  void listenToGender() {
    genderSubscription = FirebaseFirestore.instance
        .collection('manajemendomba')
        .snapshots()
        .listen((snapshot) {
          Map<String, int> genderCount = {'Jantan': 0, 'Betina': 0};

          for (var doc in snapshot.docs) {
            final kelamin = doc['kelamin'];
            if (kelamin == 'Jantan') {
              genderCount['Jantan'] = genderCount['Jantan']! + 1;
            } else if (kelamin == 'Betina') {
              genderCount['Betina'] = genderCount['Betina']! + 1;
            }
          }

          setState(() {
            genderData = genderCount;
          });
        });
  }

  void listenDombaPerMonth(int selectedYear) {
    perMonthSubscription?.cancel();

    perMonthSubscription = FirebaseFirestore.instance
        .collection('manajemendomba')
        .snapshots()
        .listen((snapshot) {
          Map<String, int> data = {
            'Jan': 0,
            'Feb': 0,
            'Mar': 0,
            'Apr': 0,
            'May': 0,
            'Jun': 0,
            'Jul': 0,
            'Aug': 0,
            'Sep': 0,
            'Oct': 0,
            'Nov': 0,
            'Dec': 0,
          };

          for (var doc in snapshot.docs) {
            try {
              DateTime tanggalLahir = DateTime.parse(doc['tanggal_lahir']);
              if (tanggalLahir.year == selectedYear) {
                String month = _getMonthName(tanggalLahir.month);
                data[month] = data[month]! + 1;
              }
            } catch (_) {}
          }

          setState(() {
            monthData = data;
          });
        });
  }

  String _getMonthName(int month) {
    switch (month) {
      case 1:
        return 'Jan';
      case 2:
        return 'Feb';
      case 3:
        return 'Mar';
      case 4:
        return 'Apr';
      case 5:
        return 'May';
      case 6:
        return 'Jun';
      case 7:
        return 'Jul';
      case 8:
        return 'Aug';
      case 9:
        return 'Sep';
      case 10:
        return 'Oct';
      case 11:
        return 'Nov';
      case 12:
        return 'Dec';
      default:
        return '';
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Map<String, double> _getGenderPercentage() {
    int total = genderData.values.fold(0, (a, b) => a + b);
    if (total == 0) return {'Jantan': 0, 'Betina': 0};

    return genderData.map(
      (key, value) => MapEntry(key, (value / total * 100).toDouble()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF0F0F0),
      appBar: const CustomAppBar2(
        title: "Laporan",
        centerTitle: false,
        actions: [
          // IconButton(
          //   icon: Icon(Icons.notifications, color: Colors.white),
          //   onPressed: null,
          // ),
          // SizedBox(width: 10),
          // IconButton(
          //   icon: CircleAvatar(
          //     backgroundImage: AssetImage('assets/icon/sheep.png'),
          //   ),
          //   onPressed: null,
          // ),
          // SizedBox(width: 10),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            _buildYearSelector(),
            _buildLineChart(),
            const Divider(thickness: 2, height: 20),
            _buildBarChart(),
            _buildBarChartUsia(),
            _buildChartSection(
              title: "Data Gender Domba",
              data: _getGenderPercentage(),
              colors: [Color(0xff4687e6), Color(0xffef649e)],
              total: genderData.values.fold(0, (a, b) => a + b),
              titleAlignment: Alignment.centerLeft,
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
        hasCenterFAB: false,
      ),
    );
  }

  Widget _buildBarChart() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Umur Domba per Kategori ( Bln = Bulan )",
          style: AppTextStyles.titleBlack,
        ),
        Text(
          "[ y = Jumlah Domba , x = Umur Domba ]",
          style: AppTextStyles.titleDash,
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 220,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: _getMaxY(),
              barTouchData: BarTouchData(enabled: true),
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, _) {
                      switch (value.toInt()) {
                        case 0:
                          return const Text('< 6 Bln');
                        case 1:
                          return const Text('6 - 12 Bln');
                        case 2:
                          return const Text('12 - 18 Bln');
                        case 3:
                          return const Text('> 18 Bln');
                        default:
                          return const Text('');
                      }
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: true),
                ),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              gridData: FlGridData(show: true),
              borderData: FlBorderData(show: true),
              barGroups: [
                BarChartGroupData(
                  x: 0,
                  barRods: [
                    BarChartRodData(
                      toY: (umurKategori['< 6 Bln'] ?? 0).toDouble(),
                      color: Color(0xff1fbeab),
                      width: 22,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                ),
                BarChartGroupData(
                  x: 1,
                  barRods: [
                    BarChartRodData(
                      toY: (umurKategori['6 - 12 Bln'] ?? 0).toDouble(),
                      color: Colors.cyan,
                      width: 22,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                ),
                BarChartGroupData(
                  x: 2,
                  barRods: [
                    BarChartRodData(
                      toY: (umurKategori['12 - 18 Bln'] ?? 0).toDouble(),
                      color: Colors.teal[200],
                      width: 22,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                ),
                BarChartGroupData(
                  x: 3,
                  barRods: [
                    BarChartRodData(
                      toY: (umurKategori['> 18 Bln'] ?? 0).toDouble(),
                      color: Colors.red,
                      width: 22,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildYearSelector() {
    return DropdownButton<int>(
      value: selectedYear,
      onChanged: (int? newYear) {
        if (newYear != null) {
          _changeYear(newYear);
        }
      },
      items:
          [2025, 2026, 2027].map<DropdownMenuItem<int>>((int value) {
            return DropdownMenuItem<int>(
              value: value,
              child: Text('Tahun $value'),
            );
          }).toList(),
    );
  }

  Widget _buildLineChart() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Tren Kelahiran Domba per Bulan",
          style: AppTextStyles.titleBlack,
        ),
        Text(
          "[ y = Jumlah Domba , x = Bulan Lahir Domba]",
          style: AppTextStyles.titleDash,
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 300,
          child: LineChart(
            LineChartData(
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, _) {
                      switch (value.toInt()) {
                        case 0:
                          return const Text('Jan');
                        case 1:
                          return const Text('Feb');
                        case 2:
                          return const Text('Mar');
                        case 3:
                          return const Text('Apr');
                        case 4:
                          return const Text('May');
                        case 5:
                          return const Text('Jun');
                        case 6:
                          return const Text('Jul');
                        case 7:
                          return const Text('Aug');
                        case 8:
                          return const Text('Sep');
                        case 9:
                          return const Text('Oct');
                        case 10:
                          return const Text('Nov');
                        case 11:
                          return const Text('Dec');
                        default:
                          return const Text('');
                      }
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: true),
                ),
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              gridData: FlGridData(show: true),
              borderData: FlBorderData(show: true),
              lineBarsData: [
                LineChartBarData(
                  spots:
                      monthData.entries
                          .map(
                            (e) => FlSpot(
                              monthData.keys.toList().indexOf(e.key).toDouble(),
                              e.value.toDouble(),
                            ),
                          )
                          .toList(),
                  isCurved: true,
                  color: Color(0xff1fbeab),
                  barWidth: 3,
                  dotData: FlDotData(show: true),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBarChartUsia() {
    final fertilitasPerBulan = {
      "Jan": 3,
      "Feb": 5,
      "Mar": 7,
      "Apr": 4,
      "May": 6,
      "Jun": 2,
      "Jul": 8,
      "Aug": 5,
      "Sep": 4,
      "Oct": 6,
      "Nov": 3,
      "Dec": 2,
    };

    final monthKeys = fertilitasPerBulan.keys.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(thickness: 2, height: 20),
        Text("Tren Fertilitas Domba", style: AppTextStyles.titleDash),
        const SizedBox(height: 10),
        SizedBox(
          height: 250,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY:
                  (fertilitasPerBulan.values.reduce((a, b) => a > b ? a : b) +
                          2)
                      .toDouble(),
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, _) {
                      if (value.toInt() < monthKeys.length) {
                        return Text(monthKeys[value.toInt()]);
                      }
                      return const Text('');
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: true),
                ),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              gridData: FlGridData(show: true),
              borderData: FlBorderData(show: true),
              barGroups: List.generate(fertilitasPerBulan.length, (index) {
                final value = fertilitasPerBulan[monthKeys[index]]!;
                return BarChartGroupData(
                  x: index,
                  barRods: [
                    BarChartRodData(
                      toY: value.toDouble(),
                      color: Color(0xff1fbeab),
                      width: 18,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                );
              }),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChartSection({
    required String title,
    required Map<String, double> data,
    required List<Color> colors,
    required int total,
    required Alignment titleAlignment,
  }) {
    return Column(
      children: [
        const Divider(thickness: 2, height: 20),
        Container(
          alignment: titleAlignment,
          child: Text(title, style: AppTextStyles.titleDash),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: _buildDonutChart(data, colors, total)),
            _buildLegend(data.keys.toList(), colors),
          ],
        ),
      ],
    );
  }

  Widget _buildDonutChart(
    Map<String, double> data,
    List<Color> colors,
    int total,
  ) {
    List<PieChartSectionData> sections = [];
    int index = 0;
    data.forEach((key, value) {
      sections.add(
        PieChartSectionData(
          color: colors[index],
          value: value,
          title: '${value.toInt()}%',
          radius: 50,
          titleStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      );
      index++;
    });

    return SizedBox(
      height: 150,
      width: 150,
      child: Stack(
        alignment: Alignment.center,
        children: [
          PieChart(
            PieChartData(
              sections: sections,
              borderData: FlBorderData(show: false),
              centerSpaceRadius: 30,
              startDegreeOffset: 90,
            ),
          ),
          Text(
            "Total\n$total",
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend(List<String> labels, List<Color> colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(labels.length, (index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 5),
          child: Row(
            children: [
              Container(width: 12, height: 12, color: colors[index]),
              const SizedBox(width: 8),
              Text(
                labels[index],
                style: const TextStyle(fontSize: 14, color: Colors.black),
              ),
            ],
          ),
        );
      }),
    );
  }
}
