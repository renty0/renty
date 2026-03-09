//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class AuthRefreshData {
  /// Returns a new [AuthRefreshData] instance.
  AuthRefreshData({
    this.accessToken,
    this.refreshToken,
  });

  String? accessToken;

  String? refreshToken;

  @override
  bool operator ==(Object other) => identical(this, other) || other is AuthRefreshData &&
    other.accessToken == accessToken &&
    other.refreshToken == refreshToken;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (accessToken == null ? 0 : accessToken!.hashCode) +
    (refreshToken == null ? 0 : refreshToken!.hashCode);

  @override
  String toString() => 'AuthRefreshData[accessToken=$accessToken, refreshToken=$refreshToken]';

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
    return json;
  }

  /// Returns a new [AuthRefreshData] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static AuthRefreshData? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "AuthRefreshData[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "AuthRefreshData[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return AuthRefreshData(
        accessToken: mapValueOfType<String>(json, r'accessToken'),
        refreshToken: mapValueOfType<String>(json, r'refreshToken'),
      );
    }
    return null;
  }

  static List<AuthRefreshData> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <AuthRefreshData>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = AuthRefreshData.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, AuthRefreshData> mapFromJson(dynamic json) {
    final map = <String, AuthRefreshData>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = AuthRefreshData.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of AuthRefreshData-objects as value to a dart map
  static Map<String, List<AuthRefreshData>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<AuthRefreshData>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = AuthRefreshData.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
  };
}

