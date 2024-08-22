import 'dart:io';

abstract class ProfileState {}

class ProfileInitial extends ProfileState {}

class ProfileUpdating extends ProfileState {}

class ProfileUpdated extends ProfileState {}

class ProfileUpdateFailed extends ProfileState {
  final String error;

  ProfileUpdateFailed(this.error);
}

class ProfileImagePicked extends ProfileState {
  final File? profileImage;

  ProfileImagePicked(this.profileImage);
}

class UserProfileLoaded extends ProfileState {
  // New state for loaded profile
  final String firstName;
  final String lastName;
  final String email;
  final String profileImageUrl;

  UserProfileLoaded({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.profileImageUrl,
  });
}

class UserProfileLoadFailed extends ProfileState {
  final String error;

  UserProfileLoadFailed(this.error);
}
