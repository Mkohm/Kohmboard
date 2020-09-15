import 'dart:async';

import 'package:dashboard/cubit/kohm_board_cubit.dart';
import 'package:dashboard/graphql_setup.dart';
import 'package:dashboard/services/remote_data_repository.dart';
import 'package:dashboard/widgets/clock.dart';
import 'package:dashboard/widgets/current_temperature.dart';
import 'package:dashboard/widgets/dashboard_tile_text.dart';
import 'package:dashboard/widgets/train_schedule.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Make the app run in full screen
    SystemChrome.setEnabledSystemUIOverlays([]);

    return GraphQLProvider(
      client: Config().setup(),
      child: MaterialApp(
          title: 'Kohmboard',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            textTheme: TextTheme(
                body1: GoogleFonts.roboto(
                    textStyle: TextStyle(
              color: Colors.white,
              fontSize: 20,
            ))),
            visualDensity: VisualDensity.adaptivePlatformDensity,
          ),
          home: BlocProvider(
              create: (context) => KohmBoardCubit(RemoteDataRepository()),
              child: MyHomePage())),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  SocketClient socketClient;

  @override
  void initState() {
    super.initState();

    var bloc = context.bloc<KohmBoardCubit>();
    bloc.getWeatherData();
    bloc.getCurrentTemperature();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // A black background container that we put the image on top of, to make the image fade gradually to a black color
          Container(
            color: Colors.black,
          ),
          OverflowBox(
            minHeight: 0.0,
            minWidth: 0.0,
            maxWidth: double.infinity,
            child: ShaderMask(
              shaderCallback: (rect) {
                return LinearGradient(
                  begin: Alignment.center,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black, Colors.transparent],
                ).createShader(
                    Rect.fromLTRB(0, 0, rect.width, rect.height - 200));
              },
              blendMode: BlendMode.dstIn,
              child: Image.network(
                "https://wallpaperaccess.com/full/2501899.jpg",
                fit: BoxFit.cover,
              ),
            ),
          ),
          SafeArea(
            child: Container(
              padding: EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Clock(),
                        SizedBox(
                          width: 50,
                        ),
                        BlocBuilder<KohmBoardCubit, KohmBoardState>(
                            builder: (context, state) {
                          if (state is KohmBoardTemperatureLoadedState) {
                            return TemperatureWidget(
                                temperature: state.temperature);
                          } else {
                            return Text("Error");
                          }
                        })
                      ],
                      crossAxisAlignment: CrossAxisAlignment.start,
                    ),
                  ),
                  Expanded(
                    child: GridView.count(
                      crossAxisCount:
                          MediaQuery.of(context).size.width <= 500 ? 1 : 2,
                      children: [
                        TrainTableToggle(),
                        BlocBuilder<KohmBoardCubit, KohmBoardState>(
                            builder: (context, state) {
                          if (state is KohmBoardWeatherDataLoadedState) {
                            print("Building weatherdata widget");
                            return DashboardTile(
                                title: "Pelvikodden",
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: state.weatherData.entries
                                      .take(6)
                                      .map<Widget>((entry) => DashboardTileText(
                                          text: "${entry.value} m/s"))
                                      .toList(),
                                ));
                          } else {
                            return Text("Trouble loading weather data");
                          }
                        })
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

class DashboardTile extends StatefulWidget {
  DashboardTile({this.child, this.title});

  final String title;
  final Widget child;

  @override
  _DashboardTileState createState() => _DashboardTileState();
}

class _DashboardTileState extends State<DashboardTile> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          widget.title,
          style: TextStyle(fontSize: 25),
        ),
        SizedBox(height: 8),
        Container(
          child: widget.child,
        ),
      ],
    );
  }
}

class TrainTableToggle extends StatefulWidget {
  @override
  _TrainTableToggleState createState() => _TrainTableToggleState();
}

class _TrainTableToggleState extends State<TrainTableToggle> {
  bool trainTableToggle = true;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() {
        trainTableToggle = !trainTableToggle;
      }),
      child: trainTableToggle == true
          ? DashboardTile(
              title: "Til Oslo S",
              child: TrainScheduleToOsloS(),
            )
          : DashboardTile(
              title: "Lillestrøm Stasjon",
              child: TrainScheduleFromLillestrom()),
    );
  }
}
