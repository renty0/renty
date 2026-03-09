//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class UpdateUserCommand {
  /// Returns a new [UpdateUserCommand] instance.
  UpdateUserCommand({
    this.firstName,
    this.lastName,
    this.phoneNumber,
    this.address,
    this.city,
    this.country,
    this.bio,
    this.profilePictureUrl,
  });

  String? firstName;

  String? lastName;

  String? phoneNumber;

  String? address;

  String? city;

  String? country;

  String? bio;

  String? profilePictureUrl;

  @override
  bool operator ==(Object other) => identical(this, other) || other is UpdateUserCommand &&
    other.firstName == firstName &&
    other.lastName == lastName &&
    other.phoneNumber == phoneNumber &&
    other.address == address &&
    other.city == city &&
    other.country == country &&
    other.bio == bio &&
    other.profilePictureUrl == profilePictureUrl;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (firstName == null ? 0 : firstName!.hashCode) +
    (lastName == null ? 0 : lastName!.hashCode) +
    (phoneNumber == null ? 0 : phoneNumber!.hashCode) +
    (address == null ? 0 : address!.hashCode) +
    (city == null ? 0 : city!.hashCode) +
    (country == null ? 0 : country!.hashCode) +
    (bio == null ? 0 : bio!.hashCode) +
    (profilePictureUrl == null ? 0 : profilePictureUrl!.hashCode);

  @override
  String toString() => 'UpdateUserCommand[firstName=$firstName, lastName=$lastName, phoneNumber=$phoneNumber, address=$address, city=$city, country=$country, bio=$bio, profilePictureUrl=$profilePictureUrl]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.firstName != null) {
      json[r'firstName'] = this.firstName;
    } else {
      json[r'firstName'] = null;
    }
    if (this.lastName != null) {
      json[r'lastName'] = this.lastName;
    } else {
      json[r'lastName'] = null;
    }
    if (this.phoneNumber != null) {
      json[r'phoneNumber'] = this.phoneNumber;
    } else {
      json[r'phoneNumber'] = null;
    }
    if (this.address != null) {
      json[r'address'] = this.address;
    } else {
      json[r'address'] = null;
    }
    if (this.city != null) {
      json[r'city'] = this.city;
    } else {
      json[r'city'] = null;
    }
    if (this.country != null) {
      json[r'country'] = this.country;
    } else {
      json[r'country'] = null;
    }
    if (this.bio != null) {
      json[r'bio'] = this.bio;
    } else {
      json[r'bio'] = null;
    }
    if (this.profilePictureUrl != null) {
      json[r'profilePictureUrl'] = this.profilePictureUrl;
    } else {
      json[r'profilePictureUrl'] = null;
    }
    return json;
  }

  /// Returns a new [UpdateUserCommand] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static UpdateUserCommand? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "UpdateUserCommand[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "UpdateUserCommand[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return UpdateUserCommand(
        firstName: mapValueOfType<String>(json, r'firstName'),
        lastName: mapValueOfType<String>(json, r'lastName'),
        phoneNumber: mapValueOfType<String>(json, r'phoneNumber'),
        address: mapValueOfType<String>(json, r'address'),
        city: mapValueOfType<String>(json, r'city'),
        country: mapValueOfType<String>(json, r'country'),
        bio: mapValueOfType<String>(json, r'bio'),
        profilePictureUrl: mapValueOfType<String>(json, r'profilePictureUrl'),
      );
    }
    return null;
  }

  static List<UpdateUserCommand> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <UpdateUserCommand>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = UpdateUserCommand.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, UpdateUserCommand> mapFromJson(dynamic json) {
    final map = <String, UpdateUserCommand>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = UpdateUserCommand.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of UpdateUserCommand-objects as value to a dart map
  static Map<String, List<UpdateUserCommand>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<UpdateUserCommand>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = UpdateUserCommand.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
  };
}

