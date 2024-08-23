import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_assign_app/Screens/Views/check_role.dart';

import '../../Blocs/Profile_bloc/profile_bloc.dart';
import '../../Blocs/Profile_bloc/profile_event.dart';
import '../../Blocs/Profile_bloc/profile_state.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<ProfileBloc>().add(FetchUserProfile());
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    UserRoleManager().init();
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Edit Profile',
          style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.w800, color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: BlocListener<ProfileBloc, ProfileState>(
            listener: (context, state) {
              if (state is ProfileUpdated) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Profile updated successfully!')),
                );
              } else if (state is ProfileUpdateFailed) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content:
                          Text('Failed to update profile: ${state.error}')),
                );
              }
            },
            child: BlocBuilder<ProfileBloc, ProfileState>(
              builder: (context, state) {
                if (state is UserProfileLoaded) {
                  _firstNameController.text = state.firstName;
                  _lastNameController.text = state.lastName;
                  _phoneNumberController.text = state.phoneNumber;
                }

                File? pickedImage;
                if (state is ProfileImagePicked) {
                  pickedImage = state.profileImage;
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          context.read<ProfileBloc>().add(PickProfileImage());
                        },
                        child: CircleAvatar(
                          radius: 50,
                          /*   backgroundImage: pickedImage != null
                              ? FileImage(pickedImage)
                              : (state is UserProfileLoaded &&
                                      state.profileImageUrl.isNotEmpty)
                                  ? NetworkImage(state.profileImageUrl)
                                  : null,*/
                          child: pickedImage == null &&
                                  (state is! UserProfileLoaded ||
                                      state.profileImageUrl.isEmpty)
                              ? const Icon(
                                  Icons.camera_alt,
                                  size: 50,
                                )
                              : null,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _firstNameController,
                      decoration: const InputDecoration(
                        labelText: 'First Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _lastNameController,
                      decoration: const InputDecoration(
                        labelText: 'Last Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _phoneNumberController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Phone Number',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          final firstName = _firstNameController.text;
                          final lastName = _lastNameController.text;
                          final phoneNumber = _phoneNumberController.text;

                          context.read<ProfileBloc>().add(UpdateProfile(
                                firstName: firstName,
                                lastName: lastName,
                                phoneNumber: phoneNumber,
                                profileImage: pickedImage,
                              ));

                          if (UserRoleManager().currentRole == "admin") {
                            Navigator.pushNamed(context, "/admin");
                          } else if (UserRoleManager().currentRole ==
                              "developer") {
                            Navigator.pushNamed(context, "/developer");
                          } else if (UserRoleManager().currentRole ==
                              "manager") {
                            Navigator.pushNamed(context, "/manager");
                          } else if (UserRoleManager().currentRole ==
                              "viewer") {
                            Navigator.pushNamed(context, "/viewer");
                          } else {
                            const Text("No role here");
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 15,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          backgroundColor: Colors.blue,
                          elevation: 5,
                        ),
                        child: const Text(
                          'Edit Profile',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
