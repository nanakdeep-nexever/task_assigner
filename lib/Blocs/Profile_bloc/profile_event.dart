import 'dart:io';

abstract class ProfileEvent {}

class UpdateProfile extends ProfileEvent {
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final File? profileImage;

  UpdateProfile({
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    this.profileImage,
  });
}

class PickProfileImage extends ProfileEvent {}

class FetchUserProfile extends ProfileEvent {}
