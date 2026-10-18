//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class PersonInfoDto {
  /// Returns a new [PersonInfoDto] instance.
  PersonInfoDto({
    this.fullName,
    this.phone,
    this.profilePicture,
  });

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? fullName;

  String? phone;

  String? profilePicture;

  @override
  bool operator ==(Object other) => identical(this, other) || other is PersonInfoDto &&
    other.fullName == fullName &&
    other.phone == phone &&
    other.profilePicture == profilePicture;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (fullName == null ? 0 : fullName!.hashCode) +
    (phone == null ? 0 : phone!.hashCode) +
    (profilePicture == null ? 0 : profilePicture!.hashCode);

  @override
  String toString() => 'PersonInfoDto[fullName=$fullName, phone=$phone, profilePicture=$profilePicture]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.fullName != null) {
      json[r'fullName'] = this.fullName;
    } else {
      json[r'fullName'] = null;
    }
    if (this.phone != null) {
      json[r'phone'] = this.phone;
    } else {
      json[r'phone'] = null;
    }
    if (this.profilePicture != null) {
      json[r'profilePicture'] = this.profilePicture;
    } else {
      json[r'profilePicture'] = null;
    }
    return json;
  }

  /// Returns a new [PersonInfoDto] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static PersonInfoDto? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "PersonInfoDto[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "PersonInfoDto[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return PersonInfoDto(
        fullName: mapValueOfType<String>(json, r'fullName'),
        phone: mapValueOfType<String>(json, r'phone'),
        profilePicture: mapValueOfType<String>(json, r'profilePicture'),
      );
    }
    return null;
  }

  static List<PersonInfoDto> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <PersonInfoDto>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = PersonInfoDto.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, PersonInfoDto> mapFromJson(dynamic json) {
    final map = <String, PersonInfoDto>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = PersonInfoDto.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of PersonInfoDto-objects as value to a dart map
  static Map<String, List<PersonInfoDto>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<PersonInfoDto>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = PersonInfoDto.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
  };
}

