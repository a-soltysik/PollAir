import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
  final String type;
  final List<SensorData> data;

  const Sensor({
    required this.type,
    required this.data,
  });

  static Option<Sensor> fromJson(Map<String, dynamic> json) {
    final type = json['key'] == null ? none() : some(json['key']);
    final data = (json['values'] as List)
        .map((e) => SensorData.fromJson(e))
        .where((element) => element.isSome())
        .map((e) => e.getOrElse(() => throw Null))
        .toList();
    return type.fold(() => none(), (a) => some(Sensor(type: a, data: data)));
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
