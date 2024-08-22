import 'package:equatable/equatable.dart';

abstract class RoleState extends Equatable {
  @override
  List<Object?> get props => [];
}

class RoleInitial extends RoleState {}

class RoleLoaded extends RoleState {
  final String? role;

  RoleLoaded(this.role);

  @override
  List<Object?> get props => [role];
}
