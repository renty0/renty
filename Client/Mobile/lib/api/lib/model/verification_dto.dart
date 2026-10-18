//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class VerificationDto {
  /// Returns a new [VerificationDto] instance.
  VerificationDto({
    this.id,
    this.checkType,
    this.status,
    this.notes,
    this.expertFirstName,
    this.createdAt,
    this.verificationCode,
  });

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? id;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? checkType;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? status;

  String? notes;

  String? expertFirstName;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  DateTime? createdAt;

  String? verificationCode;

  @override
  bool operator ==(Object other) => identical(this, other) || other is VerificationDto &&
    other.id == id &&
    other.checkType == checkType &&
    other.status == status &&
    other.notes == notes &&
    other.expertFirstName == expertFirstName &&
    other.createdAt == createdAt &&
    other.verificationCode == verificationCode;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id == null ? 0 : id!.hashCode) +
    (checkType == null ? 0 : checkType!.hashCode) +
    (status == null ? 0 : status!.hashCode) +
    (notes == null ? 0 : notes!.hashCode) +
    (expertFirstName == null ? 0 : expertFirstName!.hashCode) +
    (createdAt == null ? 0 : createdAt!.hashCode) +
    (verificationCode == null ? 0 : verificationCode!.hashCode);

  @override
  String toString() => 'VerificationDto[id=$id, checkType=$checkType, status=$status, notes=$notes, expertFirstName=$expertFirstName, createdAt=$createdAt, verificationCode=$verificationCode]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.id != null) {
      json[r'id'] = this.id;
    } else {
      json[r'id'] = null;
    }
    if (this.checkType != null) {
      json[r'checkType'] = this.checkType;
    } else {
      json[r'checkType'] = null;
    }
    if (this.status != null) {
      json[r'status'] = this.status;
    } else {
      json[r'status'] = null;
    }
    if (this.notes != null) {
      json[r'notes'] = this.notes;
    } else {
      json[r'notes'] = null;
    }
    if (this.expertFirstName != null) {
      json[r'expertFirstName'] = this.expertFirstName;
    } else {
      json[r'expertFirstName'] = null;
    }
    if (this.createdAt != null) {
      json[r'createdAt'] = this.createdAt!.toUtc().toIso8601String();
    } else {
      json[r'createdAt'] = null;
    }
    if (this.verificationCode != null) {
      json[r'verificationCode'] = this.verificationCode;
    } else {
      json[r'verificationCode'] = null;
    }
    return json;
  }

  /// Returns a new [VerificationDto] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static VerificationDto? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "VerificationDto[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "VerificationDto[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return VerificationDto(
        id: mapValueOfType<String>(json, r'id'),
        checkType: mapValueOfType<String>(json, r'checkType'),
        status: mapValueOfType<String>(json, r'status'),
        notes: mapValueOfType<String>(json, r'notes'),
        expertFirstName: mapValueOfType<String>(json, r'expertFirstName'),
        createdAt: mapDateTime(json, r'createdAt', r''),
        verificationCode: mapValueOfType<String>(json, r'verificationCode'),
      );
    }
    return null;
  }

  static List<VerificationDto> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <VerificationDto>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = VerificationDto.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, VerificationDto> mapFromJson(dynamic json) {
    final map = <String, VerificationDto>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = VerificationDto.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of VerificationDto-objects as value to a dart map
  static Map<String, List<VerificationDto>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<VerificationDto>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = VerificationDto.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
  };
}

