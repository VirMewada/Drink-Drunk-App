import 'package:flutter/material.dart';
//import 'package:drink_drunk/services/database.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:drink_app/database.dart';

class GraphPage extends StatefulWidget {
  @override
  _GraphPageState createState() => _GraphPageState();
}

var globalSize;
double value = 4;
//Database database = Database();

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
            //height: size.height * 0.5,
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
                      color: Theme.of(context).canvasColor.toString() == "brown"
                          ? Colors.white
                          : Colors.white),
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
                // SliderTheme(
                //   data: SliderTheme.of(context).copyWith(
                //     activeTrackColor: Colors.orange,
                //     inactiveTrackColor: Color(0xfff0c459),
                //     trackShape: RoundedRectSliderTrackShape(),
                //     trackHeight: 10,
                //     thumbColor: Color(0xff975711),
                //     overlayColor: Colors.amber.withAlpha(70),
                //     thumbShape: RoundSliderThumbShape(
                //         enabledThumbRadius: 12, elevation: 5),
                //     tickMarkShape: RoundSliderTickMarkShape(),
                //     activeTickMarkColor: Colors.white,
                //     inactiveTickMarkColor: Color(0xfff0c459),
                //     valueIndicatorShape: PaddleSliderValueIndicatorShape(),
                //     valueIndicatorColor: Colors.orange,
                //     valueIndicatorTextStyle:
                //         TextStyle(color: Colors.white, fontSize: 20),
                //   ),
                //   child: Slider(
                //     min: 14,
                //     max: 30,
                //     value: _value,
                //     divisions: 8,
                //     label: "$_value",
                //     onChanged: (value) {
                //       setState(() {
                //         _value = value;
                //       });
                //     },
                //   ),
                // ),
                // Text(
                //   "Adjust Y axis.",
                //   style: TextStyle(fontSize: 15, color: Colors.white),
                // ),
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
              //border: Border.all(color: Colors.amber, width: 3),
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
                  // spots: [
                  //   FlSpot(1, 3),
                  //   FlSpot(2, 4),
                  //   FlSpot(4, 5.5),
                  //   FlSpot(5, 0),
                  //   FlSpot(8, 4),
                  //   FlSpot(12, 3),
                  // ],

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
