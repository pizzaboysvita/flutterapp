import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pizza_boys/core/helpers/bloc_observer_helper.dart' as Bloc;

Bloc.AppBlocObserver observer = AppBlocObserver();

class AppBlocObserver extends BlocObserver {
  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    print('❌ [Bloc Error] ${bloc.runtimeType}: $error');
    super.onError(bloc, error, stackTrace);
  }

  @override
  void onChange(BlocBase bloc, Change change) {
    print('🔄 [Bloc Change] ${bloc.runtimeType}: $change');
    super.onChange(bloc, change);
  }
}
