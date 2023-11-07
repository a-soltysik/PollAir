import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:poll_air/sensor.dart';
import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;
import 'package:rxdart/rxdart.dart';

class Coordinates {
  final double longitude;
  final double latitude;

  const Coordinates({
    required this.longitude,
    required this.latitude,
  });
}

class Station {
  final int id;
  final String name;
  final Coordinates coordinates;
  Option<List<Sensor>> sensors = none();

  Station({
    required this.id,
    required this.name,
    required this.coordinates,
  });

  static Option<Station> fromJson(Map<String, dynamic> json) {
    final id = json['id'] == null ? null : json['id'] as int;
    final name = json['stationName'];
    final longitude =
        json['gegrLon'] == null ? null : double.parse(json['gegrLon']);
    final latitude =
        json['gegrLat'] == null ? null : double.parse(json['gegrLat']);

    if ([id, name, longitude, latitude].contains(null)) {
      return none();
    }
    return some(Station(
        id: id!,
        name: name,
        coordinates: Coordinates(
            longitude: toRadians(longitude!), latitude: toRadians(latitude!))));
  }

  Future<void> supplySensors() async {
    final response = await http
        .get(Uri.https('api.gios.gov.pl', 'pjp-api/rest/station/sensors/$id'));
    final ids = (jsonDecode(response.body) as List)
        .where((element) => element['id'] != null)
        .map((e) => e['id'] as int);
    sensors = some(await Stream.fromIterable(ids)
        .asyncMap((e) => fetchSensor(e))
        .where((e) => e.isSome())
        .map((e) => e.getOrElse(() => throw Null))
        .toList());
    return;
  }
}

double toRadians(double degrees) {
  return pi * degrees / 180;
}

Future<List<Station>> getAllStations() async {
  final response = await http
      .get(Uri.https('api.gios.gov.pl', 'pjp-api/rest/station/findAll'));
  if (response.statusCode == 200) {
    return (jsonDecode(response.body) as List)
        .map((e) => Station.fromJson(e))
        .where((e) => e.isSome())
        .map((e) => e.getOrElse(() => throw Null))
        .toList();
  }
  return [];
}

Future<Option<Station>> findNearestStation(Coordinates user) async {
  final stations = await getAllStations();
  if (stations.isEmpty) {
    return none();
  }
  var minDistance = double.maxFinite;
  Option<Station> minStation = none();

  for (var station in stations) {
    final currentDistance = distance(user, station.coordinates);
    if (currentDistance < minDistance) {
      minDistance = currentDistance;
      minStation = some(station);
    }
  }
  return minStation;
}

double distance(Coordinates user, Coordinates station) {
  final delta = Coordinates(
      longitude: (user.longitude - station.longitude).abs(),
      latitude: (user.latitude - station.latitude).abs());

  final haversine = pow(sin(delta.latitude / 2), 2) +
      cos(user.latitude) *
          cos(station.latitude) *
          pow(sin(delta.longitude / 2), 2);

  final c = 2 * atan2(sqrt(haversine), sqrt(1 - haversine));
  const radius = 6371;

  return radius * c;
}
