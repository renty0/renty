import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:renty/core/utils/app_navigator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:renty/core/services/api_service.dart';
import 'package:renty/core/services/ProfileService.dart';
import 'package:renty/core/services/secure_storage_service.dart';
import 'package:renty/core/constant/app_colors.dart';
import 'package:renty/main.dart';
import 'package:renty/pages/edit_profile_page.dart';
import 'package:renty/pages/chat_room_page.dart';
import 'package:renty/utils/language_manager.dart';

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
              child: CircularProgressIndicator(color: AppColor.fourthColor),
            )
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
                      title: Text(
                        'Profile'.tr,
                        style: const TextStyle(
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

                          // ── Owner/Renter Rating Stats ──
                          _buildRatingStats(isDark, cardColor),
                          const SizedBox(height: 12),

                          // ── Edit Profile Button ──
                          SizedBox(
                            height: 38,
                            child: OutlinedButton.icon(
                              onPressed: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const EditProfilePage(),
                                  ),
                                );
                                if (result == true) _loadProfile();
                              },
                              icon: const Icon(Icons.edit_outlined, size: 16),
                              label: Text('Edit Profile'.tr),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColor.fourthColor,
                                side: BorderSide(
                                  color: AppColor.fourthColor.withValues(
                                    alpha: 0.5,
                                  ),
                                ),
                                textStyle: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 28),

                          // ── Quick Actions ──
                          _buildSection(
                            title: 'Activity'.tr,
                            icon: Icons.grid_view_rounded,
                            isDark: isDark,
                            cardColor: cardColor,
                            children: [
                              _ActionTile(
                                icon: Icons.receipt_long_outlined,
                                label: 'My Rentals'.tr,
                                subtitle: 'View rental history'.tr,
                                isDark: isDark,
                                onTap: () => AppNavigator.pushNamed('/my-rentals'),
                              ),
                              _ActionTile(
                                icon: Icons.shopping_bag_outlined,
                                label: 'My Orders'.tr,
                                subtitle: 'Track your orders'.tr,
                                isDark: isDark,
                                onTap: () => AppNavigator.pushNamed('/my-orders'),
                              ),
                              _ActionTile(
                                icon: Icons.inventory_2_outlined,
                                label: 'My Items'.tr,
                                subtitle: 'Manage your listings'.tr,
                                isDark: isDark,
                                onTap: () => AppNavigator.pushNamed('/my-items'),
                              ),
                              _ActionTile(
                                icon: Icons.account_balance_wallet_outlined,
                                label: 'Wallet'.tr,
                                subtitle: 'Balance & transactions'.tr,
                                isDark: isDark,
                                iconColor: const Color(0xFF059669),
                                onTap: () => AppNavigator.pushNamed('/wallet'),
                              ),
                              _ActionTile(
                                icon: Icons.favorite_outline,
                                label: 'Favorites'.tr,
                                subtitle: 'Saved items'.tr,
                                isDark: isDark,
                                iconColor: Colors.red,
                                onTap: () => AppNavigator.pushNamed('/favorites'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // ── Communication ──
                          _buildSection(
                            title: 'Communication'.tr,
                            icon: Icons.forum_outlined,
                            isDark: isDark,
                            cardColor: cardColor,
                            children: [
                              _ActionTile(
                                icon: Icons.chat_bubble_outline,
                                label: 'Messages'.tr,
                                subtitle: 'Chat with others'.tr,
                                isDark: isDark,
                                onTap: () => AppNavigator.pushNamed('/chat-list'),
                              ),
                              _ActionTile(
                                icon: Icons.notifications_outlined,
                                label: 'Notifications'.tr,
                                subtitle: 'Stay updated'.tr,
                                isDark: isDark,
                                onTap: () => AppNavigator.pushNamed('/notifications'),
                              ),
                              _ActionTile(
                                icon: Icons.support_agent_outlined,
                                label: 'Support'.tr,
                                subtitle: 'Get help'.tr,
                                isDark: isDark,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const ChatRoomPage(
                                        chatId: 'support',
                                        otherUserName: 'Support Team',
                                        isSupport: true,
                                      ),
                                    ),
                                  );
                                },
                                showDivider: false,
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // ── Settings ──
                          _buildSection(
                            title: 'Settings'.tr,
                            icon: Icons.settings_outlined,
                            isDark: isDark,
                            cardColor: cardColor,
                            children: [
                              _ThemeToggleTile(
                                isDark: isDark,
                                showDivider: true,
                              ),
                              _LanguageSelectionTile(
                                isDark: isDark,
                                showDivider: true,
                              ),
                              _ActionTile(
                                icon: Icons.delete_forever_outlined,
                                label: 'Delete Account'.tr,
                                subtitle: 'Permanently remove your account'.tr,
                                isDark: isDark,
                                iconColor: const Color(0xFFDC2626),
                                showDivider: false,
                                onTap: () => _showDeleteAccountDialog(),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // ── About Renty ──
                          _buildSection(
                            title: 'About Renty'.tr,
                            icon: Icons.info_outline_rounded,
                            isDark: isDark,
                            cardColor: cardColor,
                            children: [
                              _ActionTile(
                                icon: Icons.diversity_3_outlined,
                                label: 'About Us'.tr,
                                subtitle: 'Learn about our mission'.tr,
                                isDark: isDark,
                                iconColor: const Color(0xFF0ea5e9),
                                onTap: () => _launchRentyUrl(
                                  'https://appforyou.store/Renty/about.html',
                                ),
                              ),
                              _ActionTile(
                                icon: Icons.gavel_outlined,
                                label: 'Terms & Conditions'.tr,
                                subtitle: 'Our terms of service'.tr,
                                isDark: isDark,
                                iconColor: const Color(0xFF0c295e),
                                onTap: () => _launchRentyUrl(
                                  'https://appforyou.store/Renty/terms.html',
                                ),
                              ),
                              _ActionTile(
                                icon: Icons.shield_outlined,
                                label: 'Privacy Policy'.tr,
                                subtitle: 'How we protect your data'.tr,
                                isDark: isDark,
                                iconColor: const Color(0xFF059669),
                                onTap: () => _launchRentyUrl(
                                  'https://appforyou.store/Renty/privacy.html',
                                ),
                              ),
                              _ActionTile(
                                icon: Icons.help_outline_rounded,
                                label: 'FAQ'.tr,
                                subtitle: 'Common questions answered'.tr,
                                isDark: isDark,
                                iconColor: const Color(0xFFd97706),
                                showDivider: false,
                                onTap: () => _launchRentyUrl(
                                  'https://appforyou.store/Renty/faq.html',
                                ),
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
    final displayName = name.isNotEmpty
        ? name
        : (_profile?['name'] ?? 'User'.tr);
    // SECURITY: email is read from API profile response (_profile['email']);
    // no longer stored/read from local storage.
    final email = (_profile?['email'] as String?) ?? '';
    final initials = displayName.isNotEmpty
        ? displayName[0].toUpperCase()
        : 'U';
    final profileImageUrl = _profile?['profilePictureUrl'] as String?;

    return Column(
      children: [
        // ── Avatar ──
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            // Outer ring
            Container(
              width: 92,
              height: 92,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColor.fourthColor.withValues(alpha: 0.35),
                  width: 2.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColor.fourthColor.withValues(alpha: 0.12),
                    blurRadius: 12,
                    spreadRadius: 1,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(3),
                child: ClipOval(
                  child: (profileImageUrl != null && profileImageUrl.isNotEmpty)
                      ? CachedNetworkImage(
                          imageUrl: profileImageUrl.startsWith('http')
                              ? profileImageUrl
                              : 'https://starfish-app-vavqt.ondigitalocean.app${profileImageUrl.startsWith('/') ? '' : '/'}$profileImageUrl',
                          fit: BoxFit.cover,
                          width: 84,
                          height: 84,
                          placeholder: (_, __) => _buildInitialsAvatar(initials),
                          errorWidget: (_, __, ___) =>
                              _buildInitialsAvatar(initials),
                        )
                      : _buildInitialsAvatar(initials),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              displayName,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
            ),
            if (_profile?['isVerified'] == true) ...[
              const SizedBox(width: 6),
              const Icon(
                Icons.verified_rounded,
                color: AppColor.successColor,
                size: 20,
              ),
            ],
          ],
        ),
        const SizedBox(height: 3),
        Text(
          email,
          style: TextStyle(
            fontSize: 13,
            color: subtextColor,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildInitialsAvatar(String initials) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColor.primaryColor, AppColor.fourthColor],
        ),
      ),
      child: Center(
        child: Text(
          initials,
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildRatingStats(bool isDark, Color cardColor) {
    final ownerRating = _profile?['ownerRating'];
    final renterRating = _profile?['renterRating'];
    // Only show if at least one rating exists
    if (ownerRating == null && renterRating == null)
      return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
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
      child: Row(
        children: [
          Expanded(
            child: _ratingItem(
              'Owner Rating'.tr,
              ownerRating ?? 0.0,
              const Color(0xFF059669),
              isDark,
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: isDark ? Colors.white12 : Colors.grey[200],
          ),
          Expanded(
            child: _ratingItem(
              'Renter Rating'.tr,
              renterRating ?? 0.0,
              AppColor.fourthColor,
              isDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _ratingItem(String label, dynamic rating, Color color, bool isDark) {
    final val = (rating is num) ? rating.toDouble() : 0.0;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              val.toStringAsFixed(1),
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : AppColor.darkText,
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.star_rounded, size: 20, color: color),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.white54 : AppColor.lightText,
          ),
        ),
      ],
    );
  }

  void _showDeleteAccountDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              color: Color(0xFFDC2626),
              size: 28,
            ),
            const SizedBox(width: 10),
            Text(
              'Delete Account'.tr,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppColor.darkText,
              ),
            ),
          ],
        ),
        content: Text(
          'This action is permanent and cannot be undone. All your data, listings, and history will be permanently deleted.'
              .tr,
          style: TextStyle(
            color: isDark ? Colors.white70 : AppColor.mediumText,
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel'.tr,
              style: TextStyle(color: AppColor.mediumText),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await _deleteAccount();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text('Delete Account'.tr),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAccount() async {
    try {
      // Call DELETE /api/v1/auth/me directly (not in generated client)
      await ApiService.client.invokeAPI(
        '/api/v1/auth/me',
        'DELETE',
        [],
        null,
        {},
        {},
        null,
      );
      await ApiService.clearTokens();
      AppNavigator.pushNamedAndRemoveUntil('/login');
      AppNavigator.showSnackBar(
        'Account Deleted'.tr,
        'Your account has been permanently deleted.'.tr,
        backgroundColor: const Color(0xFFDC2626).withOpacity(0.9),
        textColor: Colors.white,
      );
    } catch (e) {
      AppNavigator.showSnackBar(
        'Error'.tr,
        'Failed to delete account. Please try again.'.tr,
        backgroundColor: const Color(0xFFDC2626).withOpacity(0.9),
        textColor: Colors.white,
        isError: true,
      );
    }
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
    try {
      await launchUrl(Uri.parse(url), mode: LaunchMode.inAppBrowserView);
    } catch (_) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  Widget _buildLogoutButton(bool isDark) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton.icon(
        onPressed: _showLogoutDialog,
        icon: const Icon(Icons.logout, size: 20),
        label: Text(
          'Logout'.tr,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFFDC2626),
          side: BorderSide(color: const Color(0xFFDC2626).withOpacity(0.3)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
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
        title: Text(
          'Logout'.tr,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : AppColor.darkText,
          ),
        ),
        content: Text(
          'Are you sure you want to logout?'.tr,
          style: TextStyle(
            color: isDark ? Colors.white70 : AppColor.mediumText,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel'.tr,
              style: TextStyle(color: AppColor.mediumText),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await ApiService.clearTokens();
              AppNavigator.pushNamedAndRemoveUntil('/login');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text('Logout'.tr),
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

  const _ThemeToggleTile({required this.isDark, this.showDivider = true});

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
                child: const Icon(
                  Icons.dark_mode_outlined,
                  size: 20,
                  color: AppColor.fourthColor,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dark Theme'.tr,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : AppColor.darkText,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Toggle application theme'.tr,
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
              color: isDark ? Colors.white10 : Colors.grey[200],
            ),
          ),
      ],
    );
  }
}

// ── Language selection tile ──
class _LanguageSelectionTile extends StatelessWidget {
  final bool isDark;
  final bool showDivider;

  const _LanguageSelectionTile({required this.isDark, this.showDivider = true});

  @override
  Widget build(BuildContext context) {
    final currentLanguageCode = LanguageManager.getCurrentLanguageCode();

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
                child: const Icon(
                  Icons.language_outlined,
                  size: 20,
                  color: AppColor.fourthColor,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Language'.tr,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : AppColor.darkText,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Choose application language'.tr,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white54 : AppColor.lightText,
                      ),
                    ),
                  ],
                ),
              ),
              DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: currentLanguageCode,
                  icon: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: isDark ? Colors.white54 : AppColor.lightText,
                  ),
                  dropdownColor: isDark
                      ? const Color(0xFF1E1E1E)
                      : Colors.white,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : AppColor.darkText,
                    fontFamily: 'Cairo',
                  ),
                  onChanged: (String? newValue) {
                    if (newValue != null && newValue != currentLanguageCode) {
                      MyApp.of(context)?.changeLanguage(newValue);
                    }
                  },
                  items: [
                    DropdownMenuItem(value: 'en', child: Text('English'.tr)),
                    DropdownMenuItem(value: 'ar', child: Text('Arabic'.tr)),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (showDivider)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Divider(
              height: 1,
              color: isDark ? Colors.white10 : Colors.grey[200],
            ),
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
                Icon(
                  LanguageManager.isArabic()
                      ? Icons.chevron_left_rounded
                      : Icons.chevron_right_rounded,
                  color: isDark ? Colors.white30 : Colors.grey[350],
                  size: 22,
                ),
              ],
            ),
          ),
        ),
        if (showDivider)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Divider(
              height: 1,
              color: isDark ? Colors.white10 : Colors.grey[200],
            ),
          ),
      ],
    );
  }
}
