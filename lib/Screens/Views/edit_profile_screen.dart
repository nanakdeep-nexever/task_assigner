import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:task_assign_app/generated/Strings_s.dart';

class EditUserScreen extends StatefulWidget {
  final String uid;
  final String initialFirstName;
  final String initialLastName;
  final String initialPhoneNumber;
  final String initialProfileImageUrl;

  const EditUserScreen({
    super.key,
    required this.uid,
    required this.initialFirstName,
    required this.initialLastName,
    required this.initialPhoneNumber,
    required this.initialProfileImageUrl,
  });

  @override
  _EditUserScreenState createState() => _EditUserScreenState();
}

class _EditUserScreenState extends State<EditUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  String? _profileImageUrl;
  XFile? _imageFile;
  final _picker = ImagePicker();
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _firstNameController.text = widget.initialFirstName;
    _lastNameController.text = widget.initialLastName;
    _phoneNumberController.text = widget.initialPhoneNumber;
    _profileImageUrl = widget.initialProfileImageUrl;
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = pickedFile;
      });
    }
  }

  Future<String?> _uploadImage() async {
    if (_imageFile == null) return null;

    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_images/${DateTime.now().millisecondsSinceEpoch}');
      final uploadTask = storageRef.putFile(File(_imageFile!.path));
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  Future<void> _saveUserData() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isUpdating = true;
      });

      try {
        String? imageUrl;
        if (_imageFile != null) {
          imageUrl = await _uploadImage();
        } else {
          imageUrl = _profileImageUrl;
        }

        final userDoc = FirebaseFirestore.instance
            .collection(Com_string.Firebase_collection_users)
            .doc(widget.uid);
        Map<String, dynamic> data = {
          'firstName': _firstNameController.text,
          'lastName': _lastNameController.text,
          'phoneNumber': _phoneNumberController.text,
          'profileImageUrl': imageUrl,
        };

        await userDoc.update(data);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User details updated successfully')),
        );
        Navigator.of(context).pop();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating user details: $e')),
        );
      } finally {
        setState(() {
          _isUpdating = false; // Hide loader
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Edit User Details',
          style: TextStyle(
              color: Colors.black, fontSize: 20, fontWeight: FontWeight.w800),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: _imageFile != null
                      ? FileImage(File(_imageFile!.path))
                          as ImageProvider<Object>?
                      : (_profileImageUrl != null &&
                              _profileImageUrl!.isNotEmpty)
                          ? NetworkImage(_profileImageUrl!)
                              as ImageProvider<Object>?
                          : null,
                  child: _imageFile == null &&
                          (_profileImageUrl == null ||
                              _profileImageUrl!.isEmpty)
                      ? const Icon(Icons.add_a_photo, size: 50)
                      : null,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _firstNameController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.blue.shade50,
                  labelText: 'First Name',
                  prefixIcon: const Icon(Icons.person),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.blue, width: 2),
                  ),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter first name' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _lastNameController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.blue.shade50,
                  labelText: 'Last Name',
                  prefixIcon: const Icon(Icons.person),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.blue, width: 2),
                  ),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter last name' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneNumberController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.blue.shade50,
                  labelText: 'Phone Number',
                  prefixIcon: const Icon(Icons.phone),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.blue, width: 2),
                  ),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter phone number' : null,
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: _saveUserData,
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
                  child: Center(
                    child: _isUpdating
                        ? const CircularProgressIndicator()
                        : const Text(
                            'Update Profile',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
