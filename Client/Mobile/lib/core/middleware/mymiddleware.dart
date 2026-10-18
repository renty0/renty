import 'package:flutter/material.dart';
import 'package:renty/core/constant/routes.dart';

class MyMiddleWare {
  static String? getRedirectRoute(String? step) {
    if (step == "2") {
      return AppRoute.homepage;
    }
    if (step == "1") {
      return AppRoute.login;
    }
    return null;
  }
}
