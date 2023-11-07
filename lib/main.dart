import 'package:dartz/dartz.dart' as dartz;
import 'package:flutter/material.dart';
import 'package:poll_air/sensor.dart';
import 'package:poll_air/station.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
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
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fajna Aplikacja'),
      ),
      body: Center(
        child: Column(children: [
          FutureBuilder<dartz.Option<Station>>(
            future: findNearestStation(
                const Coordinates(longitude: 0.297, latitude: 0.891)),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Column(children: [
                  snapshot.data!.fold(
                      () => const Text("Error in Station deserialization"),
                      (a) {
                    return Column(children: [
                      Text(a.name),
                      FutureBuilder<void>(
                          future: a.supplySensors(),
                          builder: (context, snapshot) {
                            return a.sensors.fold(
                                () => const CircularProgressIndicator(),
                                (a) => Text(a
                                    .map((e) =>
                                        "${e.type}: ${e.data.first.value}")
                                    .join('\n')));
                          })
                    ]);
                  })
                ]);
              } else if (snapshot.hasError) {
                return Text('${snapshot.error}');
              }

              return const CircularProgressIndicator();
            },
          ),
        ]),
      ),
    );
  }
}
