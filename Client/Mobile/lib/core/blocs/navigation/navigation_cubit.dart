import 'package:flutter_bloc/flutter_bloc.dart';
import 'navigation_state.dart';

class NavigationCubit extends Cubit<NavigationState> {
  static NavigationCubit? _instance;
  static NavigationCubit get instance => _instance ??= NavigationCubit();

  NavigationCubit({int initialIndex = 2})
      : super(NavigationState(selectedIndex: initialIndex)) {
    _instance = this;
  }

  void switchToTab(int index) {
    emit(state.copyWith(selectedIndex: index));
  }

  int get currentIndex => state.selectedIndex;

  @override
  Future<void> close() {
    if (_instance == this) _instance = null;
    return super.close();
  }
}
