//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class AuthMeData {
  /// Returns a new [AuthMeData] instance.
  AuthMeData({
    this.id,
    this.firstName,
    this.lastName,
    this.email,
    this.phone,
    this.city,
    this.role,
    this.profileImageUrl,
    this.isVerified,
    this.createdAt,
  });

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  int? id;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? firstName;

  String? lastName;

  String? email;

  String? phone;

  String? city;

  String? role;

  String? profileImageUrl;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  bool? isVerified;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  DateTime? createdAt;

  @override
  bool operator ==(Object other) => identical(this, other) || other is AuthMeData &&
    other.id == id &&
    other.firstName == firstName &&
    other.lastName == lastName &&
    other.email == email &&
    other.phone == phone &&
    other.city == city &&
    other.role == role &&
    other.profileImageUrl == profileImageUrl &&
    other.isVerified == isVerified &&
    other.createdAt == createdAt;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id == null ? 0 : id!.hashCode) +
    (firstName == null ? 0 : firstName!.hashCode) +
    (lastName == null ? 0 : lastName!.hashCode) +
    (email == null ? 0 : email!.hashCode) +
    (phone == null ? 0 : phone!.hashCode) +
    (city == null ? 0 : city!.hashCode) +
    (role == null ? 0 : role!.hashCode) +
    (profileImageUrl == null ? 0 : profileImageUrl!.hashCode) +
    (isVerified == null ? 0 : isVerified!.hashCode) +
    (createdAt == null ? 0 : createdAt!.hashCode);

  @override
  String toString() => 'AuthMeData[id=$id, firstName=$firstName, lastName=$lastName, email=$email, phone=$phone, city=$city, role=$role, profileImageUrl=$profileImageUrl, isVerified=$isVerified, createdAt=$createdAt]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.id != null) {
      json[r'id'] = this.id;
    } else {
      json[r'id'] = null;
    }
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
    if (this.email != null) {
      json[r'email'] = this.email;
    } else {
      json[r'email'] = null;
    }
    if (this.phone != null) {
      json[r'phone'] = this.phone;
    } else {
      json[r'phone'] = null;
    }
    if (this.city != null) {
      json[r'city'] = this.city;
    } else {
      json[r'city'] = null;
    }
    if (this.role != null) {
      json[r'role'] = this.role;
    } else {
      json[r'role'] = null;
    }
    if (this.profileImageUrl != null) {
      json[r'profileImageUrl'] = this.profileImageUrl;
    } else {
      json[r'profileImageUrl'] = null;
    }
    if (this.isVerified != null) {
      json[r'isVerified'] = this.isVerified;
    } else {
      json[r'isVerified'] = null;
    }
    if (this.createdAt != null) {
      json[r'createdAt'] = this.createdAt!.toUtc().toIso8601String();
    } else {
      json[r'createdAt'] = null;
    }
    return json;
  }

  /// Returns a new [AuthMeData] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static AuthMeData? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "AuthMeData[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "AuthMeData[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return AuthMeData(
        id: mapValueOfType<int>(json, r'id'),
        firstName: mapValueOfType<String>(json, r'firstName'),
        lastName: mapValueOfType<String>(json, r'lastName'),
        email: mapValueOfType<String>(json, r'email'),
        phone: mapValueOfType<String>(json, r'phone'),
        city: mapValueOfType<String>(json, r'city'),
        role: mapValueOfType<String>(json, r'role'),
        profileImageUrl: mapValueOfType<String>(json, r'profileImageUrl'),
        isVerified: mapValueOfType<bool>(json, r'isVerified'),
        createdAt: mapDateTime(json, r'createdAt', r''),
      );
    }
    return null;
  }

  static List<AuthMeData> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <AuthMeData>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = AuthMeData.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, AuthMeData> mapFromJson(dynamic json) {
    final map = <String, AuthMeData>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = AuthMeData.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of AuthMeData-objects as value to a dart map
  static Map<String, List<AuthMeData>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<AuthMeData>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = AuthMeData.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
  };
}

