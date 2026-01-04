import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/data_preload.dart';
import '../../../../core/widgets/neumorphic_button.dart';
import '../../../../core/widgets/neumorphic_card.dart';
import '../../../../core/widgets/neumorphic_text_field.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
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
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final statusColors =
        Theme.of(context).extension<StatusColors>() ?? StatusColors.light;
    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: Icon(
            Icons.arrow_back_ios,
            color: colorScheme.onSurface,
          ),
        ),
        title: Text(
          'Edit Profile',
          style: textTheme.titleLarge?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: NeumorphicButton(
              onPressed: _saveProfile,
              child: Icon(
                Icons.check,
                color: statusColors.success,
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
                  backgroundColor: statusColors.success,
                ),
              );
              // Clear the message to prevent repeated snackbars
              context.read<ProfileBloc>().add(const ClearProfileMessage());

              if (state.message == 'Profile updated successfully') {
                final userId = context.read<AuthBloc>().state.user?.id;
                if (userId != null && userId.isNotEmpty) {
                  // Refresh auth user snapshot and reload habit data used across profile/analytics/home.
                  primeUserData(context, userId: userId, refreshAuth: true);
                  // Also refresh the profile bloc data so the profile screen sees fresh values.
                  context.read<ProfileBloc>().add(
                        GetUserProfileRequested(
                          userId: userId,
                          userEmail: context.read<AuthBloc>().state.user?.email,
                          userName:
                              context.read<AuthBloc>().state.user?.fullName ??
                                  '',
                        ),
                      );
                }
                // Ensure we land back on profile with updated data.
                context.go('/profile');
              }
            }
          } else if (state.status == ProfileStatus.error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message ?? 'An error occurred'),
                backgroundColor: colorScheme.error,
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
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return NeumorphicCard(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              'Profile Picture',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 20),
            Stack(
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundColor: colorScheme.primary.withOpacity(0.1),
                  backgroundImage: _currentProfile?.photoUrl != null
                      ? NetworkImage(_currentProfile!.photoUrl!)
                      : null,
                  child: _currentProfile?.photoUrl == null
                      ? Icon(
                          Icons.person,
                          size: 60,
                          color: colorScheme.primary,
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
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.camera_alt,
                        color: colorScheme.onPrimary,
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
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return NeumorphicCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Personal Information',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
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
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return NeumorphicCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Contact Information',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
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
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return NeumorphicCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Preferences',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
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
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return NeumorphicCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'About Me',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
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
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return NeumorphicButton(
      onPressed: _saveProfile,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.primary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          'Save Profile',
          textAlign: TextAlign.center,
          style: textTheme.titleMedium?.copyWith(
            color: colorScheme.onPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildGenderSelection() {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Gender',
          style: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedGender,
              isExpanded: true,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface,
              ),
              dropdownColor: colorScheme.surface,
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
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Birthdate',
          style: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurfaceVariant,
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
                Icon(Icons.calendar_today, color: colorScheme.primary),
                const SizedBox(width: 12),
                Text(
                  _selectedBirthdate != null
                      ? '${_selectedBirthdate!.day}/${_selectedBirthdate!.month}/${_selectedBirthdate!.year}'
                      : 'Select your birthdate',
                  style: TextStyle(
                    color: _selectedBirthdate != null
                        ? colorScheme.onSurface
                        : colorScheme.onSurfaceVariant,
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
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Primary Goal',
          style: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedGoal,
              isExpanded: true,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface,
              ),
              dropdownColor: colorScheme.surface,
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
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Coming Soon'),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
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
