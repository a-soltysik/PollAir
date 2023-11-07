import 'package:dartz/dartz.dart' as dartz;
import 'package:flutter/material.dart';
import 'package:poll_air/station.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PollAir',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late var stations = getStationsData();
  dartz.Option<DropdownButtonHideUnderline> dropDown = dartz.none();

  @override
  void initState() {
    super.initState();
  }

  DropdownButtonHideUnderline getDropDown(StationsUserData stationsReady) {
    return dropDown.getOrElse(() {
      final newDropDown = DropdownButtonHideUnderline(
          child: DropdownButton2<String>(
        items: stationsReady.allStations
            .map((station) => DropdownMenuItem<String>(
                value: station.name, child: Text(station.name)))
            .toList(),
        value: stationsReady.currentStation
            .fold(() => null, (station) => station.name),
        onChanged: (String? value) {
          setState(() {
            stationsReady.currentStation = dartz.some(stationsReady.allStations
                .firstWhere((element) => element.name == value));
          });
        },
      ));
      dropDown = dartz.some(newDropDown);
      return newDropDown;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PollAir'),
      ),
      body: Center(
        child: Column(
          children: [
            FutureBuilder<StationsUserData>(
                future: stations,
                builder: ((context, snapshot) {
                  if (snapshot.hasData) {
                    return Column(
                      children: [
                        getDropDown(snapshot.data!),
                        FutureBuilder<void>(
                            future: snapshot.data!.currentStation.fold(
                                () => null,
                                (station) => station.supplySensors()),
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
                })),
          ],
        ),
      ),
    );
  }
}
