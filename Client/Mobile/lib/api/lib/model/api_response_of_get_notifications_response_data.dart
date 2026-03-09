//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class ApiResponseOfGetNotificationsResponseData {
  /// Returns a new [ApiResponseOfGetNotificationsResponseData] instance.
  ApiResponseOfGetNotificationsResponseData({
    this.notifications = const [],
    this.unreadCount,
  });

  List<NotificationDto> notifications;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  int? unreadCount;

  @override
  bool operator ==(Object other) => identical(this, other) || other is ApiResponseOfGetNotificationsResponseData &&
    _deepEquality.equals(other.notifications, notifications) &&
    other.unreadCount == unreadCount;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (notifications.hashCode) +
    (unreadCount == null ? 0 : unreadCount!.hashCode);

  @override
  String toString() => 'ApiResponseOfGetNotificationsResponseData[notifications=$notifications, unreadCount=$unreadCount]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'notifications'] = this.notifications;
    if (this.unreadCount != null) {
      json[r'unreadCount'] = this.unreadCount;
    } else {
      json[r'unreadCount'] = null;
    }
    return json;
  }

  /// Returns a new [ApiResponseOfGetNotificationsResponseData] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static ApiResponseOfGetNotificationsResponseData? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "ApiResponseOfGetNotificationsResponseData[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "ApiResponseOfGetNotificationsResponseData[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return ApiResponseOfGetNotificationsResponseData(
        notifications: NotificationDto.listFromJson(json[r'notifications']),
        unreadCount: mapValueOfType<int>(json, r'unreadCount'),
      );
    }
    return null;
  }

  static List<ApiResponseOfGetNotificationsResponseData> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ApiResponseOfGetNotificationsResponseData>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ApiResponseOfGetNotificationsResponseData.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, ApiResponseOfGetNotificationsResponseData> mapFromJson(dynamic json) {
    final map = <String, ApiResponseOfGetNotificationsResponseData>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = ApiResponseOfGetNotificationsResponseData.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of ApiResponseOfGetNotificationsResponseData-objects as value to a dart map
  static Map<String, List<ApiResponseOfGetNotificationsResponseData>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<ApiResponseOfGetNotificationsResponseData>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = ApiResponseOfGetNotificationsResponseData.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
  };
}

