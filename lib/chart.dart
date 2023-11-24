import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:poll_air/home.dart';
import 'package:poll_air/sensor.dart';

class ChartPage extends StatefulWidget {
  const ChartPage({super.key});

  @override
  State<ChartPage> createState() => _ChartPageState();
}

class _ChartPageState extends State<ChartPage> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Column>>(
      future: getCharts(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return CustomScrollView(
            slivers: <Widget>[
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    return Container(
                      color: Colors.lightBlue
                          .shade100, // Set the background color to sky blue
                      child: Card(
                        elevation: 4,
                        margin: const EdgeInsets.all(16),
                        color: Colors.white, // Set the card color to white
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: snapshot.data![index],
                        ),
                      ),
                    );
                  },
                  childCount: snapshot.data!.length,
                ),
              ),
            ],
          );
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }

  static const customGetTitle = _customGetTitle;

  static Widget _customGetTitle(double value, TitleMeta meta) {
    if (value % 2 == 0) {
      return const Text('');
    }
    return Text(
      '-${value.toInt()} h',
      style: const TextStyle(fontSize: 12),
    );
  }

  Future<List<Column>> getCharts() async {
    final stations = await HomePageState.stations;
    const double align_percent = 0.05;
    return stations.currentStation.fold(
      () => [],
      (station) => station.sensors
          .map(
            (sensor) => Column(
              children: [
                Text(sensor.type),
                AspectRatio(
                  aspectRatio: 2,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return BarChart(BarChartData(
                        alignment: BarChartAlignment.spaceEvenly,
                        barTouchData: BarTouchData(
                          touchTooltipData: BarTouchTooltipData(
                              tooltipBgColor: Theme.of(context).cardTheme.color,
                              tooltipPadding: const EdgeInsets.all(2),
                              direction: TooltipDirection.top,
                              fitInsideHorizontally: true,
                              fitInsideVertically: true,
                              rotateAngle: 0,
                              getTooltipItem: (
                                BarChartGroupData group,
                                int groupIndex,
                                BarChartRodData rod,
                                int rodIndex,
                              ) {
                                return BarTooltipItem(
                                    rod.toY.toString(),
                                    const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 10));
                              }),
                          enabled: true,
                        ),
                        maxY: sensor.data
                                .take(min(12, sensor.data.length))
                                .map((e) => e.value)
                                .reduce(max)
                                .toDouble() *
                            (1 + align_percent),
                        minY: sensor.data
                            .take(min(12, sensor.data.length))
                            .map((e) => e.value)
                            .reduce(min)
                            .toDouble(),
                        barGroups: getGroups(sensor),
                        titlesData: const FlTitlesData(
                          bottomTitles: AxisTitles(),
                          topTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 25,
                              getTitlesWidget: customGetTitle,
                            ),
                          ),
                        ),
                      ));
                    },
                  ),
                ),
              ],
            ),
          )
          .toList(),
    );
  }

  List<BarChartGroupData> getGroups(Sensor sensor) {
    List<SensorData> data =
        sensor.data.take(min(12, sensor.data.length)).toList();
    data = data.reversed.toList();
    return data
        .take(min(12, data.length))
        .map(
          (e) => BarChartGroupData(
            x: min(12, sensor.data.length) - data.indexOf(e) - 1,
            barRods: [
              BarChartRodData(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(6),
                    topRight: Radius.circular(6),
                  ),
                  width: 20,
                  toY: e.value,
                  color: getColor(Random().nextDouble(),
                      0.8) // to mark the critical threshold later
                  )
            ],
          ),
        )
        .toList();
  }

  Color getColor(double value, double threshold) {
    // Customize color based on your criteria
    if (value < threshold) {
      return Colors.tealAccent.shade700;
    }
    return Colors.red;
  }
}
