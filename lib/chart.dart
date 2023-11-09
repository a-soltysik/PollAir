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
                    delegate: SliverChildBuilderDelegate((context, index) {
                  return Container(
                    child: snapshot.data![index],
                  );
                }, childCount: snapshot.data!.length))
              ],
            );
          } else {
            return const CircularProgressIndicator();
          }
        });
  }

  Future<List<Column>> getCharts() async {
    final stations = await HomePageState.stations;
    return stations.currentStation.fold(
        () => [],
        (station) => station.sensors
            .map((sensor) => Column(children: [
                  Text(sensor.type),
                  AspectRatio(
                    aspectRatio: 2,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return BarChart(
                            BarChartData(barGroups: getGroups(sensor)));
                      },
                    ),
                  )
                ]))
            .toList());
  }

  List<BarChartGroupData> getGroups(Sensor sensor) {
    return sensor.data
        .take(min(12, sensor.data.length))
        .map((e) => BarChartGroupData(
            x: -sensor.data.indexOf(e),
            barRods: [BarChartRodData(toY: e.value)]))
        .toList();
  }
}
