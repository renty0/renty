import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:renty/core/services/api_service.dart';
import 'package:renty/core/services/ProfileService.dart';
import 'package:renty/core/constant/app_colors.dart';
import 'package:renty/main.dart';
import 'package:renty/pages/edit_profile_page.dart';

class ProfilePage extends StatefulWidget {
  final Map<String, dynamic>? userProfile;

  const ProfilePage({super.key, this.userProfile});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ProfileService _profileService = ProfileService();

  bool _isLoading = true;
  Map<String, dynamic>? _profile;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final profile = await _profileService.getUserProfile();
      if (!mounted) return;
      setState(() {
        _profile = profile;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF121212) : AppColor.backgroundcolor;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : AppColor.darkText;
    final subtextColor = isDark ? Colors.white54 : AppColor.mediumText;

    return Scaffold(
      backgroundColor: bgColor,
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColor.fourthColor))
          : RefreshIndicator(
              color: AppColor.fourthColor,
              onRefresh: _loadProfile,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  // ── App Bar ──
                  SliverAppBar(
                    expandedHeight: 140,
                    floating: false,
                    pinned: true,
                    backgroundColor: AppColor.primaryColor,
                    flexibleSpace: FlexibleSpaceBar(
                      centerTitle: true,
                      title: const Text(
                        'Profile',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 20,
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
                              AppColor.fourthColor,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 30),
                      child: Column(
                        children: [
                          // ── User Avatar & Name ──
                          _buildUserHeader(isDark, textColor, subtextColor),
                          const SizedBox(height: 12),

                          // ── Edit Profile Button ──
                          SizedBox(
                            width: 160,
                            height: 38,
                            child: OutlinedButton.icon(
                              onPressed: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const EditProfilePage()),
                                );
                                if (result == true) _loadProfile();
                              },
                              icon: const Icon(Icons.edit_outlined, size: 16),
                              label: const Text('Edit Profile'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColor.fourthColor,
                                side: BorderSide(color: AppColor.fourthColor.withValues(alpha: 0.5)),
                                textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              ),
                            ),
                          ),
                          const SizedBox(height: 28),

                          // ── Quick Actions ──
                          _buildSection(
                            title: 'Activity',
                            icon: Icons.grid_view_rounded,
                            isDark: isDark,
                            cardColor: cardColor,
                            children: [
                              _ActionTile(
                                icon: Icons.receipt_long_outlined,
                                label: 'My Rentals',
                                subtitle: 'View rental history',
                                isDark: isDark,
                                onTap: () => Get.toNamed('/my-rentals'),
                              ),
                              _ActionTile(
                                icon: Icons.shopping_bag_outlined,
                                label: 'My Orders',
                                subtitle: 'Track your orders',
                                isDark: isDark,
                                onTap: () => Get.toNamed('/my-orders'),
                              ),
                              _ActionTile(
                                icon: Icons.inventory_2_outlined,
                                label: 'My Items',
                                subtitle: 'Manage your listings',
                                isDark: isDark,
                                onTap: () => Get.toNamed('/my-items'),
                              ),
                              _ActionTile(
                                icon: Icons.favorite_outline,
                                label: 'Favorites',
                                subtitle: 'Saved items',
                                isDark: isDark,
                                iconColor: Colors.red,
                                onTap: () => Get.toNamed('/favorites'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // ── Communication ──
                          _buildSection(
                            title: 'Communication',
                            icon: Icons.forum_outlined,
                            isDark: isDark,
                            cardColor: cardColor,
                            children: [
                              _ActionTile(
                                icon: Icons.chat_bubble_outline,
                                label: 'Messages',
                                subtitle: 'Chat with others',
                                isDark: isDark,
                                onTap: () => Get.toNamed('/chat-list'),
                              ),
                              _ActionTile(
                                icon: Icons.notifications_outlined,
                                label: 'Notifications',
                                subtitle: 'Stay updated',
                                isDark: isDark,
                                onTap: () => Get.toNamed('/notifications'),
                              ),
                              _ActionTile(
                                icon: Icons.support_agent_outlined,
                                label: 'Support',
                                subtitle: 'Get help',
                                isDark: isDark,
                                onTap: () => Get.toNamed('/support'),
                                showDivider: false,
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // ── Settings ──
                          _buildSection(
                            title: 'Settings',
                            icon: Icons.settings_outlined,
                            isDark: isDark,
                            cardColor: cardColor,
                            children: [
                              _ThemeToggleTile(
                                isDark: isDark,
                                showDivider: false,
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // ── About Renty ──
                          _buildSection(
                            title: 'About Renty',
                            icon: Icons.info_outline_rounded,
                            isDark: isDark,
                            cardColor: cardColor,
                            children: [
                              _ActionTile(
                                icon: Icons.diversity_3_outlined,
                                label: 'About Us',
                                subtitle: 'Learn about our mission',
                                isDark: isDark,
                                iconColor: const Color(0xFF0ea5e9),
                                onTap: () => _launchRentyUrl(
                                  'https://appforyou.store/Renty/about.html'),
                              ),
                              _ActionTile(
                                icon: Icons.gavel_outlined,
                                label: 'Terms & Conditions',
                                subtitle: 'Our terms of service',
                                isDark: isDark,
                                iconColor: const Color(0xFF0c295e),
                                onTap: () => _launchRentyUrl(
                                  'https://appforyou.store/Renty/terms.html'),
                              ),
                              _ActionTile(
                                icon: Icons.shield_outlined,
                                label: 'Privacy Policy',
                                subtitle: 'How we protect your data',
                                isDark: isDark,
                                iconColor: const Color(0xFF059669),
                                onTap: () => _launchRentyUrl(
                                  'https://appforyou.store/Renty/privacy.html'),
                              ),
                              _ActionTile(
                                icon: Icons.help_outline_rounded,
                                label: 'FAQ',
                                subtitle: 'Common questions answered',
                                isDark: isDark,
                                iconColor: const Color(0xFFd97706),
                                showDivider: false,
                                onTap: () => _launchRentyUrl(
                                  'https://appforyou.store/Renty/faq.html'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // ── Logout ──
                          _buildLogoutButton(isDark),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildUserHeader(bool isDark, Color textColor, Color subtextColor) {
    final firstName = _profile?['firstName'] ?? '';
    final lastName = _profile?['lastName'] ?? '';
    final name = '$firstName $lastName'.trim();
    final displayName = name.isNotEmpty ? name : (_profile?['name'] ?? 'User');
    final email = _profile?['email'] ??
        sharedPref.getString('user_email') ??
        '';
    final initials = displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U';
    final profileImageUrl = _profile?['profilePictureUrl'] as String?;

    return Column(
      children: [
        // Avatar circle — shows profile image if available, otherwise initials
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: profileImageUrl == null
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColor.fourthColor,
                      AppColor.primaryColor,
                    ],
                  )
                : null,
            boxShadow: [
              BoxShadow(
                color: AppColor.fourthColor.withValues(alpha: 0.3),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: profileImageUrl != null
              ? ClipOval(
                  child: Image.network(
                    profileImageUrl,
                    fit: BoxFit.cover,
                    width: 88,
                    height: 88,
                    errorBuilder: (_, __, ___) => Center(
                      child: Text(initials,
                          style: const TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.w700,
                              color: Colors.white)),
                    ),
                  ),
                )
              : Center(
                  child: Text(
                    initials,
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
        ),
        const SizedBox(height: 14),
        Text(
          displayName,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: textColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          email,
          style: TextStyle(
            fontSize: 14,
            color: subtextColor,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required bool isDark,
    required Color cardColor,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Section header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 4),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColor.fourthColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 20, color: AppColor.fourthColor),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : AppColor.primaryColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          ...children,
          const SizedBox(height: 6),
        ],
      ),
    );
  }

  Future<void> _launchRentyUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
    }
  }

  Widget _buildLogoutButton(bool isDark) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton.icon(
        onPressed: _showLogoutDialog,
        icon: const Icon(Icons.logout, size: 20),
        label: const Text('Logout',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFFDC2626),
          side: BorderSide(color: const Color(0xFFDC2626).withOpacity(0.3)),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Logout',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppColor.darkText)),
        content: Text('Are you sure you want to logout?',
            style: TextStyle(
                color: isDark ? Colors.white70 : AppColor.mediumText)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child:
                Text('Cancel', style: TextStyle(color: AppColor.mediumText)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await ApiService.clearTokens();
              Get.offAllNamed('/login');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}

// ── Theme toggle tile ──
class _ThemeToggleTile extends StatelessWidget {
  final bool isDark;
  final bool showDivider;

  const _ThemeToggleTile({
    required this.isDark,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: AppColor.fourthColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.dark_mode_outlined, size: 20, color: AppColor.fourthColor),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dark Theme',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : AppColor.darkText,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Toggle application theme',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white54 : AppColor.lightText,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: isDark,
                onChanged: (value) {
                  final newThemeMode = value ? ThemeMode.dark : ThemeMode.light;
                  MyApp.of(context)?.changeTheme(newThemeMode);
                },
                activeColor: AppColor.fourthColor,
                activeTrackColor: AppColor.fourthColor.withOpacity(0.5),
              ),
            ],
          ),
        ),
        if (showDivider)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Divider(
                height: 1,
                color: isDark ? Colors.white10 : Colors.grey[200]),
          ),
      ],
    );
  }
}

// ── Reusable action tile ──
class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final bool isDark;
  final Color? iconColor;
  final VoidCallback onTap;
  final bool showDivider;

  const _ActionTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.isDark,
    required this.onTap,
    this.iconColor,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    final color = iconColor ?? AppColor.fourthColor;
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 20, color: color),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : AppColor.darkText,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.white54 : AppColor.lightText,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded,
                    color: isDark ? Colors.white30 : Colors.grey[350],
                    size: 22),
              ],
            ),
          ),
        ),
        if (showDivider)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Divider(
                height: 1,
                color: isDark ? Colors.white10 : Colors.grey[200]),
          ),
      ],
    );
  }
}