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

  Future<List<Column>> getCharts() async {
    final stations = await HomePageState.stations;
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
                          barGroups: getGroups(sensor),
                          titlesData: const FlTitlesData(
                              topTitles: AxisTitles(),
                              bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                      showTitles: true,
                                      interval: 2,
                                      reservedSize: 25)))));
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
            barRods: [BarChartRodData(toY: e.value)],
          ),
        )
        .toList();
  }
}
