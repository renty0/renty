import 'package:renty/core/constant/routes.dart';
import 'package:renty/core/services/services.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
class MyMiddleWare extends GetMiddleware {
  @override
  int? get priority => 1;

  MyServices myServices = Get.find();

  @override
  RouteSettings? redirect(String? route) {
    String? step = myServices.sharedPreferences.getString("step");

    // If step is "2", user is logged in -> go to homepage
    if (step == "2") {
      return const RouteSettings(name: AppRoute.homepage);
    }

    // If step is "1", onboarding completed -> go to login
    if (step == "1") {
      return const RouteSettings(name: AppRoute.login);
    }

    // If step is null/empty, show onboarding
    return null;
  }
}
