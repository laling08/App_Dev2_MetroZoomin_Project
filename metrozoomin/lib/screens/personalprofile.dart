import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:metrozoomin/widgets/universalwidgets.dart';
import 'package:metrozoomin/widgets/custom_button.dart';
import 'package:metrozoomin/widgets/custom_text_field.dart';
import 'package:metrozoomin/screens/auth_screen.dart';

class PersonalProfile extends StatefulWidget {
  const PersonalProfile({super.key});

  @override
  State<PersonalProfile> createState() => _PersonalProfileState();
}

class _PersonalProfileState extends State<PersonalProfile> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  String _selectedGender = 'Prefer not to say';
  bool _isLoading = true;
  bool _isEditing = false;

  final List<String> _genders = [
    'Male',
    'Female',
    'Non-binary',
    'Prefer not to say'
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        print("Current user ID: ${user.uid}"); // Debug print

        final userDoc = FirebaseFirestore.instance.collection('users').doc(user.uid);
        print("Attempting to fetch user document: ${userDoc.path}"); // Debug print

        final userData = await userDoc.get();
        print("Document exists: ${userData.exists}"); // Debug print

        if (userData.exists) {
          final data = userData.data() as Map<String, dynamic>;
          print("User data: $data"); // Debug print

          setState(() {
            _usernameController.text = data['username'] ?? '';
            _emailController.text = user.email ?? '';
            _phoneController.text = data['phone'] ?? '';
            _selectedGender = data['gender'] ?? 'Prefer not to say';
          });
        } else {
          print("Creating new user document for ${user.uid}");
          // If document doesn't exist, create it
          await userDoc.set({
            'username': user.displayName ?? user.email?.split('@')[0] ?? 'User',
            'email': user.email ?? '',
            'phone': '',
            'gender': 'Prefer not to say',
            'createdAt': FieldValue.serverTimestamp(),
          });

          // Set default values
          setState(() {
            _usernameController.text = user.displayName ?? user.email?.split('@')[0] ?? 'User';
            _emailController.text = user.email ?? '';
          });
        }
      } else {
        print("No user is currently signed in");
      }
    } catch (e) {
      print('Error loading user data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading user data: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        print("Updating user document for ${user.uid}"); // Debug print

        final userDoc = FirebaseFirestore.instance.collection('users').doc(user.uid);

        // Prepare update data
        final updateData = {
          'username': _usernameController.text,
          'phone': _phoneController.text,
          'gender': _selectedGender,
          'lastUpdated': FieldValue.serverTimestamp(),
        };

        print("Update data: $updateData"); // Debug print

        await userDoc.set(updateData, SetOptions(merge: true));

        print("Profile updated successfully");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );

        setState(() {
          _isEditing = false;
        });
      } else {
        print("No user is currently signed in");
      }
    } catch (e) {
      print('Error updating profile: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating profile: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => AuthScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error signing out: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Personal Profile'),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Profile picture
            Stack(
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.blue.shade100,
                  child: const Icon(
                    Icons.person,
                    size: 80,
                    color: Colors.blue,
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // User name
            Text(
              _usernameController.text,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            // User email
            Text(
              _emailController.text,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 20),

            // Edit/Save button
            CustomButton(
              text: _isEditing ? 'Save Profile' : 'Edit Profile',
              onPressed: _isEditing ? _updateUserData : () {
                setState(() {
                  _isEditing = true;
                });
              },
              backgroundColor: Colors.blue,
            ),
            const SizedBox(height: 30),

            // Profile details
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Profile Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Username
                    const Text(
                      'Username',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _isEditing
                        ? CustomTextField(
                      controller: _usernameController,
                      hintText: 'Enter your username',
                    )
                        : Text(
                      _usernameController.text,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 16),

                    // Email
                    const Text(
                      'Email',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _emailController.text,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 16),

                    // Phone
                    const Text(
                      'Phone',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _isEditing
                        ? CustomTextField(
                      controller: _phoneController,
                      hintText: 'Enter your phone number',
                      keyboardType: TextInputType.phone,
                    )
                        : Text(
                      _phoneController.text.isEmpty
                          ? 'Not provided'
                          : _phoneController.text,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 16),

                    // Gender
                    const Text(
                      'Gender',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _isEditing
                        ? Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: _selectedGender,
                          items: _genders.map((String gender) {
                            return DropdownMenuItem<String>(
                              value: gender,
                              child: Text(gender),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              setState(() {
                                _selectedGender = newValue;
                              });
                            }
                          },
                        ),
                      ),
                    )
                        : Text(
                      _selectedGender,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Account settings
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Account Settings',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Change password
                    _buildSettingsItem(
                      icon: Icons.lock_outline,
                      title: 'Change Password',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => NewPasswordScreen()),
                        );
                      },
                    ),
                    const Divider(),

                    // Notifications
                    _buildSettingsItem(
                      icon: Icons.notifications_none,
                      title: 'Notifications',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => UnimplementedScreen()),
                        );
                      },
                    ),
                    const Divider(),

                    // Privacy
                    _buildSettingsItem(
                      icon: Icons.privacy_tip_outlined,
                      title: 'Privacy',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => UnimplementedScreen()),
                        );
                      },
                    ),
                    const Divider(),

                    // Help & Support
                    _buildSettingsItem(
                      icon: Icons.help_outline,
                      title: 'Help & Support',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => UnimplementedScreen()),
                        );
                      },
                    ),
                    const Divider(),

                    // Sign out
                    _buildSettingsItem(
                      icon: Icons.logout,
                      title: 'Sign Out',
                      onTap: _signOut,
                      color: Colors.red,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? color,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(
              icon,
              color: color ?? Colors.blue,
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                color: color,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }
}

class NewPasswordScreen extends StatefulWidget {
  const NewPasswordScreen({super.key});

  @override
  State<NewPasswordScreen> createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends State<NewPasswordScreen> {
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () {
            Navigator.of(context).pop(); // Custom behavior for the back button
          },
        ),
        title: Text('Change Password'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'New Password',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                try {
                  await FirebaseAuth.instance.currentUser?.updatePassword(
                    _passwordController.text,
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Password updated successfully!')),
                  );
                  Navigator.of(context).pop(); // Go back to the previous screen
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: ${e.toString()}')),
                  );
                }
              },
              child: Text('Update Password'),
            ),
          ],
        ),
      ),
    );
  }
}

class UnimplementedScreen extends StatelessWidget {
  const UnimplementedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () {
            Navigator.of(context).pop(); // Custom behavior for the back button
          },
        ),
        title: Text('Unimplemented Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(26.0),
        child: Column(
          children: [
            Icon(Icons.warning_amber_rounded, size: 70),
            SizedBox(height: 30),
            Text('You\'ve unfortunately reached an unimplemented page! '
                'We look forward to implementing this page in the future, '
                'but, until then, please return to the previous page!')
          ],
        ),
      ),
    );
  }
}
