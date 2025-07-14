import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/neumorphic_button.dart';
import '../../../../core/widgets/neumorphic_card.dart';
import '../../../../core/widgets/neumorphic_text_field.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../domain/entities/user_profile.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _bioController = TextEditingController();

  String _selectedGender = 'Prefer not to say';
  DateTime? _selectedBirthdate; // Make it nullable to show placeholder
  String _selectedGoal = 'Personal Growth';

  UserProfile? _currentProfile;
  bool _isLoading = true;

  final List<String> _genders = [
    'Male',
    'Female',
    'Other',
    'Prefer not to say'
  ];
  final List<String> _goals = [
    'Build Healthy Habits',
    'Improve Fitness',
    'Mental Wellness',
    'Productivity',
    'Work-Life Balance',
    'Personal Growth'
  ];

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  void _loadUserProfile() {
    final authState = context.read<AuthBloc>().state;
    if (authState.status == AuthStatus.authenticated &&
        authState.user != null) {
      // Try to load existing profile first
      context.read<ProfileBloc>().add(
            GetUserProfileRequested(
              userId: authState.user!.id,
              userEmail: authState.user!.email,
              userName:
                  '${authState.user!.firstName} ${authState.user!.lastName}'
                      .trim(),
            ),
          );
    } else {
      // User not authenticated, go back
      context.pop();
    }
  }

  void _populateFields(UserProfile profile) {
    setState(() {
      // Use the data from the profile if available, otherwise use auth user data as fallback
      final authUser = context.read<AuthBloc>().state.user;

      // Always use auth user's actual name if profile has placeholder values or is empty
      bool hasPlaceholderNames = profile.firstName == 'First' ||
          profile.lastName == 'Last' ||
          profile.firstName.isEmpty ||
          profile.lastName.isEmpty;

      String firstName = '';
      String lastName = '';

      if (hasPlaceholderNames && authUser != null) {
        // Use the names from auth user
        firstName = authUser.firstName;
        lastName = authUser.lastName;
        _firstNameController.text = firstName;
        _lastNameController.text = lastName;

        // Automatically update the profile with correct names if it had placeholders
        _autoUpdateProfileWithCorrectNames(profile, firstName, lastName);
      } else if (profile.firstName.isNotEmpty && profile.lastName.isNotEmpty) {
        // Use profile names only if they're real names (not placeholders)
        _firstNameController.text = profile.firstName;
        _lastNameController.text = profile.lastName;
      } else if (authUser != null) {
        // Fallback to auth user name
        firstName = authUser.firstName;
        lastName = authUser.lastName;
        _firstNameController.text = firstName;
        _lastNameController.text = lastName;
      }

      // Email always comes from auth user or profile
      _emailController.text =
          profile.email.isNotEmpty ? profile.email : (authUser?.email ?? '');

      // Optional fields - only show if they exist, otherwise leave empty
      _phoneController.text = profile.phone ?? '';
      _bioController.text = profile.bio ?? '';

      // Optional dropdowns - use stored values or sensible defaults
      _selectedGender = profile.gender ?? 'Prefer not to say';
      _selectedBirthdate = profile.birthdate; // Keep it null if not set
      _selectedGoal = profile.goal ?? 'Personal Growth';

      _currentProfile = profile;
    });
  }

  void _autoUpdateProfileWithCorrectNames(
      UserProfile profile, String firstName, String lastName) {
    // Silently update the profile in Firestore with correct names
    final updatedProfile = profile.copyWith(
      firstName: firstName,
      lastName: lastName,
      updatedAt: DateTime.now(),
    );

    // Update the profile in background without user notification
    context.read<ProfileBloc>().add(
          UpdateUserProfileRequested(profile: updatedProfile),
        );
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(
            Icons.arrow_back_ios,
            color: AppColors.textPrimary,
          ),
        ),
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: NeumorphicButton(
              onPressed: _saveProfile,
              child: const Icon(
                Icons.check,
                color: AppColors.success,
              ),
            ),
          ),
        ],
      ),
      body: BlocListener<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state.status == ProfileStatus.loaded && state.profile != null) {
            // Always populate fields when profile data is available
            _populateFields(state.profile!);
            if (_isLoading) {
              setState(() {
                _isLoading = false;
              });
            }
            if (state.message != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message!),
                  backgroundColor: AppColors.success,
                ),
              );
              // Clear the message to prevent repeated snackbars
              context.read<ProfileBloc>().add(const ClearProfileMessage());

              if (state.message == 'Profile updated successfully') {
                context.pop();
              }
            }
          } else if (state.status == ProfileStatus.error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message ?? 'An error occurred'),
                backgroundColor: AppColors.error,
              ),
            );
            // Clear the error message
            context.read<ProfileBloc>().add(const ClearProfileMessage());
            setState(() {
              _isLoading = false;
            });
          }
        },
        child: BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, state) {
            if (_isLoading || state.status == ProfileStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }

            return Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _buildProfilePicture(),
                  const SizedBox(height: 24),
                  _buildPersonalInfo(),
                  const SizedBox(height: 24),
                  _buildContactInfo(),
                  const SizedBox(height: 24),
                  _buildPreferences(),
                  const SizedBox(height: 24),
                  _buildBio(),
                  const SizedBox(height: 32),
                  _buildSaveButton(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildProfilePicture() {
    return NeumorphicCard(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Text(
              'Profile Picture',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 20),
            Stack(
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  backgroundImage: _currentProfile?.photoUrl != null
                      ? NetworkImage(_currentProfile!.photoUrl!)
                      : null,
                  child: _currentProfile?.photoUrl == null
                      ? const Icon(
                          Icons.person,
                          size: 60,
                          color: AppColors.primary,
                        )
                      : null,
                ),
                Positioned(
                  bottom: 5,
                  right: 5,
                  child: GestureDetector(
                    onTap: _selectProfilePicture,
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalInfo() {
    return NeumorphicCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Personal Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: NeumorphicTextField(
                    controller: _firstNameController,
                    labelText: 'First Name',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your first name';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: NeumorphicTextField(
                    controller: _lastNameController,
                    labelText: 'Last Name',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your last name';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildGenderSelection(),
            const SizedBox(height: 16),
            _buildBirthdateSelection(),
          ],
        ),
      ),
    );
  }

  Widget _buildContactInfo() {
    return NeumorphicCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Contact Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            NeumorphicTextField(
              controller: _emailController,
              labelText: 'Email',
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email';
                }
                if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                  return 'Please enter a valid email';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            NeumorphicTextField(
              controller: _phoneController,
              labelText: 'Phone Number (Optional)',
              keyboardType: TextInputType.phone,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreferences() {
    return NeumorphicCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Preferences',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            _buildGoalSelection(),
          ],
        ),
      ),
    );
  }

  Widget _buildBio() {
    return NeumorphicCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'About Me',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            NeumorphicTextField(
              controller: _bioController,
              labelText: 'Bio (Optional)',
              maxLines: 4,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return NeumorphicButton(
      onPressed: _saveProfile,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text(
          'Save Profile',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildGenderSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Gender',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedGender,
              isExpanded: true,
              style: const TextStyle(color: AppColors.textPrimary),
              dropdownColor: AppColors.surface,
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedGender = newValue;
                  });
                }
              },
              items: _genders.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBirthdateSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Birthdate',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        NeumorphicButton(
          onPressed: _selectBirthdate,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, color: AppColors.primary),
                const SizedBox(width: 12),
                Text(
                  _selectedBirthdate != null
                      ? '${_selectedBirthdate!.day}/${_selectedBirthdate!.month}/${_selectedBirthdate!.year}'
                      : 'Select your birthdate',
                  style: TextStyle(
                    color: _selectedBirthdate != null
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGoalSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Primary Goal',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedGoal,
              isExpanded: true,
              style: const TextStyle(color: AppColors.textPrimary),
              dropdownColor: AppColors.surface,
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedGoal = newValue;
                  });
                }
              },
              items: _goals.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  void _selectProfilePicture() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Select Profile Picture',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                NeumorphicButton(
                  onPressed: () => _pickImage(ImageSource.camera),
                  child: const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.camera_alt,
                          color: AppColors.primary, size: 32),
                      SizedBox(height: 8),
                      Text('Camera',
                          style: TextStyle(color: AppColors.textPrimary)),
                    ],
                  ),
                ),
                NeumorphicButton(
                  onPressed: () => _pickImage(ImageSource.gallery),
                  child: const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.photo_library,
                          color: AppColors.primary, size: 32),
                      SizedBox(height: 8),
                      Text('Gallery',
                          style: TextStyle(color: AppColors.textPrimary)),
                    ],
                  ),
                ),
                if (_currentProfile?.photoUrl != null)
                  NeumorphicButton(
                    onPressed: _removeProfilePicture,
                    child: const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.delete, color: AppColors.error, size: 32),
                        SizedBox(height: 8),
                        Text('Remove',
                            style: TextStyle(color: AppColors.textPrimary)),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    Navigator.of(context).pop(); // Close the modal

    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: source,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 80,
    );

    if (image != null) {
      // Upload the image
      final authState = context.read<AuthBloc>().state;
      if (authState.user != null) {
        context.read<ProfileBloc>().add(
              UploadProfileImageRequested(
                userId: authState.user!.id,
                imagePath: image.path,
              ),
            );
      }
    }
  }

  void _removeProfilePicture() {
    Navigator.of(context).pop();
    if (_currentProfile != null) {
      final updatedProfile = _currentProfile!.copyWith(
        photoUrl: null,
        updatedAt: DateTime.now(),
      );
      context.read<ProfileBloc>().add(
            UpdateUserProfileRequested(profile: updatedProfile),
          );
    }
  }

  Future<void> _selectBirthdate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedBirthdate ??
          DateTime.now().subtract(const Duration(days: 365 * 25)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedBirthdate = picked;
      });
    }
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      final authState = context.read<AuthBloc>().state;
      if (authState.user != null && _currentProfile != null) {
        final updatedProfile = _currentProfile!.copyWith(
          firstName: _firstNameController.text,
          lastName: _lastNameController.text,
          email: _emailController.text,
          phone: _phoneController.text.isEmpty ? null : _phoneController.text,
          bio: _bioController.text.isEmpty ? null : _bioController.text,
          gender: _selectedGender,
          birthdate: _selectedBirthdate,
          goal: _selectedGoal,
          updatedAt: DateTime.now(),
        );

        context.read<ProfileBloc>().add(
              UpdateUserProfileRequested(profile: updatedProfile),
            );
      }
    }
  }
}
