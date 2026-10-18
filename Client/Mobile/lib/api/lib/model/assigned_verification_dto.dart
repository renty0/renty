//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class AssignedVerificationDto {
  /// Returns a new [AssignedVerificationDto] instance.
  AssignedVerificationDto({
    this.verificationId,
    this.itemId,
    this.itemTitleAr,
    this.itemTitleEn,
    this.itemImage,
    this.rentalStartDate,
    this.rentalEndDate,
    this.checkType,
    this.createdAt,
  });

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? verificationId;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? itemId;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? itemTitleAr;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? itemTitleEn;

  String? itemImage;

  DateTime? rentalStartDate;

  DateTime? rentalEndDate;

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
  DateTime? createdAt;

  @override
  bool operator ==(Object other) => identical(this, other) || other is AssignedVerificationDto &&
    other.verificationId == verificationId &&
    other.itemId == itemId &&
    other.itemTitleAr == itemTitleAr &&
    other.itemTitleEn == itemTitleEn &&
    other.itemImage == itemImage &&
    other.rentalStartDate == rentalStartDate &&
    other.rentalEndDate == rentalEndDate &&
    other.checkType == checkType &&
    other.createdAt == createdAt;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (verificationId == null ? 0 : verificationId!.hashCode) +
    (itemId == null ? 0 : itemId!.hashCode) +
    (itemTitleAr == null ? 0 : itemTitleAr!.hashCode) +
    (itemTitleEn == null ? 0 : itemTitleEn!.hashCode) +
    (itemImage == null ? 0 : itemImage!.hashCode) +
    (rentalStartDate == null ? 0 : rentalStartDate!.hashCode) +
    (rentalEndDate == null ? 0 : rentalEndDate!.hashCode) +
    (checkType == null ? 0 : checkType!.hashCode) +
    (createdAt == null ? 0 : createdAt!.hashCode);

  @override
  String toString() => 'AssignedVerificationDto[verificationId=$verificationId, itemId=$itemId, itemTitleAr=$itemTitleAr, itemTitleEn=$itemTitleEn, itemImage=$itemImage, rentalStartDate=$rentalStartDate, rentalEndDate=$rentalEndDate, checkType=$checkType, createdAt=$createdAt]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.verificationId != null) {
      json[r'verificationId'] = this.verificationId;
    } else {
      json[r'verificationId'] = null;
    }
    if (this.itemId != null) {
      json[r'itemId'] = this.itemId;
    } else {
      json[r'itemId'] = null;
    }
    if (this.itemTitleAr != null) {
      json[r'itemTitleAr'] = this.itemTitleAr;
    } else {
      json[r'itemTitleAr'] = null;
    }
    if (this.itemTitleEn != null) {
      json[r'itemTitleEn'] = this.itemTitleEn;
    } else {
      json[r'itemTitleEn'] = null;
    }
    if (this.itemImage != null) {
      json[r'itemImage'] = this.itemImage;
    } else {
      json[r'itemImage'] = null;
    }
    if (this.rentalStartDate != null) {
      json[r'rentalStartDate'] = this.rentalStartDate!.toUtc().toIso8601String();
    } else {
      json[r'rentalStartDate'] = null;
    }
    if (this.rentalEndDate != null) {
      json[r'rentalEndDate'] = this.rentalEndDate!.toUtc().toIso8601String();
    } else {
      json[r'rentalEndDate'] = null;
    }
    if (this.checkType != null) {
      json[r'checkType'] = this.checkType;
    } else {
      json[r'checkType'] = null;
    }
    if (this.createdAt != null) {
      json[r'createdAt'] = this.createdAt!.toUtc().toIso8601String();
    } else {
      json[r'createdAt'] = null;
    }
    return json;
  }

  /// Returns a new [AssignedVerificationDto] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static AssignedVerificationDto? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "AssignedVerificationDto[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "AssignedVerificationDto[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return AssignedVerificationDto(
        verificationId: mapValueOfType<String>(json, r'verificationId'),
        itemId: mapValueOfType<String>(json, r'itemId'),
        itemTitleAr: mapValueOfType<String>(json, r'itemTitleAr'),
        itemTitleEn: mapValueOfType<String>(json, r'itemTitleEn'),
        itemImage: mapValueOfType<String>(json, r'itemImage'),
        rentalStartDate: mapDateTime(json, r'rentalStartDate', r''),
        rentalEndDate: mapDateTime(json, r'rentalEndDate', r''),
        checkType: mapValueOfType<String>(json, r'checkType'),
        createdAt: mapDateTime(json, r'createdAt', r''),
      );
    }
    return null;
  }

  static List<AssignedVerificationDto> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <AssignedVerificationDto>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = AssignedVerificationDto.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, AssignedVerificationDto> mapFromJson(dynamic json) {
    final map = <String, AssignedVerificationDto>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = AssignedVerificationDto.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of AssignedVerificationDto-objects as value to a dart map
  static Map<String, List<AssignedVerificationDto>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<AssignedVerificationDto>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = AssignedVerificationDto.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
  };
}

