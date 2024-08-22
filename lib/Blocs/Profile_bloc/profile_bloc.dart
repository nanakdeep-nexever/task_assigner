import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:task_assign_app/Blocs/Profile_bloc/profile_event.dart';
import 'package:task_assign_app/Blocs/Profile_bloc/profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc() : super(ProfileInitial()) {
    on<UpdateProfile>(_onUpdateProfile);
    on<PickProfileImage>(_onPickProfileImage);
    on<FetchUserProfile>(_onFetchUserProfile);
  }

  Future<void> _onUpdateProfile(
      UpdateProfile event, Emitter<ProfileState> emit) async {
    emit(ProfileUpdating());

    try {
      String? imageUrl;
      if (event.profileImage != null) {
        final storageRef = FirebaseStorage.instance.ref().child(
            'profile_images/${event.profileImage!.path.split('/').last}');
        await storageRef.putFile(event.profileImage!);
        imageUrl = await storageRef.getDownloadURL();
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .update({
        'firstName': event.firstName,
        'lastName': event.lastName,
        'phoneNumber': event.phoneNumber,
        'profileImageUrl': imageUrl,
      });

      emit(ProfileUpdated());
    } catch (e) {
      emit(ProfileUpdateFailed(e.toString()));
    }
  }

  Future<void> _onPickProfileImage(
      PickProfileImage event, Emitter<ProfileState> emit) async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      emit(ProfileImagePicked(File(pickedFile.path)));
    } else {
      emit(ProfileImagePicked(null));
    }
  }

  Future<void> _onFetchUserProfile(
      FetchUserProfile event, Emitter<ProfileState> emit) async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .get();

      if (userDoc.exists) {
        final data = userDoc.data();
        if (data != null) {
          emit(UserProfileLoaded(
            firstName: data['firstName'] ?? '',
            lastName: data['lastName'] ?? '',
            email: data['email'] ?? '',
            profileImageUrl: data['profileImageUrl'] ?? '',
          ));
        } else {
          emit(UserProfileLoadFailed('No data found'));
        }
      } else {
        emit(UserProfileLoadFailed('User document does not exist'));
      }
    } catch (e) {
      emit(UserProfileLoadFailed(e.toString()));
    }
  }
}
