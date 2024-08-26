import 'package:equatable/equatable.dart';

abstract class DevelopEvent extends Equatable {
  const DevelopEvent();

  @override
  List<Object?> get props => [];
}

class LoadTasks extends DevelopEvent {}
