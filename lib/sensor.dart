import 'package:dartz/dartz.dart';

class SensorData {
  final DateTime timeStamp;
  final double value;

  const SensorData({
    required this.timeStamp,
    required this.value,
  });

  static Option<SensorData> fromJson(Map<String, dynamic> json) {
    final timeStampOpt =
        json['date'] == null ? none() : some(DateTime.parse(json['date']));
    final valueOpt =
        json['value'] == null ? none() : some(json['value'] as double);
    return timeStampOpt.fold(
        () => none(),
        (timeStamp) => valueOpt.fold(() => none(),
            (value) => some(SensorData(timeStamp: timeStamp, value: value))));
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
