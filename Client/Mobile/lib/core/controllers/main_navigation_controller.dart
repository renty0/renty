import 'package:get/get.dart';

/// Global controller that manages the bottom navigation tab index.
/// Used by child pages (e.g. HomePage) to switch tabs programmatically.
class MainNavigationController extends GetxController {
  final currentIndex = 0.obs;

  void switchToTab(int index) {
    currentIndex.value = index;
  }
}

