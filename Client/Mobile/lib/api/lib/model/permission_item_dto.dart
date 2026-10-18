//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class PermissionItemDto {
  /// Returns a new [PermissionItemDto] instance.
  PermissionItemDto({
    this.value,
    this.label,
    this.allowedRoles = const [],
  });

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? value;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? label;

  List<String> allowedRoles;

  @override
  bool operator ==(Object other) => identical(this, other) || other is PermissionItemDto &&
    other.value == value &&
    other.label == label &&
    _deepEquality.equals(other.allowedRoles, allowedRoles);

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (value == null ? 0 : value!.hashCode) +
    (label == null ? 0 : label!.hashCode) +
    (allowedRoles.hashCode);

  @override
  String toString() => 'PermissionItemDto[value=$value, label=$label, allowedRoles=$allowedRoles]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.value != null) {
      json[r'value'] = this.value;
    } else {
      json[r'value'] = null;
    }
    if (this.label != null) {
      json[r'label'] = this.label;
    } else {
      json[r'label'] = null;
    }
      json[r'allowedRoles'] = this.allowedRoles;
    return json;
  }

  /// Returns a new [PermissionItemDto] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static PermissionItemDto? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "PermissionItemDto[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "PermissionItemDto[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return PermissionItemDto(
        value: mapValueOfType<String>(json, r'value'),
        label: mapValueOfType<String>(json, r'label'),
        allowedRoles: json[r'allowedRoles'] is Iterable
            ? (json[r'allowedRoles'] as Iterable).cast<String>().toList(growable: false)
            : const [],
      );
    }
    return null;
  }

  static List<PermissionItemDto> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <PermissionItemDto>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = PermissionItemDto.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, PermissionItemDto> mapFromJson(dynamic json) {
    final map = <String, PermissionItemDto>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = PermissionItemDto.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of PermissionItemDto-objects as value to a dart map
  static Map<String, List<PermissionItemDto>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<PermissionItemDto>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = PermissionItemDto.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
  };
}

