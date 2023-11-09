import 'package:dartz/dartz.dart' as dartz;
import 'package:flutter/material.dart';
import 'package:poll_air/station.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  static final _stations = getStationsData();
  static Future<StationsUserData> get stations => _stations;
  static List<DropdownMenuItem<String>> dropDown = [];

  List<DropdownMenuItem<String>> getDropDown(StationsUserData stationsReady) {
    if (dropDown.isEmpty) {
      dropDown = stationsReady.allStations
          .map((station) => DropdownMenuItem<String>(
              value: station.name,
              child: Text(station.name, overflow: TextOverflow.ellipsis)))
          .toList();
    }
    return dropDown;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FutureBuilder<StationsUserData>(
          future: _stations,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Column(
                children: [
                  DropdownButtonHideUnderline(
                      child: DropdownButton2<String>(
                    items: getDropDown(snapshot.data!),
                    value: snapshot.data!.currentStation
                        .fold(() => null, (station) => station.name),
                    onChanged: (String? value) {
                      setState(() {
                        snapshot.data!.currentStation = dartz.some(snapshot
                            .data!.allStations
                            .firstWhere((element) => element.name == value));
                      });
                    },
                  )),
                  FutureBuilder<void>(
                      future: snapshot.data!.currentStation.fold(
                          () => null, (station) => station.supplySensors()),
                      builder: (context, supplySnaphost) {
                        if (supplySnaphost.connectionState ==
                            ConnectionState.done) {
                          const unit = 'µg/m³';
                          return snapshot.data!.currentStation.fold(
                              () => const CircularProgressIndicator(),
                              (station) => Text(station.sensors
                                  .map((sensor) =>
                                      "${sensor.type}: ${sensor.data.first.value} $unit")
                                  .join('\n')));
                        } else {
                          return const CircularProgressIndicator();
                        }
                      })
                ],
              );
            }
            return const CircularProgressIndicator();
          }),
    );
  }
}