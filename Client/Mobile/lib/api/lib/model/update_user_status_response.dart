//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class UpdateUserStatusResponse {
  /// Returns a new [UpdateUserStatusResponse] instance.
  UpdateUserStatusResponse({
    this.success,
    this.error,
    this.userId,
    this.isActive,
  });

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  bool? success;

  String? error;

  int? userId;

  bool? isActive;

  @override
  bool operator ==(Object other) => identical(this, other) || other is UpdateUserStatusResponse &&
    other.success == success &&
    other.error == error &&
    other.userId == userId &&
    other.isActive == isActive;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (success == null ? 0 : success!.hashCode) +
    (error == null ? 0 : error!.hashCode) +
    (userId == null ? 0 : userId!.hashCode) +
    (isActive == null ? 0 : isActive!.hashCode);

  @override
  String toString() => 'UpdateUserStatusResponse[success=$success, error=$error, userId=$userId, isActive=$isActive]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.success != null) {
      json[r'success'] = this.success;
    } else {
      json[r'success'] = null;
    }
    if (this.error != null) {
      json[r'error'] = this.error;
    } else {
      json[r'error'] = null;
    }
    if (this.userId != null) {
      json[r'userId'] = this.userId;
    } else {
      json[r'userId'] = null;
    }
    if (this.isActive != null) {
      json[r'isActive'] = this.isActive;
    } else {
      json[r'isActive'] = null;
    }
    return json;
  }

  /// Returns a new [UpdateUserStatusResponse] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static UpdateUserStatusResponse? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "UpdateUserStatusResponse[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "UpdateUserStatusResponse[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return UpdateUserStatusResponse(
        success: mapValueOfType<bool>(json, r'success'),
        error: mapValueOfType<String>(json, r'error'),
        userId: mapValueOfType<int>(json, r'userId'),
        isActive: mapValueOfType<bool>(json, r'isActive'),
      );
    }
    return null;
  }

  static List<UpdateUserStatusResponse> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <UpdateUserStatusResponse>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = UpdateUserStatusResponse.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, UpdateUserStatusResponse> mapFromJson(dynamic json) {
    final map = <String, UpdateUserStatusResponse>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = UpdateUserStatusResponse.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of UpdateUserStatusResponse-objects as value to a dart map
  static Map<String, List<UpdateUserStatusResponse>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<UpdateUserStatusResponse>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = UpdateUserStatusResponse.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
  };
}

