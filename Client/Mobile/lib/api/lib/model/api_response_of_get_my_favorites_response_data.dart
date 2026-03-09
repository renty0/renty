//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class ApiResponseOfGetMyFavoritesResponseData {
  /// Returns a new [ApiResponseOfGetMyFavoritesResponseData] instance.
  ApiResponseOfGetMyFavoritesResponseData({
    this.success,
    this.items = const [],
    this.error,
  });

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  bool? success;

  List<FavoriteItemDto>? items;

  String? error;

  @override
  bool operator ==(Object other) => identical(this, other) || other is ApiResponseOfGetMyFavoritesResponseData &&
    other.success == success &&
    _deepEquality.equals(other.items, items) &&
    other.error == error;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (success == null ? 0 : success!.hashCode) +
    (items == null ? 0 : items!.hashCode) +
    (error == null ? 0 : error!.hashCode);

  @override
  String toString() => 'ApiResponseOfGetMyFavoritesResponseData[success=$success, items=$items, error=$error]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.success != null) {
      json[r'success'] = this.success;
    } else {
      json[r'success'] = null;
    }
    if (this.items != null) {
      json[r'items'] = this.items;
    } else {
      json[r'items'] = null;
    }
    if (this.error != null) {
      json[r'error'] = this.error;
    } else {
      json[r'error'] = null;
    }
    return json;
  }

  /// Returns a new [ApiResponseOfGetMyFavoritesResponseData] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static ApiResponseOfGetMyFavoritesResponseData? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "ApiResponseOfGetMyFavoritesResponseData[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "ApiResponseOfGetMyFavoritesResponseData[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return ApiResponseOfGetMyFavoritesResponseData(
        success: mapValueOfType<bool>(json, r'success'),
        items: FavoriteItemDto.listFromJson(json[r'items']),
        error: mapValueOfType<String>(json, r'error'),
      );
    }
    return null;
  }

  static List<ApiResponseOfGetMyFavoritesResponseData> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ApiResponseOfGetMyFavoritesResponseData>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ApiResponseOfGetMyFavoritesResponseData.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, ApiResponseOfGetMyFavoritesResponseData> mapFromJson(dynamic json) {
    final map = <String, ApiResponseOfGetMyFavoritesResponseData>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = ApiResponseOfGetMyFavoritesResponseData.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of ApiResponseOfGetMyFavoritesResponseData-objects as value to a dart map
  static Map<String, List<ApiResponseOfGetMyFavoritesResponseData>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<ApiResponseOfGetMyFavoritesResponseData>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = ApiResponseOfGetMyFavoritesResponseData.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
  };
}

