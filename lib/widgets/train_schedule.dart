import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:intl/intl.dart';

import 'dashboard_tile_text.dart';

class TrainScheduleFromLillestrom extends StatefulWidget {
  final String query = """{
  stopPlace(id: "NSR:StopPlace:451") {
    name
    estimatedCalls(numberOfDepartures: 6) {
      quay {
        publicCode
      }
      expectedDepartureTime
      destinationDisplay {
        frontText
      }
      serviceJourney {
        line {
          publicCode
        }
      }
    }
  }
}""";

  @override
  _TrainScheduleFromLillestromState createState() =>
      _TrainScheduleFromLillestromState();
}

class _TrainScheduleFromLillestromState
    extends State<TrainScheduleFromLillestrom> {
  @override
  Widget build(BuildContext context) {
    return Query(
      options: QueryOptions(documentNode: gql(widget.query), pollInterval: 10),
      builder: (QueryResult result,
          {VoidCallback refetch, FetchMore fetchMore}) {
        if (result.hasException) {
          return Text("Error while fetching, check the internet connection.");
        }

        if (result.loading) {
          return CircularProgressIndicator();
        } else {
          var names = result.data['stopPlace']['estimatedCalls']
              .map((element) => element['destinationDisplay']['frontText'])
              .toList();

          var departureTimes = result.data['stopPlace']['estimatedCalls']
              .map((element) => DateTime.parse(element['expectedDepartureTime'])
                  .difference(DateTime.now())
                  .inMinutes
                  .toString())
              .toList();

          var platform = result.data['stopPlace']['estimatedCalls']
              .map((element) => element['quay']['publicCode']);

          return Container(
              child: Row(mainAxisSize: MainAxisSize.min, children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: platform
                  .map<Widget>(
                      (element) => DashboardTileText(text: "Spor $element"))
                  .toList(),
            ),
            SizedBox(
              width: 8.0,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: names
                  .map<Widget>((element) => DashboardTileText(text: element))
                  .toList(),
            ),
            SizedBox(
              width: 8.0,
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: departureTimes
                  .map<Widget>(
                    (element) => DashboardTileText(
                      text: element + " min",
                    ),
                  )
                  .toList(),
            ),
          ]));
        }
      },
    );
  }
}

class TrainScheduleToOsloS extends StatefulWidget {
  final String query = """{
  trip(from: {place: "NSR:StopPlace:451"}, to: {place: "NSR:StopPlace:337", name: "Oslo S"}, numTripPatterns: 6) {
    tripPatterns {
      duration
      legs {
        fromEstimatedCall {
          expectedDepartureTime
          expectedArrivalTime
          destinationDisplay {
            frontText
          }
          quay {
            id
            publicCode
          }
        }
        
        line {
          id
          publicCode
          
        } 
      }
    }
  }
}
""";

  @override
  _TrainScheduleToOsloSState createState() => _TrainScheduleToOsloSState();
}

class _TrainScheduleToOsloSState extends State<TrainScheduleToOsloS> {
  @override
  Widget build(BuildContext context) {
    return Query(
      options: QueryOptions(documentNode: gql(widget.query), pollInterval: 10),
      builder: (QueryResult result,
          {VoidCallback refetch, FetchMore fetchMore}) {
        if (result.hasException) {
          return Text("Error while fetching, check the internet connection.");
        }

        if (result.loading) {
          return CircularProgressIndicator();
        } else {
          List<dynamic> names = result.data['trip']['tripPatterns']
              .map((element) => element['legs'][0]['fromEstimatedCall']
                  ['destinationDisplay']['frontText'])
              .toList();

          List<dynamic> minutesUntilDeparture = result.data['trip']
                  ['tripPatterns']
              .map((element) => DateTime.parse(element['legs'][0]
                      ['fromEstimatedCall']['expectedDepartureTime'])
                  .difference(DateTime.now())
                  .inMinutes
                  .toString())
              .toList();

          List<dynamic> platforms = result.data['trip']['tripPatterns']
              .map((element) =>
                  element['legs'][0]['fromEstimatedCall']['quay']['publicCode'])
              .toList();

          List<dynamic> arrivalTimes = result.data['trip']['tripPatterns']
              .map((element) => DateTime.parse(element['legs'][0]
                  ['fromEstimatedCall']['expectedArrivalTime']).toLocal())
              .toList();

          // Build the list of departures from the data
          List<Departure> departures = List<Departure>();
          for (int i = 0; i < names.length; i++) {
            departures.add(Departure(names[i], minutesUntilDeparture[i],
                arrivalTimes[i], platforms[i]));
          }

          departures.sort((Departure a, Departure b) =>
              a.arrivalTime.compareTo(b.arrivalTime));

          return Container(
              child: Row(mainAxisSize: MainAxisSize.min, children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: departures
                  .map<Widget>((Departure element) =>
                      DashboardTileText(text: "Spor ${element.platform}"))
                  .toList(),
            ),
            SizedBox(
              width: 8.0,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: departures
                  .map<Widget>((Departure element) =>
                      DashboardTileText(text: element.name))
                  .toList(),
            ),
            SizedBox(
              width: 8.0,
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: departures
                  .map<Widget>(
                    (Departure element) => DashboardTileText(
                      text: element.minutesUntilDeparture + " min",
                    ),
                  )
                  .toList(),
            ),
            SizedBox(
              width: 8.0,
            ),
            Column(
                mainAxisSize: MainAxisSize.min,
                children: departures
                    .map<Widget>(
                      (Departure element) => DashboardTileText(
                        text:
                            "${DateFormat("HH:mm").format(element.arrivalTime)}",
                      ),
                    )
                    .toList())
          ]));
        }
      },
    );
  }
}

class Departure {
  Departure(
      this.name, this.minutesUntilDeparture, this.arrivalTime, this.platform);

  String name;
  String minutesUntilDeparture;
  DateTime arrivalTime;
  String platform;
}
