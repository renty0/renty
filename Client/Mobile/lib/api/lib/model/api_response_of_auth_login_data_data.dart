//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class ApiResponseOfAuthLoginDataData {
  /// Returns a new [ApiResponseOfAuthLoginDataData] instance.
  ApiResponseOfAuthLoginDataData({
    this.accessToken,
    this.refreshToken,
    this.refreshTokenExpiresAt,
    this.user,
  });

  String? accessToken;

  String? refreshToken;

  DateTime? refreshTokenExpiresAt;

  AuthLoginDataUser? user;

  @override
  bool operator ==(Object other) => identical(this, other) || other is ApiResponseOfAuthLoginDataData &&
    other.accessToken == accessToken &&
    other.refreshToken == refreshToken &&
    other.refreshTokenExpiresAt == refreshTokenExpiresAt &&
    other.user == user;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (accessToken == null ? 0 : accessToken!.hashCode) +
    (refreshToken == null ? 0 : refreshToken!.hashCode) +
    (refreshTokenExpiresAt == null ? 0 : refreshTokenExpiresAt!.hashCode) +
    (user == null ? 0 : user!.hashCode);

  @override
  String toString() => 'ApiResponseOfAuthLoginDataData[accessToken=$accessToken, refreshToken=$refreshToken, refreshTokenExpiresAt=$refreshTokenExpiresAt, user=$user]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.accessToken != null) {
      json[r'accessToken'] = this.accessToken;
    } else {
      json[r'accessToken'] = null;
    }
    if (this.refreshToken != null) {
      json[r'refreshToken'] = this.refreshToken;
    } else {
      json[r'refreshToken'] = null;
    }
    if (this.refreshTokenExpiresAt != null) {
      json[r'refreshTokenExpiresAt'] = this.refreshTokenExpiresAt!.toUtc().toIso8601String();
    } else {
      json[r'refreshTokenExpiresAt'] = null;
    }
    if (this.user != null) {
      json[r'user'] = this.user;
    } else {
      json[r'user'] = null;
    }
    return json;
  }

  /// Returns a new [ApiResponseOfAuthLoginDataData] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static ApiResponseOfAuthLoginDataData? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "ApiResponseOfAuthLoginDataData[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "ApiResponseOfAuthLoginDataData[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return ApiResponseOfAuthLoginDataData(
        accessToken: mapValueOfType<String>(json, r'accessToken'),
        refreshToken: mapValueOfType<String>(json, r'refreshToken'),
        refreshTokenExpiresAt: mapDateTime(json, r'refreshTokenExpiresAt', r''),
        user: AuthLoginDataUser.fromJson(json[r'user']),
      );
    }
    return null;
  }

  static List<ApiResponseOfAuthLoginDataData> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ApiResponseOfAuthLoginDataData>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ApiResponseOfAuthLoginDataData.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, ApiResponseOfAuthLoginDataData> mapFromJson(dynamic json) {
    final map = <String, ApiResponseOfAuthLoginDataData>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = ApiResponseOfAuthLoginDataData.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of ApiResponseOfAuthLoginDataData-objects as value to a dart map
  static Map<String, List<ApiResponseOfAuthLoginDataData>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<ApiResponseOfAuthLoginDataData>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = ApiResponseOfAuthLoginDataData.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
  };
}

