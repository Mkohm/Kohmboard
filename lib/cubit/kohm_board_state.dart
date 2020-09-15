part of 'kohm_board_cubit.dart';

abstract class KohmBoardState extends Equatable {
  const KohmBoardState();
}

class KohmBoardInitial extends KohmBoardState {
  @override
  List<Object> get props => [];
}

class KohmBoardWeatherDataLoadedState extends KohmBoardState {
  final Map<int, double> weatherData;

  KohmBoardWeatherDataLoadedState(this.weatherData);

  @override
  List<Object> get props => [weatherData];
}

class KohmBoardTemperatureLoadedState extends KohmBoardState {
  final double temperature;

  KohmBoardTemperatureLoadedState(this.temperature);

  @override
  List<Object> get props => [temperature];
}
