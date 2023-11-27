import 'dart:convert';
import 'dart:math';

import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:poll_air/polish_comparator.dart';
import 'package:poll_air/sensor.dart';
import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;

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
  String index = '';
  List<Sensor> sensors = [];

  Station({
    required this.id,
    required this.name,
    required this.coordinates,
  });

  static Option<Station> fromJson(Map<String, dynamic> json) {
    final id = json['id'] == null ? null : json['id'] as int;
    var name = json['stationName'];
    final longitude =
        json['gegrLon'] == null ? null : double.parse(json['gegrLon']);
    final latitude =
        json['gegrLat'] == null ? null : double.parse(json['gegrLat']);

    if ([id, name, longitude, latitude].contains(null)) {
      return none();
    }
    return some(Station(
        id: id!,
        name: name.toString().trim(),
        coordinates: Coordinates(
            longitude: toRadians(longitude!), latitude: toRadians(latitude!))));
  }

  Future<void> supplyAdditionalData() async {
    final sensorResp = await http
        .get(Uri.https('api.gios.gov.pl', 'pjp-api/rest/station/sensors/$id'));
    final ids = (jsonDecode(sensorResp.body) as List)
        .where((element) => element['id'] != null)
        .map((e) => e['id'] as int);
    sensors = await Stream.fromIterable(ids)
        .asyncMap((e) => fetchSensor(e))
        .where((e) => e.isSome())
        .map((e) => e.getOrElse(() => throw Null))
        .toList();

    final indexResp = await http
        .get(Uri.https('api.gios.gov.pl', 'pjp-api/rest/aqindex/getIndex/$id'));
    final indexLevel = jsonDecode(indexResp.body)['stIndexLevel'];
    final indexName = indexLevel == null ? null : indexLevel['indexLevelName'];
    index = indexName ?? '';
    return;
  }
}

class StationsUserData {
  List<Station> allStations = [];
  Option<Station> currentStation = none();
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

Option<Station> findNearestStation(
    List<Station> allStations, Coordinates user) {
  if (allStations.isEmpty) {
    return none();
  }
  var minDistance = double.maxFinite;
  var minStation = allStations.first;

  for (var station in allStations) {
    final currentDistance = distance(user, station.coordinates);
    if (currentDistance < minDistance) {
      minDistance = currentDistance;
      minStation = station;
    }
  }
  return some(minStation);
}

Future<StationsUserData> getStationsData() async {
  await resolveLoccationPermission();
  final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high);
  var stationsData = StationsUserData();
  stationsData.allStations = await getAllStations();
  stationsData.allStations
      .sort((a, b) => PolishComparator().compare(a.name, b.name));
  stationsData.currentStation = findNearestStation(
      stationsData.allStations,
      Coordinates(
          longitude: toRadians(position.longitude),
          latitude: toRadians(position.latitude)));

  return stationsData;
}

Future<void> resolveLoccationPermission() async {
  if (await Permission.location.isGranted) {
    return;
  }
  if (await Permission.location.request().isGranted == false) {
    while (await Permission.location.isGranted == false) {
      await openAppSettings();
    }
  }
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
