import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:drink_app/database.dart';

class GraphPage extends StatefulWidget {
  @override
  _GraphPageState createState() => _GraphPageState();
}

var globalSize;
double value = 4;

class _GraphPageState extends State<GraphPage> {
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    DateTime now = new DateTime.now();
    globalSize = size;

    return Scaffold(
      backgroundColor: Color(0xff231b10),
      body: SingleChildScrollView(
        child: Padding(
          padding:
              const EdgeInsets.only(top: 40, left: 14, right: 20, bottom: 14),
          child: Container(
            alignment: Alignment.center,
            child: Column(
              children: [
                SizedBox(
                  height: 10,
                ),
                Text(
                  'Year ${now.year}',
                  style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  "Days you got drunk this year!",
                  style: TextStyle(fontSize: 15, color: Colors.white),
                ),
                SizedBox(
                  height: 25,
                ),
                ChartSelection(),
                SizedBox(
                  height: 25,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ChartSelection extends StatelessWidget {
  final List<Color> gradientColors = [
    Colors.amber,
    Colors.red,
  ];

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: globalSize.width * 0.85,
        height: globalSize.height * 0.6,
        child: LineChart(
          LineChartData(
            lineTouchData: LineTouchData(
              touchTooltipData: LineTouchTooltipData(
                tooltipBgColor: Colors.blueGrey.withOpacity(0.8),
              ),
              touchCallback: (LineTouchResponse touchResponse) {},
              handleBuiltInTouches: true,
            ),
            borderData: FlBorderData(
              show: false,
            ),
            backgroundColor: Colors.transparent,
            titlesData: FlTitlesData(
              bottomTitles: SideTitles(
                showTitles: true,
                getTextStyles: (value) => const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                margin: 15,
                getTitles: (value) {
                  switch (value.toInt()) {
                    case 1:
                      return 'JAN';
                    case 5:
                      return 'MAY';
                    case 9:
                      return 'SEPT';
                    case 12:
                      return 'DEC';
                  }
                  return '';
                },
              ),
              leftTitles: SideTitles(
                showTitles: true,
                getTextStyles: (value) => const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                margin: 15,
                reservedSize: 10,
                getTitles: (value) {
                  switch (value.toInt()) {
                    case 0:
                      return '0';
                    case 2:
                      return '2';
                    case 4:
                      return '4';
                    case 6:
                      return '6';
                    case 8:
                      return '8';
                    case 10:
                      return '10';
                    case 12:
                      return '12';
                    case 14:
                      return '14';
                    case 16:
                      return '16';
                    case 18:
                      return '18';
                    case 20:
                      return '20';
                    case 22:
                      return '22';
                    case 24:
                      return '24';
                    case 26:
                      return '26';
                    case 28:
                      return '28';
                    case 30:
                      return '30';
                  }
                  return '';
                },
              ),
            ),
            gridData: FlGridData(
              show: true,
              getDrawingHorizontalLine: (value) {
                return FlLine(
                    color: Colors.white, strokeWidth: 0.3, dashArray: [5, 10]);
              },
              getDrawingVerticalLine: (value) {
                return FlLine(
                    color: Colors.white, strokeWidth: 0.3, dashArray: [5, 10]);
              },
              drawVerticalLine: true,
            ),
            minX: 0,
            maxX: 13,
            minY: 0,
            maxY: ySliderValue(),
            lineBarsData: [
              LineChartBarData(
                  spots: dataList.length > 0 ? dataList : [FlSpot(0.0, 0.0)],
                  isCurved: true,
                  colors: gradientColors,
                  barWidth: 4,
                  belowBarData: BarAreaData(
                      show: true,
                      colors: gradientColors
                          .map((color) => color.withOpacity(0.3))
                          .toList())),
            ],
          ),
        ),
      ),
    );
  }
}

double ySliderValue() {
  return value;
}
