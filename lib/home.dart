import 'package:dartz/dartz.dart' as dartz;
import 'package:flutter/material.dart';
import 'package:poll_air/settings.dart';
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
            return Container(
              color: Colors.lightBlue.shade100,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
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
                    ),
                  ),
                  FutureBuilder<void>(
                    future: snapshot.data!.currentStation.fold(() => null,
                        (station) => station.supplyAdditionalData()),
                    builder: (context, supplySnapshot) {
                      if (supplySnapshot.connectionState ==
                          ConnectionState.done) {
                        return snapshot.data!.currentStation.fold(
                          () => const CircularProgressIndicator(),
                          (station) => Expanded(
                            child: Center(
                                child: ListView.builder(
                              itemCount: station.sensors.length + 1,
                              itemBuilder: (BuildContext context, int index) {
                                return Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  margin: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                                  child: ListTile(
                                    title: Align(
                                        alignment: Alignment.center,
                                        child: getTextByIndex(station, index)),
                                  ),
                                );
                              },
                            )),
                          ),
                        );
                      } else {
                        return const CircularProgressIndicator();
                      }
                    },
                  ),
                ],
              ),
            );
          }
          return const CircularProgressIndicator();
        },
      ),
    );
  }
}

Text getTextByIndex(Station station, int index) {
  if (index == 0) {
    return getIndexText(station);
  }
  return getSensorText(station, index - 1);
}

Text getSensorText(Station station, int index) {
  final sensor = station.sensors[index];
  const unit = 'µg/m³';
  const percent = '%';

  return Text(
      SettingsPageState.settings.first
          ? "${sensor.compound.name}: ${sensor.data.first.value.toStringAsFixed(2)} $unit"
          : "${sensor.compound.name}: ${((sensor.data.first.value / sensor.compound.max) * 100.0).toStringAsFixed(2)} $percent",
      style: TextStyle(
          fontSize: 16.0,
          fontWeight: FontWeight.bold,
          color: sensor.getColor()));
}

Text getIndexText(Station station) {
  return Text('Indeks jakości powietrza: ${station.index}',
      style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold));
}
