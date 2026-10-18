import 'package:equatable/equatable.dart';

class NavigationState extends Equatable {
  final int selectedIndex;

  const NavigationState({this.selectedIndex = 2});

  NavigationState copyWith({int? selectedIndex}) {
    return NavigationState(
      selectedIndex: selectedIndex ?? this.selectedIndex,
    );
  }

  @override
  List<Object?> get props => [selectedIndex];
}
