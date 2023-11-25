import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:poll_air/home.dart';
import 'package:poll_air/sensor.dart';
import 'package:poll_air/settings.dart';

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
    const double alignPercent = 0.05;
    return stations.currentStation.fold(
      () => [],
      (station) => station.sensors
          .map(
            (sensor) => Column(
              children: [
                Text(sensor.compound.name),
                AspectRatio(
                  aspectRatio: 2,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return BarChart(BarChartData(
                          alignment: BarChartAlignment.spaceEvenly,
                          barTouchData: BarTouchData(
                            touchTooltipData: BarTouchTooltipData(
                                tooltipBgColor:
                                    Theme.of(context).cardTheme.color,
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
                          //maxY: sensor.data
                          //    .take(min(12, sensor.data.length))
                          //    .map((e) => e.value)
                          //    .reduce(max)
                          //    .toDouble(),
                          barGroups: getGroups(sensor),
                          titlesData: FlTitlesData(
                            bottomTitles: const AxisTitles(),
                            topTitles: const AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 25,
                                getTitlesWidget: customGetTitle,
                              ),
                            ),
                            leftTitles: AxisTitles(),
                            rightTitles: AxisTitles(
                                sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 60,
                              getTitlesWidget: (value, meta) {
                                Widget axisTitle =
                                    Text(value.toStringAsFixed(2));
                                if (value == meta.max) {
                                  final remainder =
                                      value % meta.appliedInterval;
                                  if (remainder != 0.0 &&
                                      remainder / meta.appliedInterval < 0.5) {
                                    axisTitle = const SizedBox.shrink();
                                  }
                                }
                                return SideTitleWidget(
                                    axisSide: meta.axisSide, child: axisTitle);
                              },
                            )),
                          )));
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
                  width: 10,
                  toY: SettingsPageState.settings.first
                      ? e.value
                      : e.value / sensor.compound.max * 100,
                  color: getColor(e.value, sensor.compound.max))
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
