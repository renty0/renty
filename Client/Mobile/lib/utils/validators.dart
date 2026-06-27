import 'package:renty/core/constant/constants.dart';
import 'package:get/get.dart';

class Validators {
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required'.tr;
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email'.tr;
    }

    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required'.tr;
    }

    if (value.length < AppConstants.minPasswordLength) {
      return 'Password must be at least @min characters'.trParams({
        'min': AppConstants.minPasswordLength.toString(),
      });
    }

    return null;
  }

  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '@fieldName is required'.trParams({
        'fieldName': fieldName.tr,
      });
    }
    return null;
  }

  static String? validateProductName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Product name is required'.tr;
    }

    if (value.length > AppConstants.maxProductNameLength) {
      return 'Product name is too long'.tr;
    }

    return null;
  }

  static String? validateDescription(String? value) {
    if (value != null && value.length > AppConstants.maxDescriptionLength) {
      return 'Description is too long'.tr;
    }
    return null;
  }

  static String? validatePrice(String? value) {
    if (value == null || value.isEmpty) {
      return 'Price is required'.tr;
    }

    final price = double.tryParse(value);
    if (price == null || price <= 0) {
      return 'Please enter a valid price'.tr;
    }

    return null;
  }

  static String? validateStock(String? value) {
    if (value == null || value.isEmpty) {
      return 'Stock is required'.tr;
    }

    final stock = int.tryParse(value);
    if (stock == null || stock < 0) {
      return 'Please enter a valid stock quantity'.tr;
    }

    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required'.tr;
    }

    final phoneRegex = RegExp(r'^\+?[\d\s-]{10,}$');
    if (!phoneRegex.hasMatch(value)) {
      return 'Please enter a valid phone number'.tr;
    }

    return null;
  }
}