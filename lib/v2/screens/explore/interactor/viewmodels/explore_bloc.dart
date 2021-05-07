import 'package:bloc/bloc.dart';
import 'package:seeds/v2/domain-shared/page_state.dart';
import 'package:seeds/v2/screens/explore/interactor/mappers/explore_state_mapper.dart';
import 'package:seeds/v2/screens/explore/interactor/usecases/get_explore_data_use_case.dart';
import 'package:seeds/v2/screens/explore/interactor/viewmodels/explore_events.dart';
import 'package:seeds/v2/screens/explore/interactor/viewmodels/explore_state.dart';

/// --- BLOC
class ExploreBloc extends Bloc<ExploreEvent, ExploreState> {
  ExploreBloc() : super(ExploreState.initial());

  @override
  Stream<ExploreState> mapEventToState(ExploreEvent event) async* {
    if (event is LoadExploreData) {
      yield state.copyWith(pageState: PageState.loading);
      var results = await GetExploreDataUseCase().run();
      yield ExploreStateMapper().mapResultsToState(state, results);
    }
  }
}