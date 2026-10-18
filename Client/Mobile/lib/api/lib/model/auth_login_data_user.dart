//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class AuthLoginDataUser {
  /// Returns a new [AuthLoginDataUser] instance.
  AuthLoginDataUser({
    this.id,
    this.firstName,
    this.lastName,
    this.email,
    this.role,
    this.profileImageUrl,
    this.permissions = const [],
    this.idVerificationStatus,
    this.idVerified,
    this.isVerified,
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

  String? role;

  String? profileImageUrl;

  List<String>? permissions;

  String? idVerificationStatus;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  bool? idVerified;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  bool? isVerified;

  @override
  bool operator ==(Object other) => identical(this, other) || other is AuthLoginDataUser &&
    other.id == id &&
    other.firstName == firstName &&
    other.lastName == lastName &&
    other.email == email &&
    other.role == role &&
    other.profileImageUrl == profileImageUrl &&
    _deepEquality.equals(other.permissions, permissions) &&
    other.idVerificationStatus == idVerificationStatus &&
    other.idVerified == idVerified &&
    other.isVerified == isVerified;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id == null ? 0 : id!.hashCode) +
    (firstName == null ? 0 : firstName!.hashCode) +
    (lastName == null ? 0 : lastName!.hashCode) +
    (email == null ? 0 : email!.hashCode) +
    (role == null ? 0 : role!.hashCode) +
    (profileImageUrl == null ? 0 : profileImageUrl!.hashCode) +
    (permissions == null ? 0 : permissions!.hashCode) +
    (idVerificationStatus == null ? 0 : idVerificationStatus!.hashCode) +
    (idVerified == null ? 0 : idVerified!.hashCode) +
    (isVerified == null ? 0 : isVerified!.hashCode);

  @override
  String toString() => 'AuthLoginDataUser[id=$id, firstName=$firstName, lastName=$lastName, email=$email, role=$role, profileImageUrl=$profileImageUrl, permissions=$permissions, idVerificationStatus=$idVerificationStatus, idVerified=$idVerified, isVerified=$isVerified]';

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
    if (this.permissions != null) {
      json[r'permissions'] = this.permissions;
    } else {
      json[r'permissions'] = null;
    }
    if (this.idVerificationStatus != null) {
      json[r'idVerificationStatus'] = this.idVerificationStatus;
    } else {
      json[r'idVerificationStatus'] = null;
    }
    if (this.idVerified != null) {
      json[r'idVerified'] = this.idVerified;
    } else {
      json[r'idVerified'] = null;
    }
    if (this.isVerified != null) {
      json[r'isVerified'] = this.isVerified;
    } else {
      json[r'isVerified'] = null;
    }
    return json;
  }

  /// Returns a new [AuthLoginDataUser] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static AuthLoginDataUser? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "AuthLoginDataUser[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "AuthLoginDataUser[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return AuthLoginDataUser(
        id: mapValueOfType<int>(json, r'id'),
        firstName: mapValueOfType<String>(json, r'firstName'),
        lastName: mapValueOfType<String>(json, r'lastName'),
        email: mapValueOfType<String>(json, r'email'),
        role: mapValueOfType<String>(json, r'role'),
        profileImageUrl: mapValueOfType<String>(json, r'profileImageUrl'),
        permissions: json[r'permissions'] is Iterable
            ? (json[r'permissions'] as Iterable).cast<String>().toList(growable: false)
            : const [],
        idVerificationStatus: mapValueOfType<String>(json, r'idVerificationStatus'),
        idVerified: mapValueOfType<bool>(json, r'idVerified'),
        isVerified: mapValueOfType<bool>(json, r'isVerified'),
      );
    }
    return null;
  }

  static List<AuthLoginDataUser> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <AuthLoginDataUser>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = AuthLoginDataUser.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, AuthLoginDataUser> mapFromJson(dynamic json) {
    final map = <String, AuthLoginDataUser>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = AuthLoginDataUser.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of AuthLoginDataUser-objects as value to a dart map
  static Map<String, List<AuthLoginDataUser>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<AuthLoginDataUser>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = AuthLoginDataUser.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
  };
}

