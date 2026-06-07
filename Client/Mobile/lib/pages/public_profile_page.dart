import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:renty/core/constant/app_colors.dart';
import 'package:renty/core/services/api_service.dart';

/// Public profile page — mirrors the web's /user-profile/:id feature.
/// Calls GET /api/v1/public-profile/{userId} for full data (ratings, reviews,
/// items, bio, joinedAt) then falls back to passed-in args if the endpoint
/// is unavailable.
class PublicProfilePage extends StatefulWidget {
  final String userId;
  final String? userName;
  final String? userCity;
  final String? userImageUrl;

  const PublicProfilePage({
    super.key,
    required this.userId,
    this.userName,
    this.userCity,
    this.userImageUrl,
  });

  @override
  State<PublicProfilePage> createState() => _PublicProfilePageState();
}

class _PublicProfilePageState extends State<PublicProfilePage>
    with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  Map<String, dynamic>? _profile;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadProfile();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);

    try {
      final response = await ApiService.client.invokeAPI(
        '/api/v1/public-profile/${widget.userId}',
        'GET', [], null, {}, {}, null,
      );

      if (response.statusCode >= 200 && response.statusCode < 300 && response.body.isNotEmpty) {
        final body = jsonDecode(response.body);
        if (body['data'] != null) {
          setState(() {
            _profile = body['data'] as Map<String, dynamic>;
            _isLoading = false;
          });
          return;
        }
      }
    } catch (e) {
      print('PublicProfile: API call failed, using fallback: $e');
    }

    // Fallback: use passed-in args
    setState(() {
      _profile = {
        'id': widget.userId,
        'firstName': widget.userName ?? 'User',
        'lastName': '',
        'city': widget.userCity ?? '',
        'profilePictureUrl': widget.userImageUrl,
        'items': [],
        'reviews': [],
      };
      _isLoading = false;
    });
  }

  // ── Helpers ──
  String get _fullName {
    final fn = _profile?['firstName'] ?? '';
    final ln = _profile?['lastName'] ?? '';
    final n = '$fn $ln'.trim();
    return n.isNotEmpty ? n : 'User';
  }

  String get _initials => _fullName.isNotEmpty ? _fullName[0].toUpperCase() : 'U';
  String? get _imageUrl => _profile?['profilePictureUrl'] as String?;
  double get _ownerRating => (_profile?['ownerRating'] ?? 0).toDouble();
  double get _renterRating => (_profile?['renterRating'] ?? 0).toDouble();
  double get _rating => (_profile?['rating'] ?? 0).toDouble();
  List get _items => (_profile?['items'] as List?) ?? [];
  List get _reviews => (_profile?['reviews'] as List?) ?? [];
  String get _bio => _profile?['bio'] ?? '';
  String? get _joinedAt => _profile?['joinedAt'] as String?;

  String get _location {
    final city = _profile?['city'] ?? '';
    final country = _profile?['country'] ?? '';
    return [city, country].where((s) => s.toString().isNotEmpty).join(', ');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : AppColor.backgroundcolor,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColor.fourthColor))
          : NestedScrollView(
              headerSliverBuilder: (context, innerScrolled) => [
                _buildHeader(isDark),
                _buildMessageButton(isDark),
                _buildTabBar(isDark),
              ],
              body: TabBarView(
                controller: _tabController,
                children: [
                  _buildListingsTab(isDark),
                  _buildReviewsTab(isDark),
                  _buildAboutTab(isDark),
                ],
              ),
            ),
    );
  }

  // ── Header ──
  SliverAppBar _buildHeader(bool isDark) {
    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      backgroundColor: AppColor.primaryColor,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColor.primaryColor, AppColor.secondColor, AppColor.fourthColor],
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 30),
                // Avatar with PRO badge
                Stack(children: [
                  Container(
                    width: 90, height: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 16, offset: const Offset(0, 6))],
                    ),
                    child: ClipOval(
                      child: _imageUrl != null && _imageUrl!.isNotEmpty
                          ? CachedNetworkImage(imageUrl: _imageUrl!, fit: BoxFit.cover,
                              errorWidget: (_, __, ___) => _avatarFallback())
                          : _avatarFallback(),
                    ),
                  ),
                  if (_rating > 4.5)
                    Positioned(
                      bottom: 0, right: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFBBF24),
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
                        ),
                        child: const Text('PRO', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Colors.black)),
                      ),
                    ),
                ]),
                const SizedBox(height: 12),
                Text(_fullName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white)),
                if (_location.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    const Icon(Icons.location_on, size: 14, color: Colors.white70),
                    const SizedBox(width: 4),
                    Text(_location, style: const TextStyle(fontSize: 13, color: Colors.white70)),
                  ]),
                ],
                const SizedBox(height: 14),
                // Stats chips
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  _statChip(Icons.star_rounded, _ownerRating.toStringAsFixed(1), 'Owner', const Color(0xFF059669)),
                  const SizedBox(width: 10),
                  _statChip(Icons.star_rounded, _renterRating.toStringAsFixed(1), 'Renter', AppColor.fourthColor),
                  const SizedBox(width: 10),
                  _statChip(Icons.inventory_2_rounded, _items.length.toString(), 'Listings', Colors.white),
                ]),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _statChip(IconData icon, String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white)),
        ]),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.white70, fontWeight: FontWeight.w500)),
      ]),
    );
  }

  Widget _avatarFallback() {
    return Container(
      color: AppColor.fourthColor,
      child: Center(child: Text(_initials, style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w700, color: Colors.white))),
    );
  }

  // ── Send Message ──
  SliverToBoxAdapter _buildMessageButton(bool isDark) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
        child: SizedBox(
          width: double.infinity, height: 46,
          child: ElevatedButton.icon(
            onPressed: () {
              Get.toNamed('/chat-room', arguments: {
                'otherUserId': widget.userId,
                'otherUserName': _fullName,
                'otherUserImage': _imageUrl,
              });
            },
            icon: const Icon(Icons.chat_rounded, size: 20),
            label: const Text('Send Message', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              elevation: 0,
            ),
          ),
        ),
      ),
    );
  }

  // ── Tab Bar ──
  SliverPersistentHeader _buildTabBar(bool isDark) {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _TabBarDelegate(
        TabBar(
          controller: _tabController,
          labelColor: AppColor.primaryColor,
          unselectedLabelColor: isDark ? Colors.white54 : AppColor.lightText,
          indicatorColor: AppColor.primaryColor,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          tabs: [
            Tab(text: 'Listings (${_items.length})'),
            Tab(text: 'Reviews (${_reviews.length})'),
            const Tab(text: 'About'),
          ],
        ),
        isDark,
      ),
    );
  }

  // ── Listings Tab ──
  Widget _buildListingsTab(bool isDark) {
    if (_items.isEmpty) {
      return _emptyState(Icons.inventory_2_outlined, 'No Listings', 'This user has no active listings.', isDark);
    }
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, childAspectRatio: 0.72, crossAxisSpacing: 12, mainAxisSpacing: 12),
      itemCount: _items.length,
      itemBuilder: (context, i) {
        final item = _items[i] as Map<String, dynamic>;
        return _itemCard(item, isDark);
      },
    );
  }

  Widget _itemCard(Map<String, dynamic> item, bool isDark) {
    final image = item['primaryImage'] as String?;
    final title = item['titleEn'] ?? item['titleAr'] ?? 'Untitled';
    final price = item['dailyPrice'];

    return GestureDetector(
      onTap: () => Get.toNamed('/item-detail', arguments: {'itemId': item['id']?.toString()}),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.3 : 0.06), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
            flex: 3,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: image != null && image.isNotEmpty
                  ? CachedNetworkImage(imageUrl: image, fit: BoxFit.cover, width: double.infinity,
                      errorWidget: (_, __, ___) => _imgPlaceholder(isDark))
                  : _imgPlaceholder(isDark),
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isDark ? Colors.white : AppColor.darkText),
                    maxLines: 2, overflow: TextOverflow.ellipsis),
                const Spacer(),
                if (price != null)
                  Text('${(price as num).toStringAsFixed(0)} EGP/day',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColor.fourthColor)),
              ]),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _imgPlaceholder(bool isDark) {
    return Container(
      color: isDark ? Colors.grey[800] : Colors.grey[200],
      child: Center(child: Icon(Icons.image_outlined, color: Colors.grey[400], size: 36)),
    );
  }

  // ── Reviews Tab ──
  Widget _buildReviewsTab(bool isDark) {
    if (_reviews.isEmpty) {
      return _emptyState(Icons.rate_review_outlined, 'No Reviews', 'This user has no reviews yet.', isDark);
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _reviews.length,
      itemBuilder: (context, i) => _reviewCard(_reviews[i] as Map<String, dynamic>, isDark),
    );
  }

  Widget _reviewCard(Map<String, dynamic> review, bool isDark) {
    final name = review['reviewerName'] ?? 'Anonymous';
    final image = review['reviewerImage'] as String?;
    final rating = (review['rating'] ?? 0).toDouble();
    final comment = review['comment'] ?? '';
    final role = review['role'] ?? '';
    final createdAt = review['createdAt'] as String?;
    final ini = name.isNotEmpty ? name[0].toUpperCase() : 'A';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.3 : 0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          ClipOval(
            child: SizedBox(width: 40, height: 40,
              child: image != null && image.isNotEmpty
                  ? CachedNetworkImage(imageUrl: image, fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => _miniAvatar(ini))
                  : _miniAvatar(ini)),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(name, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: isDark ? Colors.white : AppColor.darkText)),
            const SizedBox(height: 2),
            Row(children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: (role == 'owner' ? const Color(0xFF059669) : AppColor.fourthColor).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(role == 'owner' ? 'Owner' : 'Renter',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600,
                        color: role == 'owner' ? const Color(0xFF059669) : AppColor.fourthColor)),
              ),
              if (createdAt != null) ...[
                const SizedBox(width: 8),
                Text(_fmtDate(createdAt), style: TextStyle(fontSize: 11, color: isDark ? Colors.white38 : AppColor.lightText)),
              ],
            ]),
          ])),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFFBBF24).withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.star_rounded, size: 16, color: Color(0xFFFBBF24)),
              const SizedBox(width: 2),
              Text(rating.toStringAsFixed(1),
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: isDark ? Colors.white : AppColor.darkText)),
            ]),
          ),
        ]),
        if (comment.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(comment, style: TextStyle(fontSize: 13, height: 1.5, color: isDark ? Colors.white70 : AppColor.mediumText)),
        ],
      ]),
    );
  }

  Widget _miniAvatar(String ini) {
    return Container(
      color: AppColor.fourthColor.withOpacity(0.2),
      child: Center(child: Text(ini, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColor.fourthColor))),
    );
  }

  // ── About Tab ──
  Widget _buildAboutTab(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.3 : 0.05), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(Icons.description_outlined, size: 20, color: AppColor.fourthColor),
            const SizedBox(width: 8),
            Text('Bio', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: isDark ? Colors.white : AppColor.darkText)),
          ]),
          const SizedBox(height: 12),
          Text(_bio.isNotEmpty ? _bio : 'No bio provided.',
              style: TextStyle(fontSize: 14, height: 1.6, color: isDark ? Colors.white70 : AppColor.mediumText)),
          if (_joinedAt != null) ...[
            const SizedBox(height: 20),
            Divider(color: isDark ? Colors.white10 : Colors.grey[200]),
            const SizedBox(height: 12),
            Row(children: [
              Icon(Icons.calendar_today_outlined, size: 16, color: isDark ? Colors.white38 : AppColor.lightText),
              const SizedBox(width: 8),
              Text('Joined ${_fmtDate(_joinedAt!)}',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: isDark ? Colors.white54 : AppColor.lightText)),
            ]),
          ],
        ]),
      ),
    );
  }

  // ── Empty State ──
  Widget _emptyState(IconData icon, String title, String subtitle, bool isDark) {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: AppColor.fourthColor.withOpacity(0.08), shape: BoxShape.circle),
          child: Icon(icon, size: 48, color: AppColor.fourthColor.withOpacity(0.5)),
        ),
        const SizedBox(height: 16),
        Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: isDark ? Colors.white : AppColor.darkText)),
        const SizedBox(height: 6),
        Text(subtitle, style: TextStyle(fontSize: 13, color: isDark ? Colors.white54 : AppColor.lightText)),
      ]),
    );
  }

  String _fmtDate(String d) {
    try { return DateFormat('MMM d, yyyy').format(DateTime.parse(d)); } catch (_) { return d; }
  }
}

// ── Tab Bar Delegate ──
class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  final bool isDark;
  _TabBarDelegate(this.tabBar, this.isDark);

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) =>
      Container(color: isDark ? const Color(0xFF121212) : Colors.white, child: tabBar);

  @override double get maxExtent => tabBar.preferredSize.height;
  @override double get minExtent => tabBar.preferredSize.height;
  @override bool shouldRebuild(covariant _TabBarDelegate old) => false;
}
