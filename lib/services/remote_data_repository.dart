import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:http/http.dart' as http;

abstract class IRemoteDataRepository {
  Future<Map<int, double>> getWeatherData();

  Future<double> getCurrentTemperature();
}

class RemoteDataRepository implements IRemoteDataRepository {
  @override
  Future<Map<int, double>> getWeatherData() async {
    print("Getting weather data");
    var url =
        'https://api.met.no/weatherapi/locationforecast/2.0/compact?lat=59.8881891&lon=10.6318358';

    try {
      var response = await http.get(url);
      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        List<WindStamp> windSpeeds =
            jsonResponse['properties']['timeseries'].map<WindStamp>((element) {
          DateTime time = DateTime.parse(element['time']).toLocal();
          double windSpeed =
              element['data']['instant']['details']['wind_speed'];

          return WindStamp(time, windSpeed);
        }).toList();

        Map<int, List<WindStamp>> group =
            groupBy(windSpeeds, (WindStamp element) => element.time.day);

        Map<int, double> maxWindSpeedByDay = {};
        for (MapEntry<int, List<WindStamp>> i in group.entries) {
          WindStamp max = i.value.reduce((value, element) =>
              value.windSpeed > element.windSpeed ? value : element);

          maxWindSpeedByDay[i.key] = max.windSpeed;
        }

        return maxWindSpeedByDay;

        // We group the windspeeds by day

      }
    } catch (e) {
      print(e);
      throw Exception('Are you sure you are connected to the internet?');
    }

    return null;
  }

  @override
  Future<double> getCurrentTemperature() async {
    var url =
        'https://api.met.no/weatherapi/locationforecast/2.0/compact?lat=59.9560&lon=11.0492';

    try {
      var response = await http.get(url);
      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);

        double currentTemp = jsonResponse['properties']['timeseries'][0]['data']
            ['instant']['details']['air_temperature'];

        return currentTemp;
      }
    } catch (e) {
      print(e);
      throw Exception('Are you sure you are connected to the internet?');
    }

    return null;
  }
}

/// Represents the windspeed at a given point time.
class WindStamp {
  WindStamp(this.time, this.windSpeed);

  DateTime time;
  double windSpeed;
}
