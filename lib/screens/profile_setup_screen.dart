import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:grief12/models/user_profile.dart';
import 'package:grief12/screens/home_screen.dart';

class ProfileSetupScreen extends StatefulWidget {
  final String email;
  final String userId;
  final bool isEditing;
  final Map<String, dynamic>? existingProfile;

  const ProfileSetupScreen({
    Key? key,
    required this.email,
    required this.userId,
    this.isEditing = false,
    this.existingProfile,
  }) : super(key: key);

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  
  bool _isLoading = false;
  File? _imageFile;
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.isEditing && widget.existingProfile != null) {
      _firstNameController.text = widget.existingProfile!['name'] ?? '';
      _lastNameController.text = widget.existingProfile!['surname'] ?? '';
      _phoneController.text = widget.existingProfile!['phoneNumber'] ?? '';
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      print('Form validation failed');
      return;
    }

    setState(() => _isLoading = true);
    print('Starting profile save process...'); // Debug log

    try {
      String? imageUrl;
      
      // Only try to upload image if one is selected
      if (_imageFile != null) {
        print('Attempting to upload profile picture...'); // Debug log
        try {
          final storageRef = FirebaseStorage.instance.ref()
              .child('profile_pictures')
              .child('${widget.userId}_${DateTime.now().millisecondsSinceEpoch}.jpg');

          print('Created storage reference'); // Debug log
          
          final uploadTask = storageRef.putFile(_imageFile!);
          print('Started upload task'); // Debug log

          final snapshot = await uploadTask;
          if (snapshot.state == TaskState.success) {
            imageUrl = await snapshot.ref.getDownloadURL();
            print('Image uploaded successfully: $imageUrl'); // Debug log
          }
        } catch (e) {
          print('Image upload failed: $e'); // Debug log
          // Continue without image if upload fails
        }
      }

      print('Creating user profile data...'); // Debug log
      
      // Create user profile map
      final Map<String, dynamic> profileData = {
        'uid': widget.userId,
        'name': _firstNameController.text.trim(),
        'surname': _lastNameController.text.trim(),
        'email': widget.email,
        'phoneNumber': _phoneController.text.trim(),
        'userId': widget.userId,
      };

      // Only update the image URL if a new image was uploaded
      if (imageUrl != null) {
        profileData['profilePictureUrl'] = imageUrl;
      } else if (widget.isEditing && widget.existingProfile != null) {
        // Keep the existing image URL when editing if no new image was uploaded
        profileData['profilePictureUrl'] = widget.existingProfile!['profilePictureUrl'];
      }

      // Add timestamp only for new profiles
      if (!widget.isEditing) {
        profileData['createdAt'] = FieldValue.serverTimestamp();
      }

      print('Saving to Firestore with data: $profileData'); // Debug log
      
      // Save to Firestore
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.userId)
            .set(profileData, SetOptions(merge: widget.isEditing));
        print('Profile saved successfully to Firestore'); // Debug log
      } catch (e, stackTrace) {
        print('Firestore save error: $e'); // Debug log
        print('Stack trace: $stackTrace'); // Debug log
        throw e; // Re-throw to be caught by outer try-catch
      }

      if (!mounted) {
        print('Widget not mounted after save'); // Debug log
        return;
      }

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.isEditing ? 'Profile updated successfully!' : 'Profile created successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      // For editing mode, just pop back to previous screen
      if (widget.isEditing) {
        if (!mounted) return;
        Navigator.pop(context);
      } else {
        // For new profile, navigate to home screen
        await Future.delayed(const Duration(seconds: 1)); // Wait for snackbar
        if (!mounted) return;
        
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
          (route) => false,
        );
      }
      
      print('Navigation completed'); // Debug log

    } catch (e, stackTrace) {
      print('Error in _saveProfile: $e'); // Debug log
      print('Stack trace: $stackTrace'); // Debug log
      
      if (!mounted) return;

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save profile: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
      print('Profile setup process completed'); // Debug log
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => widget.isEditing, // Allow back navigation only in editing mode
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.isEditing ? 'Edit Profile' : 'Complete Your Profile'),
          backgroundColor: Colors.white,
          elevation: 0,
          automaticallyImplyLeading: widget.isEditing,
          titleTextStyle: const TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        body: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.grey[200],
                        backgroundImage: _imageFile != null
                            ? FileImage(_imageFile!)
                            : (widget.existingProfile?['profilePictureUrl'] != null
                                ? NetworkImage(widget.existingProfile!['profilePictureUrl']) as ImageProvider
                                : null),
                        child: (_imageFile == null && widget.existingProfile?['profilePictureUrl'] == null)
                            ? const Icon(Icons.add_a_photo, size: 40, color: Colors.grey)
                            : null,
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _firstNameController,
                      decoration: const InputDecoration(
                        labelText: 'First Name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your first name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _lastNameController,
                      decoration: const InputDecoration(
                        labelText: 'Last Name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your last name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _phoneController,
                      decoration: const InputDecoration(
                        labelText: 'Phone Number',
                        border: OutlineInputBorder(),
                        hintText: '01234567890',
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your phone number';
                        }
                        if (!RegExp(r'^\d{11}$').hasMatch(value)) {
                          return 'Please enter a valid 11-digit phone number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _saveProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                widget.isEditing ? 'Save Changes' : 'Complete Setup',
                                style: const TextStyle(fontSize: 16),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_isLoading)
              Container(
                color: Colors.black.withOpacity(0.3),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
} 