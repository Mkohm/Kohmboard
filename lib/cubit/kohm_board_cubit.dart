import 'package:bloc/bloc.dart';
import 'package:dashboard/services/remote_data_repository.dart';
import 'package:equatable/equatable.dart';

part 'kohm_board_state.dart';

class KohmBoardCubit extends Cubit<KohmBoardState> {
  RemoteDataRepository repository;

  KohmBoardCubit(this.repository) : super(KohmBoardInitial());

  Future<void> getWeatherData() async {
    while (true) {
      emit(KohmBoardWeatherDataLoadedState(await repository.getWeatherData()));
      await Future.delayed(Duration(hours: 1));
    }
  }
}
