import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:renty/core/constant/app_colors.dart';
import 'package:renty/core/functions/alertexitapp.dart';
import 'package:renty/core/blocs/blocs.dart';
import 'package:renty/core/utils/app_navigator.dart';
import 'package:renty/component/internet_checker_widget.dart';
import 'package:renty/pages/home_page.dart';
import 'package:renty/pages/marketplace_page.dart';
import 'package:renty/pages/my_rentals_page.dart';
import 'package:renty/pages/profile_page.dart';
import 'package:renty/pages/chat_list_page.dart';
import 'package:renty/core/services/notification_signalr_service.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'dart:async';

class MainContainer extends StatefulWidget {
  final int initialIndex;

  const MainContainer({Key? key, this.initialIndex = 2}) : super(key: key);

  @override
  State<MainContainer> createState() => _MainContainerState();
}

class _MainContainerState extends State<MainContainer>
    with WidgetsBindingObserver {
  final List<Widget> _pages = [
    const ChatListPage(),      // 0
    const MarketplacePage(),   // 1
    const HomePage(),          // 2
    const MyRentalsPage(),     // 3
    const ProfilePage(),       // 4
  ];

  final _signalr = NotificationSignalrService();
  StreamSubscription? _notifSub;

  int _currentIndex = 2;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex.clamp(0, _pages.length - 1);
    WidgetsBinding.instance.addObserver(this);

    // Ensure cubit starts at initialIndex if specified
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<NavigationCubit>().switchToTab(_currentIndex);
      }
    });

    _initGlobalNotifications();
  }

  Future<void> _initGlobalNotifications() async {
    await _signalr.startConnection();
    _notifSub = _signalr.onNotification.listen((notif) {
      AppNavigator.showSnackBar(
        notif.title ?? 'Notification'.tr,
        notif.message ?? '',
        backgroundColor: AppColor.primaryColor.withOpacity(0.9),
        duration: const Duration(seconds: 4),
        icon: const Icon(Icons.notifications_active, color: Colors.white),
      );

      FlutterRingtonePlayer().playNotification();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _notifSub?.cancel();
    _signalr.stopConnection();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocConsumer<NavigationCubit, NavigationState>(
      listener: (context, navState) {
        setState(() => _currentIndex = navState.selectedIndex);
      },
      builder: (context, navState) {
        _currentIndex = navState.selectedIndex;
        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) async {
            if (!didPop) {
              // If not on Home tab, go to Home first
              if (_currentIndex != 2) {
                context.read<NavigationCubit>().switchToTab(2);
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
            child: Scaffold(
              body: IndexedStack(
                index: _currentIndex,
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
                  selectedIndex: _currentIndex,
                  onDestinationSelected: (index) {
                    context.read<NavigationCubit>().switchToTab(index);
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
                      icon: Icon(Icons.receipt_long_outlined,
                          color: isDark ? Colors.white54 : AppColor.grey),
                      selectedIcon: Icon(Icons.receipt_long_rounded,
                          color: AppColor.fourthColor),
                      label: 'Rentals'.tr,
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
            ),
          ),
        );
      },
    );
  }
}
