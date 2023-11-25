import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:poll_air/compund.dart';

class SensorData {
  final DateTime timeStamp;
  final double value;

  const SensorData({
    required this.timeStamp,
    required this.value,
  });

  static Option<SensorData> fromJson(Map<String, dynamic> json) {
    final timeStamp =
        json['date'] == null ? null : DateTime.parse(json['date']);
    final value = json['value'] == null ? null : json['value'] as double;
    if ([timeStamp, value].contains(null)) {
      return none();
    }
    return some(SensorData(timeStamp: timeStamp!, value: value!));
  }
}

class Sensor {
  final Compound compound;
  final List<SensorData> data;

  const Sensor({
    required this.compound,
    required this.data,
  });

  static Option<Sensor> fromJson(Map<String, dynamic> json) {
    final compound =
        json['key'] == null ? none() : some(Compound.compoundIds[json['key']]);
    final data = (json['values'] as List)
        .map((e) => SensorData.fromJson(e))
        .where((element) => element.isSome())
        .map((e) => e.getOrElse(() => throw Null))
        .toList();
    return compound.fold(
        () => none(), (a) => some(Sensor(compound: a.compound, data: data)));
  }

  Color getColor() {
    return data.first.value > compound.max ? Colors.red : Colors.black;
  }
}

Future<Option<Sensor>> fetchSensor(int sensorId) async {
  final response = await http
      .get(Uri.https('api.gios.gov.pl', 'pjp-api/rest/data/getData/$sensorId'));
  if (response.statusCode == 200) {
    return Sensor.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }
  return none();
}

String getCompoundName(String compound) {
  switch (compound) {
    case "SO2":
      return "SO₂";
    case "C6H6":
      return "C₆H₆";
    case "NO2":
      return "NO₂";
    case "O3":
      return "O₃";
    case "PM2.5":
      return "PM 2.5";
    case "PM10":
      return "PM 10";
    default:
      return compound;
  }
}
