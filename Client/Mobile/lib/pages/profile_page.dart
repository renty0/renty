import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:renty/core/services/ProfileService.dart';
import 'package:renty/core/constant/app_colors.dart';
import 'package:renty/main.dart';

class ProfilePage extends StatefulWidget {
  final Map<String, dynamic>? userProfile;

  const ProfilePage({Key? key, this.userProfile}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ProfileService _profileService = ProfileService();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  bool isLoading = false;
  bool isLoadingImage = false;
  Map<String, dynamic>? currentProfile;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    setState(() => isLoading = true);

    try {
      final profile = await _profileService.getUserProfile();

      if (profile != null) {
        setState(() {
          currentProfile = profile;
          nameController.text = profile['name'] ?? '';
          phoneController.text = profile['phone'] ?? '';
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
        _showMessage("Failed to load profile", isError: true);
      }
    } catch (e) {
      setState(() => isLoading = false);
      _showMessage("Error: ${e.toString()}", isError: true);
    }
  }

  Future<void> _updateProfile() async {
    final name = nameController.text.trim();
    final phone = phoneController.text.trim();

    if (name.isEmpty) {
      _showMessage("Name cannot be empty", isError: true);
      return;
    }

    setState(() => isLoading = true);

    try {
      final updatedProfile = await _profileService.updateProfile(
        name: name,
        phone: phone.isEmpty ? null : phone,
      );

      if (updatedProfile != null) {
        setState(() {
          currentProfile = updatedProfile;
          isLoading = false;
        });
        _showMessage("Profile updated successfully");
        Navigator.of(context).pop(true);
      } else {
        setState(() => isLoading = false);
        _showMessage("Failed to update profile", isError: true);
      }
    } catch (e) {
      setState(() => isLoading = false);
      _showMessage("Error: ${e.toString()}", isError: true);
    }
  }

  Future<void> _updateProfileImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 512,
        maxHeight: 512,
      );

      if (pickedFile != null) {
        setState(() => isLoadingImage = true);

        File imageFile = File(pickedFile.path);
        final imageUrl = await _profileService.uploadProfileImage(imageFile);

        setState(() => isLoadingImage = false);

        if (imageUrl != null) {
          _showMessage("Profile image updated successfully");
          _loadUserProfile();
        } else {
          _showMessage("Failed to update profile image", isError: true);
        }
      }
    } catch (e) {
      setState(() => isLoadingImage = false);
      _showMessage("Error picking image", isError: true);
    }
  }

  void _showImagePickerDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColor.cardBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColor.borderGray,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(height: 20),
              Text(
                "Update Profile Image",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColor.primaryColor,
                ),
              ),
              SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildImageOption(
                    icon: Icons.camera_alt,
                    label: "Camera",
                    color: AppColor.primaryColor,
                    onTap: () {
                      Navigator.pop(context);
                      _updateProfileImage(ImageSource.camera);
                    },
                  ),
                  _buildImageOption(
                    icon: Icons.photo_library,
                    label: "Gallery",
                    color: AppColor.goldAccent,
                    onTap: () {
                      Navigator.pop(context);
                      _updateProfileImage(ImageSource.gallery);
                    },
                  ),
                ],
              ),
              SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildImageOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.3), width: 2),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColor.warningColor : AppColor.successColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    if (isLoading && currentProfile == null) {
      return Scaffold(
        backgroundColor: isDark ? Color(0xFF1A1614) : AppColor.backgroundcolor,
        appBar: AppBar(
          title: Text("Profile"),
          backgroundColor: AppColor.primaryColor,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: CircularProgressIndicator(color: AppColor.primaryColor),
        ),
      );
    }

    return Scaffold(
      backgroundColor: isDark ? Color(0xFF1A1614) : AppColor.backgroundcolor,
      body: CustomScrollView(
        physics: BouncingScrollPhysics(),
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 180,
            floating: false,
            pinned: true,
            backgroundColor: AppColor.primaryColor,
            iconTheme: IconThemeData(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: Text(
                "Profile",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 4,
                      offset: Offset(1, 1),
                    ),
                  ],
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColor.primaryColor,
                      AppColor.secondColor,
                      AppColor.goldAccent,
                    ],
                    stops: [0.0, 0.6, 1.0],
                  ),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  // Profile Image
                  _buildProfileImage(isDark),

                  // User Name Display
                  Container(
                    margin: EdgeInsets.only(bottom: 24),
                    child: Column(
                      children: [
                        Text(
                          currentProfile?['name'] ?? "Unknown",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppColor.goldAccent : AppColor.primaryColor,
                            fontFamily: 'PlayfairDisplay',
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          currentProfile?['email'] ?? sharedPref.getString("user_email") ?? "No Email",
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColor.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Edit Form Card
                  _buildEditFormCard(isDark),

                  SizedBox(height: 20),

                  // Account Information Card
                  _buildAccountInfoCard(isDark),

                  SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileImage(bool isDark) {
    return Container(
      margin: EdgeInsets.only(bottom: 20),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background glow
          Positioned(
            top: -10,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColor.primaryColor.withOpacity(0.1),
                    AppColor.goldAccent.withOpacity(0.05),
                  ],
                ),
              ),
            ),
          ),

          // Profile image container
          GestureDetector(
            onTap: _showImagePickerDialog,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Shadow
                Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColor.primaryColor.withOpacity(0.15),
                        blurRadius: 8,
                        spreadRadius: 1,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                ),

                // Gradient border
                Container(
                  width: 136,
                  height: 136,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [AppColor.primaryColor, AppColor.goldAccent],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),

                // White/dark background
                Container(
                  width: 130,
                  height: 130,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDark ? Color(0xFF2C2520) : Colors.white,
                  ),
                ),

                // Profile image
                Container(
                  width: 126,
                  height: 126,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark ? Color(0xFF2C2520) : Colors.white,
                      width: 2,
                    ),
                  ),
                  child: ClipOval(
                    child: isLoadingImage
                        ? _buildLoadingIndicator()
                        : _buildProfileImageContent(),
                  ),
                ),

                // Edit camera button
                Positioned(
                  bottom: 4,
                  right: 4,
                  child: Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColor.primaryColor, AppColor.secondColor],
                      ),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDark ? Color(0xFF2C2520) : Colors.white,
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColor.primaryColor.withOpacity(0.2),
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(Icons.camera_alt, size: 16, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileImageContent() {
    if (currentProfile != null &&
        currentProfile!['profile_image'] != null &&
        currentProfile!['profile_image'].toString().isNotEmpty) {
      return Image.network(
        currentProfile!['profile_image'],
        width: 126,
        height: 126,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildDefaultAvatar(),
        loadingBuilder: (_, child, progress) {
          if (progress == null) return child;
          return _buildLoadingIndicator();
        },
      );
    }
    return _buildDefaultAvatar();
  }

  Widget _buildLoadingIndicator() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColor.backgroundcolor2, AppColor.backgroundcolor],
        ),
      ),
      child: Center(
        child: CircularProgressIndicator(
          color: AppColor.primaryColor,
          strokeWidth: 3,
        ),
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      width: 126,
      height: 126,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            AppColor.primaryColor.withOpacity(0.2),
            AppColor.secondColor.withOpacity(0.1),
          ],
        ),
      ),
      child: Icon(
        Icons.person,
        size: 50,
        color: AppColor.primaryColor.withOpacity(0.7),
      ),
    );
  }

  Widget _buildEditFormCard(bool isDark) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24),
      margin: EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: isDark ? Color(0xFF2C2520) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColor.primaryColor.withOpacity(0.08),
            blurRadius: 15,
            offset: Offset(0, 6),
          ),
        ],
        border: Border.all(
          color: isDark ? AppColor.earthBrown.withOpacity(0.2) : AppColor.borderGray,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColor.primaryColor, AppColor.secondColor],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.edit, color: Colors.white, size: 22),
              ),
              SizedBox(width: 12),
              Text(
                "Edit Your Profile",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColor.primaryColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 20),

          // Name field
          Text(
            "Full Name",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColor.goldAccent : AppColor.primaryColor,
            ),
          ),
          SizedBox(height: 8),
          _buildTextField(nameController, "Enter full name", isDark),

          SizedBox(height: 16),

          // Phone field
          Text(
            "Phone Number (Optional)",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColor.goldAccent : AppColor.primaryColor,
            ),
          ),
          SizedBox(height: 8),
          _buildTextField(phoneController, "Enter phone number", isDark,
              keyboardType: TextInputType.phone),

          SizedBox(height: 20),

          // Update button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: isLoading ? null : _updateProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              ),
              child: isLoading
                  ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
                  : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_outline, size: 20),
                  SizedBox(width: 8),
                  Text(
                    "Update Profile",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller,
      String hint,
      bool isDark, {
        TextInputType? keyboardType,
      }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: isDark ? Color(0xFF1A1614) : AppColor.backgroundcolor2,
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        style: TextStyle(
          fontSize: 16,
          color: isDark ? Colors.white : AppColor.primaryColor,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: AppColor.grey),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          border: InputBorder.none,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColor.primaryColor, width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.transparent),
          ),
        ),
      ),
    );
  }

  Widget _buildAccountInfoCard(bool isDark) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? Color(0xFF2C2520) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColor.primaryColor.withOpacity(0.08),
            blurRadius: 15,
            offset: Offset(0, 6),
          ),
        ],
        border: Border.all(
          color: isDark ? AppColor.earthBrown.withOpacity(0.2) : AppColor.borderGray,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColor.goldAccent, AppColor.earthBrown],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.person_outline, color: Colors.white, size: 22),
              ),
              SizedBox(width: 12),
              Text(
                "Account Information",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColor.goldAccent,
                ),
              ),
            ],
          ),
          SizedBox(height: 20),

          _buildInfoItem(
            icon: Icons.email_outlined,
            label: "Email",
            value: currentProfile?['email'] ?? "No Email",
            iconColor: AppColor.primaryColor,
          ),
          SizedBox(height: 16),
          _buildInfoItem(
            icon: Icons.shopping_bag_outlined,
            label: "Total Orders",
            value: currentProfile?['total_orders']?.toString() ?? "0",
            iconColor: AppColor.goldAccent,
          ),
          SizedBox(height: 16),
          _buildInfoItem(
            icon: Icons.verified_user_outlined,
            label: "Account Status",
            value: "Active",
            valueColor: AppColor.successColor,
            iconColor: AppColor.successColor,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
    required Color iconColor,
  }) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Color(0xFF1A1614) : AppColor.backgroundcolor2,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColor.earthBrown.withOpacity(0.1) : AppColor.borderGray,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: iconColor),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: AppColor.grey,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: valueColor ?? (isDark ? Colors.white : AppColor.primaryColor),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    super.dispose();
  }
}