import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:renty/core/constant/app_colors.dart';
import 'package:renty/core/functions/alertexitapp.dart';
import 'package:renty/core/controllers/main_navigation_controller.dart';
import 'package:renty/component/internet_checker_widget.dart';
import 'package:renty/pages/home_page.dart';
import 'package:renty/pages/marketplace_page.dart';
import 'package:renty/pages/search_page.dart';
import 'package:renty/pages/profile_page.dart';
import 'package:renty/pages/chat_list_page.dart';

class MainContainer extends StatefulWidget {
  final int initialIndex;

  const MainContainer({Key? key, this.initialIndex = 2}) : super(key: key);

  @override
  State<MainContainer> createState() => _MainContainerState();
}

class _MainContainerState extends State<MainContainer>
    with WidgetsBindingObserver {
  late final MainNavigationController _navController;

  final List<Widget> _pages = [
    const ChatListPage(),      // 0
    const MarketplacePage(),   // 1
    const HomePage(),          // 2
    const SearchPage(),        // 3
    const ProfilePage(),       // 4
  ];

  @override
  void initState() {
    super.initState();
    _navController = Get.put(MainNavigationController());
    _navController.currentIndex.value =
        widget.initialIndex.clamp(0, _pages.length - 1);
    WidgetsBinding.instance.addObserver(this);

    // Listen to tab changes from the controller
    ever(_navController.currentIndex, (int index) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          // If not on Home tab, go to Home first
          if (_navController.currentIndex.value != 2) {
            _navController.currentIndex.value = 2;
            return;
          }
          // Already on Home — show exit dialog
          final shouldPop = await alertExitApp(context);
          if (shouldPop && context.mounted) {
            Navigator.of(context).pop();
          }
        }
      },
      child: InternetCheckerWidget(
        showOnlineMessage: true,
        child: Obx(() => Scaffold(
              body: IndexedStack(
                index: _navController.currentIndex.value,
                children: _pages,
              ),
              bottomNavigationBar: Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 20,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: NavigationBar(
                  selectedIndex: _navController.currentIndex.value,
                  onDestinationSelected: (index) {
                    _navController.currentIndex.value = index;
                  },
                  backgroundColor:
                      isDark ? const Color(0xFF1E1E1E) : Colors.white,
                  indicatorColor: AppColor.fourthColor.withOpacity(0.12),
                  surfaceTintColor: Colors.transparent,
                  height: 68,
                  labelBehavior:
                      NavigationDestinationLabelBehavior.alwaysShow,
                  destinations: [
                    NavigationDestination(
                      icon: Icon(Icons.chat_bubble_outline,
                          color: isDark ? Colors.white54 : AppColor.grey),
                      selectedIcon: Icon(Icons.chat_bubble_rounded,
                          color: AppColor.fourthColor),
                      label: 'Chat'.tr,
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.storefront_outlined,
                          color: isDark ? Colors.white54 : AppColor.grey),
                      selectedIcon: Icon(Icons.storefront_rounded,
                          color: AppColor.fourthColor),
                      label: 'Marketplace'.tr,
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.home_outlined,
                          color: isDark ? Colors.white54 : AppColor.grey),
                      selectedIcon: Icon(Icons.home_rounded,
                          color: AppColor.fourthColor),
                      label: 'Home'.tr,
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.search_outlined,
                          color: isDark ? Colors.white54 : AppColor.grey),
                      selectedIcon: Icon(Icons.search_rounded,
                          color: AppColor.fourthColor),
                      label: 'Search'.tr,
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.person_outline,
                          color: isDark ? Colors.white54 : AppColor.grey),
                      selectedIcon: Icon(Icons.person_rounded,
                          color: AppColor.fourthColor),
                      label: 'Profile'.tr,
                    ),
                  ],
                ),
              ),
            )),
      ),
    );
  }
}
