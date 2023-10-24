import 'dart:convert';

import 'package:dartz/dartz.dart' as dartz;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:poll_air/sensor.dart';

void main() {
  runApp(const MyApp());
}

Future<dartz.Option<Sensor>> fetchSensor(int sensorId) async {
  final response = await http
      .get(Uri.https('api.gios.gov.pl', 'pjp-api/rest/data/getData/$sensorId'));
  if (response.statusCode == 200) {
    return Sensor.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }
  return dartz.none();
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
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Future<dartz.Option<Sensor>> sensor;

  @override
  void initState() {
    super.initState();
    sensor = fetchSensor(642);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fajna Aplikacja'),
      ),
      body: Center(
        child: FutureBuilder<dartz.Option<Sensor>>(
          future: sensor,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Text(snapshot.data!.fold(
                  () => "Error in JSON deserialization",
                  (a) => a.data
                      .map((e) =>
                          '${a.type}: ${e.timeStamp.toString()}: ${e.value.toString()}')
                      .join('\n')));
            } else if (snapshot.hasError) {
              return Text('${snapshot.error}');
            }

            return const CircularProgressIndicator();
          },
        ),
      ),
    );
  }
}
