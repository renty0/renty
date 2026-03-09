//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class OwnerDto {
  /// Returns a new [OwnerDto] instance.
  OwnerDto({
    this.firstName,
    this.city,
    this.profileImageUrl,
  });

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? firstName;

  String? city;

  String? profileImageUrl;

  @override
  bool operator ==(Object other) => identical(this, other) || other is OwnerDto &&
    other.firstName == firstName &&
    other.city == city &&
    other.profileImageUrl == profileImageUrl;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (firstName == null ? 0 : firstName!.hashCode) +
    (city == null ? 0 : city!.hashCode) +
    (profileImageUrl == null ? 0 : profileImageUrl!.hashCode);

  @override
  String toString() => 'OwnerDto[firstName=$firstName, city=$city, profileImageUrl=$profileImageUrl]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.firstName != null) {
      json[r'firstName'] = this.firstName;
    } else {
      json[r'firstName'] = null;
    }
    if (this.city != null) {
      json[r'city'] = this.city;
    } else {
      json[r'city'] = null;
    }
    if (this.profileImageUrl != null) {
      json[r'profileImageUrl'] = this.profileImageUrl;
    } else {
      json[r'profileImageUrl'] = null;
    }
    return json;
  }

  /// Returns a new [OwnerDto] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static OwnerDto? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "OwnerDto[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "OwnerDto[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return OwnerDto(
        firstName: mapValueOfType<String>(json, r'firstName'),
        city: mapValueOfType<String>(json, r'city'),
        profileImageUrl: mapValueOfType<String>(json, r'profileImageUrl'),
      );
    }
    return null;
  }

  static List<OwnerDto> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <OwnerDto>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = OwnerDto.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, OwnerDto> mapFromJson(dynamic json) {
    final map = <String, OwnerDto>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = OwnerDto.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of OwnerDto-objects as value to a dart map
  static Map<String, List<OwnerDto>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<OwnerDto>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = OwnerDto.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
  };
}

